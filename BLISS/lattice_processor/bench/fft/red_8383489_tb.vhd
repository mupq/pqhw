--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:42:44 12/04/2012
-- Design Name:   
-- Module Name:   C:/Users/thomas/SHA/Projekte/rewrite_signature/lattice_processor/lattice_processor/bench/fft/red_8383489_tb.vhd
-- Project Name:  lattice_processor
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: red_8383489
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
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 use ieee.numeric_std.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY red_8383489_tb IS
END red_8383489_tb;
 
ARCHITECTURE behavior OF red_8383489_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
   
   --Inputs
   signal clk : std_logic := '0';
   signal val : Unsigned(45 downto 0) := (others => '0');

 	--Outputs
   signal red : Unsigned(22 downto 0);
   signal val_mod: Unsigned(22 downto 0);

    signal delay : integer                   := 3;
  signal counter        : unsigned(2*23-1 downto 0) := (others => '0');
  signal error_happened : std_logic                 := '0';
  constant PRIME_P    : unsigned := to_unsigned(8383489, 23);


   
   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut:entity work.red_8383489_fft
     PORT MAP (
          clk => clk,
          val => val,
          red => red,
          delay => delay
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
   
       wait for 100 ns;


    while counter < PRIME_P*PRIME_P loop
      wait until rising_edge(clk);
      wait for 1ns;
      val <= counter;
      wait for 1ns;
      val_mod <= val mod PRIME_P;

      for j in 0 to delay-1 loop
        wait until rising_edge(clk);
        wait for 1ns;
      end loop;  -- j in range


      
      if red /= val mod PRIME_P then
        report "error";
        error_happened <= '1';

      end if;

      counter <=counter+333333333;
      
    end loop;

    if error_happened = '0' then
      report "OK";
    else
      report "ERROR";
    end if;


    wait for clk_period*10;

    -- insert stimulus here 

    wait;

      -- insert stimulus here 

      wait;
   end process;

END;
