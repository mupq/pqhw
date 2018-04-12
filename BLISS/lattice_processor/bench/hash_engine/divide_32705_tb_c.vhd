--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:45:50 09/02/2011
-- Design Name:   
-- Module Name:   /home/thomasp/xilinx/DSPMU/higher_order/divide_32705_tb_c.vhd
-- Project Name:  DSP_Mul
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: divide_32705
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

entity divide_32705_tb_c is
end divide_32705_tb_c;

architecture behavior of divide_32705_tb_c is

  -- Component Declaration for the Unit Under Test (UUT)
  
  component divide_32705
    port(
      clk    : in  std_logic;
      value  : in  std_logic_vector(23 downto 0);
      output : out std_logic_vector(8 downto 0)
      );
  end component;

  --End of simulation
  signal end_of_simulation : std_logic := '0';

  --Inputs
  signal clk             : std_logic                     := '0';
  signal value           : std_logic_vector(23 downto 0) := (others => '0');
  signal div_res         : std_logic_vector(8 downto 0)  := (others => '0');
  signal div_res_delayed : std_logic_vector(8 downto 0)  := (others => '0');


  --Outputs
  signal output : std_logic_vector(8 downto 0);

  -- Clock period definitions
  constant clk_period : time := 10 ns;

  signal error_happened : std_logic := '0';
  
begin

  -- Instantiate the Unit Under Test (UUT)
  uut : divide_32705 port map (
    clk    => clk,
    value  => value,
    output => output
    );

  -- Clock process definitions
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  --Holds data from BRAM y
  data_y_register : entity work.shift_reg
    generic map(
      width => 9,
      depth => 9
      )
    port map(
      input  => div_res,
      output => div_res_delayed,
      clk    => clk
      );

  -- Stimulus process
  stim_proc : process
    variable N                               :       integer;  -- range 0 to 2**this_size-1;
    variable seed1                           :       integer := 12362;
    variable seed2                           :       integer := 54783;
    procedure rand_int(variable seed1, seed2 : inout positive; min, max : in integer; result : out integer) is
      variable rand : real;
    begin
      uniform(seed1, seed2, rand);
      result := integer(real(min) + (rand * (real(max)-real(min))));
    end procedure;
    
  begin
    -- hold reset state for 100 ns.
    wait for 100 ns;

    -- wait until rising_edge(clk);
    wait for clk_period*10;

    -- Some examples
    value <= std_logic_vector(to_unsigned(32705, 24));
    wait for clk_period;
    value <= std_logic_vector(to_unsigned(0, 24));
    wait for clk_period*10;



    ---- Automatic testing of randomly selected values 
    --for var in 0 to 8383488+16352 loop
    --  -- Get random value
    --  rand_int(seed1, seed2, 1, 8383489, N);

    --  -- As above
    --  value   <= std_logic_vector(to_unsigned(N, 24));
    --  div_res <= std_logic_vector(to_unsigned(N / 32705, 9));
    --  wait for clk_period;
    --  if output /= std_logic_vector(div_res_delayed) then
    --    report "Error";
    --    error_happened <= '1';
    --  end if;
    --end loop;  -- var


    
    -- Automatic testing of all values 
    for var in 0 to 8383488+16352 loop
      value   <= std_logic_vector(to_unsigned(var, 24));
      div_res <= std_logic_vector(to_unsigned(var / 32705, 9));
      wait for clk_period;
      wait for 1ns;
      if output /= std_logic_vector(div_res_delayed) then
        report "Error";
        error_happened <= '1';
      end if;
    end loop;  -- var


    if error_happened='1' then
      report "ERROR";
    else
      report "OK";
    end if;
    
    end_of_simulation <= '1';
    -- insert stimulus here 

    wait;
  end process;

end;
