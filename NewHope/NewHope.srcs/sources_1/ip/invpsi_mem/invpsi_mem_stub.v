// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.3 (win64) Build 1368829 Mon Sep 28 20:06:43 MDT 2015
// Date        : Mon Apr 03 10:16:30 2017
// Host        : DESKTOP-17637OS running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               C:/Users/Toder/Documents/HardwareProjects/NewHope/NewHope.srcs/sources_1/ip/invpsi_mem/invpsi_mem_stub.v
// Design      : invpsi_mem
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_3_0,Vivado 2015.3" *)
module invpsi_mem(clka, ena, addra, douta)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,addra[9:0],douta[13:0]" */;
  input clka;
  input ena;
  input [9:0]addra;
  output [13:0]douta;
endmodule
