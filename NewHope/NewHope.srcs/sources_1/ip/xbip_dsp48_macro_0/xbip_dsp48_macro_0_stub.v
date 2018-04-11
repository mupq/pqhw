// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.3 (win64) Build 1368829 Mon Sep 28 20:06:43 MDT 2015
// Date        : Wed Jun 07 11:03:36 2017
// Host        : DESKTOP-17637OS running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               C:/Users/Toder/Documents/HardwareProjects/NewHope/NewHope.srcs/sources_1/ip/xbip_dsp48_macro_0/xbip_dsp48_macro_0_stub.v
// Design      : xbip_dsp48_macro_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "xbip_dsp48_macro_v3_0_10,Vivado 2015.3" *)
module xbip_dsp48_macro_0(CLK, SEL, A, B, C, D, P)
/* synthesis syn_black_box black_box_pad_pin="CLK,SEL[1:0],A[14:0],B[14:0],C[14:0],D[14:0],P[30:0]" */;
  input CLK;
  input [1:0]SEL;
  input [14:0]A;
  input [14:0]B;
  input [14:0]C;
  input [14:0]D;
  output [30:0]P;
endmodule
