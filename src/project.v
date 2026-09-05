/*
 * Copyright (c) 2024 Stanley Booth
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_sr_ga1_srb2149 (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // List all unused inputs to prevent warnings
    wire _unused = &{ena, 1'b0};
    
    logic [1:0] ddio_dir;

    SR_GA1 (
        // Programming interface
        .shift_clk(clk),
        shift_data_in(ui_in[0]),
        shift_data_out(uo_out[0]), //DFT

        // Global synchronous reset (positive trigger)
        .reset(!rst_n),

        // Chip IO
        .inputs({uio_in[2:0], ui_in[7:1]}),
        .outputs({uio_out[5:3], uo_out[7:1]}),

        // Chip Dual-Direction IO
        .ddio_in(uio_in[7:6]),
        .ddio_dir(ddio_dir),
        .ddio_out(uio_out[7:6])
    );
    
    always_comb
    begin : IO_Dirs
        uio_oe = {ddio_dir, 3b111, 3b000};
        uio_out[2:0] = 0;
    end

endmodule
