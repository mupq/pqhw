-- TestBench Template 

--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:37:12 04/24/2012
-- Design Name:   
-- Module Name:   C:/Users/thomas/SHA/Projekte/poly_FFT/code/poly_fft/bench/fft/red_1049089_tb.vhd
-- Project Name:  poly_fft
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: red_1049089
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

entity red_144115188076060673_tb is
end red_144115188076060673_tb;

architecture behavior of red_144115188076060673_tb is

  -- Component Declaration for the Unit Under Test (UUT)
  

  signal clk     : std_logic;
  signal val     : unsigned(2*58-1 downto 0) := (others => '0');
  signal red     : unsigned(58-1 downto 0)   := (others => '0');
  signal reduced : unsigned(58-1 downto 0)   := (others => '0');

  signal delay : integer := 3;

  signal counter        : unsigned(2*58-1 downto 0) := (others => '0');
  signal error_happened : std_logic                 := '0';


  -- Clock period definitions
  constant clk_period : time                   := 10 ns;
  constant PRIME_P    : unsigned(115 downto 0) := (to_unsigned(1, 116)sll 13)+(to_unsigned(1, 116)sll 16)+(to_unsigned(1, 116)sll 17)+(to_unsigned(1, 116)sll 57)+(to_unsigned(1, 116));

begin

  red_65537_1 : entity work.red_144115188076060673
    port map (
      clk   => clk,
      val   => val,
      red   => red,
      delay => delay
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


    while counter < PRIME_P*PRIME_P loop
      wait until rising_edge(clk);
      wait for 1ns;
      val <= counter;


      for j in 0 to delay-1 loop
        wait until rising_edge(clk);
        wait for 1ns;
      end loop;  -- j in range


      reduced <= resize(counter mod PRIME_P , reduced'length);
      if red /= (counter mod PRIME_P) then
        report "error";
        error_happened <= '1';

      end if;

      wait for 1ns;

      counter <= resize(counter+(counter/10)*2+1, counter'length);
      
    end loop;

    if error_happened = '0' then
      report "OK";
    else
      report "ERROR";
    end if;

    wait for clk_period*10;

    -- insert stimulus here 

    wait;
  end process;

end;