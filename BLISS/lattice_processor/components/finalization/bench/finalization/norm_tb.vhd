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
-- Create Date:   15:59:12 02/12/2014
-- Design Name:   
-- Module Name:   C:/Users/thomas/SHA/Projekte/BLISS/code/bliss_arithmetic/lattice_processor/components/finalization/bench/finalization/norm_tb.vhd
-- Project Name:  lattice_processor
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: norm
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
USE ieee.numeric_std.ALL;

entity norm_tb is
  generic (
    --Samples a uniform value between 0 and Sx_MAX
    PRIME_P       : unsigned := to_unsigned(12289, 14);
    MAX_RES_WIDTH : integer  := 10;
    OUTPUT_WIDTH  : integer  := 33;
    DEPTH         : integer  := 512
    );
  port (
    error_happened_out    : out std_logic := '0';
    end_of_simulation_out : out std_logic := '0'
    );
end norm_tb;

architecture behavior of norm_tb is

  -- Component Declaration for the Unit Under Test (UUT)
  signal end_of_simulation : std_logic := '0';
  signal error_happened    : std_logic := '0';

  signal clk           : std_logic                    := '0';

  --Inputs
  signal reset           : std_logic                    := '0';
  signal coeff_sc1_out   : std_logic_vector(9 downto 0) := (others => '0');
  signal coeff_sc1_valid : std_logic                    := '0';
  signal coeff_sc2_out   : std_logic_vector(9 downto 0) := (others => '0');
  signal coeff_sc2_valid : std_logic                    := '0';

  --Outputs
  signal norm       : std_logic_vector(32 downto 0);
  signal norm_valid : std_logic;
  -- No clocks detected in port list. Replace <clock> below with 
  -- appropriate port name 
  constant clk_period : time := 10 ns;

  signal cycle_counter : integer := 0;
begin

  norm_1 : entity work.norm
    generic map (
      PRIME_P       => PRIME_P,
      MAX_RES_WIDTH => MAX_RES_WIDTH,
      OUTPUT_WIDTH  => OUTPUT_WIDTH,
      DEPTH         => DEPTH)
    port map (
      clk             => clk,
      reset           => reset,
      coeff_sc1_out   => coeff_sc1_out,
      coeff_sc1_valid => coeff_sc1_valid,
      coeff_sc2_out   => coeff_sc2_out,
      coeff_sc2_valid => coeff_sc2_valid,
      norm            => norm,
      norm_valid      => norm_valid
      );



  clk_process : process
  begin
    if end_of_simulation = '0' then
      clk           <= '0';
      wait for clk_period/2;
      clk           <= '1';
      wait for clk_period/2;
      cycle_counter <= cycle_counter+1;
    end if;
  end process;
  end_of_simulation_out <= end_of_simulation;

  -- Stimulus process
  stim_proc : process
  begin
    -- hold reset state for 100 ns.
    wait for 100 ns;

    wait for clk_period;

    -- insert stimulus here
    for i in 0 to 255 loop
      coeff_sc1_out   <= std_logic_vector(to_signed(-6, coeff_sc1_out'length));
      coeff_sc1_valid <= '1';
      coeff_sc2_out   <= std_logic_vector(to_signed(5, coeff_sc1_out'length));
      coeff_sc2_valid <= '1';
      wait for clk_period;
    end loop;  -- i
    coeff_sc1_valid <= '0';
    coeff_sc2_valid <= '0';

    wait for clk_period*50;

    for i in 0 to 255 loop
      coeff_sc1_out   <= std_logic_vector(to_signed(-6, coeff_sc1_out'length));
      coeff_sc1_valid <= '1';
      coeff_sc2_out   <= std_logic_vector(to_signed(5, coeff_sc1_out'length));
      coeff_sc2_valid <= '1';
      wait for clk_period;
    end loop;  -- i
    coeff_sc1_valid <= '0';
    coeff_sc2_valid <= '0';


    wait;
  end process;

end;
