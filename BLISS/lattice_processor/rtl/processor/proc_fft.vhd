--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.lattice_processor.all;


entity proc_fft is
  --Block RAMs/PE is only accessible when the general pupose command
  --INST_NTT_GP_MODE has been triggered. Afterwards the INST_NTT_NTT_MODE
  --command is need to allow FFT operations again

  generic (
    INIT_ARRAY_VALUE_FFT : integer   := 0;
    XN                   : integer   := -1;  --ring (-1 or 1)
    N_ELEMENTS           : integer   := 32;
    PRIME_P_WIDTH        : integer   := 5;
    PRIME_P              : unsigned;
    PSI                  : unsigned;
    OMEGA                : unsigned;
    PSI_INVERSE          : unsigned;
    OMEGA_INVERSE        : unsigned;
    W_TABLE_SLAVE        : std_logic := '0';
    N_INVERSE            : unsigned
    );
  port (
    clk : in std_logic;

    ntt_ready : out std_logic                                  := '0';
    ntt_start : in  std_logic                                  := '0';
    ntt_op    : in  std_logic_vector(NTT_INST_SIZE-1 downto 0) := (others => '0');

    --Allows access to the internal RAM structure
    -- Port 1 for the FFT
    fft_ram0_rd_addr : in  std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    fft_ram0_rd_do   : out std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');

    fft_ram0_wr_addr : in std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    fft_ram0_wr_di   : in std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');
    fft_ram0_wr_we   : in std_logic                                                          := '0';

    -- Port 2 for the FFT
    fft_ram1_rd_addr : in  std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    fft_ram1_rd_do   : out std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');

    fft_ram1_wr_addr : in std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    fft_ram1_wr_di   : in std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');
    fft_ram1_wr_we   : in std_logic                                                          := '0';

    fft_ram_delay : out integer := 5;

    --Cycles counter: optional debugging port for cycle measurement
    cycles : out unsigned(31 downto 0) := (others => '0')

    );
end proc_fft;

