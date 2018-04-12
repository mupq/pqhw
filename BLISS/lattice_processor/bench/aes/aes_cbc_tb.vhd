--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:50:04 11/16/2012
-- Design Name:   
-- Module Name:   C:/Users/thomas/SHA/Projekte/rewrite_signature/uniform_sampler/uniform_sampler/bench/aes/aes_cbc_tb.vhd
-- Project Name:  uniform_sampler
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: aes_cbc
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

entity aes_cbc_tb is
end aes_cbc_tb;

architecture behavior of aes_cbc_tb is

  -- Component Declaration for the Unit Under Test (UUT)
  
  component aes_cbc
    port(
      clk    : in  std_logic;
      rst    : in  std_logic;
      enable : in  std_logic;
      seed   : in  std_logic_vector(127 downto 0);
      key    : in  std_logic_vector(127 downto 0);
      dout   : out std_logic_vector(127 downto 0);
      done   : out std_logic
      );
  end component;


  --Inputs
  signal clk    : std_logic                      := '0';
  signal rst    : std_logic                      := '0';
  signal enable : std_logic                      := '0';
  signal seed   : std_logic_vector(127 downto 0) := (others => '0');
  signal key    : std_logic_vector(127 downto 0) := (others => '0');

  --Outputs
  signal dout : std_logic_vector(127 downto 0);
  signal done : std_logic;

  -- Clock period definitions
  constant clk_period : time := 10 ns;
  
begin

  -- Instantiate the Unit Under Test (UUT)
  uut : aes_cbc port map (
    clk    => clk,
    rst    => rst,
    enable => enable,
    seed   => seed,
    key    => key,
    dout   => dout,
    done   => done
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
    seed    <= x"00112233445566778899aabbccddeeff";
    key    <= x"000102030405060708090a0b0c0d0e0f";
    rst    <= '1';
    wait for clk_period;
    rst    <= '0';
    wait for clk_period;
    enable <= '1';
    wait for clk_period;
    enable <= '0';
    
    wait until done='1';
    wait for clk_period;
    enable <='1';
    wait for clk_period;
    enable <= '0';

    wait for clk_period*130;

    wait for clk_period*10;
    seed    <= x"00112233445566778899aabbccddeeff";
    key    <= x"000102030405060708090a0b0c0d0e0f";
    rst    <= '1';
    wait for clk_period;
    rst    <= '0';
    wait for clk_period;
    enable <= '1';
    wait for clk_period;
    enable <= '0';


    -- insert stimulus here 

    wait;
  end process;

end;
