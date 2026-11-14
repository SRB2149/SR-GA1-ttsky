// Clock Loopback Controller
// Index | Function
//   0   | Locks loop to 0
//   1   | Locks loop to 1
//   2   | Clock passthrough
//   3   | Negated clock passthrough (on-chip ring oscillator without using fabric)
//   4   | inputs[0]
//   5   | inputs[1]
//   6   | inputs[2]
//   7   | inputs[3]
//   8   | inputs[4]
//   9   | inputs[5]
//   10  | inputs[6]
//   11  | inputs[7]
//   12  | inputs[8]
//   13  | inputs[9]
//   14  | ddio_inputs[0]
//   15  | ddio_inputs[1]

module Clock_Loopback_Controller (
    // Programming interface
    input   logic       shift_clk,
    input   logic       shift_data_in,
    output  logic       shift_data_out,
    
    // Input sources
    input   logic [9:0] inputs,
    input   logic [1:0] ddio_inputs,
    
    // Clock Connections
    input   logic       clk_in,
    output  logic       clk_out
);
    
    logic [15:0] clk_mux_in;

    // Configuration register block
    logic [3:0] reg_data;
    Shift_Reg_No_Reset #(
        .DEPTH(4)
    ) reg_block_u (
        .shift_clk(shift_clk),
        .data_in(shift_data_in),
        .data(reg_data),
        .data_out(shift_data_out)
    );

    always_comb
    begin : clock_loopback_controller
        clk_mux_in = {
            ddio_inputs,
            inputs,
            ~clk_in,
            clk_in,
            1'b1,
            1'b0
        };
        
        clk_out = clk_mux_in[reg_data];
    end

endmodule