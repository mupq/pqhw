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
-- Create Date:   16:01:16 01/14/2014
-- Design Name:   
-- Module Name:   C:/Users/thomas/SHA/Projekte/BLISS/code/gauss_sampler_collection/gauss_sampler_collection/bench/d_sigma2_plus_tb.vhd
-- Project Name:  gauss_sampler_collection
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: d_sigma2_plus
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



entity d_sigma2_plus_tb is
  generic (
    MAX_X : integer := 10
    );
end d_sigma2_plus_tb;

architecture behavior of d_sigma2_plus_tb is

  --Inputs
  signal clk   : std_logic := '0';
  signal din   : std_logic := '0';
  signal empty : std_logic := '0';
  signal full  : std_logic := '0';
  signal valid : std_logic := '0';

  --Outputs
  signal rd_en : std_logic;
  signal wr_en : std_logic;
  signal dout  : std_logic_vector(integer(ceil(log2(real(MAX_X))))-1 downto 0);

  -- Clock period definitions
  constant clk_period : time := 10 ns;

  type   vector_type is array (0 to 99) of integer;
  signal values : vector_type := (0, 1, 0, 1, 0, 0, 0, 0, 1, 2, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1, 0, 0, 2, 1, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 2);

  constant randomness : std_logic_vector := "0100101110101110100010111111100001100100001110110011001111001101111101010101011001101100101110000001101111100010100101110001101010011111011011001111010011111100011010010101000101011111111000011000110010011010010100000100001010011011110110101001011010010111101011001100100000101001111100101010001011111001101110000110111101000011111011111010011000";

  signal counter : integer := 0;
begin


  -- Instantiate the Unit Under Test (UUT)
  uut : entity work.d_sigma2_plus port map (
    clk   => clk,
    rd_en => rd_en,
    din   => din,
    empty => empty,
    valid => valid,
    wr_en => wr_en,
    dout  => dout,
    full  => full
    );

  -- Clock process definitions
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  process(clk)
  begin  -- process
    if rising_edge(clk) then
      valid <= '0';
      if rd_en = '1' then
        counter <= counter+1;
        din     <= randomness(counter);
        valid   <= '1';
      end if;
    end if;
  end process;

  

  -- Stimulus process
  stim_proc : process
   
  begin
    -- hold reset state for 100 ns.
    wait for 100 ns;
    full <= '0';
   

    -- insert stimulus here 

    wait;
  end process;

end;
