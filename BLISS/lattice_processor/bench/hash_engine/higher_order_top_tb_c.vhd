--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:22:51 09/02/2011
-- Design Name:   
-- Module Name:   /home/thomasp/xilinx/DSPMU/higher_order_top_tb_c.vhd
-- Project Name:  DSP_Mul
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: higher_order_top
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

entity higher_order_top_tb_c is
end higher_order_top_tb_c;

architecture behavior of higher_order_top_tb_c is

  -- Component Declaration for the Unit Under Test (UUT)
  
  component higher_order_top
    port(
      clk : in  std_logic;
      y   : in  std_logic_vector(22 downto 0);
      y1  : out std_logic_vector(8 downto 0)
      );
  end component;

  --End of simulation
  signal end_of_simulation : std_logic := '0';

  --Inputs
  signal clk : std_logic                     := '0';
  signal y   : std_logic_vector(22 downto 0) := (others => '0');

  --Outputs
  signal y1 : std_logic_vector(8 downto 0);

  -- Clock period definitions
  constant clk_period : time := 10 ns;

  signal y1_res         : std_logic_vector(8 downto 0) := (others => '0');
  signal y1_res_delayed : std_logic_vector(8 downto 0) := (others => '0');

  signal error_happened : std_logic := '0';
begin

  -- Instantiate the Unit Under Test (UUT)
  uut : higher_order_top port map (
    clk => clk,
    y   => y,
    y1  => y1
    );

  -- Clock process definitions
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  data_y_register : entity work.shift_reg
    generic map(
      width => 9,
      depth => 13
      )
    port map(
      input  => y1_res,
      output => y1_res_delayed,
      clk    => clk
      );

  -- Stimulus process
  stim_proc : process
    variable temp                            :       integer;
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
    y <= (others => '0');
    -- hold reset state for 100 ns.
    wait for 1000 ns;

    --wait until rising_edge(clk);
    wait for clk_period*1;

    --One Value
    y <= std_logic_vector(to_signed(50000, 23));
    wait for clk_period*1;
    y <= (others => '0');
    wait for clk_period*10;

    y <= std_logic_vector(to_signed(-50000, 23));
    wait for clk_period*1;
    y <= (others => '0');
    wait for clk_period*10;

    wait for clk_period*10;
    wait for clk_period*10;

    -- Automatic testing of all values consecutively
    for var in -(8383488)/2 to (8383488)/2 loop
      y    <= std_logic_vector(to_signed(var, 23));
      temp := (var mod 32705);
      if temp > (32705-1)/2 then
        temp := temp - 32705;
      end if;
      y1_res <= std_logic_vector(to_signed((var - temp)/32705, 9));
      wait for clk_period;
      if y1 /= std_logic_vector(y1_res_delayed) then
        report "Error" severity error;
        error_happened <= '1';
      end if;
      
    end loop;  -- var


    -- Automatic testing of randomly selected values 
    for var in 0 to 8383488+16352 loop
      -- Get random value
      rand_int(seed1, seed2, -(8383488)/2, (8383488)/2, N);

      -- As above
      y    <= std_logic_vector(to_signed(N, 23));
      temp := (N mod 32705);
      if temp > (32705-1)/2 then
        temp := temp - 32705;
      end if;
      y1_res <= std_logic_vector(to_signed((N - temp)/32705, 9));
      wait for clk_period;

      if y1 /= std_logic_vector(y1_res_delayed) then
        report "Error" severity error;
        error_happened <= '1';
      end if;
      
      end loop;  -- var


      if error_happened='1' then
        report "ERROR";
      else
        report "OK";
      end if;
      end_of_simulation <= '1';

      wait;
      end process;

      end;
