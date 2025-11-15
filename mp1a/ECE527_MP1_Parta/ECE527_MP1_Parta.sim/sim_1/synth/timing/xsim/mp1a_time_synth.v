// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.1 (win64) Build 6140274 Thu May 22 00:12:29 MDT 2025
// Date        : Tue Sep  2 18:11:26 2025
// Host        : JamesLiu running 64-bit major release  (build 9200)
// Command     : write_verilog -mode timesim -nolib -sdf_anno true -force -file
//               C:/Users/qyliu/ECE527_MP1_Parta/ECE527_MP1_Parta.sim/sim_1/synth/timing/xsim/mp1a_time_synth.v
// Design      : mp1a
// Purpose     : This verilog netlist is a timing simulation representation of the design and should not be modified or
//               synthesized. Please ensure that this netlist is used with the corresponding SDF file.
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps
`define XIL_TIMING

(* NotValidForBitStream *)
module mp1a
   (clk,
    SW,
    LED);
  input clk;
  input [1:0]SW;
  output [1:0]LED;

  wire [1:0]LED;
  wire [1:0]LED_OBUF;
  wire [1:0]SW;
  wire [1:0]SW_IBUF;
  wire clk;
  wire clk_IBUF;
  wire clk_IBUF_BUFG;
  wire \sw_d0_reg_n_0_[0] ;
  wire \sw_d0_reg_n_0_[1] ;
  wire \sw_d2_reg[0]_srl2_n_0 ;
  wire \sw_d2_reg[1]_srl2_n_0 ;

initial begin
 $sdf_annotate("mp1a_time_synth.sdf",,,,"tool_control");
end
  OBUF \LED_OBUF[0]_inst 
       (.I(LED_OBUF[0]),
        .O(LED[0]));
  OBUF \LED_OBUF[1]_inst 
       (.I(LED_OBUF[1]),
        .O(LED[1]));
  FDRE #(
    .INIT(1'b0)) 
    \LED_reg[0] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(\sw_d2_reg[0]_srl2_n_0 ),
        .Q(LED_OBUF[0]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \LED_reg[1] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(\sw_d2_reg[1]_srl2_n_0 ),
        .Q(LED_OBUF[1]),
        .R(1'b0));
  IBUF \SW_IBUF[0]_inst 
       (.I(SW[0]),
        .O(SW_IBUF[0]));
  IBUF \SW_IBUF[1]_inst 
       (.I(SW[1]),
        .O(SW_IBUF[1]));
  BUFG clk_IBUF_BUFG_inst
       (.I(clk_IBUF),
        .O(clk_IBUF_BUFG));
  IBUF clk_IBUF_inst
       (.I(clk),
        .O(clk_IBUF));
  FDRE #(
    .INIT(1'b0)) 
    \sw_d0_reg[0] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(SW_IBUF[0]),
        .Q(\sw_d0_reg_n_0_[0] ),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \sw_d0_reg[1] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(SW_IBUF[1]),
        .Q(\sw_d0_reg_n_0_[1] ),
        .R(1'b0));
  (* srl_bus_name = "\\sw_d2_reg " *) 
  (* srl_name = "\\sw_d2_reg[0]_srl2 " *) 
  SRL16E #(
    .INIT(16'h0000)) 
    \sw_d2_reg[0]_srl2 
       (.A0(1'b1),
        .A1(1'b0),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk_IBUF_BUFG),
        .D(\sw_d0_reg_n_0_[0] ),
        .Q(\sw_d2_reg[0]_srl2_n_0 ));
  (* srl_bus_name = "\\sw_d2_reg " *) 
  (* srl_name = "\\sw_d2_reg[1]_srl2 " *) 
  SRL16E #(
    .INIT(16'h0000)) 
    \sw_d2_reg[1]_srl2 
       (.A0(1'b1),
        .A1(1'b0),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(clk_IBUF_BUFG),
        .D(\sw_d0_reg_n_0_[1] ),
        .Q(\sw_d2_reg[1]_srl2_n_0 ));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
