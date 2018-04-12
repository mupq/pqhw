----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:30:37 03/23/2012 
-- Design Name: 
-- Module Name:    poly_mul_top - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;



entity poly_mul_top is
  generic (
    XN            : integer   := -1;    --ring (-1 or 1)
    N_ELEMENTS    : integer   := 32;
    PRIME_P_WIDTH : integer   := 5;
    PRIME_P       : unsigned;
    PSI           : unsigned;
    OMEGA         : unsigned;
    PSI_INVERSE   : unsigned;
    OMEGA_INVERSE : unsigned;
    W_TABLE_SLAVE : std_logic := '0';
    N_INVERSE     : unsigned
    );
  port (
    clk        : in  std_logic;
    start      : in  std_logic;
    finished   : out std_logic := '0';
    a_constant : in  std_logic;

    --flow control
    a_ready  : out std_logic := '0';
    a_filled : out std_logic := '0';
    b_ready  : out std_logic := '0';
    b_filled : out std_logic := '0';


    --Used to input coefficients into the polynomial multiplier
    din_valid       : in  std_logic := '0';
    din_coefficient : in  unsigned(PRIME_P_WIDTH-1 downto 0);
    din_finished    : out std_logic := '0';

    --Used as output
    dout_valid       : out std_logic;
    dout_coefficient : out unsigned(PRIME_P_WIDTH-1 downto 0);

    
    --Cycles counter
    cycles                  : out unsigned(31 downto 0)              := (others => '0');  --optional debugging
                                        --port for cycle measurement
    --If used as W_Table Master
    w_master_w_out_val      : out unsigned(PRIME_P_WIDTH-1 downto 0) := (others => '0');
    w_master_w_delay_intern : out integer                            := 0;

    w_slave_w_out_val      : in unsigned(PRIME_P_WIDTH-1 downto 0) := (others => '0');
    w_slave_w_delay_intern : in integer                            := 0



    );
end poly_mul_top;

