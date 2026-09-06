module CLB (carry_in,
    carry_out,
    clk,
    clk_out,
    reset,
    reset_out,
    shift_clk,
    shift_clk_out,
    shift_data_in,
    shift_data_out,
    horz_bus_in,
    horz_bus_out,
    vert_bus_in,
    vert_bus_out);
 input carry_in;
 output carry_out;
 input clk;
 output clk_out;
 input reset;
 output reset_out;
 input shift_clk;
 output shift_clk_out;
 input shift_data_in;
 output shift_data_out;
 input [3:0] horz_bus_in;
 output [3:0] horz_bus_out;
 input [3:0] vert_bus_in;
 output [3:0] vert_bus_out;

 wire _00_;
 wire _01_;
 wire _02_;
 wire _03_;
 wire _04_;
 wire _05_;
 wire _06_;
 wire _07_;
 wire _08_;
 wire _09_;
 wire _10_;
 wire _11_;
 wire _12_;
 wire _13_;
 wire _14_;
 wire _15_;
 wire _16_;
 wire _17_;
 wire _18_;
 wire _19_;
 wire _20_;
 wire _21_;
 wire _22_;
 wire _23_;
 wire _24_;
 wire _25_;
 wire _26_;
 wire _27_;
 wire _28_;
 wire _29_;
 wire \input_c_mux_u.sel[0] ;
 wire \input_c_mux_u.sel[1] ;
 wire input_mux_a_sel;
 wire input_mux_b_sel;
 wire \logic_mux_u.sel[0] ;
 wire \logic_mux_u.sel[1] ;
 wire \logic_mux_u.sel[2] ;
 wire \major_horz2_sel[0] ;
 wire \major_horz2_sel[1] ;
 wire \major_horz2_sel[2] ;
 wire \major_horz3_sel[0] ;
 wire \major_horz3_sel[1] ;
 wire \major_horz3_sel[2] ;
 wire \major_output_mux_h2_u.out ;
 wire \major_output_mux_h3_u.out ;
 wire \minor_horz_sel[0] ;
 wire \minor_horz_sel[1] ;
 wire \minor_vert_sel[0] ;
 wire \minor_vert_sel[1] ;
 wire \minor_vert_sel[2] ;
 wire \minor_vert_sel[3] ;
 wire operation_ff;
 wire net1;
 wire net2;
 wire net3;
 wire net4;
 wire net5;
 wire net6;
 wire net7;
 wire net8;
 wire net9;
 wire net10;
 wire net11;
 wire net12;
 wire net13;
 wire net14;
 wire net15;
 wire net16;
 wire net17;
 wire net18;
 wire net19;
 wire net20;
 wire net21;
 wire net22;
 wire net23;
 wire net24;
 wire net25;
 wire net26;
 wire net27;
 wire clknet_0_clk;
 wire clknet_1_0__leaf_clk;
 wire clknet_1_1__leaf_clk;
 wire net28;

 sky130_fd_sc_hd__inv_2 _30_ (.A(net5),
    .Y(_01_));
 sky130_fd_sc_hd__inv_2 _31_ (.A(net4),
    .Y(_02_));
 sky130_fd_sc_hd__inv_2 _32_ (.A(\logic_mux_u.sel[0] ),
    .Y(_03_));
 sky130_fd_sc_hd__inv_2 _33_ (.A(\logic_mux_u.sel[2] ),
    .Y(_04_));
 sky130_fd_sc_hd__mux2_1 _34_ (.A0(net3),
    .A1(net4),
    .S(input_mux_b_sel),
    .X(_05_));
 sky130_fd_sc_hd__mux2_1 _35_ (.A0(net2),
    .A1(net3),
    .S(input_mux_a_sel),
    .X(_06_));
 sky130_fd_sc_hd__or2_1 _36_ (.A(_05_),
    .B(_06_),
    .X(_07_));
 sky130_fd_sc_hd__and2_1 _37_ (.A(_05_),
    .B(_06_),
    .X(_08_));
 sky130_fd_sc_hd__xnor2_1 _38_ (.A(_05_),
    .B(_06_),
    .Y(_09_));
 sky130_fd_sc_hd__mux4_2 _39_ (.A0(net4),
    .A1(net9),
    .A2(net5),
    .A3(net1),
    .S0(\input_c_mux_u.sel[1] ),
    .S1(\input_c_mux_u.sel[0] ),
    .X(_10_));
 sky130_fd_sc_hd__xnor2_1 _40_ (.A(_09_),
    .B(_10_),
    .Y(_11_));
 sky130_fd_sc_hd__nand3_1 _41_ (.A(\logic_mux_u.sel[0] ),
    .B(_08_),
    .C(_10_),
    .Y(_12_));
 sky130_fd_sc_hd__o211a_1 _42_ (.A1(\logic_mux_u.sel[0] ),
    .A2(_11_),
    .B1(_12_),
    .C1(\logic_mux_u.sel[1] ),
    .X(_13_));
 sky130_fd_sc_hd__a31o_1 _43_ (.A1(_05_),
    .A2(_06_),
    .A3(_10_),
    .B1(\logic_mux_u.sel[0] ),
    .X(_14_));
 sky130_fd_sc_hd__o21ai_1 _44_ (.A1(_07_),
    .A2(_10_),
    .B1(_14_),
    .Y(_15_));
 sky130_fd_sc_hd__o21ai_1 _45_ (.A1(\logic_mux_u.sel[1] ),
    .A2(_15_),
    .B1(_04_),
    .Y(_16_));
 sky130_fd_sc_hd__a211o_1 _46_ (.A1(\logic_mux_u.sel[0] ),
    .A2(_05_),
    .B1(_08_),
    .C1(_10_),
    .X(_17_));
 sky130_fd_sc_hd__or3b_1 _47_ (.A(_03_),
    .B(_06_),
    .C_N(_10_),
    .X(_18_));
 sky130_fd_sc_hd__and3_1 _48_ (.A(\logic_mux_u.sel[1] ),
    .B(_17_),
    .C(_18_),
    .X(_19_));
 sky130_fd_sc_hd__a211oi_1 _49_ (.A1(_03_),
    .A2(_07_),
    .B1(_11_),
    .C1(\logic_mux_u.sel[1] ),
    .Y(_20_));
 sky130_fd_sc_hd__o32a_2 _50_ (.A1(_04_),
    .A2(_19_),
    .A3(_20_),
    .B1(_13_),
    .B2(_16_),
    .X(_21_));
 sky130_fd_sc_hd__mux2_1 _51_ (.A0(_21_),
    .A1(net2),
    .S(\minor_horz_sel[0] ),
    .X(net15));
 sky130_fd_sc_hd__mux2_1 _52_ (.A0(_21_),
    .A1(net3),
    .S(\minor_horz_sel[1] ),
    .X(net16));
 sky130_fd_sc_hd__mux2_1 _53_ (.A0(_21_),
    .A1(net11),
    .S(\minor_vert_sel[0] ),
    .X(net22));
 sky130_fd_sc_hd__mux2_1 _54_ (.A0(operation_ff),
    .A1(net12),
    .S(\minor_vert_sel[1] ),
    .X(net23));
 sky130_fd_sc_hd__mux2_1 _55_ (.A0(_21_),
    .A1(net9),
    .S(\minor_vert_sel[2] ),
    .X(net24));
 sky130_fd_sc_hd__mux2_1 _56_ (.A0(operation_ff),
    .A1(net10),
    .S(\minor_vert_sel[3] ),
    .X(net25));
 sky130_fd_sc_hd__mux4_1 _57_ (.A0(_21_),
    .A1(net12),
    .A2(operation_ff),
    .A3(net5),
    .S0(\major_horz2_sel[1] ),
    .S1(\major_horz2_sel[0] ),
    .X(_22_));
 sky130_fd_sc_hd__a21oi_1 _58_ (.A1(net11),
    .A2(\major_horz2_sel[1] ),
    .B1(\major_horz2_sel[0] ),
    .Y(_23_));
 sky130_fd_sc_hd__a31oi_1 _59_ (.A1(_02_),
    .A2(\major_horz2_sel[0] ),
    .A3(\major_horz2_sel[1] ),
    .B1(_23_),
    .Y(_24_));
 sky130_fd_sc_hd__mux2_1 _60_ (.A0(_24_),
    .A1(_22_),
    .S(\major_horz2_sel[2] ),
    .X(\major_output_mux_h2_u.out ));
 sky130_fd_sc_hd__mux4_1 _61_ (.A0(_21_),
    .A1(operation_ff),
    .A2(net11),
    .A3(net4),
    .S0(\major_horz3_sel[0] ),
    .S1(\major_horz3_sel[1] ),
    .X(_25_));
 sky130_fd_sc_hd__a21oi_1 _62_ (.A1(net12),
    .A2(\major_horz3_sel[1] ),
    .B1(\major_horz3_sel[0] ),
    .Y(_26_));
 sky130_fd_sc_hd__a31oi_1 _63_ (.A1(_01_),
    .A2(\major_horz3_sel[0] ),
    .A3(\major_horz3_sel[1] ),
    .B1(_26_),
    .Y(_27_));
 sky130_fd_sc_hd__mux2_1 _64_ (.A0(_27_),
    .A1(_25_),
    .S(\major_horz3_sel[2] ),
    .X(\major_output_mux_h3_u.out ));
 sky130_fd_sc_hd__o21a_1 _65_ (.A1(_08_),
    .A2(_10_),
    .B1(_07_),
    .X(net13));
 sky130_fd_sc_hd__and3b_1 _66_ (.A_N(net6),
    .B(_21_),
    .C(net5),
    .X(_28_));
 sky130_fd_sc_hd__nor2_1 _67_ (.A(net5),
    .B(net6),
    .Y(_29_));
 sky130_fd_sc_hd__a221o_1 _68_ (.A1(net6),
    .A2(net21),
    .B1(_29_),
    .B2(net28),
    .C1(_28_),
    .X(_00_));
 sky130_fd_sc_hd__dfxtp_1 _69_ (.CLK(clknet_1_0__leaf_clk),
    .D(_00_),
    .Q(operation_ff));
 sky130_fd_sc_hd__dfxtp_1 _70_ (.CLK(net27),
    .D(net8),
    .Q(input_mux_a_sel));
 sky130_fd_sc_hd__dfxtp_1 _71_ (.CLK(net27),
    .D(input_mux_a_sel),
    .Q(input_mux_b_sel));
 sky130_fd_sc_hd__dfxtp_1 _72_ (.CLK(net27),
    .D(input_mux_b_sel),
    .Q(\input_c_mux_u.sel[0] ));
 sky130_fd_sc_hd__dfxtp_1 _73_ (.CLK(net27),
    .D(\input_c_mux_u.sel[0] ),
    .Q(\input_c_mux_u.sel[1] ));
 sky130_fd_sc_hd__dfxtp_1 _74_ (.CLK(net27),
    .D(\input_c_mux_u.sel[1] ),
    .Q(\logic_mux_u.sel[0] ));
 sky130_fd_sc_hd__dfxtp_1 _75_ (.CLK(net27),
    .D(\logic_mux_u.sel[0] ),
    .Q(\logic_mux_u.sel[1] ));
 sky130_fd_sc_hd__dfxtp_1 _76_ (.CLK(net27),
    .D(\logic_mux_u.sel[1] ),
    .Q(\logic_mux_u.sel[2] ));
 sky130_fd_sc_hd__dfxtp_1 _77_ (.CLK(net26),
    .D(\logic_mux_u.sel[2] ),
    .Q(\minor_horz_sel[0] ));
 sky130_fd_sc_hd__dfxtp_1 _78_ (.CLK(net26),
    .D(\minor_horz_sel[0] ),
    .Q(\minor_horz_sel[1] ));
 sky130_fd_sc_hd__dfxtp_1 _79_ (.CLK(net26),
    .D(\minor_horz_sel[1] ),
    .Q(\minor_vert_sel[0] ));
 sky130_fd_sc_hd__dfxtp_1 _80_ (.CLK(net26),
    .D(\minor_vert_sel[0] ),
    .Q(\minor_vert_sel[1] ));
 sky130_fd_sc_hd__dfxtp_1 _81_ (.CLK(net26),
    .D(\minor_vert_sel[1] ),
    .Q(\minor_vert_sel[2] ));
 sky130_fd_sc_hd__dfxtp_1 _82_ (.CLK(net26),
    .D(\minor_vert_sel[2] ),
    .Q(\minor_vert_sel[3] ));
 sky130_fd_sc_hd__dfxtp_1 _83_ (.CLK(net26),
    .D(\minor_vert_sel[3] ),
    .Q(\major_horz2_sel[0] ));
 sky130_fd_sc_hd__dfxtp_1 _84_ (.CLK(net26),
    .D(\major_horz2_sel[0] ),
    .Q(\major_horz2_sel[1] ));
 sky130_fd_sc_hd__dfxtp_1 _85_ (.CLK(net26),
    .D(\major_horz2_sel[1] ),
    .Q(\major_horz2_sel[2] ));
 sky130_fd_sc_hd__dfxtp_1 _86_ (.CLK(net26),
    .D(\major_horz2_sel[2] ),
    .Q(\major_horz3_sel[0] ));
 sky130_fd_sc_hd__dfxtp_1 _87_ (.CLK(net27),
    .D(\major_horz3_sel[0] ),
    .Q(\major_horz3_sel[1] ));
 sky130_fd_sc_hd__dfxtp_1 _88_ (.CLK(net27),
    .D(\major_horz3_sel[1] ),
    .Q(\major_horz3_sel[2] ));
 sky130_fd_sc_hd__dfxtp_1 _89_ (.CLK(net7),
    .D(\major_horz3_sel[2] ),
    .Q(net21));
 sky130_fd_sc_hd__buf_2 _90_ (.A(clknet_1_1__leaf_clk),
    .X(net14));
 sky130_fd_sc_hd__clkbuf_1 _91_ (.A(\major_output_mux_h2_u.out ),
    .X(net17));
 sky130_fd_sc_hd__clkbuf_1 _92_ (.A(\major_output_mux_h3_u.out ),
    .X(net18));
 sky130_fd_sc_hd__clkbuf_1 _93_ (.A(net6),
    .X(net19));
 sky130_fd_sc_hd__clkbuf_1 _94_ (.A(net7),
    .X(net20));
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_0_Right_0 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_1_Right_1 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_2_Right_2 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_3_Right_3 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_4_Right_4 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_5_Right_5 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_6_Right_6 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_7_Right_7 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_8_Right_8 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_9_Right_9 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_10_Right_10 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_11_Right_11 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_12_Right_12 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_13_Right_13 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_14_Right_14 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_15_Right_15 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_0_Left_16 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_1_Left_17 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_2_Left_18 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_3_Left_19 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_4_Left_20 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_5_Left_21 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_6_Left_22 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_7_Left_23 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_8_Left_24 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_9_Left_25 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_10_Left_26 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_11_Left_27 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_12_Left_28 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_13_Left_29 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_14_Left_30 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_15_Left_31 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_0_32 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_0_33 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_1_34 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_2_35 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_3_36 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_4_37 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_5_38 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_6_39 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_7_40 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_8_41 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_9_42 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_10_43 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_11_44 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_12_45 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_13_46 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_14_47 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_15_48 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_15_49 ();
 sky130_fd_sc_hd__clkbuf_1 input1 (.A(carry_in),
    .X(net1));
 sky130_fd_sc_hd__clkbuf_1 input2 (.A(horz_bus_in[0]),
    .X(net2));
 sky130_fd_sc_hd__buf_1 input3 (.A(horz_bus_in[1]),
    .X(net3));
 sky130_fd_sc_hd__buf_1 input4 (.A(horz_bus_in[2]),
    .X(net4));
 sky130_fd_sc_hd__dlymetal6s2s_1 input5 (.A(horz_bus_in[3]),
    .X(net5));
 sky130_fd_sc_hd__buf_1 input6 (.A(reset),
    .X(net6));
 sky130_fd_sc_hd__buf_1 input7 (.A(shift_clk),
    .X(net7));
 sky130_fd_sc_hd__clkbuf_1 input8 (.A(shift_data_in),
    .X(net8));
 sky130_fd_sc_hd__clkbuf_1 input9 (.A(vert_bus_in[0]),
    .X(net9));
 sky130_fd_sc_hd__clkbuf_1 input10 (.A(vert_bus_in[1]),
    .X(net10));
 sky130_fd_sc_hd__buf_1 input11 (.A(vert_bus_in[2]),
    .X(net11));
 sky130_fd_sc_hd__buf_1 input12 (.A(vert_bus_in[3]),
    .X(net12));
 sky130_fd_sc_hd__buf_2 output13 (.A(net13),
    .X(carry_out));
 sky130_fd_sc_hd__buf_1 output14 (.A(net14),
    .X(clk_out));
 sky130_fd_sc_hd__buf_2 output15 (.A(net15),
    .X(horz_bus_out[0]));
 sky130_fd_sc_hd__buf_2 output16 (.A(net16),
    .X(horz_bus_out[1]));
 sky130_fd_sc_hd__buf_2 output17 (.A(net17),
    .X(horz_bus_out[2]));
 sky130_fd_sc_hd__buf_2 output18 (.A(net18),
    .X(horz_bus_out[3]));
 sky130_fd_sc_hd__buf_2 output19 (.A(net19),
    .X(reset_out));
 sky130_fd_sc_hd__buf_2 output20 (.A(net20),
    .X(shift_clk_out));
 sky130_fd_sc_hd__buf_2 output21 (.A(net21),
    .X(shift_data_out));
 sky130_fd_sc_hd__buf_2 output22 (.A(net22),
    .X(vert_bus_out[0]));
 sky130_fd_sc_hd__buf_2 output23 (.A(net23),
    .X(vert_bus_out[1]));
 sky130_fd_sc_hd__buf_2 output24 (.A(net24),
    .X(vert_bus_out[2]));
 sky130_fd_sc_hd__buf_2 output25 (.A(net25),
    .X(vert_bus_out[3]));
 sky130_fd_sc_hd__clkbuf_2 fanout26 (.A(net27),
    .X(net26));
 sky130_fd_sc_hd__clkbuf_2 fanout27 (.A(net7),
    .X(net27));
 sky130_fd_sc_hd__clkbuf_16 clkbuf_0_clk (.A(clk),
    .X(clknet_0_clk));
 sky130_fd_sc_hd__clkbuf_16 clkbuf_1_0__f_clk (.A(clknet_0_clk),
    .X(clknet_1_0__leaf_clk));
 sky130_fd_sc_hd__clkbuf_16 clkbuf_1_1__f_clk (.A(clknet_0_clk),
    .X(clknet_1_1__leaf_clk));
 sky130_fd_sc_hd__clkbuf_4 clkload0 (.A(clknet_1_1__leaf_clk));
 sky130_fd_sc_hd__dlygate4sd3_1 hold1 (.A(operation_ff),
    .X(net28));
 sky130_fd_sc_hd__fill_1 FILLER_0_3 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_10 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_19 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_27 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_32 ();
 sky130_fd_sc_hd__decap_8 FILLER_0_47 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_55 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_57 ();
 sky130_ef_sc_hd__decap_12 FILLER_1_3 ();
 sky130_fd_sc_hd__decap_6 FILLER_1_15 ();
 sky130_fd_sc_hd__decap_3 FILLER_1_53 ();
 sky130_fd_sc_hd__decap_6 FILLER_2_38 ();
 sky130_fd_sc_hd__decap_4 FILLER_2_69 ();
 sky130_fd_sc_hd__fill_1 FILLER_2_73 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_6 ();
 sky130_ef_sc_hd__decap_12 FILLER_3_34 ();
 sky130_fd_sc_hd__decap_4 FILLER_3_46 ();
 sky130_fd_sc_hd__fill_1 FILLER_3_55 ();
 sky130_fd_sc_hd__decap_6 FILLER_3_57 ();
 sky130_fd_sc_hd__fill_1 FILLER_3_63 ();
 sky130_fd_sc_hd__decap_8 FILLER_4_19 ();
 sky130_fd_sc_hd__fill_1 FILLER_4_27 ();
 sky130_fd_sc_hd__decap_4 FILLER_4_45 ();
 sky130_fd_sc_hd__fill_1 FILLER_4_49 ();
 sky130_ef_sc_hd__decap_12 FILLER_4_53 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_65 ();
 sky130_fd_sc_hd__decap_6 FILLER_4_71 ();
 sky130_fd_sc_hd__decap_8 FILLER_5_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_11 ();
 sky130_fd_sc_hd__fill_1 FILLER_5_39 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_10 ();
 sky130_fd_sc_hd__decap_6 FILLER_6_22 ();
 sky130_ef_sc_hd__decap_12 FILLER_6_29 ();
 sky130_fd_sc_hd__decap_4 FILLER_6_41 ();
 sky130_fd_sc_hd__fill_1 FILLER_6_45 ();
 sky130_fd_sc_hd__decap_6 FILLER_6_67 ();
 sky130_ef_sc_hd__decap_12 FILLER_7_3 ();
 sky130_fd_sc_hd__decap_8 FILLER_7_15 ();
 sky130_fd_sc_hd__decap_3 FILLER_7_23 ();
 sky130_ef_sc_hd__decap_12 FILLER_7_44 ();
 sky130_fd_sc_hd__decap_3 FILLER_7_74 ();
 sky130_ef_sc_hd__decap_12 FILLER_8_45 ();
 sky130_fd_sc_hd__fill_1 FILLER_8_57 ();
 sky130_ef_sc_hd__decap_12 FILLER_9_19 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_31 ();
 sky130_fd_sc_hd__decap_3 FILLER_9_50 ();
 sky130_fd_sc_hd__decap_6 FILLER_10_22 ();
 sky130_ef_sc_hd__decap_12 FILLER_10_29 ();
 sky130_fd_sc_hd__decap_4 FILLER_10_41 ();
 sky130_fd_sc_hd__fill_1 FILLER_10_45 ();
 sky130_fd_sc_hd__decap_8 FILLER_11_7 ();
 sky130_fd_sc_hd__decap_3 FILLER_11_15 ();
 sky130_fd_sc_hd__decap_4 FILLER_11_44 ();
 sky130_fd_sc_hd__fill_2 FILLER_12_19 ();
 sky130_fd_sc_hd__fill_2 FILLER_12_44 ();
 sky130_fd_sc_hd__decap_8 FILLER_12_62 ();
 sky130_ef_sc_hd__decap_12 FILLER_13_6 ();
 sky130_fd_sc_hd__decap_6 FILLER_13_18 ();
 sky130_fd_sc_hd__fill_1 FILLER_13_24 ();
 sky130_fd_sc_hd__fill_1 FILLER_14_10 ();
 sky130_fd_sc_hd__decap_4 FILLER_14_23 ();
 sky130_fd_sc_hd__fill_1 FILLER_14_27 ();
 sky130_fd_sc_hd__decap_6 FILLER_14_44 ();
 sky130_fd_sc_hd__fill_1 FILLER_14_50 ();
 sky130_fd_sc_hd__decap_6 FILLER_14_55 ();
 sky130_fd_sc_hd__fill_1 FILLER_14_68 ();
 sky130_fd_sc_hd__fill_1 FILLER_15_3 ();
 sky130_fd_sc_hd__decap_4 FILLER_15_11 ();
 sky130_fd_sc_hd__fill_1 FILLER_15_15 ();
 sky130_fd_sc_hd__decap_8 FILLER_15_20 ();
 sky130_fd_sc_hd__decap_6 FILLER_15_33 ();
 sky130_fd_sc_hd__fill_1 FILLER_15_39 ();
 sky130_fd_sc_hd__decap_3 FILLER_15_44 ();
endmodule
