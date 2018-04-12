--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:49:55 07/25/2013
-- Design Name:   
-- Module Name:   C:/Users/thomas/SHA/Projekte/rewrite_signature/lattice_processor/lattice_processor/bench/uniform_sampler_2/uni_sampler_2_tb.vhd
-- Project Name:  lattice_processor
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: uni_sampler_wrapper
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

entity uni_sampler_2_tb is
end uni_sampler_2_tb;

architecture behavior of uni_sampler_2_tb is
  constant PRIME_P : unsigned := to_unsigned(8383489, 23);
  constant S1_FIFO_ELEMENTS : integer := 512;
  
  signal clk          : std_logic;
  signal ready        : std_logic;
  signal start        : std_logic := '0';
  signal stop         : std_logic := '0';
  signal output_delay : integer   := 6;
  signal s1_dout      : std_logic_vector(PRIME_P'length-1 downto 0):=(others => '0');
  signal s1_addr      : std_logic_vector(integer(ceil(log2(real(S1_FIFO_ELEMENTS))))-1 downto 0):=(others => '0');


  -- Clock period definitions
  constant clk_period : time := 10 ns;
  
begin

  -- Instantiate the Unit Under Test (UUT)
  uniform_sampler2_1 :entity work.uniform_sampler2
    generic map (
      PRIME_P          => to_unsigned(8383489, 23),
      S1_MAX           => to_unsigned(2*(2**14)+1, 16),
      OUT_RANGE => "POSNEG",
      S1_FIFO_ELEMENTS => 512
      )
    port map (
      clk          => clk,
      ready        => ready,
      start        => start,
      stop         => stop,
      output_delay => output_delay,
      s1_dout      => s1_dout,
      s1_addr      => s1_addr);




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

    if ready = '0' then
      wait until ready = '1';
    end if;

    wait for clk_period*10;

    for i in 0 to 512 loop
      s1_addr <= std_logic_vector(unsigned(s1_addr)+1);
      wait for clk_period;
    end loop;  -- i

    -- insert stimulus here 

    wait;
  end process;

end;
