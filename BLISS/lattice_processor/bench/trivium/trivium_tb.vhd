--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY trivium_tb IS
END trivium_tb;
 
ARCHITECTURE behavior OF trivium_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT trivium
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         key : IN  std_logic_vector(79 downto 0);
         IV : IN  std_logic_vector(79 downto 0);
         o_vld : OUT  std_logic;
         z : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal key : std_logic_vector(79 downto 0) := (others => '0');
   signal IV : std_logic_vector(79 downto 0) := (others => '0');

 	--Outputs
   signal o_vld : std_logic;
   signal z : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: trivium PORT MAP (
          clk => clk,
          rst => rst,
          key => key,
          IV => IV,
          o_vld => o_vld,
          z => z
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
      rst <= '1';
      wait for clk_period;
      rst <= '0';
      key <= (others => '0');
      iv <= (others => '0');
      

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
