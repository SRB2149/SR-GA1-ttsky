# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer
from cocotb.types import LogicArray

import random

#CONSTANTS
SCAN_PATH_LENGTH = 889 #25*32 + 3 * 8     + 64 + 1
VERBOSE = False        #CLBs  + Clk Banks + IO controller + Start bit

ROWS = 4
COLUMNS = 8

FABRIC_CLK_INPUT = 4   # Chip input used as the fabric clock in the register tests

# LUT index is {a, b, c}
LUT_PASS_A = 0xF0
LUT_PASS_C = 0xAA
LUT_XOR_AB = 0x3C
LUT_XOR3   = 0x96
LUT_MAJ3   = 0xE8

def rand_seq(length):
    seq = [1]
    for i in range(length):
        seq.append(random.randint(0,1))
    return seq

def const_seq(length, val):
    seq = [1]
    for i in range(length):
        seq.append(val)
    return seq

def bit(val, i):
    return (val >> i) & 1

def to_bits(val, width):
    return [bit(val, i) for i in range(width)]

# Defaults give a CLB which passes the horizontal bus straight through
def clb_config(a_sel=0, b_sel=0, c_sel=0, lut=0x00, horz_sel=0b11, vert_sel=0b0000, h2_sel=3, h3_sel=3, reset_val=0):
    return {
        "a_sel": a_sel,
        "b_sel": b_sel,
        "c_sel": c_sel,
        "lut": lut,
        "horz_sel": horz_sel,
        "vert_sel": vert_sel,
        "h2_sel": h2_sel,
        "h3_sel": h3_sel,
        "reset_val": reset_val
    }

def new_config():
    return {
        "clbs": [[clb_config() for c in range(COLUMNS)] for r in range(ROWS)],
        "in_sel": [0] * 8,          # 0a, 0b, 1a, 1b, 2a, 2b, 3a, 3b
        "out_sel": [0] * 4,
        "ddio_out_sel": [0] * 2,
        "ddio_dir_sel": [0] * 2,
        "clk_sel": [0] * COLUMNS    # Bus address 0-3, or 4 to couple to the previous column clock
    }

# Drives the from fabric buses with a constant using the last two CLBs of each row
def fabric_pattern(cfg, pattern, rows=range(ROWS)):
    for r in rows:
        cfg["clbs"][r][COLUMNS-2] = clb_config(lut=0xFF if bit(pattern, 4*r+1) else 0x00, horz_sel=0b00)
        cfg["clbs"][r][COLUMNS-1] = clb_config(lut=0xFF if bit(pattern, 4*r) else 0x00, horz_sel=0b10,
                                               h2_sel=bit(pattern, 4*r+2), h3_sel=bit(pattern, 4*r+3))

def build_bitstream(cfg):
    chain = []

    # CLBs in raster order
    for r in range(ROWS):
        for c in range(COLUMNS):
            clb = cfg["clbs"][r][c]
            chain += to_bits(clb["a_sel"], 1)
            chain += to_bits(clb["b_sel"], 1)
            chain += to_bits(clb["c_sel"], 2)
            chain += to_bits(clb["lut"], 8)
            chain += to_bits(clb["horz_sel"], 2)
            chain += to_bits(clb["vert_sel"], 4)
            chain += to_bits(clb["h2_sel"], 3)
            chain += to_bits(clb["h3_sel"], 3)
            chain += to_bits(clb["reset_val"], 1)

    # IO controller
    for sel in cfg["in_sel"] + cfg["out_sel"] + cfg["ddio_out_sel"] + cfg["ddio_dir_sel"]:
        chain += to_bits(sel, 4)

    # Clock bank
    for sel in cfg["clk_sel"]:
        chain += to_bits(sel, 3)

    # First bit in ends up at the end of the chain so send it reversed after the start bit
    seq = [1] + chain[::-1]
    assert len(seq) == SCAN_PATH_LENGTH
    return seq

async def scan_in(dut, seq):
    for i in range(SCAN_PATH_LENGTH):
        if VERBOSE:
            dut._log.info(f"Loading bit[{i}] with value {seq[i]}")
        val = LogicArray(dut.ui_in.value)
        val[0] = seq[i]
        dut.ui_in.value = val
        await ClockCycles(dut.clk, 1)

