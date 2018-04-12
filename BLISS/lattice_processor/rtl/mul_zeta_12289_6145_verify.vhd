
-- ==============================================================
-- RTL generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC
-- Version: 2013.4
-- Copyright (C) 2013 Xilinx Inc. All rights reserved.
-- 
-- ===========================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mul_zeta_12289_6145_verify is
port (
    ap_clk : IN STD_LOGIC;
    ap_rst : IN STD_LOGIC;
    data_in_V : IN STD_LOGIC_VECTOR (13 downto 0);
    c_reg_V : IN STD_LOGIC_VECTOR (0 downto 0);
    ap_return : OUT STD_LOGIC_VECTOR (14 downto 0) );
end;


architecture behav of mul_zeta_12289_6145_verify is 
    attribute CORE_GENERATION_INFO : STRING;
    attribute CORE_GENERATION_INFO of behav : architecture is
    "mul_zeta_12289_6145_verify,hls_ip_2013_4,{HLS_INPUT_TYPE=cxx,HLS_INPUT_FLOAT=0,HLS_INPUT_FIXED=1,HLS_INPUT_PART=xc7z045ffg900-1,HLS_INPUT_CLOCK=10.000000,HLS_INPUT_ARCH=pipeline,HLS_SYN_CLOCK=8.469500,HLS_SYN_LAT=4,HLS_SYN_TPT=1,HLS_SYN_MEM=0,HLS_SYN_DSP=0,HLS_SYN_FF=0,HLS_SYN_LUT=0}";
    constant ap_true : BOOLEAN := true;
    constant ap_const_lv1_0 : STD_LOGIC_VECTOR (0 downto 0) := "0";
    constant ap_const_lv12_0 : STD_LOGIC_VECTOR (11 downto 0) := "000000000000";
    constant ap_const_lv13_0 : STD_LOGIC_VECTOR (12 downto 0) := "0000000000000";
    constant ap_const_lv28_3001 : STD_LOGIC_VECTOR (27 downto 0) := "0000000000000011000000000001";
    constant ap_const_lv4_0 : STD_LOGIC_VECTOR (3 downto 0) := "0000";
    constant ap_const_lv6_0 : STD_LOGIC_VECTOR (5 downto 0) := "000000";
    constant ap_const_lv8_0 : STD_LOGIC_VECTOR (7 downto 0) := "00000000";
    constant ap_const_lv10_0 : STD_LOGIC_VECTOR (9 downto 0) := "0000000000";
    constant ap_const_lv14_0 : STD_LOGIC_VECTOR (13 downto 0) := "00000000000000";
    constant ap_const_lv32_1D : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000011101";
    constant ap_const_lv32_2A : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000101010";
    constant ap_const_lv28_6001 : STD_LOGIC_VECTOR (27 downto 0) := "0000000000000110000000000001";
    constant ap_const_lv28_1FFE : STD_LOGIC_VECTOR (27 downto 0) := "0000000000000001111111111110";
    constant ap_const_logic_1 : STD_LOGIC := '1';
    constant ap_const_logic_0 : STD_LOGIC := '0';

    signal mul_res_V_2_fu_149_p3 : STD_LOGIC_VECTOR (27 downto 0);
    signal mul_res_V_2_reg_381 : STD_LOGIC_VECTOR (27 downto 0);
    signal ap_reg_ppstg_mul_res_V_2_reg_381_pp0_it1 : STD_LOGIC_VECTOR (27 downto 0);
    signal ap_reg_ppstg_mul_res_V_2_reg_381_pp0_it2 : STD_LOGIC_VECTOR (27 downto 0);
    signal r_V_6_fu_192_p2 : STD_LOGIC_VECTOR (32 downto 0);
    signal r_V_6_reg_394 : STD_LOGIC_VECTOR (32 downto 0);
    signal r_V_12_fu_254_p2 : STD_LOGIC_VECTOR (38 downto 0);
    signal r_V_12_reg_399 : STD_LOGIC_VECTOR (38 downto 0);
    signal tmp_fu_301_p4 : STD_LOGIC_VECTOR (13 downto 0);
    signal tmp_reg_404 : STD_LOGIC_VECTOR (13 downto 0);
    signal p_neg_i_fu_323_p2 : STD_LOGIC_VECTOR (27 downto 0);
    signal p_neg_i_reg_410 : STD_LOGIC_VECTOR (27 downto 0);
    signal r_V_fu_95_p3 : STD_LOGIC_VECTOR (14 downto 0);
    signal r_V_1_fu_107_p3 : STD_LOGIC_VECTOR (25 downto 0);
    signal r_V_2_fu_119_p3 : STD_LOGIC_VECTOR (26 downto 0);
    signal r_V_2_cast_fu_127_p1 : STD_LOGIC_VECTOR (27 downto 0);
    signal r_V_cast_fu_103_p1 : STD_LOGIC_VECTOR (27 downto 0);
    signal tmp1_fu_131_p2 : STD_LOGIC_VECTOR (27 downto 0);
    signal r_V_1_cast_fu_115_p1 : STD_LOGIC_VECTOR (27 downto 0);
    signal mul_res_V_fu_137_p2 : STD_LOGIC_VECTOR (27 downto 0);
    signal mul_res_V_1_fu_143_p2 : STD_LOGIC_VECTOR (27 downto 0);
    signal r_V_3_fu_157_p3 : STD_LOGIC_VECTOR (28 downto 0);
    signal rhs_V_cast_fu_167_p1 : STD_LOGIC_VECTOR (29 downto 0);
    signal lhs_V_cast_fu_164_p1 : STD_LOGIC_VECTOR (29 downto 0);
    signal r_V_4_fu_171_p2 : STD_LOGIC_VECTOR (29 downto 0);
    signal r_V_5_fu_177_p3 : STD_LOGIC_VECTOR (31 downto 0);
    signal lhs_V_1_cast_fu_184_p1 : STD_LOGIC_VECTOR (32 downto 0);
    signal rhs_V_1_cast_fu_188_p1 : STD_LOGIC_VECTOR (32 downto 0);
    signal r_V_7_fu_198_p3 : STD_LOGIC_VECTOR (33 downto 0);
    signal lhs_V_2_cast_fu_205_p1 : STD_LOGIC_VECTOR (34 downto 0);
    signal rhs_V_2_cast_fu_208_p1 : STD_LOGIC_VECTOR (34 downto 0);
    signal r_V_8_fu_212_p2 : STD_LOGIC_VECTOR (34 downto 0);
    signal r_V_9_fu_218_p3 : STD_LOGIC_VECTOR (35 downto 0);
    signal lhs_V_3_cast_fu_225_p1 : STD_LOGIC_VECTOR (36 downto 0);
    signal rhs_V_3_cast_fu_229_p1 : STD_LOGIC_VECTOR (36 downto 0);
    signal r_V_10_fu_233_p2 : STD_LOGIC_VECTOR (36 downto 0);
    signal r_V_11_fu_239_p3 : STD_LOGIC_VECTOR (37 downto 0);
    signal lhs_V_4_cast_fu_246_p1 : STD_LOGIC_VECTOR (38 downto 0);
    signal rhs_V_4_cast_fu_250_p1 : STD_LOGIC_VECTOR (38 downto 0);
    signal r_V_13_fu_260_p3 : STD_LOGIC_VECTOR (39 downto 0);
    signal lhs_V_5_cast_fu_267_p1 : STD_LOGIC_VECTOR (40 downto 0);
    signal rhs_V_5_cast_fu_270_p1 : STD_LOGIC_VECTOR (40 downto 0);
    signal r_V_14_fu_274_p2 : STD_LOGIC_VECTOR (40 downto 0);
    signal r_V_15_fu_280_p3 : STD_LOGIC_VECTOR (41 downto 0);
    signal lhs_V_6_cast_fu_287_p1 : STD_LOGIC_VECTOR (42 downto 0);
    signal rhs_V_6_cast_fu_291_p1 : STD_LOGIC_VECTOR (42 downto 0);
    signal r_V_16_fu_295_p2 : STD_LOGIC_VECTOR (42 downto 0);
    signal phitmp2_i_fu_311_p3 : STD_LOGIC_VECTOR (14 downto 0);
    signal phitmp2_i_cast_fu_319_p1 : STD_LOGIC_VECTOR (27 downto 0);
    signal phitmp_i_fu_328_p3 : STD_LOGIC_VECTOR (26 downto 0);
    signal phitmp1_i_fu_339_p3 : STD_LOGIC_VECTOR (27 downto 0);
    signal p_neg1_i_fu_346_p2 : STD_LOGIC_VECTOR (27 downto 0);
    signal phitmp_i_cast_fu_335_p1 : STD_LOGIC_VECTOR (27 downto 0);
    signal tmp_1_i_fu_351_p2 : STD_LOGIC_VECTOR (27 downto 0);
    signal tmp_2_i_fu_357_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal p_i_fu_363_p2 : STD_LOGIC_VECTOR (27 downto 0);
    signal tmp_3_i_fu_369_p3 : STD_LOGIC_VECTOR (27 downto 0);


