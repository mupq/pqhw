--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/


--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:15:13 02/14/2014
-- Design Name:   
-- Module Name:   C:/Users/thomas/SHA/Projekte/BLISS/code/bliss_arithmetic/lattice_processor/components/finalization/bench/sparse_mul/sparse_mul_speed_tb.vhd
-- Project Name:  lattice_processor
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: sparse_mul_top
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

entity sparse_mul_speed_tb is
  generic (
    --FFT and general configuration
    CORES         : integer               := 4;
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
    cycles_out            : out integer   := 0;
    error_happened_out    : out std_logic := '0';
    end_of_simulation_out : out std_logic := '0'
    );
end sparse_mul_speed_tb;

architecture behavior of sparse_mul_speed_tb is

  signal end_of_simulation : std_logic := '0';
  signal error_happened    : std_logic := '0';

  signal cycles           : integer                                                            := 0;
  -- Component Declaration for the Unit Under Test (UUT)
  signal clk             : std_logic;
  signal start           : std_logic                                                          := '0';
  signal ready           : std_logic                                                          := '0';
  signal finished        : std_logic                                                          := '0';
  signal s1_addr         : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal s1_in           : std_logic_vector(WIDTH_S1-1 downto 0)                              := (others => '0');
  signal s1_wr_en        : std_logic                                                          := '0';
  signal s2_addr         : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal s2_in           : std_logic_vector(WIDTH_S2-1 downto 0)                              := (others => '0');
  signal s2_wr_en        : std_logic                                                          := '0';
  signal addr_c          : std_logic_vector(integer(ceil(log2(real(KAPPA))))-1 downto 0)      := (others => '0');
  signal data_c          : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal coeff_sc1_out   : std_logic_vector(MAX_RES_WIDTH-1 downto 0)                         := (others => '0');
  signal coeff_sc1_addr  : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal coeff_sc1_valid : std_logic                                                          := '0';
  signal coeff_sc2_out   : std_logic_vector(MAX_RES_WIDTH-1 downto 0)                         := (others => '0');
  signal coeff_sc2_addr  : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal coeff_sc2_valid : std_logic                                                          := '0';

  -- Clock period definitions
  constant clk_period : time := 10 ns;
  
begin


  cycles_out <= cycles;

  sparse_mul_top_1 : entity work.sparse_mul_top
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


  -- Clock process definitions
  clk_process : process
  begin
    if end_of_simulation = '0' then
      clk <= '0';
      wait for clk_period/2;
      clk <= '1';
      wait for clk_period/2;
    end if;
  end process;
  end_of_simulation_out <= end_of_simulation;


  -- Stimulus process
  stim_proc : process
  begin
    -- hold reset state for 100 ns.
    wait for 100 ns;

    wait for clk_period*100;


    while ready = '0' loop
      wait for clk_period;
    end loop;

    start  <= '1';
    cycles <= cycles+1;
    wait for clk_period;
    cycles <= cycles+1;
    start  <= '0';
    wait for clk_period;
    cycles <= cycles+1;
    wait for clk_period;

    while ready = '0' loop
      cycles <= cycles+1;
      wait for clk_period;
    end loop;



    --if error_happened = '1' then
    --  report "ERROR";
    --else
    --  report "OK";
    --end if;

    --end_of_simulation <= '1';
    wait;

  end process;

end;
