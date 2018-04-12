--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:31:59 11/19/2012
-- Design Name:   
-- Module Name:   C:/Users/thomas/SHA/Projekte/rewrite_signature/uniform_sampler/uniform_sampler/bench/uniform_sampler_tb.vhd
-- Project Name:  uniform_sampler
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: uniform_sampler
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
use std.textio.all;

--use work.txt_util.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

entity uniform_sampler_tb is
end uniform_sampler_tb;

architecture behavior of uniform_sampler_tb is

  -- Component Declaration for the Unit Under Test (UUT)
  
  

  constant S1_MAX           : unsigned := to_unsigned(37011, integer(ceil(log2(real(37011)))));
  constant S1_FIFO_ELEMENTS : integer  := 512;



  --Inputs
  signal clk        : std_logic := '0';
  signal sample_s1  : std_logic := '0';
  signal key_update : std_logic := '0';

  signal reset : std_logic                      := '0';
  signal seed  : std_logic_vector(127 downto 0) := (others => '0');
  signal key   : std_logic_vector(127 downto 0) := (others => '0');
  signal init  : std_logic;

  --Outputs
  signal ready : std_logic;

  signal s1_out   : std_logic_vector(S1_MAX'length-1 downto 0);
  signal s1_addr  : std_logic_vector(integer(ceil(log2(real(S1_FIFO_ELEMENTS))))-1 downto 0) :=(others => '0');
  signal s1_valid : std_logic := '0';

  -- Clock period definitions
  constant clk_period : time := 10 ns;


  --File Stuff
  file random_file : text open write_mode is "random_data";
  
begin

  -- Instantiate the Unit Under Test (UUT)

  uniform_sampler_1 : entity work.uniform_sampler
    generic map (
      S1_MAX           => S1_MAX,
      S1_FIFO_ELEMENTS => S1_FIFO_ELEMENTS)
    port map (
      clk        => clk,
      ready      => ready,
      seed       => seed,
      key        => key,
      init       => init,
      key_update => key_update,
      s1_dout     => s1_out,
      s1_addr    => s1_addr
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
    variable l : line;
  begin  -- process
    if rising_edge(clk) then
      if s1_valid = '1' then
        write(l, to_integer(unsigned(s1_out)));
        writeline(random_file, l);
      end if;
      
    end if;
    
  end process;


  -- Stimulus process
  stim_proc : process
    variable i : integer := 0;
  begin
    -- hold reset state for 100 ns.
    wait for 100 ns;

    init       <= '1';
    key        <= (others => '1');
    wait for clk_period;
    init       <= '0';
    wait for clk_period;
    sample_s1  <= '1';
    wait for clk_period*1;
    sample_s1  <= '0';
    wait for clk_period*500;
    key_update <= '1';
    key        <= std_logic_vector(to_unsigned(1, key'length));
    wait for clk_period*1;
    key_update <= '0';

    for i in 0 to 10 loop
      wait until ready = '1';
      wait for clk_period/2;
      wait for clk_period*10000;
      sample_s1 <= '1';
      wait for clk_period*1;
      sample_s1 <= '0';
      
    end loop;  -- i


    -- insert stimulus here 

    wait;
  end process;

end;
