// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.3 (win64) Build 1368829 Mon Sep 28 20:06:43 MDT 2015
// Date        : Wed Jun 07 11:03:36 2017
// Host        : DESKTOP-17637OS running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               C:/Users/Toder/Documents/HardwareProjects/NewHope/NewHope.srcs/sources_1/ip/xbip_dsp48_macro_0/xbip_dsp48_macro_0_sim_netlist.v
// Design      : xbip_dsp48_macro_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "xbip_dsp48_macro_0,xbip_dsp48_macro_v3_0_10,{}" *) (* core_generation_info = "xbip_dsp48_macro_0,xbip_dsp48_macro_v3_0_10,{x_ipProduct=Vivado 2015.3,x_ipVendor=xilinx.com,x_ipLibrary=ip,x_ipName=xbip_dsp48_macro,x_ipVersion=3.0,x_ipCoreRevision=10,x_ipLanguage=VHDL,x_ipSimLanguage=MIXED,C_VERBOSITY=0,C_MODEL_TYPE=0,C_XDEVICEFAMILY=artix7,C_HAS_CE=0,C_HAS_INDEP_CE=0,C_HAS_CED=0,C_HAS_CEA=0,C_HAS_CEB=0,C_HAS_CEC=0,C_HAS_CECONCAT=0,C_HAS_CEM=0,C_HAS_CEP=0,C_HAS_CESEL=0,C_HAS_SCLR=0,C_HAS_INDEP_SCLR=0,C_HAS_SCLRD=0,C_HAS_SCLRA=0,C_HAS_SCLRB=0,C_HAS_SCLRC=0,C_HAS_SCLRM=0,C_HAS_SCLRP=0,C_HAS_SCLRCONCAT=0,C_HAS_SCLRSEL=0,C_HAS_CARRYCASCIN=0,C_HAS_CARRYIN=0,C_HAS_ACIN=0,C_HAS_BCIN=0,C_HAS_PCIN=0,C_HAS_A=1,C_HAS_B=1,C_HAS_D=1,C_HAS_CONCAT=0,C_HAS_C=1,C_A_WIDTH=15,C_B_WIDTH=15,C_C_WIDTH=15,C_D_WIDTH=15,C_CONCAT_WIDTH=48,C_P_MSB=30,C_P_LSB=0,C_SEL_WIDTH=2,C_HAS_ACOUT=0,C_HAS_BCOUT=0,C_HAS_CARRYCASCOUT=0,C_HAS_CARRYOUT=0,C_HAS_PCOUT=0,C_CONSTANT_1=1,C_LATENCY=80,C_OPMODES=000000000011010100000000_000001100011010100000000_000100100000010100001001_000100100000010100011000,C_REG_CONFIG=00000000000000000000000011100000,C_TEST_CORE=0}" *) (* downgradeipidentifiedwarnings = "yes" *) 
(* x_core_info = "xbip_dsp48_macro_v3_0_10,Vivado 2015.3" *) 
(* NotValidForBitStream *)
module xbip_dsp48_macro_0
   (CLK,
    SEL,
    A,
    B,
    C,
    D,
    P);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk_intf CLK" *) input CLK;
  (* x_interface_info = "xilinx.com:signal:data:1.0 sel_intf DATA" *) input [1:0]SEL;
  (* x_interface_info = "xilinx.com:signal:data:1.0 a_intf DATA" *) input [14:0]A;
  (* x_interface_info = "xilinx.com:signal:data:1.0 b_intf DATA" *) input [14:0]B;
  (* x_interface_info = "xilinx.com:signal:data:1.0 c_intf DATA" *) input [14:0]C;
  (* x_interface_info = "xilinx.com:signal:data:1.0 d_intf DATA" *) input [14:0]D;
  (* x_interface_info = "xilinx.com:signal:data:1.0 p_intf DATA" *) output [30:0]P;

  wire [14:0]A;
  wire [14:0]B;
  wire [14:0]C;
  wire CLK;
  wire [14:0]D;
  wire [30:0]P;
  wire [1:0]SEL;
  wire NLW_U0_CARRYCASCOUT_UNCONNECTED;
  wire NLW_U0_CARRYOUT_UNCONNECTED;
  wire [29:0]NLW_U0_ACOUT_UNCONNECTED;
  wire [17:0]NLW_U0_BCOUT_UNCONNECTED;
  wire [47:0]NLW_U0_PCOUT_UNCONNECTED;

  (* C_A_WIDTH = "15" *) 
  (* C_B_WIDTH = "15" *) 
  (* C_CONCAT_WIDTH = "48" *) 
  (* C_CONSTANT_1 = "1" *) 
  (* C_C_WIDTH = "15" *) 
  (* C_D_WIDTH = "15" *) 
  (* C_HAS_A = "1" *) 
  (* C_HAS_ACIN = "0" *) 
  (* C_HAS_ACOUT = "0" *) 
  (* C_HAS_B = "1" *) 
  (* C_HAS_BCIN = "0" *) 
  (* C_HAS_BCOUT = "0" *) 
  (* C_HAS_C = "1" *) 
  (* C_HAS_CARRYCASCIN = "0" *) 
  (* C_HAS_CARRYCASCOUT = "0" *) 
  (* C_HAS_CARRYIN = "0" *) 
  (* C_HAS_CARRYOUT = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_CEA = "0" *) 
  (* C_HAS_CEB = "0" *) 
  (* C_HAS_CEC = "0" *) 
  (* C_HAS_CECONCAT = "0" *) 
  (* C_HAS_CED = "0" *) 
  (* C_HAS_CEM = "0" *) 
  (* C_HAS_CEP = "0" *) 
  (* C_HAS_CESEL = "0" *) 
  (* C_HAS_CONCAT = "0" *) 
  (* C_HAS_D = "1" *) 
  (* C_HAS_INDEP_CE = "0" *) 
  (* C_HAS_INDEP_SCLR = "0" *) 
  (* C_HAS_PCIN = "0" *) 
  (* C_HAS_PCOUT = "0" *) 
  (* C_HAS_SCLR = "0" *) 
  (* C_HAS_SCLRA = "0" *) 
  (* C_HAS_SCLRB = "0" *) 
  (* C_HAS_SCLRC = "0" *) 
  (* C_HAS_SCLRCONCAT = "0" *) 
  (* C_HAS_SCLRD = "0" *) 
  (* C_HAS_SCLRM = "0" *) 
  (* C_HAS_SCLRP = "0" *) 
  (* C_HAS_SCLRSEL = "0" *) 
  (* C_LATENCY = "80" *) 
  (* C_MODEL_TYPE = "0" *) 
  (* C_OPMODES = "000000000011010100000000,000001100011010100000000,000100100000010100001001,000100100000010100011000" *) 
  (* C_P_LSB = "0" *) 
  (* C_P_MSB = "30" *) 
  (* C_REG_CONFIG = "00000000000000000000000011100000" *) 
  (* C_SEL_WIDTH = "2" *) 
  (* C_TEST_CORE = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* x_interface_info = "xilinx.com:signal:data:1.0 p_intf DATA" *) 
  xbip_dsp48_macro_0_xbip_dsp48_macro_v3_0_10 U0
       (.A(A),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_U0_ACOUT_UNCONNECTED[29:0]),
        .B(B),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_U0_BCOUT_UNCONNECTED[17:0]),
        .C(C),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_U0_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYOUT(NLW_U0_CARRYOUT_UNCONNECTED),
        .CE(1'b1),
        .CEA(1'b1),
        .CEA1(1'b1),
        .CEA2(1'b1),
        .CEA3(1'b1),
        .CEA4(1'b1),
        .CEB(1'b1),
        .CEB1(1'b1),
        .CEB2(1'b1),
        .CEB3(1'b1),
        .CEB4(1'b1),
        .CEC(1'b1),
        .CEC1(1'b1),
        .CEC2(1'b1),
        .CEC3(1'b1),
        .CEC4(1'b1),
        .CEC5(1'b1),
        .CECONCAT(1'b1),
        .CECONCAT3(1'b1),
        .CECONCAT4(1'b1),
        .CECONCAT5(1'b1),
        .CED(1'b1),
        .CED1(1'b1),
        .CED2(1'b1),
        .CED3(1'b1),
        .CEM(1'b1),
        .CEP(1'b1),
        .CESEL(1'b1),
        .CESEL1(1'b1),
        .CESEL2(1'b1),
        .CESEL3(1'b1),
        .CESEL4(1'b1),
        .CESEL5(1'b1),
        .CLK(CLK),
        .CONCAT({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .D(D),
        .P(P),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_U0_PCOUT_UNCONNECTED[47:0]),
        .SCLR(1'b0),
        .SCLRA(1'b0),
        .SCLRB(1'b0),
        .SCLRC(1'b0),
        .SCLRCONCAT(1'b0),
        .SCLRD(1'b0),
        .SCLRM(1'b0),
        .SCLRP(1'b0),
        .SCLRSEL(1'b0),
        .SEL(SEL));
endmodule

(* C_A_WIDTH = "15" *) (* C_B_WIDTH = "15" *) (* C_CONCAT_WIDTH = "48" *) 
(* C_CONSTANT_1 = "1" *) (* C_C_WIDTH = "15" *) (* C_D_WIDTH = "15" *) 
(* C_HAS_A = "1" *) (* C_HAS_ACIN = "0" *) (* C_HAS_ACOUT = "0" *) 
(* C_HAS_B = "1" *) (* C_HAS_BCIN = "0" *) (* C_HAS_BCOUT = "0" *) 
(* C_HAS_C = "1" *) (* C_HAS_CARRYCASCIN = "0" *) (* C_HAS_CARRYCASCOUT = "0" *) 
(* C_HAS_CARRYIN = "0" *) (* C_HAS_CARRYOUT = "0" *) (* C_HAS_CE = "0" *) 
(* C_HAS_CEA = "0" *) (* C_HAS_CEB = "0" *) (* C_HAS_CEC = "0" *) 
(* C_HAS_CECONCAT = "0" *) (* C_HAS_CED = "0" *) (* C_HAS_CEM = "0" *) 
(* C_HAS_CEP = "0" *) (* C_HAS_CESEL = "0" *) (* C_HAS_CONCAT = "0" *) 
(* C_HAS_D = "1" *) (* C_HAS_INDEP_CE = "0" *) (* C_HAS_INDEP_SCLR = "0" *) 
(* C_HAS_PCIN = "0" *) (* C_HAS_PCOUT = "0" *) (* C_HAS_SCLR = "0" *) 
(* C_HAS_SCLRA = "0" *) (* C_HAS_SCLRB = "0" *) (* C_HAS_SCLRC = "0" *) 
(* C_HAS_SCLRCONCAT = "0" *) (* C_HAS_SCLRD = "0" *) (* C_HAS_SCLRM = "0" *) 
(* C_HAS_SCLRP = "0" *) (* C_HAS_SCLRSEL = "0" *) (* C_LATENCY = "80" *) 
(* C_MODEL_TYPE = "0" *) (* C_OPMODES = "000000000011010100000000,000001100011010100000000,000100100000010100001001,000100100000010100011000" *) (* C_P_LSB = "0" *) 
(* C_P_MSB = "30" *) (* C_REG_CONFIG = "00000000000000000000000011100000" *) (* C_SEL_WIDTH = "2" *) 
(* C_TEST_CORE = "0" *) (* C_VERBOSITY = "0" *) (* C_XDEVICEFAMILY = "artix7" *) 
(* ORIG_REF_NAME = "xbip_dsp48_macro_v3_0_10" *) (* downgradeipidentifiedwarnings = "yes" *) 
module xbip_dsp48_macro_0_xbip_dsp48_macro_v3_0_10
   (CLK,
    CE,
    SCLR,
    SEL,
    CARRYCASCIN,
    CARRYIN,
    PCIN,
    ACIN,
    BCIN,
    A,
    B,
    C,
    D,
    CONCAT,
    ACOUT,
    BCOUT,
    CARRYOUT,
    CARRYCASCOUT,
    PCOUT,
    P,
    CED,
    CED1,
    CED2,
    CED3,
    CEA,
    CEA1,
    CEA2,
    CEA3,
    CEA4,
    CEB,
    CEB1,
    CEB2,
    CEB3,
    CEB4,
    CECONCAT,
    CECONCAT3,
    CECONCAT4,
    CECONCAT5,
    CEC,
    CEC1,
    CEC2,
    CEC3,
    CEC4,
    CEC5,
    CEM,
    CEP,
    CESEL,
    CESEL1,
    CESEL2,
    CESEL3,
    CESEL4,
    CESEL5,
    SCLRD,
    SCLRA,
    SCLRB,
    SCLRCONCAT,
    SCLRC,
    SCLRM,
    SCLRP,
    SCLRSEL);
  input CLK;
  input CE;
  input SCLR;
  input [1:0]SEL;
  input CARRYCASCIN;
  input CARRYIN;
  input [47:0]PCIN;
  input [29:0]ACIN;
  input [17:0]BCIN;
  input [14:0]A;
  input [14:0]B;
  input [14:0]C;
  input [14:0]D;
  input [47:0]CONCAT;
  output [29:0]ACOUT;
  output [17:0]BCOUT;
  output CARRYOUT;
  output CARRYCASCOUT;
  output [47:0]PCOUT;
  output [30:0]P;
  input CED;
  input CED1;
  input CED2;
  input CED3;
  input CEA;
  input CEA1;
  input CEA2;
  input CEA3;
  input CEA4;
  input CEB;
  input CEB1;
  input CEB2;
  input CEB3;
  input CEB4;
  input CECONCAT;
  input CECONCAT3;
  input CECONCAT4;
  input CECONCAT5;
  input CEC;
  input CEC1;
  input CEC2;
  input CEC3;
  input CEC4;
  input CEC5;
  input CEM;
  input CEP;
  input CESEL;
  input CESEL1;
  input CESEL2;
  input CESEL3;
  input CESEL4;
  input CESEL5;
  input SCLRD;
  input SCLRA;
  input SCLRB;
  input SCLRCONCAT;
  input SCLRC;
  input SCLRM;
  input SCLRP;
  input SCLRSEL;

  wire [14:0]A;
  wire [29:0]ACIN;
  wire [29:0]ACOUT;
  wire [14:0]B;
  wire [17:0]BCIN;
  wire [17:0]BCOUT;
  wire [14:0]C;
  wire CARRYCASCIN;
  wire CARRYCASCOUT;
  wire CARRYIN;
  wire CARRYOUT;
  wire CE;
  wire CEA;
  wire CEA1;
  wire CEA2;
  wire CEA3;
  wire CEA4;
  wire CEB;
  wire CEB1;
  wire CEB2;
  wire CEB3;
  wire CEB4;
  wire CEC;
  wire CEC1;
  wire CEC2;
  wire CEC3;
  wire CEC4;
  wire CEC5;
  wire CECONCAT;
  wire CECONCAT3;
  wire CECONCAT4;
  wire CECONCAT5;
  wire CED;
  wire CED1;
  wire CED2;
  wire CED3;
  wire CEM;
  wire CEP;
  wire CESEL;
  wire CESEL1;
  wire CESEL2;
  wire CESEL3;
  wire CESEL4;
  wire CESEL5;
  wire CLK;
  wire [47:0]CONCAT;
  wire [14:0]D;
  wire [30:0]P;
  wire [47:0]PCIN;
  wire [47:0]PCOUT;
  wire SCLR;
  wire SCLRA;
  wire SCLRB;
  wire SCLRC;
  wire SCLRCONCAT;
  wire SCLRD;
  wire SCLRM;
  wire SCLRP;
  wire SCLRSEL;
  wire [1:0]SEL;

  (* C_A_WIDTH = "15" *) 
  (* C_B_WIDTH = "15" *) 
  (* C_CONCAT_WIDTH = "48" *) 
  (* C_CONSTANT_1 = "1" *) 
  (* C_C_WIDTH = "15" *) 
  (* C_D_WIDTH = "15" *) 
  (* C_HAS_A = "1" *) 
  (* C_HAS_ACIN = "0" *) 
  (* C_HAS_ACOUT = "0" *) 
  (* C_HAS_B = "1" *) 
  (* C_HAS_BCIN = "0" *) 
  (* C_HAS_BCOUT = "0" *) 
  (* C_HAS_C = "1" *) 
  (* C_HAS_CARRYCASCIN = "0" *) 
  (* C_HAS_CARRYCASCOUT = "0" *) 
  (* C_HAS_CARRYIN = "0" *) 
  (* C_HAS_CARRYOUT = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_CEA = "0" *) 
  (* C_HAS_CEB = "0" *) 
  (* C_HAS_CEC = "0" *) 
  (* C_HAS_CECONCAT = "0" *) 
  (* C_HAS_CED = "0" *) 
  (* C_HAS_CEM = "0" *) 
  (* C_HAS_CEP = "0" *) 
  (* C_HAS_CESEL = "0" *) 
  (* C_HAS_CONCAT = "0" *) 
  (* C_HAS_D = "1" *) 
  (* C_HAS_INDEP_CE = "0" *) 
  (* C_HAS_INDEP_SCLR = "0" *) 
  (* C_HAS_PCIN = "0" *) 
  (* C_HAS_PCOUT = "0" *) 
  (* C_HAS_SCLR = "0" *) 
  (* C_HAS_SCLRA = "0" *) 
  (* C_HAS_SCLRB = "0" *) 
  (* C_HAS_SCLRC = "0" *) 
  (* C_HAS_SCLRCONCAT = "0" *) 
  (* C_HAS_SCLRD = "0" *) 
  (* C_HAS_SCLRM = "0" *) 
  (* C_HAS_SCLRP = "0" *) 
  (* C_HAS_SCLRSEL = "0" *) 
  (* C_LATENCY = "80" *) 
  (* C_MODEL_TYPE = "0" *) 
  (* C_OPMODES = "000000000011010100000000,000001100011010100000000,000100100000010100001001,000100100000010100011000" *) 
  (* C_P_LSB = "0" *) 
  (* C_P_MSB = "30" *) 
  (* C_REG_CONFIG = "00000000000000000000000011100000" *) 
  (* C_SEL_WIDTH = "2" *) 
  (* C_TEST_CORE = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  xbip_dsp48_macro_0_xbip_dsp48_macro_v3_0_10_viv i_synth
       (.A(A),
        .ACIN(ACIN),
        .ACOUT(ACOUT),
        .B(B),
        .BCIN(BCIN),
        .BCOUT(BCOUT),
        .C(C),
        .CARRYCASCIN(CARRYCASCIN),
        .CARRYCASCOUT(CARRYCASCOUT),
        .CARRYIN(CARRYIN),
        .CARRYOUT(CARRYOUT),
        .CE(CE),
        .CEA(CEA),
        .CEA1(CEA1),
        .CEA2(CEA2),
        .CEA3(CEA3),
        .CEA4(CEA4),
        .CEB(CEB),
        .CEB1(CEB1),
        .CEB2(CEB2),
        .CEB3(CEB3),
        .CEB4(CEB4),
        .CEC(CEC),
        .CEC1(CEC1),
        .CEC2(CEC2),
        .CEC3(CEC3),
        .CEC4(CEC4),
        .CEC5(CEC5),
        .CECONCAT(CECONCAT),
        .CECONCAT3(CECONCAT3),
        .CECONCAT4(CECONCAT4),
        .CECONCAT5(CECONCAT5),
        .CED(CED),
        .CED1(CED1),
        .CED2(CED2),
        .CED3(CED3),
        .CEM(CEM),
        .CEP(CEP),
        .CESEL(CESEL),
        .CESEL1(CESEL1),
        .CESEL2(CESEL2),
        .CESEL3(CESEL3),
        .CESEL4(CESEL4),
        .CESEL5(CESEL5),
        .CLK(CLK),
        .CONCAT(CONCAT),
        .D(D),
        .P(P),
        .PCIN(PCIN),
        .PCOUT(PCOUT),
        .SCLR(SCLR),
        .SCLRA(SCLRA),
        .SCLRB(SCLRB),
        .SCLRC(SCLRC),
        .SCLRCONCAT(SCLRCONCAT),
        .SCLRD(SCLRD),
        .SCLRM(SCLRM),
        .SCLRP(SCLRP),
        .SCLRSEL(SCLRSEL),
        .SEL(SEL));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2014"
`pragma protect key_keyowner = "Cadence Design Systems.", key_keyname= "cds_rsa_key", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 64)
`pragma protect key_block
VsinksLpJWI1tuaOI7h8aSORfn/+DW4FgGWyEDOqHNlVivfJQf+MdvTR8ppGqPOJph04UfQew3Tt
9UcXkhvcCQ==


`pragma protect key_keyowner = "Mentor Graphics Corporation", key_keyname= "MGC-VERIF-SIM-RSA-1", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 128)
`pragma protect key_block
c+q7wFKp4PHZ99AOUXOfirVj8vjzVgTcROZi67zAuw/5nj1fUNd8IrtLm017VkcF7WHeCEaKQOit
7blqlCcFByKHzQZW2lCOHhJ9lEeJxJj967u6BCbISZhlKVikQBA8fKRVVZn0WvcMZn77lmVL7JTc
D8KSr6wy9yJwkkV+ppg=


`pragma protect key_keyowner = "Xilinx", key_keyname= "xilinx_2014_03", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
W2UVrope1p5WH2sS/2M7d2v+U87r5bZ1kcQCK80etZcsJN7glyuCz7NAnFVTiQhwq2JxwCBoVOEf
8BNELEM0HOxMWOFqPzWztADNCxArYYKM7CGbUSiNCCD4bdpKHBPHGPYVs4ePAKJGoVYgB8JAz9cG
Aa8RBN5Qx71Y9FxO58FCXPFCc6UTW26PNiGdlVOGG182Blnfw2zmLnNc/DXqiUa/NQKsDHrDwxHR
XPsvWVIUh6+IU5hYZZJwEqWBcm4bj4I16etHiYIe+EPeftbKa6UcdBWIzYmW0Bz2WOn7tCADIUpM
PifKVu5RzyoJjNiGbp9Z3S9dpTJynoDuBvID9w==


`pragma protect key_keyowner = "Synopsys", key_keyname= "SNPS-VCS-RSA-1", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 128)
`pragma protect key_block
h6rZV2rYxkx1Ra2F0CM6473N9Mzbp8xIWRu0//VbQefhQbOMXtTVTxhCItdVdR4EfFsRZVI7+nt7
9KJ7Um1ycu0Gx2wyjgWOmLlY2v62OYdx4w7yId4HA35a4yo2J6/kKJYlM00NmVziarFDB7al9/de
EwEjHKg7DQl0oyrlbvw=


`pragma protect key_keyowner = "Aldec", key_keyname= "ALDEC15_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
bv4R6oBTTV/Ekm8xZ5sZQat0BLfpO8TeLbF1+Xcd6TrfhzW5K3nQ80+HK8qvK6o6zcyKypall82o
bEISra9NsvpO17A/MNcMY8Jvt4J+nlPv2hZqLiR4f/Tau55kV3j+FopH6wzcicrl672uRYGgNBB6
wPEhmpqGHrIloK11m124q5xZEHCZmz+16YsroAgM8nfdm7r8dBytwyF5338RSeK8MlbvBR8kYUFx
f30JLB2q9/nlc57jD1fhdTsLKIaxFI6L/hh4l+vWb3d2FG0fW1mQJnB0omomUYLkfezFp/WkmP+X
JoEz3xpGC/PExNVEwJnGKnFX4uSp2hZRTx46Wg==


`pragma protect key_keyowner = "ATRENTA", key_keyname= "ATR-SG-2015-RSA-3", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
LSNZAyyvsFlTnG6tGAEv7pRHmgtMyJkEsbP6DfPx7YLChIw7VTeSUXKqKiSxcdFMzbEH6PVN5OXU
TOzOe4LQSB4VrDpMHU1iWuuQK5hU6V+wT9+NKx1cCF2+4zfr2alMgIb9PGOgArGsXYvJBEEKTH7v
SQ2wXjEs8OBK/1ScP8hDVuAAHMTRDlfU4a9W50nqxIHdJOzL5EPbQa2W1W3sEyJ51s0yVcASBMwH
b+rBsOhU6NgQuKQ6DQj9VNNr7myYq7PN/TIdYKSzLOuFMm7bG7gu7rUs7LtIxQeSI2Z4K70PKGJF
OVJKu6LUG9jJJXt7UlnU74Siw0CA/SX0KpbOOw==


`pragma protect key_keyowner = "Mentor Graphics Corporation", key_keyname= "MGC-PREC-RSA", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
a5FRscv3K6TmLClcGdS7MkDRbgr9EwHf1K4jcTHT54sJuF5zHZxt0aWVBfv0zWcmvLm3h+3dCpUf
Cb0DVELCu6QOShPK7Nfn0vimymkV69NKnhsCqU7hj2tspuV/NAUgNWkyXTXGjWwtmQOLscx0xwn6
4sWXivPwoXcpW5Hh/ReSvV5ZRiY18nR9ZUq22ANFL2xEfYK2LQQaNWxpZP7bHsuBHaZDRdX2iW/U
j5yECB6ASSgLdaav3XbwYeUuhv4OsNuYDt8ui/40+mKaGkwn5SK1RLNcN3JFLXCuFipjj2g9Gb2G
h6t634fgYvpzj5ClJS8VDzScmxA9h6Dxw+BLWA==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
rXahPvdKTeEUDQKiOLiHxxE+WBrZXfXN6bjKp6HzZCgVgDo5VVid3tgu146LSN02MXhznoPdi5Ii
ulD7KvDoFH1alvKq1cxA2pOGez0aWqoWa2QGrf4QYpl/8iGWy4179P/cjBDwpzVwEC/q0SsZFUHo
jhkQkEsvOpvEjNHfL93rPmXtp5AwHJwH0NOdM4pqz7Ras/N9+Offxsv9NaE7+yt4q4dmITUbbJN+
balc3yV1+JvB5LPpwD9aF+8xFKLXNl8jBJ/OExj4D9BwwKoWB1Kph36PLdQDgviglX1NLjFQgZMb
X94nDs9QWqiXRN97j6SkJLL1oHJCkRUknlrSpg==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 7264)
`pragma protect data_block
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
PRa8eEPgM4iKL+MznrjiFxU4ZYITv0qpEw==
`pragma protect end_protected
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2014"
`pragma protect key_keyowner = "Cadence Design Systems.", key_keyname= "cds_rsa_key", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 64)
`pragma protect key_block
VsinksLpJWI1tuaOI7h8aSORfn/+DW4FgGWyEDOqHNlVivfJQf+MdvTR8ppGqPOJph04UfQew3Tt
9UcXkhvcCQ==


`pragma protect key_keyowner = "Mentor Graphics Corporation", key_keyname= "MGC-VERIF-SIM-RSA-1", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 128)
`pragma protect key_block
c+q7wFKp4PHZ99AOUXOfirVj8vjzVgTcROZi67zAuw/5nj1fUNd8IrtLm017VkcF7WHeCEaKQOit
7blqlCcFByKHzQZW2lCOHhJ9lEeJxJj967u6BCbISZhlKVikQBA8fKRVVZn0WvcMZn77lmVL7JTc
D8KSr6wy9yJwkkV+ppg=


`pragma protect key_keyowner = "Xilinx", key_keyname= "xilinx_2014_03", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
W2UVrope1p5WH2sS/2M7d2v+U87r5bZ1kcQCK80etZcsJN7glyuCz7NAnFVTiQhwq2JxwCBoVOEf
8BNELEM0HOxMWOFqPzWztADNCxArYYKM7CGbUSiNCCD4bdpKHBPHGPYVs4ePAKJGoVYgB8JAz9cG
Aa8RBN5Qx71Y9FxO58FCXPFCc6UTW26PNiGdlVOGG182Blnfw2zmLnNc/DXqiUa/NQKsDHrDwxHR
XPsvWVIUh6+IU5hYZZJwEqWBcm4bj4I16etHiYIe+EPeftbKa6UcdBWIzYmW0Bz2WOn7tCADIUpM
PifKVu5RzyoJjNiGbp9Z3S9dpTJynoDuBvID9w==


`pragma protect key_keyowner = "Synopsys", key_keyname= "SNPS-VCS-RSA-1", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 128)
`pragma protect key_block
h6rZV2rYxkx1Ra2F0CM6473N9Mzbp8xIWRu0//VbQefhQbOMXtTVTxhCItdVdR4EfFsRZVI7+nt7
9KJ7Um1ycu0Gx2wyjgWOmLlY2v62OYdx4w7yId4HA35a4yo2J6/kKJYlM00NmVziarFDB7al9/de
EwEjHKg7DQl0oyrlbvw=


`pragma protect key_keyowner = "Aldec", key_keyname= "ALDEC15_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
bv4R6oBTTV/Ekm8xZ5sZQat0BLfpO8TeLbF1+Xcd6TrfhzW5K3nQ80+HK8qvK6o6zcyKypall82o
bEISra9NsvpO17A/MNcMY8Jvt4J+nlPv2hZqLiR4f/Tau55kV3j+FopH6wzcicrl672uRYGgNBB6
wPEhmpqGHrIloK11m124q5xZEHCZmz+16YsroAgM8nfdm7r8dBytwyF5338RSeK8MlbvBR8kYUFx
f30JLB2q9/nlc57jD1fhdTsLKIaxFI6L/hh4l+vWb3d2FG0fW1mQJnB0omomUYLkfezFp/WkmP+X
JoEz3xpGC/PExNVEwJnGKnFX4uSp2hZRTx46Wg==


`pragma protect key_keyowner = "ATRENTA", key_keyname= "ATR-SG-2015-RSA-3", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
LSNZAyyvsFlTnG6tGAEv7pRHmgtMyJkEsbP6DfPx7YLChIw7VTeSUXKqKiSxcdFMzbEH6PVN5OXU
TOzOe4LQSB4VrDpMHU1iWuuQK5hU6V+wT9+NKx1cCF2+4zfr2alMgIb9PGOgArGsXYvJBEEKTH7v
SQ2wXjEs8OBK/1ScP8hDVuAAHMTRDlfU4a9W50nqxIHdJOzL5EPbQa2W1W3sEyJ51s0yVcASBMwH
b+rBsOhU6NgQuKQ6DQj9VNNr7myYq7PN/TIdYKSzLOuFMm7bG7gu7rUs7LtIxQeSI2Z4K70PKGJF
OVJKu6LUG9jJJXt7UlnU74Siw0CA/SX0KpbOOw==


`pragma protect key_keyowner = "Mentor Graphics Corporation", key_keyname= "MGC-PREC-RSA", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
a5FRscv3K6TmLClcGdS7MkDRbgr9EwHf1K4jcTHT54sJuF5zHZxt0aWVBfv0zWcmvLm3h+3dCpUf
Cb0DVELCu6QOShPK7Nfn0vimymkV69NKnhsCqU7hj2tspuV/NAUgNWkyXTXGjWwtmQOLscx0xwn6
4sWXivPwoXcpW5Hh/ReSvV5ZRiY18nR9ZUq22ANFL2xEfYK2LQQaNWxpZP7bHsuBHaZDRdX2iW/U
j5yECB6ASSgLdaav3XbwYeUuhv4OsNuYDt8ui/40+mKaGkwn5SK1RLNcN3JFLXCuFipjj2g9Gb2G
h6t634fgYvpzj5ClJS8VDzScmxA9h6Dxw+BLWA==


`pragma protect key_keyowner = "Synplicity", key_keyname= "SYNP05_001", key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 256)
`pragma protect key_block
rXahPvdKTeEUDQKiOLiHxxE+WBrZXfXN6bjKp6HzZCgVgDo5VVid3tgu146LSN02MXhznoPdi5Ii
ulD7KvDoFH1alvKq1cxA2pOGez0aWqoWa2QGrf4QYpl/8iGWy4179P/cjBDwpzVwEC/q0SsZFUHo
jhkQkEsvOpvEjNHfL93rPmXtp5AwHJwH0NOdM4pqz7Ras/N9+Offxsv9NaE7+yt4q4dmITUbbJN+
balc3yV1+JvB5LPpwD9aF+8xFKLXNl8jBJ/OExj4D9BwwKoWB1Kph36PLdQDgviglX1NLjFQgZMb
X94nDs9QWqiXRN97j6SkJLL1oHJCkRUknlrSpg==


`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 4960)
`pragma protect data_block
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
Yg==
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
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

    assign (weak1, weak0) GSR = GSR_int;
    assign (weak1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

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

endmodule
`endif
