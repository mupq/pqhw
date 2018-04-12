--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:44:09 02/11/2014
-- Design Name:   
-- Module Name:   C:/Users/thomas/SHA/Projekte/BLISS/code/sparse_mul/sparse_mul/rtl/bliss_keccack/keccak_tb.vhd
-- Project Name:  sparse_mul
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: keccak
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

entity keccak_test_tb is
end keccak_test_tb;

architecture behavior of keccak_test_tb is

  -- Component Declaration for the Unit Under Test (UUT)

  --Inputs
  signal clk     : std_logic                     := '0';
  signal rst_n   : std_logic                     := '0';
  signal init    : std_logic                     := '0';
  signal go      : std_logic                     := '0';
  signal absorb  : std_logic                     := '0';
  signal squeeze : std_logic                     := '0';
  signal din     : std_logic_vector(63 downto 0) := (others => '0');

  --Outputs
  signal ready : std_logic;
  signal dout  : std_logic_vector(63 downto 0);

  -- Clock period definitions
  constant clk_period : time := 10 ns;
  
begin



  -- Instantiate the Unit Under Test (UUT)
  uut : entity work.keccak port map (
    clk     => clk,
    rst_n   => rst_n,
    init    => init,
    go      => go,
    absorb  => absorb,
    squeeze => squeeze,
    din     => din,
    ready   => ready,
    dout    => dout
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
    --To test if the keccak works as the Keccak from the C version
    rst_n <= '0';
    wait for clk_period;
    rst_n <= '1';
    wait for clk_period*5;

    for i in 0 to 14 loop
      absorb <= '1';
      din    <= (others => '1');
      wait for clk_period;
    end loop;  -- i

    --Absorb the padding
    absorb <= '1';
    din    <= (din'length-1 => '1', others => '0');
    wait for clk_period;
    absorb <= '0';

    wait for clk_period;
    go <= '1';
    wait for clk_period;
    go <= '0';

    wait for clk_period*5;

    while ready='0' loop
      wait for clk_period;
    end loop;

    wait for clk_period*5;

    for i in 0 to 3 loop
      squeeze <= '1';
      wait for clk_period;
    end loop;  -- i 
    squeeze <= '0';


    -- insert stimulus here 

    wait;
  end process;

end;