architecture Behavioral of proc_fft is
  constant ADDR_WIDTH : integer := integer(ceil(log2(real(N_ELEMENTS))));

  type eg_state is (IDLE, NTT_BITREV_A, NTT_BITREV_B, NTT_BITREV_WAIT, NTT_NTT_A, NTT_NTT_B , NTT_NTT_WAIT, NTT_POINTWISE_MUL, NTT_POINTWISE_MUL_WAIT, NTT_INTT, NTT_INV_PSI, NTT_INV_PSI_WAIT, NTT_INV_N, NTT_INV_N_WAIT, NTT_GP_MODE);

  signal state_reg           : eg_state  := IDLE;
  signal internal_a_constant : std_logic := '0';

  constant MUX_OPTIONS : integer := 9;

  constant MUX_MAR_TO_BITREV : integer := 1;
  constant MUX_W_TO_BITREV   : integer := 1;
  constant MUX_MAR_TO_FFT    : integer := 2;
  constant MUX_W_TO_FFT      : integer := 2;
  constant MUX_MAR_TO_PW     : integer := 3;
  constant MUX_W_TO_IPSI     : integer := 3;
  constant MUX_MAR_TO_IPSI   : integer := 4;
  constant MUX_MAR_TO_INVN   : integer := 4;  --5
  constant MUX_MAR_TO_EXTERN : integer := 6;

  constant MUX_BITREV_TO_BRAM : integer := 6;
  constant MUX_FFT_TO_BRAM    : integer := 4;

  constant MUX_BITREV_TO_BRAM_A : integer := 4;
  constant MUX_BITREV_TO_BRAM_B : integer := 5;

  constant MUX_IPSI_TO_BRAM_B : integer := 7;
  constant MUX_INVN_TO_BRAM_B : integer := 7;  --8

  constant MUX_PW_TO_BRAM_A : integer := 2;
  constant MUX_PW_TO_BRAM_B : integer := 3;

  constant MUX_R0_TO_BITREV : integer := 1;
  constant MUX_R1_TO_BITREV : integer := 2;

  constant WRITE_INTO_BRAM_A : integer := 0;
  constant WRITE_INTO_BRAM_B : integer := 1;


  type storage_type is array (MUX_OPTIONS-1 downto 0) of unsigned(PRIME_P_WIDTH-1 downto 0);
  type storage_type_addr is array (MUX_OPTIONS-1 downto 0) of unsigned(ADDR_WIDTH-1 downto 0);
  type storage_type_std is array (MUX_OPTIONS-1 downto 0) of std_logic_vector(PRIME_P_WIDTH-1 downto 0);
  type storage_type_addr_std is array (MUX_OPTIONS-1 downto 0) of std_logic_vector(ADDR_WIDTH-1 downto 0);
  type storage_op is array (MUX_OPTIONS-1 downto 0) of std_logic_vector(0 downto 0);

  --Bitrev
  signal bitrev_din   : unsigned(PRIME_P_WIDTH-1 downto 0);  --ostorage_type;
  signal bitrev_valid : std_logic := '0';

  signal bitrev_ready    : std_logic                                := '0';
  signal bitrev_finished : std_logic                                := '0';
  signal w_psi_req       : std_logic_vector(MUX_OPTIONS-1 downto 0) := (others => '0');
  signal w_inverse_req   : std_logic_vector(MUX_OPTIONS-1 downto 0) := (others => '0');
  signal w_index         : storage_type_addr                        := (others => (others => '0'));
  signal w_out_val       : unsigned(PRIME_P_WIDTH-1 downto 0);  --ostorage_type;
  signal w_delay         : integer                                  := 5;
  signal a_op            : storage_op                               := (others => (others => '0'));
  signal a_w_in          : storage_type                             := (others => (others => '0'));
  signal a_a_in          : storage_type                             := (others => (others => '0'));
  signal a_b_in          : storage_type                             := (others => (others => '0'));
  signal a_x_out         : unsigned(PRIME_P_WIDTH-1 downto 0);
  signal a_delay         : integer                                  := 8;

  signal bram_wea   : std_logic_vector(MUX_OPTIONS-1 downto 0)   := (others => '0');
  signal bram_web   : std_logic_vector(MUX_OPTIONS-1 downto 0)   := (others => '0');
  signal bram_addra : storage_type_addr_std                      := (others => (others => '0'));
  signal bram_addrb : storage_type_addr_std                      := (others => (others => '0'));
  signal bram_dia   : storage_type_std                           := (others => (others => '0'));
  signal bram_dib   : storage_type_std                           := (others => (others => '0'));
  signal bram_doa   : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal bram_dob   : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');

  --BRAM A
  signal bram_a_wea     : std_logic;
  signal bram_a_web     : std_logic;
  signal bram_a_addra   : std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
  signal bram_a_addrb   : std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
  signal bram_a_dia     : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal bram_a_dib     : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal bram_a_doa     : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal bram_a_dob     : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal bram_a_doa_int : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal bram_a_dob_int : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal bram_a_dic     : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal bram_a_dod     : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal bram_a_addrd   : std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
  signal bram_a_addrc   : std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
  signal bram_a_wec     : std_logic;

  --BRAM B
  signal bram_b_wea     : std_logic;
  signal bram_b_web     : std_logic;
  signal bram_b_addra   : std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
  signal bram_b_addrb   : std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
  signal bram_b_dia     : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal bram_b_dib     : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal bram_b_doa     : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal bram_b_dob     : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal bram_b_doa_int : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal bram_b_dob_int : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal bram_b_dic     : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal bram_b_dod     : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal bram_b_addrd   : std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
  signal bram_b_addrc   : std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
  signal bram_b_wec     : std_logic;

  signal fft_dic   : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal fft_dod   : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal fft_addrd : std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
  signal fft_addrc : std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
  signal fft_wec   : std_logic;

  signal ntt_start_r : std_logic;

  signal a_x_sub_out : unsigned(PRIME_P_WIDTH-1 downto 0) := (others => '0');

  --Connections
  signal conn_mar    : integer := 0;
  signal conn_w      : integer := 0;
  signal conn_bram   : integer := 0;
  signal bram_delay  : integer := 8;
  signal sel_bram    : integer := 0;
  signal conn_bitrev : integer := 0;

  --FFTs
  signal fft_start    : std_logic := '0';
  signal fft_inverse  : std_logic := '0';
  signal fft_finished : std_logic := '0';

  signal w_delay_intern : integer := 0;
  signal a_delay_intern : integer := 0;

  --PW
  signal pw_start    : std_logic := '0';
  signal pw_finished : std_logic := '0';
  signal pointwise   : std_logic := '0';

  signal output_counter : integer := 0;

  signal finished_reg_delay : integer                      := 0;
  signal fin_rin            : std_logic_vector(0 downto 0) := (others => '0');
  signal fin_rout           : std_logic_vector(0 downto 0) := (others => '0');

  signal val_out_reg_delay : integer                      := 0;
  signal val_out_rin       : std_logic_vector(0 downto 0) := (others => '0');
  signal val_out_rout      : std_logic_vector(0 downto 0) := (others => '0');

  signal ipsi_start    : std_logic := '0';
  signal ipsi_finished : std_logic := '0';

  signal w_psi_req_in     : std_logic := '0';
  signal w_inverse_req_in : std_logic := '0';

