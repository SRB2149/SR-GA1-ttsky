<#
.SYNOPSIS
    Splices a centered grid of CLB macro instances into a Tiny Tapeout config.json.

.DESCRIPTION
    The Tiny Tapeout config.json uses repeated "//" keys as comments. That is not
    valid JSON for most parsers, so this script does NOT parse and rewrite the
    file. It reads the macro SIZE from the LEF, computes centered placements, and
    splices a MACROS block into the config as text, between marker comments.
    Everything else in the file is preserved byte for byte.

    Re-running replaces the previously generated block rather than appending a
    second one.

    Runs on Windows PowerShell 5.1+ and PowerShell Core (pwsh), which is
    preinstalled on GitHub Actions ubuntu-latest and windows-latest runners.

.EXAMPLE
    ./Generate-Grid.ps1 -Rows 3 -Cols 8 -DieArea "0 0 334.88 225.76"

.EXAMPLE
    ./Generate-Grid.ps1 -Rows 3 -Cols 8 -DieArea "0 0 334.88 225.76" -DryRun
#>

[CmdletBinding()]
param(
    # Grid dimensions
    [int]$Rows = 4,
    [int]$Cols = 7,

    # Extra spacing between cells, in um. 0 = macros abut directly.
    [double]$RowGap = 0,
    [double]$ColGap = 0,

    # Die area "x1 y1 x2 y2". Tiny Tapeout sets FP_SIZING to absolute but injects
    # DIE_AREA from the tile size at build time, so it is usually NOT in the
    # checked-in config. Override if your tile count differs.
    [string]$DieArea = "0 0 334 216",

    # Manual offset applied AFTER centering, in um. Positive X moves the array
    # right, positive Y moves it up. Negative Y moves it down. Values are
    # snapped to the site grid (0.46 um horizontally, 2.72 um vertically), so
    # -2.72 shifts the array down by exactly one standard-cell row.
    [double]$OffsetX = 0,
    [double]$OffsetY = -5.44,

    # Paths, relative to the repo root (or absolute)
    [string]$ConfigPath  = "config.json",
    [string]$MacroLef    = "clb_macro/CLB.lef",
    [string]$MacroGds    = "clb_macro/CLB.gds",
    [string]$MacroNl     = "clb_macro/CLB.nl.v",
    [string]$MacroLibDir = "clb_macro/lib",

    [string]$MacroName      = "CLB",
    [string]$InstancePrefix = "row",

    # The instance name of the macro inside the innermost generate block, i.e.
    # the identifier in "CLB <name> (" in your RTL.
    [string]$InstanceName = "clb_u",

    # Prepended to every generated instance path. Needed because the grid module
    # is instantiated inside the tt_um_* wrapper rather than being the top
    # module. Include the trailing dot. Set to "" if synthesis flattens the
    # hierarchy and the prefix does not appear in the netlist.
    [string]$HierarchyPrefix = "sr_ga1_u.clb_grid_u.",

    # Prefix applied to the macro paths WRITTEN INTO config.json. The paths in
    # the config are resolved relative to the config file's own directory
    # (src/), while this script is run from the repo root, so the two differ.
    # Filesystem checks below use the unprefixed paths.
    [string]$ConfigPathPrefix = "src/",

    # Instance naming: "generate" produces row[R].col[C].<InstanceName> to match
    # SystemVerilog generate blocks. "flat" produces <InstanceName>_R_C.
    [ValidateSet("generate", "flat")]
    [string]$NameStyle = "generate",

    # Report what would be placed without modifying config.json.
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$BeginMarker = '  "//": "BEGIN GENERATED MACROS - managed by Generate-Grid.ps1, do not edit by hand",'
$EndMarker   = '  "//": "END GENERATED MACROS"'

function Assert-Path {
    param([string]$Path, [string]$What)
    if (-not (Test-Path $Path)) { throw "$What not found: $Path" }
}

function ConvertTo-ConfigPath {
    # Normalize separators and apply the prefix used inside config.json.
    param([string]$Path)
    $p = $Path -replace '\\', '/'
    if ([string]::IsNullOrEmpty($ConfigPathPrefix)) { return $p }
    $prefix = $ConfigPathPrefix -replace '\\', '/'
    if (-not $prefix.EndsWith("/")) { $prefix += "/" }
    # Don't double up if the caller already passed a prefixed path.
    if ($p.StartsWith($prefix)) { return $p }
    return "$prefix$p"
}

Assert-Path $ConfigPath  "config.json"
Assert-Path $MacroLef    "Macro LEF"
Assert-Path $MacroGds    "Macro GDS"
Assert-Path $MacroLibDir "Macro lib directory"

# --- Parse macro SIZE from the LEF -----------------------------------------

$inMacro = $false
$macroW = 0.0
$macroH = 0.0

foreach ($line in (Get-Content $MacroLef)) {
    if ($line -match "^\s*MACRO\s+$([regex]::Escape($MacroName))\s*$") { $inMacro = $true; continue }
    if ($inMacro -and $line -match "^\s*SIZE\s+([\d.]+)\s+BY\s+([\d.]+)\s*;") {
        $macroW = [double]$Matches[1]
        $macroH = [double]$Matches[2]
        break
    }
}

if ($macroW -le 0 -or $macroH -le 0) {
    throw "Could not parse 'SIZE <w> BY <h>' for MACRO $MacroName from $MacroLef"
}

Write-Host "Macro $MacroName size: $macroW x $macroH um"

# --- Die area and centering -------------------------------------------------

$dieParts = $DieArea -split '\s+' | Where-Object { $_ -ne "" }
if ($dieParts.Count -ne 4) { throw "DIE_AREA must be 'x1 y1 x2 y2', got: '$DieArea'" }

$dieX1 = [double]$dieParts[0]; $dieY1 = [double]$dieParts[1]
$dieX2 = [double]$dieParts[2]; $dieY2 = [double]$dieParts[3]
$dieW  = $dieX2 - $dieX1
$dieH  = $dieY2 - $dieY1

$pitchX = $macroW + $ColGap
$pitchY = $macroH + $RowGap
$gridW  = ($Cols * $pitchX) - $ColGap
$gridH  = ($Rows * $pitchY) - $RowGap

Write-Host "Die area:       $dieW x $dieH um"
Write-Host "Grid footprint: $gridW x $gridH um  ($Rows rows x $Cols cols)"

if ($gridW -gt $dieW -or $gridH -gt $dieH) {
    throw "Grid ($gridW x $gridH um) does not fit the die ($dieW x $dieH um). Reduce -Rows/-Cols, shrink the macro, or use more tiles."
}

# Snap the array origin to the sky130 placement site grid (0.46 x 2.72 um).
$siteW = 0.46
$siteH = 2.72

$centeredX = [math]::Round((($dieX1 + ($dieW - $gridW) / 2.0) / $siteW)) * $siteW
$centeredY = [math]::Round((($dieY1 + ($dieH - $gridH) / 2.0) / $siteH)) * $siteH

# Apply the manual offset, snapped to the site grid so macros stay on legal
# placement coordinates.
$originX = $centeredX + ([math]::Round($OffsetX / $siteW) * $siteW)
$originY = $centeredY + ([math]::Round($OffsetY / $siteH) * $siteH)

Write-Host ("Centered at:    {0:N3}, {1:N3} um" -f $centeredX, $centeredY)
if ($OffsetX -ne 0 -or $OffsetY -ne 0) {
    Write-Host ("Offset applied: {0:N3}, {1:N3} um ({2} site cols, {3} cell rows)" -f `
        ([math]::Round($OffsetX / $siteW) * $siteW), `
        ([math]::Round($OffsetY / $siteH) * $siteH), `
        [math]::Round($OffsetX / $siteW), `
        [math]::Round($OffsetY / $siteH))
}
Write-Host ("Array origin:   {0:N3}, {1:N3} um" -f $originX, $originY)
Write-Host ("Free margin:    {0:N2} um each side horizontally, {1:N2} um vertically (before offset)" -f (($dieW - $gridW) / 2), (($dieH - $gridH) / 2))

# Warn if the offset pushes the array outside the die.
$rightEdge = $originX + $gridW
$topEdge   = $originY + $gridH
if ($originX -lt $dieX1 -or $originY -lt $dieY1 -or $rightEdge -gt $dieX2 -or $topEdge -gt $dieY2) {
    Write-Warning ("Offset pushes the array outside the die: occupies {0:N2},{1:N2} to {2:N2},{3:N2} but the die is {4},{5} to {6},{7}." -f `
        $originX, $originY, $rightEdge, $topEdge, $dieX1, $dieY1, $dieX2, $dieY2)
}

# --- Discover timing corners ------------------------------------------------

$libDict = [ordered]@{}
$cornerDirs = @(Get-ChildItem -Path $MacroLibDir -Directory -ErrorAction SilentlyContinue)

if ($cornerDirs.Count -gt 0) {
    foreach ($dir in $cornerDirs) {
        $libFile = Get-ChildItem -Path $dir.FullName -Filter "*.lib" -File |
                   Where-Object { $_.Name -notlike "*Zone.Identifier*" } | Select-Object -First 1
        if ($libFile) {
            $libDict[$dir.Name] = @((ConvertTo-ConfigPath "$MacroLibDir/$($dir.Name)/$($libFile.Name)"))
            Write-Verbose "  corner $($dir.Name) -> $($libFile.Name)"
        }
    }
} else {
    foreach ($libFile in (Get-ChildItem -Path $MacroLibDir -Filter "*.lib" -File |
                          Where-Object { $_.Name -notlike "*Zone.Identifier*" })) {
        if ($libFile.BaseName -match "__(.+)$") {
            $libDict[$Matches[1]] = @((ConvertTo-ConfigPath "$MacroLibDir/$($libFile.Name)"))
            Write-Verbose "  corner $($Matches[1]) -> $($libFile.Name)"
        }
    }
}

if ($libDict.Count -eq 0) {
    throw "No .lib files under $MacroLibDir. Expected <corner>/ subfolders, or files named ${MacroName}__<corner>.lib"
}
Write-Host "Timing corners: $($libDict.Count)"

# --- Build the MACROS object ------------------------------------------------

$instances = [ordered]@{}
for ($r = 0; $r -lt $Rows; $r++) {
    for ($c = 0; $c -lt $Cols; $c++) {
        $name = if ($NameStyle -eq "generate") {
            "$HierarchyPrefix$InstancePrefix[$r].col[$c].$InstanceName"
        } else {
            "$HierarchyPrefix${InstanceName}_${r}_${c}"
        }
        $instances[$name] = [ordered]@{
            location    = @([math]::Round($originX + ($c * $pitchX), 3),
                            [math]::Round($originY + ($r * $pitchY), 3))
            orientation = "N"
        }
    }
}

$macroEntry = [ordered]@{
    gds = @((ConvertTo-ConfigPath $MacroGds))
    lef = @((ConvertTo-ConfigPath $MacroLef))
    lib = $libDict
}
if (Test-Path $MacroNl) {
    $macroEntry.nl = @((ConvertTo-ConfigPath $MacroNl))
} else {
    Write-Warning "Macro netlist not found at $MacroNl - omitting 'nl'."
}
$macroEntry.instances = $instances

# Serialize only this object. It is a fresh hashtable with no duplicate keys,
# so ConvertTo-Json is safe here even though it is not safe on the whole config.
$macrosJson = ([ordered]@{ MACROS = [ordered]@{ $MacroName = $macroEntry } } |
               ConvertTo-Json -Depth 12)

# Strip the outer braces so the body can sit inside the existing config object.
$macrosJson = $macrosJson.Trim()
$macrosJson = $macrosJson.Substring(1, $macrosJson.Length - 2)
$macrosBody = (($macrosJson -split "`n") |
               Where-Object { $_.Trim() -ne "" } |
               ForEach-Object { $_.TrimEnd() }) -join "`n"

# The end marker is a JSON entry in its own right, so the MACROS entry that
# precedes it needs a trailing comma.
$macrosBody = $macrosBody + ","

if ($DryRun) {
    Write-Host ""
    Write-Host "--- DRY RUN: config.json not modified ---"
    Write-Host $macrosBody
    return
}

# --- Splice into the config as text ----------------------------------------

$raw = Get-Content $ConfigPath -Raw
Copy-Item $ConfigPath "$ConfigPath.bak" -Force

# Strip a UTF-8 BOM if one is present (e.g. written by an older version of this
# script). Tiny Tapeout's tooling reads the config with plain utf-8 and fails on
# a BOM with "Unexpected UTF-8 BOM".
if ($raw.Length -gt 0 -and [int]$raw[0] -eq 0xFEFF) {
    Write-Verbose "Stripping existing UTF-8 BOM."
    $raw = $raw.Substring(1)
}

# Remove a previously generated block so re-runs are idempotent.
$pattern = [regex]::Escape($BeginMarker) + "(?s).*?" + [regex]::Escape($EndMarker) + "\r?\n?"
if ($raw -match $pattern) {
    Write-Verbose "Replacing existing generated block."
    $raw = [regex]::Replace($raw, $pattern, "")
}

$block = "$BeginMarker`n$macrosBody`n$EndMarker"

# Insert immediately before the final closing brace of the top-level object.
$lastBrace = $raw.LastIndexOf("}")
if ($lastBrace -lt 0) { throw "Could not find the closing brace of $ConfigPath" }

$head = $raw.Substring(0, $lastBrace).TrimEnd()
$tail = $raw.Substring($lastBrace)

# The preceding entry needs a trailing comma before the inserted block.
if (-not $head.EndsWith(",")) { $head += "," }

$configFullPath = (Resolve-Path $ConfigPath).Path
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($configFullPath, "$head`n$block`n$tail", $utf8NoBom)

Write-Host ""
Write-Host "Spliced $($instances.Count) instances into $ConfigPath (backup: $ConfigPath.bak)"
Write-Host "First: $(@($instances.Keys)[0])"
Write-Host "Last:  $(@($instances.Keys)[-1])"
Write-Host "Original config contents preserved; generated block sits between the marker comments."