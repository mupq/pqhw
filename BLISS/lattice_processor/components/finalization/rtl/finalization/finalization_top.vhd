--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:56:50 02/11/2014 
-- Design Name: 
-- Module Name:    finalization_top - Behavioral 
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


entity finalization_top is
  generic (
    RAM_DEPTH        : integer               := 64;
    NUMBER_OF_BLOCKS : integer               := 16;
    KECCAK_SLICES    : integer               := 16;
    PARAMETER_SET:integer:=1;
    --------------------------General -----------------------------------------
    N_ELEMENTS       : integer               := 512;
    PRIME_P_WIDTH    : integer               := 14;
    PRIME_P          : unsigned              := to_unsigned(12289, 14);
    -----------------------  Sparse Mul Core ----------------------------------
    KAPPA            : integer               := 23;
    HASH_BLOCKS      : integer               := 4;
    HASH_WIDTH       : integer               := 64;
    --------------------------General --------------------------------------
    GAUSS_S_MAX      : unsigned              := to_unsigned(24, 5);
    ZETA             : unsigned              := to_unsigned(6145, 13);
    D_BLISS          : integer               := 10;
    MODULUS_P_BLISS  : unsigned              := to_unsigned(24, 5);
    -----------------------  Sparse Mul Core ------------------------------------------
    CORES            : integer               := 8;
    WIDTH_S1         : integer               := 2;
    WIDTH_S2         : integer               := 3;
    --Used to initialize the right s (s1 or s2)
    INIT_TABLE       : integer               := 0;
    USE_MOCKUP       : integer               := 0;
    c_delay          : integer range 0 to 16 := 2;
    ---------------------------------------------------------------------------
    MAX_RES_WIDTH    : integer               := 6
    );
  port (
    clk : in std_logic;

    --control logic
    --start : in  std_logic := '0';
    --ready : out std_logic := '0';
    --We have to hash again due to rejection
    rehash_message : in std_logic := '0';
    --We want to start a new signing operation
    reset          : in std_logic := '0';


    --Access to the message port  
    ready_message    : out std_logic                               := '0';
    message_finished : in  std_logic                               := '0';
    message_din      : in  std_logic_vector(HASH_WIDTH-1 downto 0) := (others => '0');
    message_valid    : in  std_logic                               := '0';

    --Access to the key port (to change the secret key). Write only
    s1_addr  : in std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    s1_in    : in std_logic_vector(WIDTH_S1-1 downto 0)                              := (others => '0');
    s1_wr_en :    std_logic                                                          := '0';


    s2_addr  : in std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    s2_in    : in std_logic_vector(WIDTH_S2-1 downto 0)                              := (others => '0');
    s2_wr_en :    std_logic                                                          := '0';

    --Results of the multiplication
    coeff_sc1_out   : out std_logic_vector(MAX_RES_WIDTH-1 downto 0)                         := (others => '0');
    coeff_sc1_addr  : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    coeff_sc1_valid : out std_logic                                                          := '0';

    coeff_sc2_out   : out std_logic_vector(MAX_RES_WIDTH-1 downto 0)                         := (others => '0');
    coeff_sc2_addr  : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    coeff_sc2_valid : out std_logic                                                          := '0';

    --Input of values into the core
    addr_in   : in std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    data_in   : in std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
    ay1_wr_en :    std_logic                                                          := '0';
    y1_wr_en  :    std_logic                                                          := '0';
    y2_wr_en  :    std_logic                                                          := '0';

    c_pos_signature       : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    c_pos_signature_valid : out std_logic                                                          := '0';

    --The u ports
    u_out_data : out std_logic_vector(PRIME_P'length+1-1 downto 0)                      := (others => '0');
    u_out_addr : in  std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');





    --The y ports
    y1_out_data : out std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
    y1_out_addr : in  std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');

    y2_out_data : out std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
    y2_out_addr : in  std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0')

    );
end finalization_top;

architecture Behavioral of finalization_top is



  signal comp_start : std_logic := '0';
  signal comp_ready : std_logic := '0';

  signal comp_u_out_data     : std_logic_vector(PRIME_P'length+1-1 downto 0)                      := (others => '0');
  signal comp_u_out_addr     : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal comp_y1_out_data    : std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
  signal comp_y1_out_addr    : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal comp_y2_out_data    : std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
  signal comp_y2_out_addr    : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal comp_u_keccak_data  : std_logic_vector(MODULUS_P_BLISS'length-1 downto 0)                := (others => '0');
  signal comp_u_keccak_valid : std_logic                                                          := '0';

  signal keccak_positions_finished : std_logic := '0';

  signal keccak_message_valid : std_logic                                                          := '0';
  signal keccak_u_in          : std_logic_vector(MODULUS_P_BLISS'length-1 downto 0)                := (others => '0');
  signal keccak_u_wr_en       : std_logic                                                          := '0';
  signal keccak_c_addr        : std_logic_vector(integer(ceil(log2(real(KAPPA))))-1 downto 0)      := (others => '0');
  signal keccak_c_out         : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');

  signal spm_start : std_logic := '0';
  signal spm_ready : std_logic := '0';

  signal spm_addr_c : std_logic_vector(integer(ceil(log2(real(KAPPA))))-1 downto 0)      := (others => '0');
  signal spm_data_c : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');

  signal spm_started  : std_logic := '0';
  signal spm_finished : std_logic := '0';
  signal wait_cycle   : std_logic := '0';

 -- type ram_type is array (0 to 512-1) of integer;

  --signal u_ref : ram_type := (9, 4, 1, -7, -8, 10, 11, 6, 7, -11, 12, -9, -11, -2, 5, 8, -3, 6, -9, -7, 1, 0, 3, -11, -4, 5, -6, 3, 3, -2, -1, 9, 4, 11, -8, -8, 11, 6, -1, 5, -6, 0, 6, 0, -8, -3, 12, -5, 7, -9, 8, 5, 7, -5, -10, -6, -6, 1, 1, 6, 0, 9, -5, 6, -5, -1, -8, -1, 4, -2, 9, 4, -7, -1, 6, 10, -5, -4, -4, -9, 0, 10, 1, -4, 1, 6, -7, -4, 9, 3, 6, -7, -6, -6, -8, -4, -4, 10, -6, 9, -10, 5, -11, 6, 9, -2, -1, -6, 12, 8, -6, -1, 9, 2, -9, -8, -7, -11, -10, 8, 8, 4, 1, 2, 11, 1, -8, -10, -10, -5, 4, -6, -9, -10, -9, -3, 12, -7, 11, 11, -9, 10, 3, -7, -7, 1, 6, 9, 0, 7, 6, -8, 11, 11, 11, 11, 8, -2, -9, 5, 11, 10, 1, 8, -10, 0, -7, 6, 10, -8, 11, -8, -8, 11, 10, 6, 9, -3, -2, 12, -4, 9, -2, 4, 3, -9, -9, 10, 5, 2, -7, 1, -9, -1, 8, 3, -4, 2, 0, -2, -9, 2, 10, 2, -6, 1, 9, 7, -7, -2, 1, -9, 5, -1, 12, -1, -4, -1, 10, -3, -11, 5, 7, 3, -4, -11, -7, 10, -8, 2, 6, -7, 9, 8, 0, 2, -3, 8, -11, 10, -4, 8, -4, -8, -10, -1, 3, -7, -6, -10, 0, 5, 6, 10, 10, 8, -10, 3, 10, -1, 2, -2, 0, 4, 0, 4, -1, 2, -3, 1, 10, 5, 12, -3, -5, 6, -3, 4, -8, 6, 10, 2, -1, 3, 8, -1, -1, 8, 7, 4, 9, 12, 11, 12, 1, -8, -2, -5, 0, -10, -7, 12, -2, -11, 1, 11, -5, 12, 5, 8, 7, -9, -6, -9, 3, 9, -5, -6, 0, -10, 12, -7, -6, -3, -2, -2, -4, -8, 3, 9, 4, -4, 2, 9, -4, 10, -6, 0, 2, 5, 5, 0, 3, 9, 5, -2, -3, 1, -9, -3, 0, 11, 1, -4, -11, 6, -11, 6, -2, 6, -10, -3, 0, -10, 1, 2, 10, -11, 5, 10, -5, 5, -9, -2, 6, -2, -4, 8, 6, -1, -11, 2, 6, -9, 12, -9, -9, 5, -7, 2, 11, 11, -2, 8, 10, 1, -6, 6, -3, 7, 4, -8, 10, 2, 6, 1, 1, 11, -9, 11, 3, -7, -3, -2, 0, -9, 9, 5, 12, 11, -4, -3, -4, -6, 0, -2, 11, 12, 7, 2, 7, -10, -4, 5, -9, 8, 0, 1, 5, -8, 3, 4, 5, 10, -2, -7, -5, -9, -7, 8, -7, 10, 6, -10, 1, 12, 4, -9, 7, -1, 5, -8, 7, -6, -4, 4, 2, -6, -7, -3, -8, -6, -6, 11, -5, 9, -10, 7, 10, 5, 4, 12, -9, 8, 9, -5, -9, 8, 7, 11, 7, 9, 6, -10, 3, -2, 7, 0, 9, 1, 1, 4, 11, 0, 1, 0, 0, -2, 7, 3, 5, -8);

  signal u_counter : integer := 0;


begin


  --process(clk)
  --begin  -- process
  --  if rising_edge(clk) then
  --    if keccak_u_wr_en ='1' then
  --      if signed(keccak_u_in) /= to_signed(u_ref(u_counter),keccak_u_in'length) then
  --        report "bad kkk";
  --      end if;
  --      u_counter <= (u_counter+1)mod 512;
  --    end if;
  --  end if;
  --end process;


  sig_comp_1 : entity work.sig_comp
    generic map (
      N_ELEMENTS      => N_ELEMENTS,
      PRIME_P_WIDTH   => PRIME_P_WIDTH,
      PRIME_P         => PRIME_P,
      ZETA            => ZETA,
      D_BLISS         => D_BLISS,
      MODULUS_P_BLISS => MODULUS_P_BLISS,
      CORES           => CORES,
      KAPPA           => KAPPA,
      WIDTH_S1        => WIDTH_S1,
      WIDTH_S2        => WIDTH_S2,
      INIT_TABLE      => INIT_TABLE,
      c_delay         => c_delay,
      MAX_RES_WIDTH   => MAX_RES_WIDTH)
    port map (
      clk            => clk,
      --start          => comp_start,
      --ready          => comp_ready,
      addr_in        => addr_in,
      data_in        => data_in,
      ay1_wr_en      => ay1_wr_en,
      y1_wr_en       => y1_wr_en,
      y2_wr_en       => y2_wr_en,
      u_keccak_data  => comp_u_keccak_data,
      u_keccak_valid => comp_u_keccak_valid,
      u_out_data     => u_out_data,
      u_out_addr     => u_out_addr,
      y1_out_data    => y1_out_data,
      y1_out_addr    => y1_out_addr,
      y2_out_data    => y2_out_data,
      y2_out_addr    => y2_out_addr
      );


  keccak_u_in    <= comp_u_keccak_data;
  keccak_u_wr_en <= comp_u_keccak_valid;
  biss_keccak_top_1 : entity work.biss_keccak_top
    generic map (
      RAM_DEPTH        => RAM_DEPTH,
      KECCAK_SLICES    => KECCAK_SLICES,
      NUMBER_OF_BLOCKS => NUMBER_OF_BLOCKS,
      N_ELEMENTS       => N_ELEMENTS,
      PRIME_P_WIDTH    => PRIME_P_WIDTH,
      PRIME_P          => PRIME_P,
      KAPPA            => KAPPA,
      HASH_BLOCKS      => HASH_BLOCKS,
      USE_MOCKUP       => USE_MOCKUP,
      HASH_WIDTH       => HASH_WIDTH,
      MODULUS_P_BLISS  => MODULUS_P_BLISS)
    port map (
      clk                   => clk,
      ext_rehash_message    => rehash_message,
      ext_reset             => reset,
      ready_message         => ready_message,
      message_finished      => message_finished,
      positions_finished    => keccak_positions_finished,
      message_din           => message_din,
      message_valid         => message_valid,
      c_pos_signature       => c_pos_signature ,
      c_pos_signature_valid => c_pos_signature_valid,
      u_in                  => keccak_u_in,
      u_wr_en               => keccak_u_wr_en,
      c_addr                => keccak_c_addr,
      c_out                 => keccak_c_out
      );

  keccak_c_addr <= spm_addr_c;
  spm_data_c    <= keccak_c_out;
  sparse_mul_top_1 : entity work.sparse_mul_top
    generic map (
      PARAMETER_SET => PARAMETER_SET,
      CORES         => CORES,
      N_ELEMENTS    => N_ELEMENTS,
      KAPPA         => KAPPA,
      WIDTH_S1      => WIDTH_S1,
      WIDTH_S2      => WIDTH_S2,
      INIT_TABLE    => INIT_TABLE,
      c_delay       => c_delay,
      MAX_RES_WIDTH => MAX_RES_WIDTH)
    port map (
      clk             => clk,
      start           => spm_start,
      ready           => spm_ready,
      finished        => spm_finished,
      s1_addr         => s1_addr,
      s1_in           => s1_in,
      s1_wr_en        => s1_wr_en,
      s2_addr         => s2_addr,
      s2_in           => s2_in,
      s2_wr_en        => s2_wr_en,
      addr_c          => spm_addr_c,
      data_c          => spm_data_c,
      coeff_sc1_out   => coeff_sc1_out,
      coeff_sc1_addr  => coeff_sc1_addr,
      coeff_sc1_valid => coeff_sc1_valid,
      coeff_sc2_out   => coeff_sc2_out,
      coeff_sc2_addr  => coeff_sc2_addr,
      coeff_sc2_valid => coeff_sc2_valid
      );


  
  process (clk)
  begin  -- process

    if rising_edge(clk) then            -- rising clock edge
      spm_start  <= '0';
      wait_cycle <= '0';
      if keccak_positions_finished = '1' and spm_started = '0' and wait_cycle = '0' then
        spm_start   <= '1';
        spm_started <= '1';
      end if;

      if reset = '1' or rehash_message = '1' then
        spm_started <= '0';
        wait_cycle  <= '1';
      end if;

      
    end if;
  end process;


  
end Behavioral;




















--library IEEE;
--use IEEE.STD_LOGIC_1164.all;
--use ieee.numeric_std.all;
--use ieee.math_real.all;


--entity finalization_top is
--  generic (
--    RAM_DEPTH        : integer               := 64;
--    NUMBER_OF_BLOCKS : integer               := 16;
--     KECCAK_SLICES    : integer  := 16;
--    --------------------------General -----------------------------------------
--    N_ELEMENTS       : integer               := 512;
--    PRIME_P_WIDTH    : integer               := 14;
--    PRIME_P          : unsigned              := to_unsigned(12289, 14);
--    -----------------------  Sparse Mul Core ----------------------------------
--    KAPPA            : integer               := 23;
--    HASH_BLOCKS      : integer               := 4;
--    HASH_WIDTH       : integer               := 64;
--    --------------------------General --------------------------------------
--    GAUSS_S_MAX      : unsigned              := to_unsigned(24, 5);
--    ZETA             : unsigned              := to_unsigned(6145, 13);
--    D_BLISS          : integer               := 10;
--    MODULUS_P_BLISS  : unsigned              := to_unsigned(24, 5);
--    -----------------------  Sparse Mul Core ------------------------------------------
--    CORES            : integer               := 8;
--    WIDTH_S1         : integer               := 2;
--    WIDTH_S2         : integer               := 3;
--    --Used to initialize the right s (s1 or s2)
--    INIT_TABLE       : integer               := 0;
--     USE_MOCKUP       : integer               := 0;
--    c_delay          : integer range 0 to 16 := 2;
--    ---------------------------------------------------------------------------
--    MAX_RES_WIDTH    : integer               := 6
--    );
--  port (
--    clk : in std_logic;

--    --control logic
--    --start : in  std_logic := '0';
--    --ready : out std_logic := '0';
--    --We have to hash again due to rejection
--    rehash_message : in std_logic := '0';
--    --We want to start a new signing operation
--    reset          : in std_logic := '0';


--    --Access to the message port  
--    ready_message    : out std_logic                               := '0';
--    message_finished : in  std_logic                               := '0';
--    message_din      : in  std_logic_vector(HASH_WIDTH-1 downto 0) := (others => '0');
--    message_valid    : in  std_logic                               := '0';

--    --Access to the key port (to change the secret key). Write only
--    s1_addr  : in std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
--    s1_in    : in std_logic_vector(WIDTH_S1-1 downto 0)                              := (others => '0');
--    s1_wr_en :    std_logic                                                          := '0';


--    s2_addr  : in std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
--    s2_in    : in std_logic_vector(WIDTH_S2-1 downto 0)                              := (others => '0');
--    s2_wr_en :    std_logic                                                          := '0';

--    --Results of the multiplication
--    coeff_sc1_out   : out std_logic_vector(MAX_RES_WIDTH-1 downto 0)                         := (others => '0');
--    coeff_sc1_addr  : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
--    coeff_sc1_valid : out std_logic                                                          := '0';

--    coeff_sc2_out   : out std_logic_vector(MAX_RES_WIDTH-1 downto 0)                         := (others => '0');
--    coeff_sc2_addr  : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
--    coeff_sc2_valid : out std_logic                                                          := '0';

--    --Input of values into the core
--    addr_in   : in std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
--    data_in   : in std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
--    ay1_wr_en :    std_logic                                                          := '0';
--    y1_wr_en  :    std_logic                                                          := '0';
--    y2_wr_en  :    std_logic                                                          := '0';

--    c_pos_signature       : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
--    c_pos_signature_valid : out std_logic                                                          := '0';

--    --The u ports
--    u_out_data : out std_logic_vector(PRIME_P'length+1-1 downto 0)                      := (others => '0');
--    u_out_addr : in  std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');





--    --The y ports
--    y1_out_data : out std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
--    y1_out_addr : in  std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');

--    y2_out_data : out std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
--    y2_out_addr : in  std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0')

--    );
--end finalization_top;

--architecture Behavioral of finalization_top is



--  signal comp_start : std_logic := '0';
--  signal comp_ready : std_logic := '0';

--  signal comp_u_out_data     : std_logic_vector(PRIME_P'length+1-1 downto 0)                      := (others => '0');
--  signal comp_u_out_addr     : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
--  signal comp_y1_out_data    : std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
--  signal comp_y1_out_addr    : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
--  signal comp_y2_out_data    : std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
--  signal comp_y2_out_addr    : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
--  signal comp_u_keccak_data  : std_logic_vector(MODULUS_P_BLISS'length-1 downto 0)                := (others => '0');
--  signal comp_u_keccak_valid : std_logic                                                          := '0';

--  signal keccak_positions_finished : std_logic := '0';

--  signal keccak_message_valid : std_logic                                                          := '0';
--  signal keccak_u_in          : std_logic_vector(MODULUS_P_BLISS'length-1 downto 0)                := (others => '0');
--  signal keccak_u_wr_en       : std_logic                                                          := '0';
--  signal keccak_c_addr        : std_logic_vector(integer(ceil(log2(real(KAPPA))))-1 downto 0)      := (others => '0');
--  signal keccak_c_out         : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');

--  signal spm_start : std_logic := '0';
--  signal spm_ready : std_logic := '0';

--  signal spm_addr_c : std_logic_vector(integer(ceil(log2(real(KAPPA))))-1 downto 0)      := (others => '0');
--  signal spm_data_c : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');

--  signal spm_started : std_logic := '0';
--    signal spm_finished : std_logic := '0';
--    signal wait_cycle : std_logic := '0';

--begin


--  sig_comp_1 : entity work.sig_comp
--    generic map (
--      N_ELEMENTS      => N_ELEMENTS,
--      GAUSS_S_MAX     => GAUSS_S_MAX,
--      PRIME_P_WIDTH   => PRIME_P_WIDTH,
--      PRIME_P         => PRIME_P,
--      ZETA            => ZETA,
--      D_BLISS         => D_BLISS,
--      MODULUS_P_BLISS => MODULUS_P_BLISS,
--      CORES           => CORES,
--      KAPPA           => KAPPA,
--      WIDTH_S1        => WIDTH_S1,
--      WIDTH_S2        => WIDTH_S2,
--      INIT_TABLE      => INIT_TABLE,
--      c_delay         => c_delay,
--      MAX_RES_WIDTH   => MAX_RES_WIDTH)
--    port map (
--      clk            => clk,
--      --start          => comp_start,
--      --ready          => comp_ready,
--      addr_in        => addr_in,
--      data_in        => data_in,
--      ay1_wr_en      => ay1_wr_en,
--      y1_wr_en       => y1_wr_en,
--      y2_wr_en       => y2_wr_en,
--      u_keccak_data  => comp_u_keccak_data,
--      u_keccak_valid => comp_u_keccak_valid,
--      u_out_data     => u_out_data,
--      u_out_addr     => u_out_addr,
--      y1_out_data    => y1_out_data,
--      y1_out_addr    => y1_out_addr,
--      y2_out_data    => y2_out_data,
--      y2_out_addr    => y2_out_addr
--      );


--  keccak_u_in    <= comp_u_keccak_data;
--  keccak_u_wr_en <= comp_u_keccak_valid;
--  biss_keccak_top_1 : entity work.biss_keccak_top
--    generic map (
--      RAM_DEPTH        => RAM_DEPTH,
--      KECCAK_SLICES => KECCAK_SLICES,
--      NUMBER_OF_BLOCKS => NUMBER_OF_BLOCKS,
--      N_ELEMENTS       => N_ELEMENTS,
--      PRIME_P_WIDTH    => PRIME_P_WIDTH,
--      PRIME_P          => PRIME_P,
--      KAPPA            => KAPPA,
--      HASH_BLOCKS      => HASH_BLOCKS,
--      USE_MOCKUP => USE_MOCKUP,
--      HASH_WIDTH       => HASH_WIDTH,
--      MODULUS_P_BLISS  => MODULUS_P_BLISS)
--    port map (
--      clk                   => clk,
--      ext_rehash_message               => rehash_message,
--      ext_reset => reset,
--      ready_message         => ready_message,
--      message_finished      => message_finished,
--      positions_finished    => keccak_positions_finished,
--      message_din           => message_din,
--      message_valid         => message_valid,
--      c_pos_signature       => c_pos_signature ,
--      c_pos_signature_valid => c_pos_signature_valid,
--      u_in                  => keccak_u_in,
--      u_wr_en               => keccak_u_wr_en,
--      c_addr                => keccak_c_addr,
--      c_out                 => keccak_c_out
--      );

--  keccak_c_addr <= spm_addr_c;
--  spm_data_c    <= keccak_c_out;
--  sparse_mul_top_1 : entity work.sparse_mul_top
--    generic map (
--      CORES         => CORES,
--      N_ELEMENTS    => N_ELEMENTS,
--      KAPPA         => KAPPA,
--      WIDTH_S1      => WIDTH_S1,
--      WIDTH_S2      => WIDTH_S2,
--      INIT_TABLE    => INIT_TABLE,
--      c_delay       => c_delay,
--      MAX_RES_WIDTH => MAX_RES_WIDTH)
--    port map (
--      clk             => clk,
--      start           => spm_start,
--      ready           => spm_ready,
--      finished => spm_finished,
--      s1_addr         => s1_addr,
--      s1_in           => s1_in,
--      s1_wr_en        => s1_wr_en,
--      s2_addr         => s2_addr,
--      s2_in           => s2_in,
--      s2_wr_en        => s2_wr_en,
--      addr_c          => spm_addr_c,
--      data_c          => spm_data_c,
--      coeff_sc1_out   => coeff_sc1_out,
--      coeff_sc1_addr  => coeff_sc1_addr,
--      coeff_sc1_valid => coeff_sc1_valid,
--      coeff_sc2_out   => coeff_sc2_out,
--      coeff_sc2_addr  => coeff_sc2_addr,
--      coeff_sc2_valid => coeff_sc2_valid
--      );



--  process (clk)
--  begin  -- process

--    if rising_edge(clk) then            -- rising clock edge
--      spm_start <= '0';
--      wait_cycle <= '0';
--      if keccak_positions_finished = '1' and spm_started = '0' and       wait_cycle = '0' then
--        spm_start   <= '1';
--        spm_started <= '1';
--      end if;

--    if reset ='1' or rehash_message='1' then
--      spm_started <= '0';
--      wait_cycle <= '1';
--    end if;


--    end if;
--  end process;



--end Behavioral;
