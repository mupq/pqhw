--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:11:25 11/16/2012
-- Design Name:   
-- Module Name:   C:/Users/thomas/SHA/Projekte/rewrite_signature/uniform_sampler/uniform_sampler/bench/sampler_tb.vhd
-- Project Name:  uniform_sampler
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: sampler
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



entity sampler_tb is
end sampler_tb;

architecture behavior of sampler_tb is

  -- Component Declaration for the Unit Under Test (UUT)
  
  component sampler
    generic(
      S_MAX : unsigned := to_unsigned(90, 7)
      );
    port(
      clk         : in  std_logic;
      clk_en      : in  std_logic;
      din_refresh : in  std_logic;
      din         : in  std_logic_vector(127 downto 0);
      dout        : out std_logic_vector(S_MAX'length-1 downto 0);
      valid       : out std_logic
      );
  end component;


  --Inputs
  signal clk         : std_logic                      := '0';
  signal clk_en      : std_logic                      := '0';
  signal din_refresh : std_logic                      := '0';
  signal din         : std_logic_vector(127 downto 0) := (others => '0');

  --Outputs
  signal dout  : std_logic_vector(6 downto 0);
  signal valid : std_logic;

  -- Clock period definitions
  constant clk_period : time := 10 ns;
begin

  -- Instantiate the Unit Under Test (UUT)
  uut : sampler
    generic map (
      S_MAX => to_unsigned(90, 7)
      )
    port map (
      clk         => clk,
      clk_en      => clk_en,
      din_refresh => din_refresh,
      din         => din,
      dout        => dout,
      valid       => valid
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

    clk_en            <= '1';
    wait for clk_period*10;
    din(6 downto 0)   <= std_logic_vector(to_unsigned(33, 7));
    din(13 downto 7)  <= std_logic_vector(to_unsigned(90, 7));
    din(20 downto 14) <= std_logic_vector(to_unsigned(91, 7));
    din(27 downto 21) <= std_logic_vector(to_unsigned(127, 7));
    din(34 downto 28) <= std_logic_vector(to_unsigned(45, 7));
    din_refresh       <= '1';
    wait for clk_period;
    din_refresh       <= '0';

    wait for clk_period*30;
    din(6 downto 0)   <= std_logic_vector(to_unsigned(91, 7));
    din(13 downto 7)  <= std_logic_vector(to_unsigned(20, 7));
    din(20 downto 14) <= std_logic_vector(to_unsigned(11, 7));
    din(27 downto 21) <= std_logic_vector(to_unsigned(111, 7));
    din(34 downto 28) <= std_logic_vector(to_unsigned(45, 7));
    din_refresh       <= '1';
    wait for clk_period;
    din_refresh       <= '0';

    -- insert stimulus here 

    wait;
  end process;

end;