# Full programming sequence. The clock is stopped afterwards since it is also the shift clock
async def program(dut, cfg):
    clock = Clock(dut.clk, 1, unit="us")
    cocotb.start_soon(clock.start())

    # Assert reset with shift data low
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 1)

    await scan_in(dut, build_bitstream(cfg))

    clock.stop()

    # Deassert reset to unfreeze the fabric
    dut.rst_n.value = 1
    await Timer(1, unit="ns")

# chip_inputs[6:0] -> ui_in[7:1], chip_inputs[9:7] -> uio_in[2:0], ddio_in[1:0] -> uio_in[7:6]
async def set_inputs(dut, chip_inputs, ddio_in=0):
    dut.ui_in.value = (chip_inputs & 0x7F) << 1
    dut.uio_in.value = ((chip_inputs >> 7) & 0x7) | (ddio_in << 6)
    await Timer(1, unit="ns")

async def clock_fabric(dut, chip_inputs):
    await set_inputs(dut, chip_inputs | (1 << FABRIC_CLK_INPUT))
    await set_inputs(dut, chip_inputs)

# chip_outputs[6:0] -> uo_out[7:1], chip_outputs[9:7] -> uio_out[5:3]
def chip_output(dut, i):
    if i < 7:
        return dut.uo_out.value[i+1]
    return dut.uio_out.value[i-4]

def ddio_out(dut, i):
    return dut.uio_out.value[6+i]

def ddio_dir(dut, i):
    return dut.uio_oe.value[6+i]


