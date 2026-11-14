module Clock_Bank # (
    parameter CLK_NUM
) (
    // Programming interface
    input   logic       shift_clk,
    input   logic       shift_data_in,
    output  logic       shift_data_out,
    
    // Fabric Connections
    input   logic [(4*CLK_NUM)-1:0] buses,
    output  logic [CLK_NUM-1:0]     clks,
    
    // Clock Wrapping
    input   logic   clk_in,
    output  logic   clk_out       
);

    logic [CLK_NUM:0]   shift_data;
    logic [CLK_NUM-1:0] prev_clk;
    
    genvar i;
    generate
        for (i = 0; i < CLK_NUM; i++)
        begin : gen_block
            Clock_Selector clk_sel_u (
                .shift_clk(shift_clk),
                .shift_data_in(shift_data[i]),
                .shift_data_out(shift_data[i+1]),
                
                // Fabric Connections
                .bus(buses[(4*i) +: 4]),
                .prev_clk(prev_clk[i]),
                .clk(clks[i])
            );
            
            always_comb
            begin : clk_routing
                if (i == 0)
                begin
                    prev_clk[i] = clk_in;
                end
                else
                begin
                    prev_clk[i] = clks[i-1];
                end
            end
        end
    endgenerate
    
    // Continuous assignments rather than an always_comb block: a block which both writes and
    // reads shift_data is not sensitive to it, so shift_data_out went stale in simulation
    assign shift_data[0]  = shift_data_in;
    assign shift_data_out = shift_data[CLK_NUM];
    
    always_comb
    begin : clk_wrapping
        clk_out = clks[CLK_NUM-1];
    end
    
endmodule