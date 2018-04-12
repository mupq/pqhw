--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:16:42 03/16/2012
-- Design Name:   
-- Module Name:   C:/Users/thomas/SHA/Projekte/poly_FFT/code/poly_fft/bench/fft/fft_addr_gen_tb.vhd
-- Project Name:  poly_fft
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: fft_addr_gen
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


entity fft_addr_gen_tb is
  generic (
    N_ELEMENTS : integer := 32
    );
end fft_addr_gen_tb;

architecture behavior of fft_addr_gen_tb is

  -- Component Declaration for the Unit Under Test (UUT)

  signal error_happened : std_logic := '0';  --


  --Inputs
  signal clk      : std_logic := '0';
  signal start    : std_logic := '0';
  signal finished : std_logic := '0';

  --Outputs

  signal valid : std_logic;
  signal a     : unsigned(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0);
  signal b     : unsigned(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0);
  signal n     : unsigned(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0);
  signal op    : std_logic;

  -- Clock period definitions
  constant clk_period : time := 10 ns;

  -- Generic in type does not work properly - so fixed width
  type tv_type is array (40000 downto 0) of unsigned(50 downto 0);

  impure function InitTestVector(N_ELEMENTS , N_LENGTH : integer) return tv_type is
    
    variable m    : integer := 2;
    variable s    : integer := 0;
    variable i    : integer := 0;
    variable n    : integer := 0;
    variable a    : integer := 0;
    variable b    : integer := 0;
    variable cnt  : integer := 0;
    variable l_tv : tv_type;
  begin
    while m <= N_ELEMENTS loop
      s := 0;
      while s < N_ELEMENTS loop
        for i in 0 to m/2-1 loop
          n           := i*N_ELEMENTS/m;
          a           := s+i;
          b           := s+i+m/2;
          --format (a,b,n)
          l_tv(cnt+1) := resize(to_unsigned(a, N_LENGTH) & to_unsigned(b, N_LENGTH) & to_unsigned(n, N_LENGTH) , l_tv(cnt)'length);
          cnt         := cnt +1;
        end loop;  -- i
        s := s+m;
      end loop;
      m := m*2;
    end loop;

    l_tv(0) := to_unsigned(cnt -1, l_tv(0)'length);

    return l_tv;
  end function;


  signal tv      : tv_type := InitTestVector(N_ELEMENTS , integer(ceil(log2(real(N_ELEMENTS)))));
  signal counter : integer := 1;
  
begin

  -- Instantiate the Unit Under Test (UUT)
  uut : entity work.fft_addr_gen
    generic map (
      N_ELEMENTS => N_ELEMENTS
      )
    port map (
      clk      => clk,
      start    => start,
      finished => finished,
      valid    => valid,
      a        => a,
      b        => b,
      n        => n,
      op       => op
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

    -- insert stimulus here 
    wait until falling_edge(clk);
    wait for 1ns;
    start <= '1';
    wait until falling_edge(clk);
    wait for 1ns;
    start <= '0';

    if valid /= '1' then
      wait until valid = '1';
    end if;

    wait until falling_edge(clk);
    wait for 1ns;

    while valid = '1' loop
      --Signal should hold for two cycles
        if resize(a&b&n, tv(counter)'length) /= tv(counter) then
          error_happened <= '1';
        end if;
        wait until falling_edge(clk);
        wait for 1ns;
      counter <= counter+1;
      wait for 1ns;
    end loop;

    --Now test the number of outputted values
    if to_unsigned(counter-1,tv(0)'length) /= tv(0)  then
      error_happened <= '1';
    end if;




    if error_happened = '1' then
      report "ERROR";
    else
      report "OK";
    end if;

    wait;
  end process;

end;
