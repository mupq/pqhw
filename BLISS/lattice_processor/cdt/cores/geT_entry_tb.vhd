--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:05:26 02/19/2014
-- Design Name:   
-- Module Name:   C:/Users/thomas/SHA/Projekte/BLISS/code/bliss_arithmetic/lattice_processor/cdt/cores/geT_entry_tb.vhd
-- Project Name:  lattice_processor
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: get_entry
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

entity get_entry_tb is
  generic (
    MAX_BYTE  : integer := 50;
    MAX_INDEX : integer := 2800
    );
end get_entry_tb;

architecture behavior of get_entry_tb is

  -- Component Declaration for the Unit Under Test (UUT)
  
  signal clk      : std_logic;
  signal read_ram : std_logic                                                         := '0';
  signal byte     : std_logic_vector(integer(ceil(log2(real(MAX_BYTE))))-1 downto 0)  := (others => '0');
  signal index    : std_logic_vector(integer(ceil(log2(real(MAX_INDEX))))-1 downto 0) := (others => '0');
  signal value    : std_logic_vector(7 downto 0);
  signal valid    : std_logic                                                         := '0';


  -- Clock period definitions
  constant clk_period : time := 10 ns;
  
begin
  get_entry_1 : entity work.get_entry
    generic map (
      MAX_BYTE  => MAX_BYTE,
      MAX_INDEX => MAX_INDEX)
    port map (
      clk      => clk,
      read_ram => read_ram,
      byte     => byte,
      index    => index,
      value    => value,
      valid    => valid
      );


  -- Clock process definitions
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;


  -- Stimulus process
  stim_proc : process
  begin
    -- hold reset state for 100 ns.
    wait for 100 ns;

    wait for clk_period*10;
    index     <= std_logic_vector(to_unsigned(215, index'length));
    byte     <= std_logic_vector(to_unsigned(7, byte'length));
    read_ram <= '1';
    wait for clk_period;
    read_ram <= '0';


    -- insert stimulus here 

    wait;
  end process;

end;