begin




    -- assign process. --
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if ((ap_true = ap_true)) then
                ap_reg_ppstg_mul_res_V_2_reg_381_pp0_it1 <= mul_res_V_2_reg_381;
                ap_reg_ppstg_mul_res_V_2_reg_381_pp0_it2 <= ap_reg_ppstg_mul_res_V_2_reg_381_pp0_it1;
                mul_res_V_2_reg_381 <= mul_res_V_2_fu_149_p3;
                p_neg_i_reg_410 <= p_neg_i_fu_323_p2;
                r_V_12_reg_399 <= r_V_12_fu_254_p2;
                r_V_6_reg_394 <= r_V_6_fu_192_p2;
                tmp_reg_404 <= r_V_16_fu_295_p2(42 downto 29);
            end if;
        end if;
    end process;
    ap_return <= tmp_3_i_fu_369_p3(15 - 1 downto 0);
    lhs_V_1_cast_fu_184_p1 <= std_logic_vector(resize(unsigned(r_V_4_fu_171_p2),33));
    lhs_V_2_cast_fu_205_p1 <= std_logic_vector(resize(unsigned(r_V_6_reg_394),35));
    lhs_V_3_cast_fu_225_p1 <= std_logic_vector(resize(unsigned(r_V_8_fu_212_p2),37));
    lhs_V_4_cast_fu_246_p1 <= std_logic_vector(resize(unsigned(r_V_10_fu_233_p2),39));
    lhs_V_5_cast_fu_267_p1 <= std_logic_vector(resize(unsigned(r_V_12_reg_399),41));
    lhs_V_6_cast_fu_287_p1 <= std_logic_vector(resize(unsigned(r_V_14_fu_274_p2),43));
    lhs_V_cast_fu_164_p1 <= std_logic_vector(resize(unsigned(mul_res_V_2_reg_381),30));
    mul_res_V_1_fu_143_p2 <= std_logic_vector(unsigned(mul_res_V_fu_137_p2) + unsigned(ap_const_lv28_3001));
    mul_res_V_2_fu_149_p3 <= 
        mul_res_V_1_fu_143_p2 when (c_reg_V(0) = '1') else 
        mul_res_V_fu_137_p2;
    mul_res_V_fu_137_p2 <= std_logic_vector(unsigned(tmp1_fu_131_p2) + unsigned(r_V_1_cast_fu_115_p1));
    p_i_fu_363_p2 <= std_logic_vector(unsigned(tmp_1_i_fu_351_p2) + unsigned(ap_const_lv28_1FFE));
    p_neg1_i_fu_346_p2 <= std_logic_vector(unsigned(p_neg_i_reg_410) - unsigned(phitmp1_i_fu_339_p3));
    p_neg_i_fu_323_p2 <= std_logic_vector(unsigned(ap_reg_ppstg_mul_res_V_2_reg_381_pp0_it2) - unsigned(phitmp2_i_cast_fu_319_p1));
    phitmp1_i_fu_339_p3 <= (tmp_reg_404 & ap_const_lv14_0);
    phitmp2_i_cast_fu_319_p1 <= std_logic_vector(resize(unsigned(phitmp2_i_fu_311_p3),28));
    phitmp2_i_fu_311_p3 <= (tmp_fu_301_p4 & ap_const_lv1_0);
    phitmp_i_cast_fu_335_p1 <= std_logic_vector(resize(unsigned(phitmp_i_fu_328_p3),28));
    phitmp_i_fu_328_p3 <= (tmp_reg_404 & ap_const_lv13_0);
    r_V_10_fu_233_p2 <= std_logic_vector(unsigned(lhs_V_3_cast_fu_225_p1) + unsigned(rhs_V_3_cast_fu_229_p1));
    r_V_11_fu_239_p3 <= (ap_reg_ppstg_mul_res_V_2_reg_381_pp0_it1 & ap_const_lv10_0);
    r_V_12_fu_254_p2 <= std_logic_vector(unsigned(lhs_V_4_cast_fu_246_p1) + unsigned(rhs_V_4_cast_fu_250_p1));
    r_V_13_fu_260_p3 <= (ap_reg_ppstg_mul_res_V_2_reg_381_pp0_it2 & ap_const_lv12_0);
    r_V_14_fu_274_p2 <= std_logic_vector(unsigned(lhs_V_5_cast_fu_267_p1) + unsigned(rhs_V_5_cast_fu_270_p1));
    r_V_15_fu_280_p3 <= (ap_reg_ppstg_mul_res_V_2_reg_381_pp0_it2 & ap_const_lv14_0);
    r_V_16_fu_295_p2 <= std_logic_vector(unsigned(lhs_V_6_cast_fu_287_p1) + unsigned(rhs_V_6_cast_fu_291_p1));
    r_V_1_cast_fu_115_p1 <= std_logic_vector(resize(unsigned(r_V_1_fu_107_p3),28));
    r_V_1_fu_107_p3 <= (data_in_V & ap_const_lv12_0);
    r_V_2_cast_fu_127_p1 <= std_logic_vector(resize(unsigned(r_V_2_fu_119_p3),28));
    r_V_2_fu_119_p3 <= (data_in_V & ap_const_lv13_0);
    r_V_3_fu_157_p3 <= (mul_res_V_2_reg_381 & ap_const_lv1_0);
    r_V_4_fu_171_p2 <= std_logic_vector(unsigned(rhs_V_cast_fu_167_p1) + unsigned(lhs_V_cast_fu_164_p1));
    r_V_5_fu_177_p3 <= (mul_res_V_2_reg_381 & ap_const_lv4_0);
    r_V_6_fu_192_p2 <= std_logic_vector(unsigned(lhs_V_1_cast_fu_184_p1) + unsigned(rhs_V_1_cast_fu_188_p1));
    r_V_7_fu_198_p3 <= (ap_reg_ppstg_mul_res_V_2_reg_381_pp0_it1 & ap_const_lv6_0);
    r_V_8_fu_212_p2 <= std_logic_vector(unsigned(lhs_V_2_cast_fu_205_p1) + unsigned(rhs_V_2_cast_fu_208_p1));
    r_V_9_fu_218_p3 <= (ap_reg_ppstg_mul_res_V_2_reg_381_pp0_it1 & ap_const_lv8_0);
    r_V_cast_fu_103_p1 <= std_logic_vector(resize(unsigned(r_V_fu_95_p3),28));
    r_V_fu_95_p3 <= (data_in_V & ap_const_lv1_0);
    rhs_V_1_cast_fu_188_p1 <= std_logic_vector(resize(unsigned(r_V_5_fu_177_p3),33));
    rhs_V_2_cast_fu_208_p1 <= std_logic_vector(resize(unsigned(r_V_7_fu_198_p3),35));
    rhs_V_3_cast_fu_229_p1 <= std_logic_vector(resize(unsigned(r_V_9_fu_218_p3),37));
    rhs_V_4_cast_fu_250_p1 <= std_logic_vector(resize(unsigned(r_V_11_fu_239_p3),39));
    rhs_V_5_cast_fu_270_p1 <= std_logic_vector(resize(unsigned(r_V_13_fu_260_p3),41));
    rhs_V_6_cast_fu_291_p1 <= std_logic_vector(resize(unsigned(r_V_15_fu_280_p3),43));
    rhs_V_cast_fu_167_p1 <= std_logic_vector(resize(unsigned(r_V_3_fu_157_p3),30));
    tmp1_fu_131_p2 <= std_logic_vector(unsigned(r_V_2_cast_fu_127_p1) + unsigned(r_V_cast_fu_103_p1));
    tmp_1_i_fu_351_p2 <= std_logic_vector(unsigned(p_neg1_i_fu_346_p2) - unsigned(phitmp_i_cast_fu_335_p1));
    tmp_2_i_fu_357_p2 <= "1" when (unsigned(tmp_1_i_fu_351_p2) > unsigned(ap_const_lv28_6001)) else "0";
    tmp_3_i_fu_369_p3 <= 
        p_i_fu_363_p2 when (tmp_2_i_fu_357_p2(0) = '1') else 
        tmp_1_i_fu_351_p2;
    tmp_fu_301_p4 <= r_V_16_fu_295_p2(42 downto 29);
end behav;