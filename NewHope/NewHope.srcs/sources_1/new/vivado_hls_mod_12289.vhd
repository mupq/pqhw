-- ==============================================================
-- RTL generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC
-- Version: 2013.4
-- Copyright (C) 2013 Xilinx Inc. All rights reserved.
-- 
-- ===========================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity vivado_hls_mod_12289 is
port (
    ap_clk : IN STD_LOGIC;
    ap_rst : IN STD_LOGIC;
    val_V : IN STD_LOGIC_VECTOR (27 downto 0);
    ap_return : OUT STD_LOGIC_VECTOR (13 downto 0) );
end;


architecture behav of vivado_hls_mod_12289 is 
    attribute CORE_GENERATION_INFO : STRING;
    attribute CORE_GENERATION_INFO of behav : architecture is
    "vivado_hls_mod_12289,hls_ip_2013_4,{HLS_INPUT_TYPE=cxx,HLS_INPUT_FLOAT=0,HLS_INPUT_FIXED=1,HLS_INPUT_PART=xc7z020clg484-1,HLS_INPUT_CLOCK=10.000000,HLS_INPUT_ARCH=pipeline,HLS_SYN_CLOCK=8.469500,HLS_SYN_LAT=3,HLS_SYN_TPT=1,HLS_SYN_MEM=0,HLS_SYN_DSP=0,HLS_SYN_FF=0,HLS_SYN_LUT=0}";
    constant ap_true : BOOLEAN := true;
    constant ap_const_lv1_0 : STD_LOGIC_VECTOR (0 downto 0) := "0";
    constant ap_const_lv2_0 : STD_LOGIC_VECTOR (1 downto 0) := "00";
    constant ap_const_lv5_0 : STD_LOGIC_VECTOR (4 downto 0) := "00000";
    constant ap_const_lv7_0 : STD_LOGIC_VECTOR (6 downto 0) := "0000000";
    constant ap_const_lv9_0 : STD_LOGIC_VECTOR (8 downto 0) := "000000000";
    constant ap_const_lv11_0 : STD_LOGIC_VECTOR (10 downto 0) := "00000000000";
    constant ap_const_lv13_0 : STD_LOGIC_VECTOR (12 downto 0) := "0000000000000";
    constant ap_const_lv15_0 : STD_LOGIC_VECTOR (14 downto 0) := "000000000000000";
    constant ap_const_lv32_1D : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000011101";
    constant ap_const_lv32_2B : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000101011";
    constant ap_const_lv12_0 : STD_LOGIC_VECTOR (11 downto 0) := "000000000000";
    constant ap_const_lv28_3000 : STD_LOGIC_VECTOR (27 downto 0) := "0000000000000011000000000000";
    constant ap_const_lv28_FFF : STD_LOGIC_VECTOR (27 downto 0) := "0000000000000000111111111111";
    constant ap_const_logic_1 : STD_LOGIC := '1';
    constant ap_const_logic_0 : STD_LOGIC := '0';

    signal val_V_read_reg_310 : STD_LOGIC_VECTOR (27 downto 0);
    signal ap_reg_ppstg_val_V_read_reg_310_pp0_it1 : STD_LOGIC_VECTOR (27 downto 0);
    signal r_V_4_fu_129_p2 : STD_LOGIC_VECTOR (33 downto 0);
    signal r_V_4_reg_320 : STD_LOGIC_VECTOR (33 downto 0);
    signal r_V_10_fu_191_p2 : STD_LOGIC_VECTOR (39 downto 0);
    signal r_V_10_reg_325 : STD_LOGIC_VECTOR (39 downto 0);
    signal tmp_fu_238_p4 : STD_LOGIC_VECTOR (14 downto 0);
    signal tmp_reg_330 : STD_LOGIC_VECTOR (14 downto 0);
    signal p_neg_fu_252_p2 : STD_LOGIC_VECTOR (27 downto 0);
    signal p_neg_reg_336 : STD_LOGIC_VECTOR (27 downto 0);
    signal r_V_fu_83_p3 : STD_LOGIC_VECTOR (28 downto 0);
    signal r_V_1_fu_91_p3 : STD_LOGIC_VECTOR (29 downto 0);
    signal lhs_V_cast_fu_99_p1 : STD_LOGIC_VECTOR (30 downto 0);
    signal rhs_V_cast_fu_103_p1 : STD_LOGIC_VECTOR (30 downto 0);
    signal r_V_2_fu_107_p2 : STD_LOGIC_VECTOR (30 downto 0);
    signal r_V_3_fu_113_p3 : STD_LOGIC_VECTOR (32 downto 0);
    signal lhs_V_1_cast_fu_121_p1 : STD_LOGIC_VECTOR (33 downto 0);
    signal rhs_V_1_cast_fu_125_p1 : STD_LOGIC_VECTOR (33 downto 0);
    signal r_V_5_fu_135_p3 : STD_LOGIC_VECTOR (34 downto 0);
    signal lhs_V_2_cast_fu_142_p1 : STD_LOGIC_VECTOR (35 downto 0);
    signal rhs_V_2_cast_fu_145_p1 : STD_LOGIC_VECTOR (35 downto 0);
    signal r_V_6_fu_149_p2 : STD_LOGIC_VECTOR (35 downto 0);
    signal r_V_7_fu_155_p3 : STD_LOGIC_VECTOR (36 downto 0);
    signal lhs_V_3_cast_fu_162_p1 : STD_LOGIC_VECTOR (37 downto 0);
    signal rhs_V_3_cast_fu_166_p1 : STD_LOGIC_VECTOR (37 downto 0);
    signal r_V_8_fu_170_p2 : STD_LOGIC_VECTOR (37 downto 0);
    signal r_V_9_fu_176_p3 : STD_LOGIC_VECTOR (38 downto 0);
    signal lhs_V_4_cast_fu_183_p1 : STD_LOGIC_VECTOR (39 downto 0);
    signal rhs_V_4_cast_fu_187_p1 : STD_LOGIC_VECTOR (39 downto 0);
    signal r_V_11_fu_197_p3 : STD_LOGIC_VECTOR (40 downto 0);
    signal lhs_V_5_cast_fu_204_p1 : STD_LOGIC_VECTOR (41 downto 0);
    signal rhs_V_5_cast_fu_207_p1 : STD_LOGIC_VECTOR (41 downto 0);
    signal r_V_13_fu_217_p3 : STD_LOGIC_VECTOR (42 downto 0);
    signal r_V_12_fu_211_p2 : STD_LOGIC_VECTOR (41 downto 0);
    signal lhs_V_6_cast_fu_228_p1 : STD_LOGIC_VECTOR (43 downto 0);
    signal r_V_13_cast_fu_224_p1 : STD_LOGIC_VECTOR (43 downto 0);
    signal r_V_14_fu_232_p2 : STD_LOGIC_VECTOR (43 downto 0);
    signal phitmp_fu_248_p1 : STD_LOGIC_VECTOR (27 downto 0);
    signal phitmp1_fu_257_p3 : STD_LOGIC_VECTOR (26 downto 0);
    signal phitmp2_fu_268_p3 : STD_LOGIC_VECTOR (27 downto 0);
    signal p_neg1_fu_275_p2 : STD_LOGIC_VECTOR (27 downto 0);
    signal phitmp1_cast_fu_264_p1 : STD_LOGIC_VECTOR (27 downto 0);
    signal tmp_5_fu_280_p2 : STD_LOGIC_VECTOR (27 downto 0);
    signal tmp_6_fu_286_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal p_s_fu_292_p2 : STD_LOGIC_VECTOR (27 downto 0);
    signal tmp_7_fu_298_p3 : STD_LOGIC_VECTOR (27 downto 0);


