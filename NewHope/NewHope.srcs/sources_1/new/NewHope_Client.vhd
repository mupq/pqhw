--/****************************************************************************/
--Copyright (C) by Tobias Oder and the Chair for Security Engineering of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY NewHope_Client IS
    GENERIC (
    paramQ          : UNSIGNED                      := to_unsigned(12289, 14);
    paramQhalf      : UNSIGNED                      := to_unsigned(6144, 15);
    paramN          : INTEGER                       := 1024;
    paramNlength    : INTEGER                       := 10;
    paramK          : INTEGER                       := 16;
    paramNINV       : STD_LOGIC_VECTOR(13 DOWNTO 0) := "10111111110101"
);
PORT (  
    clk           : IN  STD_LOGIC;
    reset         : IN  STD_LOGIC;
    en            : IN STD_LOGIC;
    a_seed        : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    poly_b        : IN STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    poly_u        : OUT STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    poly_c        : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    streaming     : OUT STD_LOGIC;
    request_b     : OUT STD_LOGIC;
    done          : OUT STD_LOGIC;
    key           : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
);
END NewHope_Client;

ARCHITECTURE Behavioral OF NewHope_Client IS

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
    
    COMPONENT ErrorMessageAdderCompressor IS
        GENERIC(
            paramQ          : UNSIGNED     := to_unsigned(12289, 14);
            paramQhalf      : UNSIGNED     := to_unsigned(6144, 16);
            paramN          : INTEGER      := 1024
        );
        PORT( 
            clk             : IN  STD_LOGIC;
            reset           : IN  STD_LOGIC;
            en              : IN  STD_LOGIC;
            addr            : OUT STD_LOGIC_VECTOR(10-1 DOWNTO 0);
            data1           : IN  STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
            data_add        : IN  STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
            data_msg        : IN  STD_LOGIC;
            data_res        : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);            
            add_done        : OUT STD_LOGIC;
            poly_add_done   : OUT STD_LOGIC
        );
    END COMPONENT;
    
    -- sampler signals
    SIGNAL sample_en        : STD_LOGIC;
    SIGNAl sample_out       : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    SIGNAl sample_done      : STD_LOGIC;
    SIGNAL sampler_restart  : STD_LOGIC := '1';
    SIGNAL sample_addr      : STD_LOGIC_VECTOR(9 DOWNTO 0);
    
    -- FSM signals    
    TYPE states IS (SAMPLE_SP, NTT_SP, NTT_EP, GEN_A_1, GEN_A_2, GEN_A_3, MUL_ADD, MUL_2, STREAM_OUT_U, NTT_BWD, MUL_NINV, ADD, DONE_STATE);
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
    
    -- keccak signals
    SIGNAL keccak_rst       : STD_LOGIC;
    SIGNAL keccak_en        : STD_LOGIC;
    SIGNAL keccak_done      : STD_LOGIC;
    SIGNAL keccak_input     : STD_LOGIC_VECTOR( 255 DOWNTO 0);
    SIGNAL keccak_padding   : STD_LOGIC_VECTOR(1343 DOWNTO 0);
    SIGNAL keccak_result    : STD_LOGIC_VECTOR(1343 DOWNTO 0);
    
    -- gen_a signals
    SIGNAL a_seed_intern            : STD_LOGIC_VECTOR(255 DOWNTO 0);
    SIGNAL gen_a_rst, gen_a_en      : STD_LOGIC;
    SIGNAL gen_a1, gen_a2, gen_a3   : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    SIGNAL a_select                 : INTEGER range 0 to 27;
    
    -- output signals
    SIGNAL output_addr      : STD_LOGIC_VECTOR(paramNlength-1 DOWNTO 0);
    
    -- add error signals
    SIGNAL add_addr      : STD_LOGIC_VECTOR(paramNlength-1 DOWNTO 0);
    SIGNAL add_a_in      : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    SIGNAL add_out       : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL add_done      : STD_LOGIC;
    SIGNAL poly_add_done : STD_LOGIC;
    SIGNAL add_en        : STD_LOGIC;
    SIGNAL add_add_in    : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    SIGNAL add_rst       : STD_LOGIC;
    SIGNAL add_data_msg  : STD_LOGIC;
    
    SIGNAL key_intern    : STD_LOGIC_VECTOR(255 DOWNTO 0);
    SIGNAL k_fix         : STD_LOGIC_VECTOR(255 DOWNTO 0) := x"5051525354555657606162636465666770717273747576778081828384858687";
    
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
        paramK => paramK,
        KEY    => X"2165726F6D20646E6172"
    )
    PORT MAP(
        clk         => clk,
        reset       => reset,
        en          => sample_en,
        sample_done => sample_done,
        gauss_out   => sample_out
    );
    
    adder : ErrorMessageAdderCompressor
    PORT MAP(
        clk             => clk,
        reset           => add_rst,
        en              => add_en,
        addr            => add_addr,
        data1           => add_a_in,
        data_add        => add_add_in,
        data_msg        => add_data_msg,
        data_res        => add_out,
        add_done        => add_done,
        poly_add_done   => poly_add_done
    );
    
    state_memory: PROCESS (clk)
        BEGIN
            IF rising_edge(clk) THEN
                IF (reset = '1') THEN
                    state <= SAMPLE_SP;
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
                    ntt_fwd_bwd <= '0';
                    sample_en   <= '0';
                    keccak_rst  <= '1';
                    keccak_en   <= '0';
                    gen_a_rst   <= '1';
                    gen_a_en    <= '0';
                    pw_mul_en   <= '0'; 
                    pw_mul_rst  <= '1';
                    a_select    <= 0;
                    add_en      <= '0';
                    add_rst     <= '1';
                    done        <= '0';
                    streaming   <= '0';
                    output_addr <= (OTHERS => '0');
                    
                ELSIF en = '1' THEN
                    ntt_rst     <= '0';
                    pw_mul_rst  <= '0';
                    add_rst     <= '0';
                    a_seed_intern <= a_seed_intern;
                    
                    CASE state IS
                        WHEN SAMPLE_SP => 
                            sample_en <= '1';                            
                            
                            IF sample_done = '1' THEN                                
                                sample_addr <= STD_LOGIC_VECTOR(UNSIGNED(sample_addr) + 1);
                                IF(UNSIGNED(sample_addr) < "0000100000") THEN
                                    a_seed_intern(7+8*TO_INTEGER(UNSIGNED(sample_addr(4 DOWNTO 0))) DOWNTO 8*TO_INTEGER(UNSIGNED(sample_addr(4 DOWNTO 0)))) <= a_seed;
                                END IF;
                                IF sample_addr = "1111111111" THEN
                                    next_state  <= NTT_SP;
                                    ntt_en      <= '1'; 
                                    sample_addr <= (OTHERS => '0'); 
                                END IF;                            
                            END IF;
                        WHEN NTT_SP => 
                            -- sample e meanwhile
                            IF sample_done = '1' THEN
                                sample_addr <= STD_LOGIC_VECTOR(UNSIGNED(sample_addr) + 1);
                                IF sample_addr = "1111111111" THEN
                                    sample_en   <= '0';
                                END IF;                            
                            END IF;
                            IF ntt_done = '1' THEN
                                next_state  <= NTT_EP;
                                ntt_rst     <= '1'; 
                            END IF;
                        WHEN NTT_EP =>
                            ntt_rst      <= '0';
                            IF ntt_done = '1' THEN
                                next_state  <= GEN_A_1;
                                ntt_en      <= '0';
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
                                next_state  <= STREAM_OUT_U;
                                streaming   <= '1';                                
                                keccak_rst  <= '1';
                                keccak_en   <= '0';
                                gen_a_en    <= '0';
                            END IF;
                        WHEN STREAM_OUT_U =>
                            output_addr <= STD_LOGIC_VECTOR(UNSIGNED(output_addr) + 1);
                            IF output_addr = "1111111111" THEN
                                next_state  <= MUL_2;
                                pw_mul_rst  <= '1'; 
                                request_b   <= '1';
                                streaming   <= '0';
                            END IF;
                        WHEN MUL_2 =>
                           pw_mul_rst <= '0';
                           pw_mul_b_in <= poly_b;
                           request_b   <= '0';
                           IF poly_done = '1' THEN
                                next_state  <= NTT_BWD;
                                sample_en <= '1';
                                ntt_fwd_bwd <= '1';
                                ntt_rst     <= '1';
                                ntt_en      <= '1';
                           END IF;
                        WHEN NTT_BWD =>
                            ntt_rst     <= '0';
                            IF sample_done = '1' THEN
                                sample_addr <= STD_LOGIC_VECTOR(UNSIGNED(sample_addr) + 1);
                                IF sample_addr = "1111111111" THEN
                                    sample_en   <= '0';
                                END IF;                            
                            END IF;
                            IF ntt_done = '1' THEN
                                ntt_en      <= '0';
                                pw_mul_rst  <= '1'; 
                                next_state  <= MUL_NINV;
                            END IF;
                        WHEN MUL_NINV =>
                           pw_mul_rst <= '0';
                           pw_mul_b_in <= paramNINV;
                           IF poly_done = '1' THEN
                                pw_mul_en   <= '0'; 
                                next_state  <= ADD;
                                streaming   <= '1';                                
                                add_en      <= '1';
                                keccak_rst  <= '0';
                                keccak_en   <= '1';
                                keccak_input <= k_fix;
                                keccak_padding <= x"000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006";
                                                            
                           END IF;
                        WHEN ADD =>                                       
                               
                            IF(keccak_done = '1') THEN
                                keccak_en   <= '0';
                                key_intern  <= keccak_result(255 DOWNTO 0);
                            END IF;                                                   
                            
                            IF poly_add_done = '1' THEN
                                add_en      <= '0';
                                sample_en   <= '0';
                                next_state  <= DONE_STATE; 
                                key_addr := 31;                               
                                output_addr <= (OTHERS => '0');
                            END IF;
                        WHEN DONE_STATE =>
                            done        <= '1';
                            
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
    
    
    poly_u <= reg1_dout_a;
    poly_c <= add_out;
    
    add_data_msg    <= k_fix(TO_INTEGER(UNSIGNED(add_addr(7 DOWNTO 0))));
    add_add_in      <= reg1_dout_a; 
    
    ntt_res_red    <= STD_LOGIC_VECTOR(res_red_unsigned);
    pw_mul_res_red <= STD_LOGIC_VECTOR(res_red_unsigned);
    
    reg0_addr_b <= ntt_b_addr;
    reg0_din_b  <= ntt_b_out;
    
    psi_addr    <= ntt_psi_addr;
    invpsi_addr <= ntt_psi_addr;
    
    WITH state SElECT ntt_psi_data <=
        psi_data        WHEN NTT_SP,
        psi_data        WHEN NTT_EP,
        invpsi_data     WHEN NTT_BWD,
        (OTHERS => '0') WHEN OTHERS;
    
    WITH state SELECT ntt_a_in <=
        reg0_dout_a     WHEN NTT_SP,
        reg1_dout_a     WHEN NTT_EP,
        reg0_dout_a     WHEN NTT_BWD,
        (OTHERS => '0') WHEN OTHERS;
    
    WITH state SELECT ntt_b_in <=
        reg0_dout_b     WHEN NTT_SP,
        reg1_dout_b     WHEN NTT_EP,
        reg0_dout_b     WHEN NTT_BWD,
        (OTHERS => '0') WHEN OTHERS;
    
    WITH state SELECT reg0_din_a <=  
        sample_out      WHEN SAMPLE_SP,
        ntt_a_out       WHEN NTT_SP,
        pw_mul_out      WHEN MUL_2,
        pw_mul_out      WHEN MUL_NINV,
        ntt_a_out       WHEN NTT_BWD,
        (OTHERS => '0') WHEN OTHERS;
           
    WITH state SELECT reg0_addr_a <=  
        sample_addr     WHEN SAMPLE_SP,
        ntt_a_addr      WHEN NTT_SP,
        pw_mul_addr     WHEN MUL_ADD,
        pw_mul_addr     WHEN MUL_2,
        pw_mul_addr     WHEN MUL_NINV,
        ntt_a_addr      WHEN NTT_BWD,
        add_addr        WHEN ADD,        
        (OTHERS => '0') WHEN OTHERS;
           
    WITH state SELECT reg0_we_a <=
        "" & sample_done    WHEN SAMPLE_SP,
        "" & butterfly_done WHEN NTT_SP,
        "" & mul_done       WHEN MUL_2,
        "" & mul_done       WHEN MUL_NINV,
        "" & butterfly_done WHEN NTT_BWD,
        "" & add_done       WHEN ADD,
        (OTHERS => '0') WHEN OTHERS;
       
    WITH state SELECT reg0_we_b <=
        "" & butterfly_done  WHEN NTT_SP,
        "" & butterfly_done  WHEN NTT_BWD,
        (OTHERS => '0') WHEN OTHERS;
          
    WITH state SELECT reg1_din_a <=
        sample_out       WHEN NTT_SP,
        ntt_a_out        WHEN NTT_EP,
        pw_mul_out       WHEN MUL_ADD,
        sample_out       WHEN NTT_BWD,
        (OTHERS => '0')  WHEN OTHERS;
          
    WITH state SELECT reg1_addr_a <= 
        sample_addr      WHEN NTT_SP,
        ntt_a_addr       WHEN NTT_EP,
        pw_mul_addr      WHEN MUL_ADD,
        output_addr      WHEN STREAM_OUT_U,
        sample_addr      WHEN NTT_BWD,
        add_addr         WHEN ADD,
        (OTHERS => '0')  WHEN OTHERS;
          
    WITH state SELECT reg1_din_b <=
        ntt_b_out        WHEN NTT_EP,
        (OTHERS => '0')  WHEN OTHERS;
         
    WITH state SELECT reg1_addr_b <=  
        ntt_b_addr       WHEN NTT_EP,
        (OTHERS => '0')  WHEN OTHERS;
          
    WITH state SELECT reg1_we_a <=
        "" & sample_done     WHEN NTT_SP,
        "" & butterfly_done  WHEN NTT_EP,
        "" & mul_done        WHEN MUL_ADD,
        "" & sample_done     WHEN NTT_BWD,
        "0"                  WHEN OTHERS;
      
    WITH state SELECT reg1_we_b <=
        "" & butterfly_done  WHEN NTT_EP, 
        "0"                  WHEN OTHERS;
                
    pw_mul_a_in     <= reg0_dout_a;
    
    WITH state SELECT pw_mul_add_in <= 
        reg1_dout_a WHEN MUL_ADD,
        (OTHERS => '0') WHEN OTHERS;
        
    WITH state SELECT dsp_sel <=
        ntt_dsp_sel     WHEN NTT_SP,
        ntt_dsp_sel     WHEN NTT_EP,
        ntt_dsp_sel     WHEN NTT_BWD,
        pw_mul_dsp_sel  WHEN MUL_ADD,
        pw_mul_dsp_sel  WHEN MUL_2,
        pw_mul_dsp_sel  WHEN MUL_NINV,
        "00"            WHEN OTHERS;
    
    WITH state SELECT dsp_a <=
        ntt_dsp_a       WHEN NTT_SP,
        ntt_dsp_a       WHEN NTT_EP,
        ntt_dsp_a       WHEN NTT_BWD,
        pw_mul_dsp_a    WHEN MUL_ADD,
        pw_mul_dsp_a    WHEN MUL_2,
        pw_mul_dsp_a    WHEN MUL_NINV,
        (OTHERS => '0') WHEN OTHERS;
    
    WITH state SELECT dsp_b <=
        ntt_dsp_b       WHEN NTT_SP,
        ntt_dsp_b       WHEN NTT_EP,
        ntt_dsp_b       WHEN NTT_BWD,
        pw_mul_dsp_b    WHEN MUL_ADD,
        pw_mul_dsp_b    WHEN MUL_2,
        pw_mul_dsp_b    WHEN MUL_NINV,
        (OTHERS => '0') WHEN OTHERS;
    
    WITH state SELECT dsp_c <=
        ntt_dsp_c       WHEN NTT_SP,
        ntt_dsp_c       WHEN NTT_EP,
        ntt_dsp_c       WHEN NTT_BWD,
        pw_mul_dsp_c    WHEN MUL_ADD,
        pw_mul_dsp_c    WHEN MUL_2,
        pw_mul_dsp_c    WHEN MUL_NINV,
        (OTHERS => '0') WHEN OTHERS;
    
    WITH state SELECT dsp_d <=
        ntt_dsp_d       WHEN NTT_SP,
        ntt_dsp_d       WHEN NTT_EP,
        ntt_dsp_d       WHEN NTT_BWD,
        pw_mul_dsp_d    WHEN MUL_ADD,
        pw_mul_dsp_d    WHEN MUL_2,
        pw_mul_dsp_d    WHEN MUL_NINV,
        (OTHERS => '0') WHEN OTHERS;
        
    add_a_in        <= reg0_dout_a;           

END Behavioral;