# Shifts all 1s through the scan path and checks they come out the other end
@cocotb.test()
async def test_scan_path(dut):
    dut._log.info("Start")

    # Set the clock period to 1 us (1 MHz)
    clock = Clock(dut.clk, 1, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0

    dut._log.info("Test scan path")

    # Get random sequence
    seq = const_seq(SCAN_PATH_LENGTH, 1)

    # Scan in 111111111...
    await scan_in(dut, seq)

    dut._log.info(f"Written {SCAN_PATH_LENGTH} bits into the programming shift register")

    # Check the output is correct
    for i in range(SCAN_PATH_LENGTH-1):
        dut._log.info(f"Reading bit: {i}")
        val = LogicArray(dut.ui_in.value)
        val[0] = 0
        dut.ui_in.value = val
        await ClockCycles(dut.clk, 1)
        assert dut.uo_out.value[0] == seq[i+1]

    dut.rst_n.value = 1
    dut._log.info(f"Read {SCAN_PATH_LENGTH} bits out of the programming shift register")

'''
# Shifts a random sequence through the scan path and checks it comes out unchanged
@cocotb.test()
async def test_scan_path_random(dut):
    dut._log.info("Start")

    clock = Clock(dut.clk, 1, unit="us")
    cocotb.start_soon(clock.start())

    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 1)

    seq = rand_seq(SCAN_PATH_LENGTH)
    await scan_in(dut, seq)

    for i in range(SCAN_PATH_LENGTH-1):
        val = LogicArray(dut.ui_in.value)
        val[0] = 0
        dut.ui_in.value = val
        await ClockCycles(dut.clk, 1)
        assert dut.uo_out.value[0] == seq[i+1]

    clock.stop()
    dut.rst_n.value = 1
    dut._log.info("Random sequence read back correctly")


# Outputs held low and DDIO set to input while programming, released when reset deasserted
@cocotb.test()
async def test_freeze(dut):
    dut._log.info("Start")

    # Everything driven high once unfrozen
    cfg = new_config()
    fabric_pattern(cfg, 0xFFFF)
    seq = build_bitstream(cfg)

    clock = Clock(dut.clk, 1, unit="us")
    cocotb.start_soon(clock.start())

    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 1)

    for i in range(SCAN_PATH_LENGTH):
        val = LogicArray(dut.ui_in.value)
        val[0] = seq[i]
        dut.ui_in.value = val
        await ClockCycles(dut.clk, 1)

        # Frozen from the start bit onwards
        if i > 0:
            for k in range(10):
                assert chip_output(dut, k) == 0
            for k in range(2):
                assert ddio_out(dut, k) == 0
                assert ddio_dir(dut, k) == 0

    clock.stop()
    await Timer(1, unit="ns")

    # Still frozen until reset is deasserted
    for k in range(10):
        assert chip_output(dut, k) == 0

    dut.rst_n.value = 1
    await Timer(1, unit="ns")

    for k in range(10):
        assert chip_output(dut, k) == 1
    for k in range(2):
        assert ddio_out(dut, k) == 1
        assert ddio_dir(dut, k) == 1

    # Reset alone doesn't freeze
    dut.rst_n.value = 0
    await Timer(1, unit="ns")
    for k in range(10):
        assert chip_output(dut, k) == 1

    # Reset plus a high shift bit does
    dut.ui_in.value = 1
    dut.clk.value = 0
    await Timer(500, unit="ns")
    dut.clk.value = 1
    await Timer(1, unit="ns")
    for k in range(10):
        assert chip_output(dut, k) == 0
    for k in range(2):
        assert ddio_dir(dut, k) == 0

    dut.ui_in.value = 0
    dut.rst_n.value = 1
    dut._log.info("Freeze works")


# Selects every one of the 16 input mux sources on mux 0a
@cocotb.test()
async def test_io_input_mux(dut):
    dut._log.info("Start")

    for sel in range(16):
        dut._log.info(f"Input mux source {sel}")
        cfg = new_config()

        # Row 3 driven low and used as the DDIO directions so they stay as inputs
        fabric_pattern(cfg, 0x0000, rows=[3])
        cfg["ddio_dir_sel"] = [12, 12]

        # Observe mux 0a on chip output 1, other outputs take fixed chip inputs for loopback.
        # Output 0 is used instead when looping back output 1 to avoid a loop.
        obs = 0 if sel == 13 else 1
        others = [2, 3, 6]
        cfg["in_sel"][0] = sel
        for k in range(4):
            cfg["out_sel"][k] = 0 if k == obs else others.pop(0)

        await program(dut, cfg)

        for n in range(8):
            chip_in = random.getrandbits(10)
            ddio_in = random.getrandbits(2)
            await set_inputs(dut, chip_in, ddio_in)

            if sel < 10:
                expected = bit(chip_in, sel)
            elif sel < 12:
                expected = bit(ddio_in, sel-10)
            else:
                expected = bit(chip_in, cfg["out_sel"][sel-12])
            assert chip_output(dut, obs) == expected

    dut._log.info("All input mux sources work")


# Checks all 8 input mux channels reach their own horizontal bus
@cocotb.test()
async def test_io_input_channels(dut):
    dut._log.info("Start")

    for group in range(2):
        cfg = new_config()
        sources = random.sample(range(10), 4)
        for k in range(4):
            ch = 4*group + k
            cfg["in_sel"][ch] = sources[k]
            cfg["out_sel"][k] = 4*(ch // 2) + (ch % 2)

        await program(dut, cfg)

        for n in range(16):
            chip_in = random.getrandbits(10)
            await set_inputs(dut, chip_in)
            for k in range(4):
                assert chip_output(dut, k) == bit(chip_in, sources[k])

    dut._log.info("All input mux channels work")


# Walks a 1 and a 0 across the from fabric buses through every output mux and the fixed outputs
@cocotb.test()
async def test_io_output_mux(dut):
    dut._log.info("Start")

    for sel in range(16):
        for pattern in [1 << sel, 0xFFFF ^ (1 << sel)]:
            dut._log.info(f"Output mux source {sel}, pattern {pattern:04X}")
            cfg = new_config()
            fabric_pattern(cfg, pattern)
            cfg["out_sel"] = [sel] * 4
            cfg["ddio_out_sel"] = [sel] * 2
            cfg["ddio_dir_sel"] = [sel] * 2

            await program(dut, cfg)

            expected = bit(pattern, sel)
            for k in range(4):
                assert chip_output(dut, k) == expected
            for k in range(2):
                assert ddio_out(dut, k) == expected
                assert ddio_dir(dut, k) == expected

            # Fixed outputs
            for k, bus in enumerate([6, 7, 10, 11, 14, 15]):
                assert chip_output(dut, 4+k) == bit(pattern, bus)

            # Fixed IO directions and unused outputs
            for k in range(6):
                assert dut.uio_oe.value[k] == (1 if k >= 3 else 0)
            for k in range(3):
                assert dut.uio_out.value[k] == 0

    dut._log.info("All output muxes work")


# DDIO direction and output control, and the fabric reading the pin or its own output
@cocotb.test()
async def test_ddio(dut):
    dut._log.info("Start")

    # DDIO 0 dir/out from chip inputs 2/3, DDIO 1 dir/out from chip inputs 8/9
    cfg = new_config()
    cfg["ddio_dir_sel"] = [2, 14]
    cfg["ddio_out_sel"] = [3, 15]

    await program(dut, cfg)

    for n in range(64):
        dir0, out0, in0, dir1, out1, in1 = [bit(n, k) for k in range(6)]
        chip_in = (dir0 << 2) | (out0 << 3) | (dir1 << 8) | (out1 << 9)
        await set_inputs(dut, chip_in, in0 | (in1 << 1))

        assert ddio_dir(dut, 0) == dir0
        assert ddio_out(dut, 0) == out0
        assert ddio_dir(dut, 1) == dir1
        assert ddio_out(dut, 1) == out1

        # Fabric sees the DDIO on fixed outputs 6 and 7
        assert chip_output(dut, 6) == (out0 if dir0 else in0)
        assert chip_output(dut, 7) == (out1 if dir1 else in1)

    dut._log.info("DDIO works")


# Random LUTs on CLB 0:0 with every input mux setting
@cocotb.test()
async def test_clb_lut(dut):
    dut._log.info("Start")

    for a_sel in range(2):
        for b_sel in range(2):
            for c_sel in range(4):
                lut = random.getrandbits(8)
                dut._log.info(f"a_sel {a_sel}, b_sel {b_sel}, c_sel {c_sel}, LUT {lut:02X}")
                cfg = new_config()
                cfg["clbs"][0][0] = clb_config(a_sel=a_sel, b_sel=b_sel, c_sel=c_sel, lut=lut,
                                               horz_sel=0b00, h2_sel=4, h3_sel=4)

                # Top CLB of column 0 puts chip input 4 onto vertical bus 0
                cfg["clbs"][3][0] = clb_config(lut=LUT_PASS_A)
                cfg["in_sel"][0] = 0
                cfg["in_sel"][1] = 1
                cfg["in_sel"][6] = 4
                cfg["out_sel"] = [0, 1, 2, 3]

                await program(dut, cfg)

                for n in range(32):
                    await set_inputs(dut, n)
                    h = [bit(n, k) for k in range(4)]
                    a = h[1] if a_sel else h[0]
                    b = h[2] if b_sel else h[1]
                    c = [h[2], h[3], bit(n, 4), 0][c_sel] # Carry in is 0 on row 0
                    expected = bit(lut, 4*a + 2*b + c)
                    for k in range(4):
                        assert chip_output(dut, k) == expected

    dut._log.info("CLB LUT works")


# A random 2 input LUT in every CLB of the grid in turn
@cocotb.test()
async def test_clb_grid(dut):
    dut._log.info("Start")

    for r in range(ROWS):
        for c in range(COLUMNS):
            lut_ab = random.getrandbits(4)
            lut = 0
            for i in range(8):
                lut |= bit(lut_ab, i >> 1) << i # Ignore c input
            dut._log.info(f"CLB {r}:{c}, LUT {lut:02X}")

            cfg = new_config()
            cfg["clbs"][r][c] = clb_config(lut=lut, horz_sel=0b10)
            cfg["in_sel"][2*r] = 0
            cfg["in_sel"][2*r+1] = 1
            cfg["out_sel"][0] = 4*r
            cfg["out_sel"][1] = 4*r + 1

            await program(dut, cfg)

            for n in range(4):
                await set_inputs(dut, n)
                assert chip_output(dut, 0) == bit(lut_ab, 2*bit(n, 0) + bit(n, 1))
                assert chip_output(dut, 1) == bit(n, 1)

    dut._log.info("All CLBs work")


# 4 bit ripple carry adder up column 0 with carry out from a copy of the carry chain in column 1
@cocotb.test()
async def test_ripple_adder(dut):
    dut._log.info("Start")

    cfg = new_config()
    for r in range(ROWS):
        # Sum on horizontal bus 2, operands passed on to column 1
        cfg["clbs"][r][0] = clb_config(c_sel=3, lut=LUT_XOR3, h2_sel=4)
        cfg["clbs"][r][1] = clb_config(c_sel=3)
    cfg["clbs"][3][1] = clb_config(c_sel=3, lut=LUT_MAJ3, h3_sel=4)

    # a[r] on mux ra, b[r] on mux rb
    cfg["in_sel"] = [0, 1, 4, 5, 6, 7, 8, 9]
    cfg["out_sel"] = [2, 6, 10, 14]

    await program(dut, cfg)

    for a in range(16):
        for b in range(16):
            chip_in = 0
            for r in range(ROWS):
                chip_in |= bit(a, r) << cfg["in_sel"][2*r]
                chip_in |= bit(b, r) << cfg["in_sel"][2*r+1]
            await set_inputs(dut, chip_in)

            total = a + b
            for k in range(4):
                assert chip_output(dut, k) == bit(total, k)
            assert chip_output(dut, 9) == bit(total, 4)

    dut._log.info("Adder works")


# Every minor horizontal and major output mux source on CLB 0:0 except the register (see test_clb_ff)
@cocotb.test()
async def test_clb_output_muxes(dut):
    dut._log.info("Start")

    for sel in range(8):
        dut._log.info(f"Output mux select {sel}")
        cfg = new_config()
        cfg["clbs"][0][0] = clb_config(lut=LUT_XOR_AB, horz_sel=sel % 4, h2_sel=sel, h3_sel=sel)

        # Top CLB of column 0 puts chip input 4 onto vertical bus 2
        cfg["clbs"][3][0] = clb_config(lut=LUT_PASS_A)
        cfg["in_sel"][0] = 0
        cfg["in_sel"][1] = 1
        cfg["in_sel"][6] = 4
        cfg["out_sel"] = [0, 1, 2, 3]

        await program(dut, cfg)

        for n in range(32):
            await set_inputs(dut, n)
            h = [bit(n, k) for k in range(4)]
            v2 = bit(n, 4)
            res = h[0] ^ h[1]
            h2_src = [0, 1, v2, h[2], res, None, None, h[3]]
            h3_src = [0, 1, None, h[3], res, None, v2, h[2]]

            assert chip_output(dut, 0) == (h[0] if bit(sel, 0) else res)
            assert chip_output(dut, 1) == (h[1] if bit(sel, 1) else res)
            if h2_src[sel] is not None:
                assert chip_output(dut, 2) == h2_src[sel]
            if h3_src[sel] is not None:
                assert chip_output(dut, 3) == h3_src[sel]

    dut._log.info("CLB output muxes work")


# Snakes signals up column 0 through the vertical passthroughs and back round to the bottom
@cocotb.test()
async def test_vertical_routing(dut):
    dut._log.info("Start")

    # CLB 0:0 result up lanes 0 -> 2 -> 0 -> 2 and back into its horizontal bus 2 mux
    cfg = new_config()
    cfg["clbs"][0][0] = clb_config(lut=LUT_XOR_AB, h2_sel=2)
    cfg["clbs"][1][0] = clb_config(vert_sel=0b0100)
    cfg["clbs"][2][0] = clb_config(vert_sel=0b0001)
    cfg["clbs"][3][0] = clb_config(vert_sel=0b0100)
    cfg["in_sel"][0] = 0
    cfg["in_sel"][1] = 1
    cfg["out_sel"][2] = 2

    await program(dut, cfg)

    for n in range(4):
        await set_inputs(dut, n)
        assert chip_output(dut, 2) == bit(n, 0) ^ bit(n, 1)

    # CLB 1:0 result (chip input 4) up lanes 0 -> 2 -> 0 and back into the c input of CLB 0:0
    cfg = new_config()
    cfg["clbs"][0][0] = clb_config(c_sel=2, lut=LUT_PASS_C, horz_sel=0b00)
    cfg["clbs"][1][0] = clb_config(lut=LUT_PASS_A)
    cfg["clbs"][2][0] = clb_config(vert_sel=0b0100)
    cfg["clbs"][3][0] = clb_config(vert_sel=0b0001)
    cfg["in_sel"][2] = 4
    cfg["out_sel"][0] = 0

    await program(dut, cfg)

    for n in range(2):
        await set_inputs(dut, n << 4)
        assert chip_output(dut, 0) == n

    dut._log.info("Vertical routing works")


# CLB 0:0 register: enable, synchronous reset to both reset values and the register vertical lanes
@cocotb.test()
async def test_clb_ff(dut):
    dut._log.info("Start")

    for reset_val, h2_sel, h3_sel in [(0, 5, 2), (1, 6, 5)]:
        dut._log.info(f"Reset value {reset_val}")
        cfg = new_config()

        # Register captures chip input 0 when chip input 3 is high
        cfg["clbs"][0][0] = clb_config(lut=LUT_PASS_A, horz_sel=0b00, h2_sel=h2_sel, h3_sel=h3_sel, reset_val=reset_val)

        # Register routed up lanes 1 -> 3 -> 1 -> 3 and back into vertical bus 3 of CLB 0:0
        cfg["clbs"][1][0] = clb_config(vert_sel=0b1000)
        cfg["clbs"][2][0] = clb_config(vert_sel=0b0010)

        # Column 0 clock from chip input 4
        cfg["clbs"][3][0] = clb_config(lut=LUT_PASS_A, vert_sel=0b1000)
        cfg["in_sel"][0] = 0
        cfg["in_sel"][6] = FABRIC_CLK_INPUT
        cfg["out_sel"] = [0, 1, 2, 3]

        await program(dut, cfg)

        # Load the opposite of the reset value
        ff = 1 - reset_val
        chip_in = ff | (1 << 3)
        await set_inputs(dut, chip_in)
        await clock_fabric(dut, chip_in)
        assert chip_output(dut, 2) == ff
        assert chip_output(dut, 3) == ff

        # Reset is synchronous and beats the enable
        dut.rst_n.value = 0
        await Timer(1, unit="ns")
        assert chip_output(dut, 2) == ff
        assert chip_output(dut, 3) == ff

        await clock_fabric(dut, chip_in)
        ff = reset_val
        assert chip_output(dut, 2) == ff
        assert chip_output(dut, 3) == ff

        dut.rst_n.value = 1

        for n in range(32):
            data = random.getrandbits(1)
            enable = random.getrandbits(1)
            pulse = random.getrandbits(1)
            chip_in = data | (enable << 3)
            await set_inputs(dut, chip_in)
            if pulse:
                await clock_fabric(dut, chip_in)
                if enable:
                    ff = data

            assert chip_output(dut, 0) == data
            assert chip_output(dut, 2) == ff
            assert chip_output(dut, 3) == ff

    dut._log.info("CLB register works")


# Every column clock from vertical buses 0 and 2 and coupled to the previous column clock
@cocotb.test()
async def test_clock_bank(dut):
    dut._log.info("Start")

    for col in range(COLUMNS):
        for clk_sel in [0, 2, 4]:
            dut._log.info(f"Column {col}, clock select {clk_sel}")
            cfg = new_config()

            # Register in the bottom CLB captures chip input 0
            cfg["clbs"][0][col] = clb_config(lut=LUT_PASS_A, h2_sel=5)

            # Top CLB of the clocking column puts chip input 4 onto vertical buses 0 and 2
            src = (col - 1) % COLUMNS if clk_sel == 4 else col
            cfg["clbs"][3][src] = clb_config(lut=LUT_PASS_A)
            cfg["clk_sel"][col] = clk_sel
            cfg["in_sel"][0] = 0
            cfg["in_sel"][6] = FABRIC_CLK_INPUT
            cfg["out_sel"][2] = 2

            await program(dut, cfg)

            for data in [0, 1, 0, 1]:
                chip_in = data | (1 << 3)
                await set_inputs(dut, chip_in)
                await clock_fabric(dut, chip_in)
                assert chip_output(dut, 2) == data

            # No change without a clock edge
            await set_inputs(dut, 1 << 3)
            assert chip_output(dut, 2) == 1

    dut._log.info("Clock bank works")
'''