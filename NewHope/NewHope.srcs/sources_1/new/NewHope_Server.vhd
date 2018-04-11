--/****************************************************************************/
--Copyright (C) by Tobias Oder and the Chair for Security Engineering of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY NewHope_Server IS
    GENERIC (
        paramQ          : UNSIGNED     := to_unsigned(12289, 14);
        paramN          : INTEGER      := 1024;
        paramNlength    : INTEGER      := 10;
        paramK          : INTEGER      := 16;
        paramNINV       : STD_LOGIC_VECTOR(13 DOWNTO 0) := "10111111110101"
    );
    PORT (  
        clk           : IN  STD_LOGIC;
        reset         : IN  STD_LOGIC;
		en            : IN STD_LOGIC;
		a_seed        : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		poly_b        : OUT STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
		poly_u        : IN STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
		poly_c        : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		streaming     : OUT STD_LOGIC;
		done_first    : OUT STD_LOGIC;
		done_second   : OUT STD_LOGIC;
		finalize      : IN  STD_LOGIC;
		request_c     : OUT  STD_LOGIC;
		key           : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END NewHope_Server;

ARCHITECTURE Behavioral OF NewHope_Server IS

    COMPONENT blk_mem_gen_0 IS
      PORT (
        clka    : IN STD_LOGIC;
        ena     : IN STD_LOGIC;
        wea     : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra   : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        dina    : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
        douta   : OUT STD_LOGIC_VECTOR(13 DOWNTO 0);
        clkb    : IN STD_LOGIC;
        enb     : IN STD_LOGIC;
        web     : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addrb   : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        dinb    : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
        doutb   : OUT STD_LOGIC_VECTOR(13 DOWNTO 0)
      );
    END COMPONENT;
    
    COMPONENT bin_sample IS
        GENERIC(
            paramQ  : unsigned;
            paramK : integer;
            KEY    : STD_LOGIC_VECTOR := X"21646e6172202e78616d"
        );
        PORT( 
            clk         : IN  STD_LOGIC;
            en          : IN  STD_LOGIC;
            reset       : IN  STD_LOGIC;
            sample_done : OUT STD_LOGIC;
            gauss_out   : OUT STD_LOGIC_VECTOR (paramQ'length-1 DOWNTO 0)
        );
    END COMPONENT;
    
    COMPONENT fwd_ntt IS
        GENERIC(
            paramQ  : UNSIGNED     := to_unsigned(12289, 14);
            paramN  : INTEGER      := 1024
        );
        PORT( 
            clk             : IN  STD_LOGIC;
            reset           : IN  STD_LOGIC;
            en              : IN  STD_LOGIC;
            fwd_bwd         : IN  STD_LOGIC;
            addr1           : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
            addr2           : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
            addr_psi        : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
            data1           : IN  STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
            data2           : IN  STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
            data_psi        : IN  STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
            data_res1       : OUT STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
            data_res2       : OUT STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
            butterfly_done  : OUT STD_LOGIC;
            ntt_done        : OUT STD_LOGIC;
            dsp_sel         : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            dsp_a           : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
            dsp_b           : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
            dsp_c           : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
            dsp_d           : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
            dsp_res_red     : IN STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0)
    );
    END COMPONENT;
    
    COMPONENT PWMul IS
        GENERIC(
            paramQ         : UNSIGNED     := to_unsigned(12289, 14);
            paramN         : INTEGER      := 1024
        );
        PORT( 
            clk         : IN  STD_LOGIC;
            reset       : IN  STD_LOGIC;
            en          : IN  STD_LOGIC;
            addr        : OUT STD_LOGIC_VECTOR(paramNlength-1 DOWNTO 0);
            data1       : IN  STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
            data2       : IN  STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
            data_add    : IN  STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
            data_res    : OUT STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);            
            mul_done    : OUT STD_LOGIC;
            poly_done   : OUT STD_LOGIC;
            dsp_sel     : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            dsp_a       : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
            dsp_b       : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
            dsp_c       : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
            dsp_d       : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
            dsp_res_red : IN STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0)
        );
    END COMPONENT;
    
    COMPONENT SubMul IS
        GENERIC(
            paramQ         : UNSIGNED     := to_unsigned(12289, 14);
            paramN         : INTEGER      := 1024;
            paramNINV      : STD_LOGIC_VECTOR(13 DOWNTO 0) := "10111111110101"
        );
        PORT( 
            clk         : IN  STD_LOGIC;
            reset       : IN  STD_LOGIC;
            en          : IN  STD_LOGIC;
            addr        : OUT STD_LOGIC_VECTOR(10-1 DOWNTO 0);
            data1       : IN  STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
            poly_c      : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
            data_res    : OUT STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);            
            sub_done    : OUT STD_LOGIC;
            poly_done   : OUT STD_LOGIC;
            dsp_sel     : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            dsp_a       : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
            dsp_b       : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
            dsp_c       : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
            dsp_d       : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
            dsp_res_nored : IN STD_LOGIC_VECTOR(30 DOWNTO 0)
        );
    END COMPONENT;
    
    COMPONENT psi_mem IS
      PORT (
        clka    : IN STD_LOGIC;
        ena     : IN STD_LOGIC;
        addra   : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        douta   : OUT STD_LOGIC_VECTOR(13 DOWNTO 0)
      );
    END COMPONENT;
    
    COMPONENT invpsi_mem IS
        PORT (
            clka    : IN STD_LOGIC;
            ena     : IN STD_LOGIC;
            addra   : IN STD_LOGIC_VECTOR(paramNlength-1 DOWNTO 0);
            douta   : OUT STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0)
        );
    END COMPONENT;
    
    COMPONENT xbip_dsp48_macro_0 IS
      PORT (
          CLK   : IN STD_LOGIC;
          SEL   : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
          A     : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
          B     : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
          C     : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
          D     : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
          P     : OUT STD_LOGIC_VECTOR(30 DOWNTO 0)
        );
    END COMPONENT;
    
    COMPONENT red_12289 IS
        port (
            clk   : IN  STD_LOGIC;
            val   : IN  UNSIGNED(2*14-1 DOWNTO 0) := (OTHERS => '0');
            red   : OUT UNSIGNED(14-1 DOWNTO 0)   := (OTHERS => '0')
        );
    END COMPONENT;
    
    COMPONENT Keccak1600 IS
        PORT ( CLK      : IN  STD_LOGIC;
               -- CONTROL SIGNAL PORTS ---------------------------
               RESET    : IN  STD_LOGIC;
               ENABLE   : IN  STD_LOGIC;
               DONE     : OUT STD_LOGIC;
               -- DATA SIGNAL PORTS ------------------------------
               MESSAGE  : IN  STD_LOGIC_VECTOR( 255 DOWNTO 0);
               PADDING  : IN  STD_LOGIC_VECTOR(1343 DOWNTO 0);
               RESULT   : OUT STD_LOGIC_VECTOR(1343 DOWNTO 0));
    END COMPONENT;
    
    COMPONENT gen_a IS
        GENERIC(
            paramQ         : UNSIGNED     := to_unsigned(12289, 14)
        );
        PORT( 
            clk         :  IN STD_LOGIC;
            reset       :  IN STD_LOGIC;
            en          :  IN STD_LOGIC;
            keccak_out  :  IN STD_LOGIC_VECTOR(1343 DOWNTO 0);
            keccak_done :  IN STD_LOGIC; 
            coeff_out1  : OUT STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
            coeff_out2  : OUT STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
            coeff_out3  : OUT STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0)
        );
    END COMPONENT;
    
    COMPONENT abs_mod IS
        GENERIC (
            paramQ          : SIGNED  := to_signed(12289, 15);
            paramQhalf      : SIGNED  := to_signed(6144, 15)
        );
        PORT ( 
            val_in   : IN STD_LOGIC_VECTOR(paramQ'length-2 DOWNTO 0);
            val_out  : OUT STD_LOGIC_VECTOR(paramQ'length-2 DOWNTO 0)
        );
    END COMPONENT;
    
    -- sampler signals
    SIGNAL sample_en        : STD_LOGIC;
    SIGNAl sample_out       : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    SIGNAl sample_done      : STD_LOGIC;
    SIGNAL sampler_restart  : STD_LOGIC := '1';
    SIGNAL sample_addr      : STD_LOGIC_VECTOR(9 DOWNTO 0);
    
    -- FSM signals    
    TYPE states IS (SAMPLE_S, NTT_S, NTT_E, GEN_A_1, GEN_A_2, GEN_A_3, MUL_ADD, STREAM_OUT_B, DONEFIRST, MUL_SUB, NTT_BWD, SUB_MUL_NINV, DECODE, HASH_KEY, DONESECOND);
    SIGNAL state, next_state    : states;  
    
    -- NTT signals
    SIGNAL psi_addr         : STD_LOGIC_VECTOR(paramNlength-1 DOWNTO 0);
    SIGNAL psi_data         : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    SIGNAL psi_data_low     : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL psi_data_high    : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL invpsi_addr      : STD_LOGIC_VECTOR(paramNlength-1 DOWNTO 0);
    SIGNAL invpsi_data_low  : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL invpsi_data_high : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL invpsi_data      : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    SIGNAL ntt_a_addr       : STD_LOGIC_VECTOR(paramNlength-1 DOWNTO 0);
    SIGNAL ntt_b_addr       : STD_LOGIC_VECTOR(paramNlength-1 DOWNTO 0);
    SIGNAL ntt_a_in         : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    SIGNAL ntt_b_in         : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    SIGNAL ntt_a_out        : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    SIGNAL ntt_b_out        : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    SIGNAL ntt_done         : STD_LOGIC;
    SIGNAL butterfly_done   : STD_LOGIC;
    SIGNAL ntt_en           : STD_LOGIC;
    SIGNAL ntt_rst          : STD_LOGIC;
    SIGNAL ntt_fwd_bwd      : STD_LOGIC;
    SIGNAL ntt_psi_addr     : STD_LOGIC_VECTOR(paramNlength-1 DOWNTO 0);
    SIGNAL ntt_psi_data     : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    SIGNAL ntt_dsp_sel      : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL ntt_dsp_a        : STD_LOGIC_VECTOR(14 DOWNTO 0);
    SIGNAL ntt_dsp_b        : STD_LOGIC_VECTOR(14 DOWNTO 0);
    SIGNAL ntt_dsp_c        : STD_LOGIC_VECTOR(14 DOWNTO 0);
    SIGNAL ntt_dsp_d        : STD_LOGIC_VECTOR(14 DOWNTO 0);
    SIGNAL ntt_res_red      : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    
    -- pointwise-multiplication signals
    SIGNAL pw_mul_addr      : STD_LOGIC_VECTOR(paramNlength-1 DOWNTO 0);
    SIGNAL pw_mul_a_in      : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    SIGNAL pw_mul_b_in      : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    SIGNAL pw_mul_out       : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    SIGNAL mul_done         : STD_LOGIC;
    SIGNAL poly_done        : STD_LOGIC;
    SIGNAL pw_mul_en        : STD_LOGIC;
    SIGNAL pw_mul_add_in    : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    SIGNAL pw_mul_rst       : STD_LOGIC;
    SIGNAL pw_mul_dsp_sel   : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL pw_mul_dsp_a     : STD_LOGIC_VECTOR(14 DOWNTO 0);
    SIGNAL pw_mul_dsp_b     : STD_LOGIC_VECTOR(14 DOWNTO 0);
    SIGNAL pw_mul_dsp_c     : STD_LOGIC_VECTOR(14 DOWNTO 0);
    SIGNAL pw_mul_dsp_d     : STD_LOGIC_VECTOR(14 DOWNTO 0);
    SIGNAL pw_mul_res_red   : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    
    -- sub NINV
    SIGNAL sub_mul_addr      : STD_LOGIC_VECTOR(paramNlength-1 DOWNTO 0);
    SIGNAL sub_mul_a_in      : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    SIGNAL sub_mul_out       : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    SIGNAL sub_mul_done      : STD_LOGIC;
    SIGNAL sub_done          : STD_LOGIC;
    SIGNAL sub_mul_en        : STD_LOGIC;
    SIGNAL sub_mul_sub_in    : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL sub_mul_rst       : STD_LOGIC;
    SIGNAL sub_mul_dsp_sel   : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL sub_mul_dsp_a     : STD_LOGIC_VECTOR(14 DOWNTO 0);
    SIGNAL sub_mul_dsp_b     : STD_LOGIC_VECTOR(14 DOWNTO 0);
    SIGNAL sub_mul_dsp_c     : STD_LOGIC_VECTOR(14 DOWNTO 0);
    SIGNAL sub_mul_dsp_d     : STD_LOGIC_VECTOR(14 DOWNTO 0);
    SIGNAL sub_mul_res_nored : STD_LOGIC_VECTOR(30 DOWNTO 0); 
    
    -- reg_0 signals
    SIGNAL reg0_we_a        : STD_LOGIC_VECTOR(0 DOWNTO 0);
    SIGNAL reg0_we_b        : STD_LOGIC_VECTOR(0 DOWNTO 0);
    SIGNAL reg0_addr_a      : STD_LOGIC_VECTOR(paramNlength-1 DOWNTO 0);
    SIGNAL reg0_addr_b      : STD_LOGIC_VECTOR(paramNlength-1 DOWNTO 0);
    SIGNAL reg0_din_a       : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    SIGNAL reg0_din_b       : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    SIGNAL reg0_dout_a      : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    SIGNAL reg0_dout_b      : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    
    -- reg_1 signals
    SIGNAL reg1_we_a        : STD_LOGIC_VECTOR(0 DOWNTO 0);
    SIGNAL reg1_we_b        : STD_LOGIC_VECTOR(0 DOWNTO 0);
    SIGNAL reg1_addr_a      : STD_LOGIC_VECTOR(paramNlength-1 DOWNTO 0);
    SIGNAL reg1_addr_b      : STD_LOGIC_VECTOR(paramNlength-1 DOWNTO 0);
    SIGNAL reg1_din_a       : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    SIGNAL reg1_din_b       : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    SIGNAL reg1_dout_a      : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    SIGNAL reg1_dout_b      : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    
    -- DSP signals
    SIGNAL dsp_sel          : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL dsp_a            : STD_LOGIC_VECTOR(14 DOWNTO 0);
    SIGNAL dsp_b            : STD_LOGIC_VECTOR(14 DOWNTO 0);
    SIGNAL dsp_c            : STD_LOGIC_VECTOR(14 DOWNTO 0);
    SIGNAL dsp_d            : STD_LOGIC_VECTOR(14 DOWNTO 0);
    SIGNAL dsp_p            : STD_LOGIC_VECTOR(30 DOWNTO 0);
    
    -- Reduction signals
    SIGNAL res_red_unsigned : UNSIGNED(paramQ'length-1 DOWNTO 0);
    
    -- a signals
    SIGNAL a_seed_intern    : STD_LOGIC_VECTOR(255 DOWNTO 0) := X"4847464544434241383736353433323128272625242322211817161514131211";
    
    -- keccak signals
    SIGNAL keccak_rst       : STD_LOGIC;
    SIGNAL keccak_en        : STD_LOGIC;
    SIGNAL keccak_done      : STD_LOGIC;
    SIGNAL keccak_input     : STD_LOGIC_VECTOR( 255 DOWNTO 0);
    SIGNAL keccak_padding   : STD_LOGIC_VECTOR(1343 DOWNTO 0);
    SIGNAL keccak_result    : STD_LOGIC_VECTOR(1343 DOWNTO 0);
    
    -- gen_a signals
    SIGNAL gen_a_rst, gen_a_en      : STD_LOGIC;
    SIGNAL gen_a1, gen_a2, gen_a3   : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    SIGNAL a_select                 : INTEGER range 0 to 27;
    
    -- output signals
    SIGNAL output_addr      : STD_LOGIC_VECTOR(paramNlength-1 DOWNTO 0);
    
    -- decoding signals     
    SIGNAL accumulator      : UNSIGNED(paramQ'length DOWNTO 0);
    SIGNAL decoding_addr    : STD_LOGIC_VECTOR(paramNlength DOWNTO 0);
    SIGNAL abs_mod_out      : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    SIGNAL abs_mod_in       : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    
    -- hash key
    SIGNAL key_pre          : STD_LOGIC_VECTOR( 256 DOWNTO 0);
    SIGNAL key_intern       : STD_LOGIC_VECTOR( 255 DOWNTO 0);

BEGIN

    gena : gen_a
    GENERIC MAP(
        paramQ => paramQ
    )
    PORT MAP(
        clk         => clk,
        reset       => gen_a_rst,
        en          => gen_a_en,
        keccak_out  => keccak_result,
        keccak_done => keccak_done, 
        coeff_out1  => gen_a1,
        coeff_out2  => gen_a2,
        coeff_out3  => gen_a3
    );

    keccak : Keccak1600
    PORT MAP(
       CLK      => clk,
       RESET    => keccak_rst,
       ENABLE   => keccak_en,
       DONE     => keccak_done,
       MESSAGE  => keccak_input,
       PADDING  => keccak_padding,
       RESULT   => keccak_result
    );

    multipurpose_dsp: xbip_dsp48_macro_0
    PORT MAP(
        CLK => clk,
        SEL => dsp_sel,
        A => dsp_a,
        B => dsp_b,
        C => dsp_c,
        D => dsp_d,
        P => dsp_p
    );
    
    multipurpose_red : red_12289
    PORT MAP(
        clk => clk,
        val => UNSIGNED(dsp_p(27 DOWNTO 0)),
        red => res_red_unsigned
    );
    
    psi : psi_mem
    PORT MAP(
        clka => clk,
        ena => '1',
        addra => psi_addr,
        douta => psi_data
    );
    
    invpsi : invpsi_mem
    PORT MAP(
        clka    => clk,
        ena     => '1',
        addra   => invpsi_addr,
        douta   => invpsi_data
    );
    
    ntt1 : fwd_ntt
    PORT MAP(
        clk             => clk,
        reset           => ntt_rst,
        en              => ntt_en,
        fwd_bwd         => ntt_fwd_bwd,
        addr1           => ntt_a_addr,
        addr2           => ntt_b_addr,
        addr_psi        => ntt_psi_addr,
        data1           => ntt_a_in,
        data2           => ntt_b_in,
        data_psi        => ntt_psi_data,
        data_res1       => ntt_a_out,
        data_res2       => ntt_b_out,
        butterfly_done  => butterfly_done,
        ntt_done        => ntt_done,
        dsp_sel         => ntt_dsp_sel,
        dsp_a           => ntt_dsp_a,
        dsp_b           => ntt_dsp_b,
        dsp_c           => ntt_dsp_c,
        dsp_d           => ntt_dsp_d,
        dsp_res_red     => ntt_res_red
    );
    
    pwmul_0 : PWMul
    PORT MAP(
        clk         => clk,
        reset       => pw_mul_rst,
        en          => pw_mul_en,
        addr        => pw_mul_addr,
        data1       => pw_mul_a_in,
        data2       => pw_mul_b_in,
        data_add    => pw_mul_add_in,
        data_res    => pw_mul_out,
        mul_done    => mul_done,
        poly_done   => poly_done,
        dsp_sel     => pw_mul_dsp_sel,
        dsp_a       => pw_mul_dsp_a,
        dsp_b       => pw_mul_dsp_b,
        dsp_c       => pw_mul_dsp_c,
        dsp_d       => pw_mul_dsp_d,
        dsp_res_red => pw_mul_res_red
    );
    
    sub_mul_0 : SubMul
    PORT MAP(
        clk         => clk,
        reset       => sub_mul_rst,
        en          => sub_mul_en,
        addr        => sub_mul_addr,
        data1       => sub_mul_a_in,
        poly_c      => sub_mul_sub_in,
        data_res    => sub_mul_out,
        sub_done    => sub_mul_done,
        poly_done   => sub_done,
        dsp_sel     => sub_mul_dsp_sel,
        dsp_a       => sub_mul_dsp_a,
        dsp_b       => sub_mul_dsp_b,
        dsp_c       => sub_mul_dsp_c,
        dsp_d       => sub_mul_dsp_d,
        dsp_res_nored => sub_mul_res_nored
    );

    reg_0 : blk_mem_gen_0
    PORT MAP(
            clka    => clk,
            ena     => '1',
            wea     => reg0_we_a,
            addra   => reg0_addr_a,
            dina    => reg0_din_a,
            douta   => reg0_dout_a,
            clkb    => clk,
            enb     => '1',
            web     => reg0_we_b,
            addrb   => reg0_addr_b,
            dinb    => reg0_din_b,
            doutb   => reg0_dout_b
    );
    reg_1 : blk_mem_gen_0
    PORT MAP(
            clka    => clk,
            ena     => '1',
            wea     => reg1_we_a,
            addra   => reg1_addr_a,
            dina    => reg1_din_a,
            douta   => reg1_dout_a,
            clkb    => clk,
            enb     => '1',
            web     => reg1_we_b,
            addrb   => reg1_addr_b,
            dinb    => reg1_din_b,
            doutb   => reg1_dout_b
    );
    
    sampler : bin_sample
    GENERIC MAP(
        paramQ => paramQ,
        paramK => paramK
    )
    PORT MAP(
        clk         => clk,
        reset       => reset,
        en          => sample_en,
        sample_done => sample_done,
        gauss_out   => sample_out
    );
    
    abs_mod_inst : abs_mod
    PORT MAP(
        val_in  => abs_mod_in,
        val_out => abs_mod_out
    );
    
    state_memory: PROCESS (clk)
        BEGIN
            IF rising_edge(clk) THEN
                IF (reset = '1') THEN
                    state <= SAMPLE_S;
                ELSE
                    IF (en = '1') THEN
                        state <= next_state;
                     END IF;
                 END IF;
            END IF;
    END PROCESS;
    
    NewHopeServer : PROCESS(clk, state)
       VARIABLE key_addr : INTEGER range 0 to 31; 
       BEGIN         
            IF RISING_EDGE(clk) THEN
                IF reset='1' THEN
                    sample_addr <= (OTHERS => '0');
                    ntt_en      <= '0';
                    ntt_rst     <= '1';
                    sub_mul_rst <= '1';
                    sub_mul_en  <= '0';
                    ntt_fwd_bwd <= '0';
                    sample_en   <= '0';
                    keccak_rst  <= '1';
                    keccak_en   <= '0';
                    gen_a_rst   <= '1';
                    gen_a_en    <= '0';
                    pw_mul_en   <= '0'; 
                    pw_mul_rst  <= '1';
                    a_select    <= 0;
                    done_first  <= '0';
                    done_second <= '0';
                    request_c   <= '0';
                    streaming   <= '0';
                    decoding_addr   <= (OTHERS => '0');
                    accumulator     <= (OTHERS => '0');
                    output_addr <= (OTHERS => '0');
                ELSIF en = '1' THEN
                    ntt_rst     <= '0';
                    pw_mul_rst  <= '0';
                    
                    CASE state IS
                        WHEN SAMPLE_S => 
                            sample_en <= '1';
                            IF sample_done = '1' THEN                                
                                sample_addr <= STD_LOGIC_VECTOR(UNSIGNED(sample_addr) + 1);
                                IF sample_addr = "1111111111" THEN
                                    next_state  <= NTT_S;
                                    ntt_en      <= '1'; 
                                    sample_addr <= (OTHERS => '0'); 
                                END IF;                            
                            END IF;
                        WHEN NTT_S => 
                            -- sample e meanwhile
                            IF sample_done = '1' THEN
                                sample_addr <= STD_LOGIC_VECTOR(UNSIGNED(sample_addr) + 1);
                                IF sample_addr = "1111111111" THEN
                                    sample_en   <= '0';
                                END IF;                            
                            END IF;
                            IF ntt_done = '1' THEN
                                next_state  <= NTT_E;
                                --ntt_fwd_bwd <= '0';
                                ntt_rst     <= '1'; 
                            END IF;
                        WHEN NTT_E =>
                            ntt_rst      <= '0';
                            IF ntt_done = '1' THEN
                                next_state  <= GEN_A_1;
                                ntt_en      <= '0';
                                --pw_mul_en   <= '1'; 
                                keccak_rst  <= '0';
                                keccak_en   <= '1';
                                keccak_input <= a_seed_intern;
                                keccak_padding <= x"00000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001f";
                            END IF;
                        WHEN GEN_A_1 =>        
                            gen_a_rst   <= '0';
                            gen_a_en    <= '1';                         
                            IF keccak_done = '1' THEN                                
                                next_state  <= GEN_A_2;
                            END IF;
                         WHEN GEN_A_2 =>                         
                            IF keccak_done = '1' THEN                                
                                next_state  <= GEN_A_3;                                
                            END IF;
                        WHEN GEN_A_3 =>
                            pw_mul_b_in <= gen_a1;
                            a_select    <= 1;
                            pw_mul_en   <= '1'; 
                            next_state <= MUL_ADD;
                        WHEN MUL_ADD =>
                            IF(a_select = 0) THEN
                                pw_mul_b_in <= gen_a1;
                                a_select    <= a_select + 1;
                            ELSIF(a_select = 9) THEN
                                pw_mul_b_in <= gen_a2;
                                a_select    <= a_select + 1;
                            ELSIF(a_select = 18) THEN
                                pw_mul_b_in <= gen_a3;
                                a_select    <= a_select + 1;
                            ELSIF(a_select = 26) THEN
                                a_select    <= 0;
                            ELSE
                                a_select    <= a_select + 1;
                                pw_mul_b_in <= pw_mul_b_in;
                            END IF;
                            IF poly_done = '1' THEN
                                next_state  <= STREAM_OUT_B;
                                streaming   <= '1';
                                pw_mul_en   <= '0'; 
                                pw_mul_rst  <= '1'; 
                                keccak_rst  <= '1';
                                keccak_en   <= '0';
                                gen_a_en    <= '0';
                            END IF;
                        WHEN STREAM_OUT_B =>
                            output_addr <= STD_LOGIC_VECTOR(UNSIGNED(output_addr) + 1);
                            IF output_addr = "1111111111" THEN
                                next_state  <= DONEFIRST;
                                done_first  <= '1';
                                streaming   <= '0';
                            END IF;
                        WHEN DONEFIRST =>
                            IF finalize = '1' THEN
                                next_state  <= MUL_SUB;
                                pw_mul_b_in <= poly_u;
                                pw_mul_en   <= '1'; 
                                pw_mul_rst  <= '0'; 
                            END IF;
                        WHEN MUL_SUB =>                        
                            pw_mul_b_in <= poly_u;
                            IF poly_done = '1' THEN
                                next_state  <= NTT_BWD;
                                ntt_rst     <= '1';
                                ntt_en      <= '1';
                                ntt_fwd_bwd <= '1';                                
                            END IF;
                        WHEN NTT_BWD =>                            
                            ntt_rst      <= '0';
                            IF ntt_done = '1' THEN
                                next_state  <= SUB_MUL_NINV;
                                ntt_en      <= '0';
                                sub_mul_rst <= '0';
                                sub_mul_en  <= '1'; 
                                request_c   <= '1';
                            END IF;
                        WHEN SUB_MUL_NINV =>
                            IF sub_done = '1' THEN
                                next_state  <= DECODE; 
                                request_c   <= '0';                              
                                streaming   <= '1';
                                key_pre     <= (OTHERS => '0');
                            END IF;
                        WHEN DECODE =>
                            decoding_addr <= STD_LOGIC_VECTOR(UNSIGNED(decoding_addr) + 1);
                            IF(decoding_addr(1 DOWNTO 0) = "10") THEN
                                accumulator <= UNSIGNED('0' & abs_mod_out);
                                IF(accumulator < paramQ) THEN
                                    key_pre(TO_INTEGER(UNSIGNED(decoding_addr(9 DOWNTO 2)))) <= '0';
                                ELSE
                                    key_pre(TO_INTEGER(UNSIGNED(decoding_addr(9 DOWNTO 2)))) <= '1';
                                END IF;
                            ELSE
                                accumulator <= accumulator + UNSIGNED('0' & abs_mod_out);
                            END IF;
                            IF(decoding_addr = "10000000010") THEN
                                next_state  <= HASH_KEY;
                                keccak_rst  <= '0';
                                keccak_en   <= '1';
                                keccak_input <= key_pre(256 DOWNTO 1);
                                keccak_padding <= x"000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006";                                  
                            END IF;
                        WHEN HASH_KEY =>
                            IF(keccak_done = '1') THEN
                                keccak_en   <= '0';
                                key_intern  <= keccak_result(255 DOWNTO 0);
                                next_state  <= DONESECOND;
                                key_addr    := 31;
                            END IF;
                        WHEN DONESECOND =>
                            done_second <= '1';
                            
                            IF(key_addr = 31) THEN
                                key_addr := 0;
                            ELSE
                                key_addr := key_addr + 1;
                            END IF;
                            
                            key <= key_intern(key_addr*8+7 DOWNTO key_addr*8);
                    END CASE;
                END IF;
            END IF;
    END PROCESS;
    
    a_seed <= a_seed_intern(7+8*TO_INTEGER(UNSIGNED(output_addr(4 DOWNTO 0))) DOWNTO 8*TO_INTEGER(UNSIGNED(output_addr(4 DOWNTO 0))));
    poly_b <= reg1_dout_a;
    
    ntt_res_red         <= STD_LOGIC_VECTOR(res_red_unsigned);
    pw_mul_res_red      <= STD_LOGIC_VECTOR(res_red_unsigned);
    sub_mul_res_nored   <= dsp_p;
    
    reg0_addr_b <= ntt_b_addr;
    reg0_din_b  <= ntt_b_out;
    
    psi_addr    <= ntt_psi_addr;
    invpsi_addr <= ntt_psi_addr;
    
    abs_mod_in  <= reg0_dout_a;     
                    
    pw_mul_a_in     <= reg0_dout_a;
    sub_mul_a_in    <= reg0_dout_a;
    sub_mul_sub_in  <= poly_c; 
    
    WITH state SElECT ntt_psi_data <=
        psi_data        WHEN NTT_S,
        psi_data        WHEN NTT_E,
        invpsi_data     WHEN NTT_BWD,
        (OTHERS => '0') WHEN OTHERS;
    
    WITH state SELECT ntt_a_in <=
        reg0_dout_a     WHEN NTT_S,
        reg1_dout_a     WHEN NTT_E,
        reg0_dout_a     WHEN NTT_BWD,
        (OTHERS => '0') WHEN OTHERS;
    
    WITH state SELECT ntt_b_in <=
        reg0_dout_b     WHEN NTT_S,
        reg1_dout_b     WHEN NTT_E,
        reg0_dout_b     WHEN NTT_BWD,
        (OTHERS => '0') WHEN OTHERS;
    
    WITH state SELECT reg0_din_a <=  
        sample_out      WHEN SAMPLE_S,
        ntt_a_out       WHEN NTT_S,
        pw_mul_out      WHEN MUL_SUB,
        sub_mul_out     WHEN SUB_MUL_NINV,
        ntt_a_out       WHEN NTT_BWD,
        (OTHERS => '0') WHEN OTHERS;
           
    WITH state SELECT reg0_addr_a <=  
        sample_addr     WHEN SAMPLE_S,
        ntt_a_addr      WHEN NTT_S,
        pw_mul_addr     WHEN MUL_ADD,
        pw_mul_addr     WHEN MUL_SUB,
        sub_mul_addr    WHEN SUB_MUL_NINV,
        ntt_a_addr      WHEN NTT_BWD,
        decoding_addr(1 DOWNTO 0) & decoding_addr(paramNlength-1 DOWNTO 2)   WHEN DECODE,
        (OTHERS => '0') WHEN OTHERS;
           
    WITH state SELECT reg0_we_a <=
        "" & sample_done    WHEN SAMPLE_S,
        "" & butterfly_done WHEN NTT_S,
        "" & mul_done       WHEN MUL_SUB,
        "" & sub_mul_done   WHEN SUB_MUL_NINV,
        "" & butterfly_done WHEN NTT_BWD,
        (OTHERS => '0') WHEN OTHERS;
       
    WITH state SELECT reg0_we_b <=
        "" & butterfly_done  WHEN NTT_S,
        "" & butterfly_done  WHEN NTT_BWD,
        (OTHERS => '0') WHEN OTHERS;
          
    WITH state SELECT reg1_din_a <=
        sample_out       WHEN NTT_S,
        ntt_a_out        WHEN NTT_E,
        pw_mul_out       WHEN MUL_ADD,
        (OTHERS => '0')  WHEN OTHERS;
          
    WITH state SELECT reg1_addr_a <= 
        sample_addr      WHEN NTT_S,
        ntt_a_addr       WHEN NTT_E,
        pw_mul_addr      WHEN MUL_ADD,
        output_addr      WHEN STREAM_OUT_B,
        (OTHERS => '0')  WHEN OTHERS;
          
    WITH state SELECT reg1_din_b <=
        ntt_b_out        WHEN NTT_E,
        (OTHERS => '0')  WHEN OTHERS;
         
    WITH state SELECT reg1_addr_b <=  
        ntt_b_addr       WHEN NTT_E,
        (OTHERS => '0')  WHEN OTHERS;
          
    WITH state SELECT reg1_we_a <=
        "" & sample_done     WHEN NTT_S,
        "" & butterfly_done  WHEN NTT_E,
        "" & mul_done        WHEN MUL_ADD,
        "0"                  WHEN OTHERS;
      
    WITH state SELECT reg1_we_b <=
        "" & butterfly_done  WHEN NTT_E, 
        "0"                  WHEN OTHERS;
    
    WITH state SELECT pw_mul_add_in <=  
        reg1_dout_a WHEN MUL_ADD,
        (OTHERS => '0')  WHEN OTHERS;
        
    WITH state SELECT dsp_sel <=
        ntt_dsp_sel     WHEN NTT_S,
        ntt_dsp_sel     WHEN NTT_E,
        ntt_dsp_sel     WHEN NTT_BWD,
        pw_mul_dsp_sel  WHEN MUL_ADD,
        pw_mul_dsp_sel  WHEN MUL_SUB,
        sub_mul_dsp_sel WHEN SUB_MUL_NINV,
        "00"            WHEN OTHERS;
    
    WITH state SELECT dsp_a <=
        ntt_dsp_a       WHEN NTT_S,
        ntt_dsp_a       WHEN NTT_E,
        ntt_dsp_a       WHEN NTT_BWD,
        pw_mul_dsp_a    WHEN MUL_ADD,
        pw_mul_dsp_a    WHEN MUL_SUB,
        sub_mul_dsp_a   WHEN SUB_MUL_NINV,
        (OTHERS => '0') WHEN OTHERS;
    
    WITH state SELECT dsp_b <=
        ntt_dsp_b       WHEN NTT_S,
        ntt_dsp_b       WHEN NTT_E,
        ntt_dsp_b       WHEN NTT_BWD,
        pw_mul_dsp_b    WHEN MUL_ADD,
        pw_mul_dsp_b    WHEN MUL_SUB,
        sub_mul_dsp_b   WHEn SUB_MUL_NINV,
        (OTHERS => '0') WHEN OTHERS;
    
    WITH state SELECT dsp_c <=
        ntt_dsp_c       WHEN NTT_S,
        ntt_dsp_c       WHEN NTT_E,
        ntt_dsp_c       WHEN NTT_BWD,
        pw_mul_dsp_c    WHEN MUL_ADD,
        pw_mul_dsp_c    WHEN MUL_SUB,
        sub_mul_dsp_c   WHEN SUB_MUL_NINV,
        (OTHERS => '0') WHEN OTHERS;
    
    WITH state SELECT dsp_d <=
        ntt_dsp_d       WHEN NTT_S,
        ntt_dsp_d       WHEN NTT_E,
        ntt_dsp_d       WHEN NTT_BWD,
        pw_mul_dsp_d    WHEN MUL_ADD,
        pw_mul_dsp_d    WHEN MUL_SUB,
        sub_mul_dsp_d   WHEN SUB_MUL_NINV,
        (OTHERS => '0') WHEN OTHERS;
        
END Behavioral;