--INversen
  signal inv_n_start       : std_logic                          := '0';
  signal inv_n_finished    : std_logic                          := '0';
  signal inv_n_coeff_valid : std_logic                          := '0';
  signal inv_n_coeff_in    : unsigned(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal inv_n_coeff_op    : std_logic                          := '0';

  signal clk_1        : std_logic := '0';
  signal gp_mode_flag : std_logic := '0';


  signal w_in_V      : std_logic_vector (13 downto 0);
  signal a_in_V      : std_logic_vector (13 downto 0);
  signal b_in_V      : std_logic_vector (13 downto 0);
  signal x_add_out_V : std_logic_vector (13 downto 0);
  signal x_sub_out_V : std_logic_vector (13 downto 0);

  signal ap_rst : std_logic := '1';
begin
  clk_1 <= clk;
  process (clk_1)
    variable counter : unsigned(cycles'length-1 downto 0) := (others => '0');
  begin  -- process
    if rising_edge(clk_1) then
      --increment the cylce clounter
      if state_reg /= IDLE then
        counter := counter +1;
      end if;
      --reset when unit is started
      if ntt_start = '1' then
        counter := (others => '0');
      end if;

      if state_reg = IDLE then
        cycles <= counter;
      end if;
    end if;
  end process;


  not_12289 : if PRIME_P /= 12289 generate
    a_delay <= a_delay_intern+1;        -- a_delay_intern +1;
    fft_mar_1 : entity work.fft_mar
      generic map (
        W_WIDTH         => PRIME_P_WIDTH,
        A_WIDTH         => PRIME_P_WIDTH,
        B_WIDTH         => PRIME_P_WIDTH,
        RED_PRIME_WIDTH => PRIME_P_WIDTH,
        RED_PRIME       => PRIME_P
        )
      port map (
        clk       => clk_1,
        w_in      => a_w_in(0),
        a_in      => a_a_in(0),
        b_in      => a_b_in(0),
        x_add_out => a_x_out,
        x_sub_out => a_x_sub_out,
        delay     => a_delay_intern
        );
  end generate not_12289;


  prime_12289 : if PRIME_P = 12289 generate
    a_delay <= 6+1;

    w_in_V      <= std_logic_vector(a_w_in(0));
    a_in_V      <= std_logic_vector(a_a_in(0));
    b_in_V      <= std_logic_vector(a_b_in(0));
    a_x_out     <= unsigned(x_add_out_V);
    a_x_sub_out <= unsigned(x_sub_out_V);

    fft_mar_12289_1 : entity work.fft_mar_12289
      port map (
        ap_clk      => clk_1,
        ap_rst      => ap_rst,
        w_in_V      => w_in_V,
        a_in_V      => a_in_V,
        b_in_V      => b_in_V,
        x_add_out_V => x_add_out_V,
        x_sub_out_V => x_sub_out_V
        );

  end generate prime_12289;

  w_delay <= w_delay_intern +1;
  w_table_1 : entity work.w_table_improved
    generic map (
      XN            => XN,
      N_ELEMENTS    => N_ELEMENTS,
      PRIME_P_WIDTH => PRIME_P_WIDTH,
      PRIME_P       => PRIME_P,
      PSI           => PSI,
      OMEGA         => OMEGA,
      PSI_INVERSE   => PSI_INVERSE,
      OMEGA_INVERSE => OMEGA_INVERSE
      )
    port map (
      clk         => clk_1,
      psi_req     => w_psi_req_in,
      inverse_req => w_inverse_req_in,
      index       => w_index(0),
      out_val     => w_out_val,
      delay       => w_delay_intern
      );

  bram_delay    <= 1+3+2;
  fft_ram_delay <= bram_delay;
  fft_top_1 : entity work.fft_top
    generic map (
      N_ELEMENTS    => N_ELEMENTS,
      PRIME_P_WIDTH => PRIME_P_WIDTH,
      XN            => XN)
    port map (
      clk           => clk_1,
      usr_start     => fft_start,
      usr_inverse   => fft_inverse,
      usr_finished  => fft_finished,
      w_psi_req     => w_psi_req(MUX_W_TO_FFT),
      w_inverse_req => w_inverse_req(MUX_W_TO_FFT),
      w_index       => w_index(MUX_W_TO_FFT),
      w_out_val     => w_out_val,
      w_delay       => w_delay,

      a_x_add_out => a_x_out,
      a_x_sub_out => a_x_sub_out,

      a_w_in => a_w_in(MUX_MAR_TO_FFT),
      a_a_in => a_a_in(MUX_MAR_TO_FFT),
      a_b_in => a_b_in(MUX_MAR_TO_FFT),

      a_delay    => a_delay,
      bram_addra => bram_addra(MUX_FFT_TO_BRAM),
      bram_doa   => bram_doa,
      bram_addrb => bram_addrb(MUX_FFT_TO_BRAM),
      bram_dib   => bram_dib(MUX_FFT_TO_BRAM),
      bram_web   => bram_web(MUX_FFT_TO_BRAM),
      bram_delay => bram_delay,

      bram_addrc => fft_addrc,
      bram_dic   => fft_dic,
      bram_wec   => fft_wec,
      bram_addrd => fft_addrd,
      bram_dod   => fft_dod
      );


  bitrev_din <= unsigned(fft_ram0_wr_di) when conn_bitrev = MUX_R0_TO_BITREV
                else unsigned(fft_ram1_wr_di) when conn_bitrev = MUX_R1_TO_BITREV
                else (others => '0');

  bitrev_valid <= fft_ram0_wr_we when conn_bitrev = MUX_R0_TO_BITREV
                  else fft_ram1_wr_we when conn_bitrev = MUX_R1_TO_BITREV
                  else '0';

  -- Bitrevision unit
  bitrev : entity work.bitrev
    generic map (
      N_ELEMENTS    => N_ELEMENTS,
      PRIME_P_WIDTH => PRIME_P_WIDTH,
      XN            => XN
      )
    port map (
      clk             => clk_1,
      usr_valid       => bitrev_valid,
      usr_coefficient => bitrev_din,
      usr_ready       => bitrev_ready,
      usr_finished    => bitrev_finished,
      w_psi_req       => w_psi_req(MUX_W_TO_BITREV),
      w_inverse_req   => w_inverse_req(MUX_W_TO_BITREV),
      w_index         => w_index(MUX_W_TO_BITREV),
      w_out_val       => w_out_val,
      w_delay         => w_delay,
      a_op            => a_op(MUX_MAR_TO_BITREV),
      a_w_in          => a_w_in(MUX_MAR_TO_BITREV),
      a_a_in          => a_a_in(MUX_MAR_TO_BITREV),
      a_b_in          => a_b_in(MUX_MAR_TO_BITREV),
      a_x_out         => a_x_out,
      a_delay         => a_delay,
      bram_addra      => bram_addra(6),
      bram_din        => bram_dia(6),
      bram_we         => bram_wea(6)
      );


  --Combined INVN and IPSI_Mul component
  coeff_ops_1 : entity work.coeff_ops
    generic map (
      N_ELEMENTS    => N_ELEMENTS,
      N_INVERSE     => N_INVERSE,
      PRIME_P_WIDTH => PRIME_P_WIDTH,
      XN            => XN)
    port map (
      clk                => clk,
      usr_inv_n_start    => inv_n_start,
      usr_inv_n_finished => inv_n_finished,

      usr_ipsi_start    => ipsi_start,
      usr_ipsi_finished => ipsi_finished,
      --Connection to w table
      w_psi_req         => w_psi_req(MUX_W_TO_IPSI),
      w_inverse_req     => w_inverse_req(MUX_W_TO_IPSI),
      w_index           => w_index(MUX_W_TO_IPSI),
      w_out_val         => w_out_val,
      w_delay           => w_delay,
      --Conection to MAR
      a_op              => a_op(MUX_MAR_TO_INVN),
      a_w_in            => a_w_in(MUX_MAR_TO_INVN),
      a_a_in            => a_a_in(MUX_MAR_TO_INVN),
      a_b_in            => a_b_in(MUX_MAR_TO_INVN),
      a_x_out           => a_x_out,
      a_delay           => a_delay,
      --Connection to RAM
      bram_delay        => bram_delay,
      bram_addra        => bram_addra(MUX_INVN_TO_BRAM_B),
      bram_doa          => bram_doa,
      bram_addrb        => bram_addrb(MUX_INVN_TO_BRAM_B),
      bram_dib          => bram_dib(MUX_INVN_TO_BRAM_B),
      bram_web          => bram_web(MUX_INVN_TO_BRAM_B)
      );

  --Pointwise multiplication
  pw_mul_1 : entity work.pw_mul
    generic map (
      N_ELEMENTS    => N_ELEMENTS,
      PRIME_P_WIDTH => PRIME_P_WIDTH
      )
    port map (
      clk        => clk_1,
      start      => pw_start,
      finished   => pw_finished,
      a_op       => a_op(MUX_MAR_TO_PW),
      a_w_in     => a_w_in(MUX_MAR_TO_PW),
      a_a_in     => a_a_in(MUX_MAR_TO_PW),
      a_b_in     => a_b_in(MUX_MAR_TO_PW),
      a_x_out    => a_x_out,
      a_delay    => a_delay,
      bram_delay => bram_delay,
      bram_addra => bram_addra(MUX_PW_TO_BRAM_A),
      bram_doa   => bram_a_doa,

      bram_addrb => bram_addra(MUX_PW_TO_BRAM_B),
      bram_dob   => bram_b_doa,
      bram_addrc => bram_addrb(MUX_PW_TO_BRAM_B),
      bram_dic   => bram_dib(MUX_PW_TO_BRAM_B),
      bram_wec   => bram_web(MUX_PW_TO_BRAM_B)
      );


  --use_bram_a : if 1 = 2 generate
  --  --Pseudo four port BRAM (needed for NTT)
  --  bram_a : entity work.four_port_Bram
  --    generic map (
  --      SIZE       => N_ELEMENTS,
  --      ADDR_WIDTH => ADDR_WIDTH,
  --      COL_WIDTH  => PRIME_P_WIDTH,
  --      add_reg_a  => 0,
  --      add_reg_b  => 0,
  --      InitFile   => ""
  --      )
  --    port map (
  --      clk   => clk_1,
  --      wea   => bram_a_wea,
  --      web   => bram_a_web,
  --      addra => bram_a_addra,
  --      addrb => bram_a_addrb,
  --      dia   => bram_a_dia,            --not used by FFT
  --      dib   => bram_a_dib,
  --      doa   => bram_a_doa_int,
  --      dob   => bram_a_dob_int,

  --      addrc => bram_a_addrc,
  --      dic   => bram_a_dic,
  --      wec   => bram_a_wec,
  --      addrd => bram_a_addrd,
  --      dod   => bram_a_dod
  --      );
  --end generate use_bram_a;

 
    --We do not need bram_a as a NTT RAM
    --Cannot change bram_b as it is target of pw_mul
    bram_with_delay_1 : entity work.bram_with_delay
      generic map (
        SIZE       => N_ELEMENTS,
        ADDR_WIDTH => ADDR_WIDTH,
        COL_WIDTH  => PRIME_P_WIDTH,
        add_reg_a  => 1,
        add_reg_b  => 1,
        InitFile   => get_init_vector(INIT_ARRAY_VALUE_FFT)
        )
      port map (
        clka  => clk,
        clkb  => clk,
        ena   => '1',
        enb   => '1',
        wea   => bram_a_wea,
        web   => bram_a_web,
        addra => bram_a_addra,
        addrb => bram_a_addrb,
        dia   => bram_a_dia,            --not used by FFT
        dib   => bram_a_dib,
        doa   => bram_a_doa_int,
        dob   => bram_a_dob_int
        );


  --Pseudo four port BRAM (needed for NTT)
  bram_b : entity work.four_port_Bram
    generic map (
      SIZE       => N_ELEMENTS,
      ADDR_WIDTH => ADDR_WIDTH,
      COL_WIDTH  => PRIME_P_WIDTH,
      add_reg_a  => 0,
      add_reg_b  => 0,
      InitFile   => ""
      )
    port map (
      clk => clk_1,

      wea   => bram_b_wea,
      web   => bram_b_web,
      addra => bram_b_addra,
      addrb => bram_b_addrb,
      dia   => bram_b_dia,
      dib   => bram_b_dib,
      doa   => bram_b_doa_int,
      dob   => bram_b_dob_int,

      addrc => bram_b_addrc,
      dic   => bram_b_dic,
      wec   => bram_b_wec,
      addrd => bram_b_addrd,
      dod   => bram_b_dod

      );


  fsm : process (clk_1)
  begin  -- process
    if rising_edge(clk_1) then          -- rising clock edge
      --egister Transfer
      --Connections of MAR
      ap_rst <= '0';

      a_w_in(0) <= a_w_in(conn_mar);
      a_a_in(0) <= a_a_in(conn_mar);
      a_b_in(0) <= a_b_in(conn_mar);
      a_op(0)   <= a_op(conn_mar);

      --Connections of W Table
      w_psi_req_in     <= w_psi_req(conn_w);
      w_inverse_req_in <= w_inverse_req(conn_w);
      w_index(0)       <= w_index(conn_w);

      --FFT only ports
      bram_b_addrc <= fft_addrc;
      bram_b_dic   <= fft_dic;
      bram_b_wec   <= fft_wec;
      bram_b_addrd <= fft_addrd;
      fft_dod      <= bram_b_dod;

      if pointwise = '0' then
        --Connection of BRAM
        if sel_bram = 0 then
          bram_a_wea   <= bram_wea(conn_bram);
          bram_a_web   <= bram_web(conn_bram);
          bram_a_addra <= bram_addra(conn_bram);
          bram_a_addrb <= bram_addrb(conn_bram);
          bram_a_dia   <= bram_dia(conn_bram);
          bram_a_dib   <= bram_dib(conn_bram);
          bram_doa     <= bram_a_doa_int;
          bram_dob     <= bram_a_dob_int;
          bram_b_wea   <= '0';
          bram_b_web   <= '0';

          ----FFT only ports
          --bram_a_addrc <= fft_addrc;
          --bram_a_dic   <= fft_dic;
          --bram_a_wec   <= fft_wec;
          --bram_a_addrd <= fft_addrd;
          --fft_dod      <= bram_a_dod;
        else
          bram_b_wea   <= bram_wea(conn_bram);
          bram_b_web   <= bram_web(conn_bram);
          bram_b_addra <= bram_addra(conn_bram);
          bram_b_addrb <= bram_addrb(conn_bram);
          bram_b_dia   <= bram_dia(conn_bram);
          bram_b_dib   <= bram_dib(conn_bram);
          bram_doa     <= bram_b_doa_int;
          bram_dob     <= bram_b_dob_int;
          bram_a_wea   <= '0';
          bram_a_web   <= '0';  
        end if;
      else
        if pointwise = '1' then
          bram_a_wea   <= bram_wea(MUX_PW_TO_BRAM_A);
          bram_a_web   <= bram_web(MUX_PW_TO_BRAM_A);
          bram_a_addra <= bram_addra(MUX_PW_TO_BRAM_A);
          bram_a_addrb <= bram_addrb(MUX_PW_TO_BRAM_A);
          bram_a_dia   <= bram_dia(MUX_PW_TO_BRAM_A);
          bram_a_dib   <= bram_dib(MUX_PW_TO_BRAM_A);
          bram_a_doa   <= bram_a_doa_int;
          bram_a_dob   <= bram_a_dob_int;

          bram_b_wea   <= bram_wea(MUX_PW_TO_BRAM_B);
          bram_b_web   <= bram_web(MUX_PW_TO_BRAM_B);
          bram_b_addra <= bram_addra(MUX_PW_TO_BRAM_B);
          bram_b_addrb <= bram_addrb(MUX_PW_TO_BRAM_B);
          bram_b_dia   <= bram_dia(MUX_PW_TO_BRAM_B);
          bram_b_dib   <= bram_dib(MUX_PW_TO_BRAM_B);
          bram_b_doa   <= bram_b_doa_int;
          bram_b_dob   <= bram_b_dob_int;
        end if;
        
      end if;
      if gp_mode_flag = '1' then
        bram_a_web     <= fft_ram0_wr_we;
        bram_a_addra   <= fft_ram0_rd_addr;
        bram_a_addrb   <= fft_ram0_wr_addr;
        bram_a_dib     <= fft_ram0_wr_di;
        fft_ram0_rd_do <= bram_a_doa_int;

        bram_b_web     <= fft_ram1_wr_we;
        bram_b_addra   <= fft_ram1_rd_addr;
        bram_b_addrb   <= fft_ram1_wr_addr;
        bram_b_dib     <= fft_ram1_wr_di;
        fft_ram1_rd_do <= bram_b_doa_int;
      end if;

      --Set defaults
      --defaults
      fin_rin(0)     <= '0';
      val_out_rin(0) <= '0';
      fft_inverse    <= '0';
      ipsi_start     <= '0';
      fft_start      <= '0';
      pw_start       <= '0';
      inv_n_start    <= '0';
      ntt_ready      <= '0';

      --State machine that controlls the internals microcode of the NTT multiplier
      case state_reg is
        when IDLE =>
          ntt_ready <= '1';
          pointwise <= '0';

          conn_mar <= MUX_MAR_TO_EXTERN;
          if ntt_start = '1' then
            gp_mode_flag <= '0';
            if ntt_op = INST_NTT_BITREV_A then
              state_reg <= NTT_BITREV_A;
            elsif ntt_op = INST_NTT_BITREV_B then
              state_reg <= NTT_BITREV_B;
            elsif ntt_op = INST_NTT_NTT_A then
              state_reg <= NTT_NTT_A;
            elsif ntt_op = INST_NTT_NTT_B then
              state_reg <= NTT_NTT_b;
            elsif ntt_op = INST_NTT_POINTWISE_MUL then
              state_reg <= NTT_POINTWISE_MUL;
            elsif ntt_op = INST_NTT_INTT then
              state_reg <= NTT_INTT;
            elsif ntt_op = INST_NTT_INV_N then
              state_reg <= NTT_INV_N;
            elsif ntt_op = INST_NTT_INV_PSI then
              state_reg <= NTT_INV_PSI;
            elsif ntt_op = INST_NTT_GP_MODE then
              state_reg <= NTT_GP_MODE;
            end if;
          end if;

        when NTT_BITREV_A =>
           report "NOT SUPPORTED" severity error;
          state_reg <= IDLE;
          --conn_mar    <= MUX_MAR_TO_BITREV;
          --conn_bram   <= MUX_BITREV_TO_BRAM;
          --conn_w      <= MUX_W_TO_BITREV;
          --conn_bitrev <= MUX_R0_TO_BITREV;
          --sel_bram    <= WRITE_INTO_BRAM_A;
          --state_reg   <= NTT_BITREV_WAIT;
          
        when NTT_BITREV_B =>
          conn_mar    <= MUX_MAR_TO_BITREV;
          conn_bram   <= MUX_BITREV_TO_BRAM;
          conn_w      <= MUX_W_TO_BITREV;
          conn_bitrev <= MUX_R1_TO_BITREV;
          sel_bram    <= WRITE_INTO_BRAM_B;
          state_reg   <= NTT_BITREV_WAIT;

        when NTT_BITREV_WAIT =>
          if bitrev_finished = '1' then
            state_reg   <= IDLE;
            conn_bitrev <= 0;
          end if;
          
        when NTT_NTT_A =>
           report "NOT SUPPORTED" severity error;
          state_reg <= IDLE;
          --conn_bram <= MUX_FFT_TO_BRAM;
          --conn_mar  <= MUX_MAR_TO_FFT;
          --conn_w    <= MUX_W_TO_FFT;
          --sel_bram  <= WRITE_INTO_BRAM_A;
          --fft_start <= '1';
          --state_reg <= NTT_NTT_WAIT;

        when NTT_NTT_B =>
          conn_bram <= MUX_FFT_TO_BRAM;
          conn_mar  <= MUX_MAR_TO_FFT;
          conn_w    <= MUX_W_TO_FFT;
          sel_bram  <= WRITE_INTO_BRAM_B;
          fft_start <= '1';

          state_reg <= NTT_NTT_WAIT;
          
        when NTT_NTT_WAIT =>
          if fft_finished = '1' then
            state_reg <= IDLE;
          end if;
          
        when NTT_POINTWISE_MUL =>
          state_reg <= NTT_POINTWISE_MUL_WAIT;
          sel_bram  <= WRITE_INTO_BRAM_B;
          pointwise <= '1';
          conn_mar  <= MUX_MAR_TO_PW;
          pw_start  <= '1';

        when NTT_POINTWISE_MUL_WAIT =>
          if pw_finished = '1' then
            state_reg <= IDLE;
          end if;


          
          
        when NTT_INTT =>
          conn_bram   <= MUX_FFT_TO_BRAM;
          conn_mar    <= MUX_MAR_TO_FFT;
          conn_w      <= MUX_W_TO_FFT;
          sel_bram    <= WRITE_INTO_BRAM_B;
          pointwise   <= '0';
          fft_inverse <= '1';
          fft_start   <= '1';
          state_reg   <= NTT_NTT_WAIT;

        when NTT_INV_PSI =>
          output_counter <= 0;
          ipsi_start     <= '1';
          sel_bram       <= WRITE_INTO_BRAM_B;
          conn_bram      <= MUX_IPSI_TO_BRAM_B;
          conn_mar       <= MUX_MAR_TO_IPSI;
          conn_w         <= MUX_W_TO_IPSI;
          state_reg      <= NTT_INV_PSI_WAIT;

        when NTT_INV_PSI_WAIT =>
          if ipsi_finished = '1' then
            state_reg <= IDLE;
          end if;

        when NTT_INV_N =>
          inv_n_start       <= '1';
          sel_bram          <= WRITE_INTO_BRAM_B;
          conn_bram         <= MUX_INVN_TO_BRAM_B;
          conn_mar          <= MUX_MAR_TO_INVN;
          inv_n_coeff_valid <= '1';
          state_reg         <= NTT_INV_N_WAIT;
          
        when NTT_INV_N_WAIT =>
          if inv_n_finished = '1' then
            state_reg <= IDLE;
          end if;

        when NTT_GP_MODE =>
          gp_mode_flag <= '1';
          conn_mar     <= MUX_MAR_TO_EXTERN;

          state_reg <= IDLE;
      end case;

      ntt_start_r <= ntt_start;
      if ntt_start = '1' or ntt_start_r = '1' then
        ntt_ready <= '0';
      end if;
      
    end if;
  end process fsm;
end Behavioral;






























































