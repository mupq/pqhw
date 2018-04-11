-- Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2015.3 (win64) Build 1368829 Mon Sep 28 20:06:43 MDT 2015
-- Date        : Wed Jun 07 11:03:36 2017
-- Host        : DESKTOP-17637OS running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               C:/Users/Toder/Documents/HardwareProjects/NewHope/NewHope.srcs/sources_1/ip/xbip_dsp48_macro_0/xbip_dsp48_macro_0_stub.vhdl
-- Design      : xbip_dsp48_macro_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a35tcpg236-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity xbip_dsp48_macro_0 is
  Port ( 
    CLK : in STD_LOGIC;
    SEL : in STD_LOGIC_VECTOR ( 1 downto 0 );
    A : in STD_LOGIC_VECTOR ( 14 downto 0 );
    B : in STD_LOGIC_VECTOR ( 14 downto 0 );
    C : in STD_LOGIC_VECTOR ( 14 downto 0 );
    D : in STD_LOGIC_VECTOR ( 14 downto 0 );
    P : out STD_LOGIC_VECTOR ( 30 downto 0 )
  );

end xbip_dsp48_macro_0;

architecture stub of xbip_dsp48_macro_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "CLK,SEL[1:0],A[14:0],B[14:0],C[14:0],D[14:0],P[30:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "xbip_dsp48_macro_v3_0_10,Vivado 2015.3";
begin
end;
