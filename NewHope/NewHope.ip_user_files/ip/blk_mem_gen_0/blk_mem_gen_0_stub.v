// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.3 (win64) Build 1368829 Mon Sep 28 20:06:43 MDT 2015
// Date        : Mon Apr 03 10:14:21 2017
// Host        : DESKTOP-17637OS running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               C:/Users/Toder/Documents/HardwareProjects/NewHope/NewHope.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0_stub.v
// Design      : blk_mem_gen_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_3_0,Vivado 2015.3" *)
module blk_mem_gen_0(clka, ena, wea, addra, dina, douta, clkb, enb, web, addrb, dinb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[0:0],addra[9:0],dina[13:0],douta[13:0],clkb,enb,web[0:0],addrb[9:0],dinb[13:0],doutb[13:0]" */;
  input clka;
  input ena;
  input [0:0]wea;
  input [9:0]addra;
  input [13:0]dina;
  output [13:0]douta;
  input clkb;
  input enb;
  input [0:0]web;
  input [9:0]addrb;
  input [13:0]dinb;
  output [13:0]doutb;
endmodule
