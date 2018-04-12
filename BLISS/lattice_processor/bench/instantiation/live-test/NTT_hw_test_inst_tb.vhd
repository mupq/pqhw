-- TestBench Template 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity NTT_hw_test_tb is
end NTT_hw_test_tb;

architecture behavior of NTT_hw_test_tb is


  signal clk    : std_logic;
  signal status : std_logic_vector(3 downto 0);
  signal coeff : std_logic_vector(57 downto 0);
  signal dout_valid : std_logic;
   -- Clock period definitions
   constant clk_period : time := 20 ns;
begin

  -- Clock process definitions
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;


  NTT_hw_test_instantiation_1 : entity work.NTT_hw_test_instantiation
    port map (
      clk    => clk,
      status => status,
      dout_coeff => coeff,
      dout_valid => dout_valid
      );


  --  Test Bench Statements
  tb : process
  begin

    wait for 100 ns;  -- wait until global set/reset completes

    -- Add user defined stimulus here

    wait;                               -- will wait forever
  end process tb;
  --  End Test Bench 

end;