begin




    -- assign process. --
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if ((ap_true = ap_true)) then
                ap_reg_ppstg_val_V_read_reg_310_pp0_it1 <= val_V_read_reg_310;
                p_neg_reg_336 <= p_neg_fu_252_p2;
                r_V_10_reg_325(1) <= r_V_10_fu_191_p2(1);
    r_V_10_reg_325(2) <= r_V_10_fu_191_p2(2);
    r_V_10_reg_325(3) <= r_V_10_fu_191_p2(3);
    r_V_10_reg_325(4) <= r_V_10_fu_191_p2(4);
    r_V_10_reg_325(5) <= r_V_10_fu_191_p2(5);
    r_V_10_reg_325(6) <= r_V_10_fu_191_p2(6);
    r_V_10_reg_325(7) <= r_V_10_fu_191_p2(7);
    r_V_10_reg_325(8) <= r_V_10_fu_191_p2(8);
    r_V_10_reg_325(9) <= r_V_10_fu_191_p2(9);
    r_V_10_reg_325(10) <= r_V_10_fu_191_p2(10);
    r_V_10_reg_325(11) <= r_V_10_fu_191_p2(11);
    r_V_10_reg_325(12) <= r_V_10_fu_191_p2(12);
    r_V_10_reg_325(13) <= r_V_10_fu_191_p2(13);
    r_V_10_reg_325(14) <= r_V_10_fu_191_p2(14);
    r_V_10_reg_325(15) <= r_V_10_fu_191_p2(15);
    r_V_10_reg_325(16) <= r_V_10_fu_191_p2(16);
    r_V_10_reg_325(17) <= r_V_10_fu_191_p2(17);
    r_V_10_reg_325(18) <= r_V_10_fu_191_p2(18);
    r_V_10_reg_325(19) <= r_V_10_fu_191_p2(19);
    r_V_10_reg_325(20) <= r_V_10_fu_191_p2(20);
    r_V_10_reg_325(21) <= r_V_10_fu_191_p2(21);
    r_V_10_reg_325(22) <= r_V_10_fu_191_p2(22);
    r_V_10_reg_325(23) <= r_V_10_fu_191_p2(23);
    r_V_10_reg_325(24) <= r_V_10_fu_191_p2(24);
    r_V_10_reg_325(25) <= r_V_10_fu_191_p2(25);
    r_V_10_reg_325(26) <= r_V_10_fu_191_p2(26);
    r_V_10_reg_325(27) <= r_V_10_fu_191_p2(27);
    r_V_10_reg_325(28) <= r_V_10_fu_191_p2(28);
    r_V_10_reg_325(29) <= r_V_10_fu_191_p2(29);
    r_V_10_reg_325(30) <= r_V_10_fu_191_p2(30);
    r_V_10_reg_325(31) <= r_V_10_fu_191_p2(31);
    r_V_10_reg_325(32) <= r_V_10_fu_191_p2(32);
    r_V_10_reg_325(33) <= r_V_10_fu_191_p2(33);
    r_V_10_reg_325(34) <= r_V_10_fu_191_p2(34);
    r_V_10_reg_325(35) <= r_V_10_fu_191_p2(35);
    r_V_10_reg_325(36) <= r_V_10_fu_191_p2(36);
    r_V_10_reg_325(37) <= r_V_10_fu_191_p2(37);
    r_V_10_reg_325(38) <= r_V_10_fu_191_p2(38);
    r_V_10_reg_325(39) <= r_V_10_fu_191_p2(39);
                r_V_4_reg_320(1) <= r_V_4_fu_129_p2(1);
    r_V_4_reg_320(2) <= r_V_4_fu_129_p2(2);
    r_V_4_reg_320(3) <= r_V_4_fu_129_p2(3);
    r_V_4_reg_320(4) <= r_V_4_fu_129_p2(4);
    r_V_4_reg_320(5) <= r_V_4_fu_129_p2(5);
    r_V_4_reg_320(6) <= r_V_4_fu_129_p2(6);
    r_V_4_reg_320(7) <= r_V_4_fu_129_p2(7);
    r_V_4_reg_320(8) <= r_V_4_fu_129_p2(8);
    r_V_4_reg_320(9) <= r_V_4_fu_129_p2(9);
    r_V_4_reg_320(10) <= r_V_4_fu_129_p2(10);
    r_V_4_reg_320(11) <= r_V_4_fu_129_p2(11);
    r_V_4_reg_320(12) <= r_V_4_fu_129_p2(12);
    r_V_4_reg_320(13) <= r_V_4_fu_129_p2(13);
    r_V_4_reg_320(14) <= r_V_4_fu_129_p2(14);
    r_V_4_reg_320(15) <= r_V_4_fu_129_p2(15);
    r_V_4_reg_320(16) <= r_V_4_fu_129_p2(16);
    r_V_4_reg_320(17) <= r_V_4_fu_129_p2(17);
    r_V_4_reg_320(18) <= r_V_4_fu_129_p2(18);
    r_V_4_reg_320(19) <= r_V_4_fu_129_p2(19);
    r_V_4_reg_320(20) <= r_V_4_fu_129_p2(20);
    r_V_4_reg_320(21) <= r_V_4_fu_129_p2(21);
    r_V_4_reg_320(22) <= r_V_4_fu_129_p2(22);
    r_V_4_reg_320(23) <= r_V_4_fu_129_p2(23);
    r_V_4_reg_320(24) <= r_V_4_fu_129_p2(24);
    r_V_4_reg_320(25) <= r_V_4_fu_129_p2(25);
    r_V_4_reg_320(26) <= r_V_4_fu_129_p2(26);
    r_V_4_reg_320(27) <= r_V_4_fu_129_p2(27);
    r_V_4_reg_320(28) <= r_V_4_fu_129_p2(28);
    r_V_4_reg_320(29) <= r_V_4_fu_129_p2(29);
    r_V_4_reg_320(30) <= r_V_4_fu_129_p2(30);
    r_V_4_reg_320(31) <= r_V_4_fu_129_p2(31);
    r_V_4_reg_320(32) <= r_V_4_fu_129_p2(32);
    r_V_4_reg_320(33) <= r_V_4_fu_129_p2(33);
                tmp_reg_330 <= r_V_14_fu_232_p2(43 downto 29);
                val_V_read_reg_310 <= val_V;
            end if;
        end if;
    end process;
    r_V_4_reg_320(0) <= '0';
    r_V_10_reg_325(0) <= '0';
    ap_return <= tmp_7_fu_298_p3(14 - 1 downto 0);
    lhs_V_1_cast_fu_121_p1 <= std_logic_vector(resize(unsigned(r_V_2_fu_107_p2),34));
    lhs_V_2_cast_fu_142_p1 <= std_logic_vector(resize(unsigned(r_V_4_reg_320),36));
    lhs_V_3_cast_fu_162_p1 <= std_logic_vector(resize(unsigned(r_V_6_fu_149_p2),38));
    lhs_V_4_cast_fu_183_p1 <= std_logic_vector(resize(unsigned(r_V_8_fu_170_p2),40));
    lhs_V_5_cast_fu_204_p1 <= std_logic_vector(resize(unsigned(r_V_10_reg_325),42));
    lhs_V_6_cast_fu_228_p1 <= std_logic_vector(resize(unsigned(r_V_12_fu_211_p2),44));
    lhs_V_cast_fu_99_p1 <= std_logic_vector(resize(unsigned(r_V_fu_83_p3),31));
    p_neg1_fu_275_p2 <= std_logic_vector(unsigned(p_neg_reg_336) - unsigned(phitmp2_fu_268_p3));
    p_neg_fu_252_p2 <= std_logic_vector(unsigned(ap_reg_ppstg_val_V_read_reg_310_pp0_it1) - unsigned(phitmp_fu_248_p1));
    p_s_fu_292_p2 <= std_logic_vector(unsigned(tmp_5_fu_280_p2) + unsigned(ap_const_lv28_FFF));
    phitmp1_cast_fu_264_p1 <= std_logic_vector(resize(unsigned(phitmp1_fu_257_p3),28));
    phitmp1_fu_257_p3 <= (tmp_reg_330 & ap_const_lv12_0);
    phitmp2_fu_268_p3 <= (tmp_reg_330 & ap_const_lv13_0);
    phitmp_fu_248_p1 <= std_logic_vector(resize(unsigned(tmp_fu_238_p4),28));
    r_V_10_fu_191_p2 <= std_logic_vector(unsigned(lhs_V_4_cast_fu_183_p1) + unsigned(rhs_V_4_cast_fu_187_p1));
    r_V_11_fu_197_p3 <= (ap_reg_ppstg_val_V_read_reg_310_pp0_it1 & ap_const_lv13_0);
    r_V_12_fu_211_p2 <= std_logic_vector(unsigned(lhs_V_5_cast_fu_204_p1) + unsigned(rhs_V_5_cast_fu_207_p1));
    r_V_13_cast_fu_224_p1 <= std_logic_vector(resize(unsigned(r_V_13_fu_217_p3),44));
    r_V_13_fu_217_p3 <= (ap_reg_ppstg_val_V_read_reg_310_pp0_it1 & ap_const_lv15_0);
    r_V_14_fu_232_p2 <= std_logic_vector(unsigned(lhs_V_6_cast_fu_228_p1) + unsigned(r_V_13_cast_fu_224_p1));
    r_V_1_fu_91_p3 <= (val_V & ap_const_lv2_0);
    r_V_2_fu_107_p2 <= std_logic_vector(unsigned(lhs_V_cast_fu_99_p1) + unsigned(rhs_V_cast_fu_103_p1));
    r_V_3_fu_113_p3 <= (val_V & ap_const_lv5_0);
    r_V_4_fu_129_p2 <= std_logic_vector(unsigned(lhs_V_1_cast_fu_121_p1) + unsigned(rhs_V_1_cast_fu_125_p1));
    r_V_5_fu_135_p3 <= (val_V_read_reg_310 & ap_const_lv7_0);
    r_V_6_fu_149_p2 <= std_logic_vector(unsigned(lhs_V_2_cast_fu_142_p1) + unsigned(rhs_V_2_cast_fu_145_p1));
    r_V_7_fu_155_p3 <= (val_V_read_reg_310 & ap_const_lv9_0);
    r_V_8_fu_170_p2 <= std_logic_vector(unsigned(lhs_V_3_cast_fu_162_p1) + unsigned(rhs_V_3_cast_fu_166_p1));
    r_V_9_fu_176_p3 <= (val_V_read_reg_310 & ap_const_lv11_0);
    r_V_fu_83_p3 <= (val_V & ap_const_lv1_0);
    rhs_V_1_cast_fu_125_p1 <= std_logic_vector(resize(unsigned(r_V_3_fu_113_p3),34));
    rhs_V_2_cast_fu_145_p1 <= std_logic_vector(resize(unsigned(r_V_5_fu_135_p3),36));
    rhs_V_3_cast_fu_166_p1 <= std_logic_vector(resize(unsigned(r_V_7_fu_155_p3),38));
    rhs_V_4_cast_fu_187_p1 <= std_logic_vector(resize(unsigned(r_V_9_fu_176_p3),40));
    rhs_V_5_cast_fu_207_p1 <= std_logic_vector(resize(unsigned(r_V_11_fu_197_p3),42));
    rhs_V_cast_fu_103_p1 <= std_logic_vector(resize(unsigned(r_V_1_fu_91_p3),31));
    tmp_5_fu_280_p2 <= std_logic_vector(unsigned(p_neg1_fu_275_p2) - unsigned(phitmp1_cast_fu_264_p1));
    tmp_6_fu_286_p2 <= "1" when (unsigned(tmp_5_fu_280_p2) > unsigned(ap_const_lv28_3000)) else "0";
    tmp_7_fu_298_p3 <= 
        p_s_fu_292_p2 when (tmp_6_fu_286_p2(0) = '1') else 
        tmp_5_fu_280_p2;
    tmp_fu_238_p4 <= r_V_14_fu_232_p2(43 downto 29);
end behav;