architecture Behavioral of poly_mul_top is
  constant ADDR_WIDTH : integer := integer(ceil(log2(real(N_ELEMENTS))));

  type   eg_state is (IDLE, INPUT_POLY_A, INPUT_POLY_B, FFT_A, FFT_B, PREPARE_FFT, POINTWISE_MUL, INVERSE_FFT, OUTPUT, IPSI_CAL, INV_N, CLEANUP);
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
  constant MUX_MAR_TO_INVN   : integer := 5;

  constant MUX_BITREV_TO_BRAM : integer := 6;
  constant MUX_FFT_TO_BRAM    : integer := 4;

  constant MUX_BITREV_TO_BRAM_A : integer := 4;
  constant MUX_BITREV_TO_BRAM_B : integer := 5;

  constant MUX_IPSI_TO_BRAM_B : integer := 7;
  constant MUX_INVN_TO_BRAM_B : integer := 8;


  constant MUX_PW_TO_BRAM_A : integer := 2;
  constant MUX_PW_TO_BRAM_B : integer := 3;


  constant WRITE_INTO_BRAM_A : integer := 0;
  constant WRITE_INTO_BRAM_B : integer := 1;


  type storage_type is array (MUX_OPTIONS-1 downto 0) of unsigned(PRIME_P_WIDTH-1 downto 0);
  type storage_type_addr is array (MUX_OPTIONS-1 downto 0) of unsigned(ADDR_WIDTH-1 downto 0);

  type storage_type_std is array (MUX_OPTIONS-1 downto 0) of std_logic_vector(PRIME_P_WIDTH-1 downto 0);

  type storage_type_addr_std is array (MUX_OPTIONS-1 downto 0) of std_logic_vector(ADDR_WIDTH-1 downto 0);


  type storage_op is array (MUX_OPTIONS-1 downto 0) of std_logic_vector(0 downto 0);

  --Bitrev

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
  signal a_delay         : integer                                  := 35;



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

  signal bram_a_dic   : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal bram_a_dod   : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal bram_a_addrd : std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
  signal bram_a_addrc : std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
  signal bram_a_wec   : std_logic;


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

  signal bram_b_dic   : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal bram_b_dod   : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal bram_b_addrd : std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
  signal bram_b_addrc : std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
  signal bram_b_wec   : std_logic;


  signal fft_dic   : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal fft_dod   : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal fft_addrd : std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
  signal fft_addrc : std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
  signal fft_wec   : std_logic;


  signal a_x_sub_out : unsigned(PRIME_P_WIDTH-1 downto 0) := (others => '0');

  --Connections
  signal conn_mar   : integer := 0;
  signal conn_w     : integer := 0;
  signal conn_bram  : integer := 0;
  signal bram_delay : integer := 10;
  signal sel_bram   : integer := 0;

  --FFTs
  signal fft_start    : std_logic := '0';
  signal fft_inverse  : std_logic := '0';
  signal fft_finished : std_logic := '0';


  signal w_delay_intern   : integer   := 0;
  signal a_delay_intern   : integer   := 0;
  signal bitrev_processed : std_logic := '0';

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


  signal clk_1 : std_logic := '0';



  -----------------------------------------------------------------------------
  -- Input/output registers
  -----------------------------------------------------------------------------

  signal start_reg      : std_logic;
  signal finished_reg   : std_logic := '0';
  signal a_constant_reg : std_logic;

  --flow control
  signal a_ready_reg  : std_logic := '0';
  signal a_filled_reg : std_logic := '0';
  signal b_ready_reg  : std_logic := '0';
  signal b_filled_reg : std_logic := '0';


  --Used to input coefficients into the polynomial multiplier
  signal din_valid_reg       : std_logic := '0';
  signal din_coefficient_reg : unsigned(PRIME_P_WIDTH-1 downto 0);
  signal din_finished_reg    : std_logic := '0';

  --Used as output
  signal dout_valid_reg       : std_logic;
  signal dout_coefficient_reg : unsigned(PRIME_P_WIDTH-1 downto 0);

  -----------------------------------------------------------------------------
  -- Input/output registers stage 2
  -----------------------------------------------------------------------------

  signal start_reg2      : std_logic;
  signal finished_reg2   : std_logic := '0';
  signal a_constant_reg2 : std_logic;

  --flow control
  signal a_ready_reg2  : std_logic := '0';
  signal a_filled_reg2 : std_logic := '0';
  signal b_ready_reg2  : std_logic := '0';
  signal b_filled_reg2 : std_logic := '0';


  --Used to input coefficients into the polynomial multiplier
  signal din_valid_reg2       : std_logic := '0';
  signal din_coefficient_reg2 : unsigned(PRIME_P_WIDTH-1 downto 0);
  signal din_finished_reg2    : std_logic := '0';

  --Used as output
  signal dout_valid_reg2       : std_logic;
  signal dout_coefficient_reg2 : unsigned(PRIME_P_WIDTH-1 downto 0);
  
begin


  clk_1 <= clk;

  process (clk_1)
  begin  -- process

