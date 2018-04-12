----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:02:20 02/28/2014 
-- Design Name: 
-- Module Name:    PAPER_COMPRESSION - Behavioral 
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
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity PAPER_COMPRESSION is
  generic (
    PARAMETER_SET          : integer               := 1;
    MAX_PREC               : integer               := 79;
    CONST_K                : integer               := 253;
    MAX_X                  : integer               := 10;
    --------------------------General --------------------------------------
    N_ELEMENTS             : integer               := 512;
    PRIME_P_WIDTH          : integer               := 14;
    PRIME_P                : unsigned              := to_unsigned(12289, 14);
    ZETA                   : unsigned              := to_unsigned(6145, 13);
    D_BLISS                : integer               := 10;
    MODULUS_P_BLISS        : unsigned              := to_unsigned(24, 5);
    MAX_RES_WIDTH_COEFF_SC : integer               := 6;
    -----------------------  Sparse Mul Core --------------------------------
    CORES                  : integer               := 8;
    KAPPA                  : integer               := 23;
    WIDTH_S1               : integer               := 2;
    WIDTH_S2               : integer               := 3;
    --Used to initialize the right s (s1 or s2)
    INIT_TABLE             : integer               := 0;
    c_delay                : integer range 0 to 16 := 2;
    MAX_RES_WIDTH          : integer               := 6
    ---------------------------------------------------------------------------
    );

  port(

    clk : in std_logic;

    reset     : in  std_logic;
    rejection : out std_logic;
    finished  : out std_logic;

    encoder_finished : in std_logic := '1';
    encoder_ok       : in std_logic := '1';

    --Results of the multiplication
    coeff_sc_addr : in std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');

    coeff_sc1       : in std_logic_vector(MAX_RES_WIDTH-1 downto 0) := (others => '0');
    coeff_sc1_valid : in std_logic                                  := '0';

    coeff_sc2       : in std_logic_vector(MAX_RES_WIDTH-1 downto 0) := (others => '0');
    coeff_sc2_valid : in std_logic                                  := '0';

    --The u ports
    delay_temp_ram : in  integer range 0 to 63                                              := 10;
    u_data         : in  std_logic_vector(PRIME_P'length+1-1 downto 0)                      := (others => '0');
    u_addr         : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    --The y1 port
    y1_data        : in  std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
    y1_addr        : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    --T y2 port
    y2_data        : in  std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
    y2_addr        : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');


    --Final ports
    z1_final       : out std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
    z1_final_addr  : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    z1_final_valid : out std_logic                                                          := '0';

    --Final ports
    z2_final       : out std_logic_vector(MODULUS_P_BLISS'length-1 downto 0)                := (others => '0');
    z2_final_addr  : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    z2_final_valid : out std_logic                                                          := '0'


    );
end PAPER_COMPRESSION;

architecture Behavioral of PAPER_COMPRESSION is

begin


  rejection_module_1:entity work.rejection_module
    generic map (
      PARAMETER_SET          => PARAMETER_SET,
      MAX_PREC               => MAX_PREC,
      CONST_K                => CONST_K,
      MAX_X                  => MAX_X,
      N_ELEMENTS             => N_ELEMENTS,
      PRIME_P_WIDTH          => PRIME_P_WIDTH,
      PRIME_P                => PRIME_P,
      ZETA                   => ZETA,
      D_BLISS                => D_BLISS,
      MODULUS_P_BLISS        => MODULUS_P_BLISS,
      MAX_RES_WIDTH_COEFF_SC => MAX_RES_WIDTH_COEFF_SC,
      CORES                  => CORES,
      KAPPA                  => KAPPA,
      WIDTH_S1               => WIDTH_S1,
      WIDTH_S2               => WIDTH_S2,
      INIT_TABLE             => INIT_TABLE,
      c_delay                => c_delay,
      MAX_RES_WIDTH          => MAX_RES_WIDTH)
    port map (
      clk              => clk,
      reset            => reset,
      rejection        => rejection,
      finished         => finished,
      encoder_finished => encoder_finished,
      encoder_ok       => encoder_ok,
      coeff_sc_addr    => coeff_sc_addr,
      coeff_sc1        => coeff_sc1,
      coeff_sc1_valid  => coeff_sc1_valid,
      coeff_sc2        => coeff_sc2,
      coeff_sc2_valid  => coeff_sc2_valid,
      delay_temp_ram   => delay_temp_ram,
      u_data           => u_data,
      u_addr           => u_addr,
      y1_data          => y1_data,
      y1_addr          => y1_addr,
      y2_data          => y2_data,
      y2_addr          => y2_addr,
      z1_final         => z1_final,
      z1_final_addr    => z1_final_addr,
      z1_final_valid   => z1_final_valid,
      z2_final         => z2_final,
      z2_final_addr    => z2_final_addr,
      z2_final_valid   => z2_final_valid);

  
end Behavioral;

