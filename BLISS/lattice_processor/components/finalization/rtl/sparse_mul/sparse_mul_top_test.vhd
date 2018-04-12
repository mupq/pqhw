----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:46:47 02/14/2014 
-- Design Name: 
-- Module Name:    sparse_mul_top_test - Behavioral 
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



entity sparse_mul_top_test is
    generic (
    --FFT and general configuration
    CORES         : integer               := 8;
    N_ELEMENTS    : integer               := 512;
    KAPPA         : integer               := 23;
    WIDTH_S1      : integer               := 2;
    WIDTH_S2      : integer               := 3;
    --Used to initialize the right s (s1 or s2)
    INIT_TABLE    : integer               := 0;
    c_delay       : integer range 0 to 16 := 2;
    MAX_RES_WIDTH : integer               := 6
    );
  port (
    clk : in std_logic;

    start : in  std_logic := '0';
    ready : out std_logic := '0';
    finished : out std_logic := '0';

    --Access to the key port (to change the secret key). Write only
    s1_addr  : in std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    s1_in    : in std_logic_vector(WIDTH_S1-1 downto 0)                              := (others => '0');
    s1_wr_en :    std_logic                                                          := '0';

    --Access to the key port (to change the secret key). Write only
    s2_addr  : in std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    s2_in    : in std_logic_vector(WIDTH_S2-1 downto 0)                              := (others => '0');
    s2_wr_en :    std_logic                                                          := '0';

    --Access to the positions of c
    addr_c : out std_logic_vector(integer(ceil(log2(real(KAPPA))))-1 downto 0)      := (others => '0');
    data_c : in  std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');

    --valid_c : in  std_logic                                                          := '0';

    --Results of the multiplication
    coeff_sc1_out   : out std_logic_vector(MAX_RES_WIDTH-1 downto 0)                         := (others => '0');
    coeff_sc1_addr  : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    coeff_sc1_valid : out std_logic                                                          := '0';

    coeff_sc2_out   : out std_logic_vector(MAX_RES_WIDTH-1 downto 0)                         := (others => '0');
    coeff_sc2_addr  : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    coeff_sc2_valid : out std_logic                                                          := '0'
    );
end sparse_mul_top_test;

architecture Behavioral of sparse_mul_top_test is

begin
  sparse_mul_top_1:entity work.sparse_mul_top
    generic map (
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
      start           => start,
      ready           => ready,
      finished        => finished,
      s1_addr         => s1_addr,
      s1_in           => s1_in,
      s1_wr_en        => s1_wr_en,
      s2_addr         => s2_addr,
      s2_in           => s2_in,
      s2_wr_en        => s2_wr_en,
      addr_c          => addr_c,
      data_c          => data_c,
      coeff_sc1_out   => coeff_sc1_out,
      coeff_sc1_addr  => coeff_sc1_addr,
      coeff_sc1_valid => coeff_sc1_valid,
      coeff_sc2_out   => coeff_sc2_out,
      coeff_sc2_addr  => coeff_sc2_addr,
      coeff_sc2_valid => coeff_sc2_valid);

end Behavioral;