--For large FPGA to deal with input delays
    
    if rising_edge(clk_1) then
      start_reg2           <= start;
      finished             <= finished_reg2;
      a_constant_reg2      <= a_constant;
      --flow control
      a_ready              <= a_ready_reg2;
      a_filled             <= a_filled_reg2;
      b_ready              <= b_ready_reg2;
      b_filled             <= b_filled_reg2;
      --Used to input coefficients into the polynomial multiplier
      din_valid_reg2       <= din_valid;
      din_coefficient_reg2 <= din_coefficient;
      din_finished         <= din_finished_reg2;
      --Used as output
      dout_valid           <= dout_valid_reg2;
      dout_coefficient     <= dout_coefficient_reg2;


      start_reg             <= start_reg2;
      finished_reg2         <= finished_reg;
      a_constant_reg        <= a_constant_reg2;
      --flow control
      a_ready_reg2          <= a_ready_reg;
      a_filled_reg2         <= a_filled_reg;
      b_ready_reg2          <= b_ready_reg;
      b_filled_reg2         <= b_filled_reg;
      --Used to input coefficients into the polynomial multiplier
      din_valid_reg         <= din_valid_reg2;
      din_coefficient_reg   <= din_coefficient_reg2;
      din_finished_reg2     <= din_finished_reg;
      --Used as output
      dout_valid_reg2       <= dout_valid_reg;
      dout_coefficient_reg2 <= dout_coefficient_reg;

    end if;
  end process;



  process (clk_1)
    variable counter : unsigned(cycles'length-1 downto 0) := (others => '0');
  begin  -- process
    if rising_edge(clk_1) then
      --increment the cylce clounter
      counter := counter +1;

      --reset when unit is started
      if start_reg = '1' then
        counter := (others => '0');
      end if;

      if fin_rout(0) = '1' then
        cycles <= counter;
      end if;
    end if;
  end process;




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

  a_delay <= a_delay_intern+1;          -- a_delay_intern +1;


  W_MODE_FALSE : if W_TABLE_SLAVE = '0' generate
    w_table_1 : entity work.w_table
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

    --In case beeing used as a master, we output the output of the w table
    w_master_w_out_val      <= w_out_val;
    w_master_w_delay_intern <= w_delay_intern;
    w_delay                 <= w_delay_intern +1;
  end generate W_MODE_FALSE;


  W_MODE_TRUE : if W_TABLE_SLAVE = '1' generate
    w_out_val      <= w_slave_w_out_val;
    w_delay_intern <= w_slave_w_delay_intern;
  end generate W_MODE_TRUE;




  bram_delay <= 1+3+2;
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


  -- Instantiate the Unit Under Test (UUT)
  bitrev : entity work.bitrev
    generic map (
      N_ELEMENTS    => N_ELEMENTS,
      PRIME_P_WIDTH => PRIME_P_WIDTH,
      XN            => XN
      )
    port map (
      clk             => clk_1,
      usr_valid       => din_valid_reg,
      usr_coefficient => din_coefficient_reg,
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

  
 
  ipsi_mul_1 : entity work.ipsi_mul
    generic map (
      N_ELEMENTS    => N_ELEMENTS,
      PRIME_P_WIDTH => PRIME_P_WIDTH,
      XN            => XN)
    port map (
      clk           => clk_1,
      usr_start     => ipsi_start,
      usr_finished  => ipsi_finished,
      w_psi_req     => w_psi_req(MUX_W_TO_IPSI),
      w_inverse_req => w_inverse_req(MUX_W_TO_IPSI),
      w_index       => w_index(MUX_W_TO_IPSI),
      w_out_val     => w_out_val,
      w_delay       => w_delay,
      a_op          => a_op(MUX_MAR_TO_IPSI) ,
      a_w_in        => a_w_in(MUX_MAR_TO_IPSI) ,
      a_a_in        => a_a_in(MUX_MAR_TO_IPSI) ,
      a_b_in        => a_b_in(MUX_MAR_TO_IPSI) ,
      a_x_out       => a_x_out,
      a_delay       => a_delay,
      bram_delay    => bram_delay,
      bram_addra    => bram_addra(MUX_IPSI_TO_BRAM_B),
      bram_doa      => bram_doa,
      bram_addrb    => bram_addrb(MUX_IPSI_TO_BRAM_B),
      bram_dib      => bram_dib(MUX_IPSI_TO_BRAM_B),
      bram_web      => bram_web(MUX_IPSI_TO_BRAM_B)
      );


  
  inv_n_mul_add_1 : entity work.inv_n_mul_add
    generic map (
      N_ELEMENTS    => N_ELEMENTS,
      N_INVERSE     => N_INVERSE,
      PRIME_P_WIDTH => PRIME_P_WIDTH,
      XN            => XN
      )
    port map (
      clk          => clk_1,
      usr_start    => inv_n_start,
      usr_finished => inv_n_finished,
      coeff_in     => inv_n_coeff_in,
      coeff_valid  => inv_n_coeff_valid,
      coeff_op     => inv_n_coeff_op,
      a_op         => a_op(MUX_MAR_TO_INVN),
      a_w_in       => a_w_in(MUX_MAR_TO_INVN),
      a_a_in       => a_a_in(MUX_MAR_TO_INVN),
      a_b_in       => a_b_in(MUX_MAR_TO_INVN),
      a_x_out      => a_x_out,
      a_delay      => a_delay,
      bram_delay   => bram_delay,
      bram_addra   => bram_addra(MUX_INVN_TO_BRAM_B),
      bram_doa     => bram_doa,
      bram_addrb   => bram_addrb(MUX_INVN_TO_BRAM_B),
      bram_dib     => bram_dib(MUX_INVN_TO_BRAM_B),
      bram_web     => bram_web(MUX_INVN_TO_BRAM_B)
      );

  dout_coefficient_reg <= unsigned(bram_dib(MUX_INVN_TO_BRAM_B));
  dout_valid_reg       <= bram_web(MUX_INVN_TO_BRAM_B);


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



  bram_a : entity work.four_port_Bram
    generic map (
      SIZE       => N_ELEMENTS,
      ADDR_WIDTH => ADDR_WIDTH,
      COL_WIDTH  => PRIME_P_WIDTH,
      add_reg_a  => 0,
      add_reg_b  => 0,
      InitFile   => ""
      )
    port map (
      clk   => clk_1,
      wea   => bram_a_wea,
      web   => bram_a_web,
      addra => bram_a_addra,
      addrb => bram_a_addrb,
      dia   => bram_a_dia,              --not used by FFT
      dib   => bram_a_dib,
      doa   => bram_a_doa_int,
      dob   => bram_a_dob_int,

      addrc => bram_a_addrc,
      dic   => bram_a_dic,
      wec   => bram_a_wec,
      addrd => bram_a_addrd,
      dod   => bram_a_dod
      );


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



  finished_reg_delay <= bram_delay;
  finished_ref_reg_1 : entity work.dyn_shift_reg
    generic map (
      width => 1
      )
    port map (
      clk    => clk_1,
      depth  => finished_reg_delay,
      Input  => fin_rin,
      Output => fin_rout
      );

  finished_reg <= fin_rout(0);



  fsm : process (clk_1)
  begin  -- process
    if rising_edge(clk_1) then          -- rising clock edge
      --egister Transfer
      --Connections of MAR
      a_w_in(0) <= a_w_in(conn_mar);
      a_a_in(0) <= a_a_in(conn_mar);
      a_b_in(0) <= a_b_in(conn_mar);
      a_op(0)   <= a_op(conn_mar);

      --Connections of W Table
      w_psi_req_in     <= w_psi_req(conn_w);
      w_inverse_req_in <= w_inverse_req(conn_w);
      w_index(0)       <= w_index(conn_w);

      if pointwise = '0' then
        --Connection of BRAM
        if sel_bram = 0 then
          bram_a_wea   <= bram_wea(conn_bram);
          bram_a_web   <= bram_web(conn_bram);
          bram_a_addra <= bram_addra(conn_bram);
          bram_a_addrb <= bram_addrb(conn_bram);
          bram_a_dia   <= bram_dia(conn_bram);
          bram_a_dib   <= bram_dib(conn_bram);

          bram_doa <= bram_a_doa_int;
          bram_dob <= bram_a_dob_int;


          bram_b_wea <= '0';
          bram_b_web <= '0';

          --FFT only ports
          bram_a_addrc <= fft_addrc;
          bram_a_dic   <= fft_dic;
          bram_a_wec   <= fft_wec;
          bram_a_addrd <= fft_addrd;
          fft_dod      <= bram_a_dod;  
        else
          bram_b_wea   <= bram_wea(conn_bram);
          bram_b_web   <= bram_web(conn_bram);
          bram_b_addra <= bram_addra(conn_bram);
          bram_b_addrb <= bram_addrb(conn_bram);
          bram_b_dia   <= bram_dia(conn_bram);
          bram_b_dib   <= bram_dib(conn_bram);

          bram_doa <= bram_b_doa_int;
          bram_dob <= bram_b_dob_int;

          bram_a_wea <= '0';
          bram_a_web <= '0';

          --FFT only ports
          bram_b_addrc <= fft_addrc;
          bram_b_dic   <= fft_dic;
          bram_b_wec   <= fft_wec;
          bram_b_addrd <= fft_addrd;
          fft_dod      <= bram_b_dod;
          
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
      --Set defaults
      --defaults
      a_ready_reg    <= '0';
      b_ready_reg    <= '0';
      a_filled_reg   <= '0';
      b_filled_reg   <= '0';
      fin_rin(0)     <= '0';
      val_out_rin(0) <= '0';
      fft_inverse    <= '0';
      ipsi_start     <= '0';
      fft_start      <= '0';
      pw_start       <= '0';
      inv_n_start    <= '0';

      case state_reg is

        when IDLE =>
          if start_reg = '1' then
            internal_a_constant <= a_constant_reg;
            conn_mar            <= MUX_MAR_TO_BITREV;
            conn_bram           <= MUX_BITREV_TO_BRAM;
            conn_w              <= MUX_W_TO_BITREV;
            conn_bram           <= MUX_BITREV_TO_BRAM;
            if a_constant_reg = '1' then
              if bitrev_ready = '1' then
                b_ready_reg <= '1';
                state_reg   <= INPUT_POLY_B;
                sel_bram    <= WRITE_INTO_BRAM_B;
              end if;
            else
              if bitrev_ready = '1' then
                a_ready_reg <= '1';
                state_reg   <= INPUT_POLY_A;
                sel_bram    <= WRITE_INTO_BRAM_A;
              end if;
            end if;
          end if;

        when INPUT_POLY_A =>
          if bitrev_finished = '1' then
            a_filled_reg     <= '1';
            bitrev_processed <= '1';
          end if;

          if bitrev_ready = '1' and bitrev_processed = '1' then
            b_ready_reg      <= '1';
            state_reg        <= INPUT_POLY_B;
            sel_bram         <= WRITE_INTO_BRAM_B;
            bitrev_processed <= '0';
          end if;


        when INPUT_POLY_B =>
          if bitrev_finished = '1' then
            b_filled_reg <= '1';
            state_reg    <= PREPARE_FFT;
          end if;

          
        when PREPARE_FFT =>
          conn_bram <= MUX_FFT_TO_BRAM;
          conn_mar  <= MUX_MAR_TO_FFT;
          conn_w    <= MUX_W_TO_FFT;

          if internal_a_constant = '1' then
            state_reg <= FFT_B;
            sel_bram  <= WRITE_INTO_BRAM_B;
            fft_start <= '1';
          else
            sel_bram  <= WRITE_INTO_BRAM_A;
            state_reg <= FFT_A;
            fft_start <= '1';
          end if;
          
        when FFT_A =>
          if fft_finished = '1' then
            state_reg <= FFT_B;
            sel_bram  <= WRITE_INTO_BRAM_B;
            fft_start <= '1';
          end if;
          

        when FFT_B =>
          if fft_finished = '1' then
            state_reg <= POINTWISE_MUL;
            pointwise <= '1';
            conn_mar  <= MUX_MAR_TO_PW;
            pw_start  <= '1';
          end if;

        when POINTWISE_MUL =>
          if pw_finished = '1' then
            state_reg   <= INVERSE_FFT;
            conn_bram   <= MUX_FFT_TO_BRAM;
            conn_mar    <= MUX_MAR_TO_FFT;
            conn_w      <= MUX_W_TO_FFT;
            sel_bram    <= WRITE_INTO_BRAM_B;
            pointwise   <= '0';
            fft_inverse <= '1';
            fft_start   <= '1';
          end if;

        when INVERSE_FFT =>
          if fft_finished = '1' then
            state_reg      <= IPSI_CAL;
            output_counter <= 0;
            ipsi_start     <= '1';
            sel_bram       <= WRITE_INTO_BRAM_B;
            conn_bram      <= MUX_IPSI_TO_BRAM_B;
            conn_mar       <= MUX_MAR_TO_IPSI;
            conn_w         <= MUX_W_TO_IPSI;

          end if;

        when IPSI_CAL =>
          if ipsi_finished = '1' then
            inv_n_start       <= '1';
            sel_bram          <= WRITE_INTO_BRAM_B;
            conn_bram         <= MUX_INVN_TO_BRAM_B;
            conn_mar          <= MUX_MAR_TO_INVN;
            state_reg         <= INV_N;
            inv_n_coeff_valid <= '1';

          end if;

        when INV_N =>
          if inv_n_finished = '1' then
            state_reg         <= OUTPUT;
            inv_n_coeff_valid <= '0';
            state_reg         <= CLEANUP;
            fin_rin(0)        <= '1';
          end if;
          
        when OUTPUT =>
          --bram_b_addra   <= std_logic_vector(to_unsigned(output_counter, bram_b_addra'length));
          --val_out_rin(0) <= '1';
          --output_counter <= output_counter+1;
          --if output_counter = N_ELEMENTS-1 then
          --end if;


        when CLEANUP =>
          --Currently not needed
          state_reg <= IDLE;
          
          
      end case;
    end if;
  end process fsm;
  
end Behavioral;

