--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:55:17 02/03/2012 
-- Design Name: 
-- Module Name:    adder - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;



entity adder is
  generic (
    VAL1_WIDTH : integer := 23;
    VAL2_WIDTH : integer := 23
    );
  port (
    clk  : in  std_logic;
    val1 : in  unsigned(VAL1_WIDTH-1 downto 0);
    val2 : in  unsigned(VAL2_WIDTH-1 downto 0);
    delay: out integer :=3;
    sum  : out unsigned( VAL1_WIDTH+1 -1 downto 0)
    );
end adder;

architecture Behavioral of adder is

  signal val1_reg : unsigned(val1'length-1 downto 0);
  signal val2_reg : unsigned(val2'length-1 downto 0);
  signal out_reg  : unsigned(sum'length-1 downto 0);
  
begin

  process(clk)
  begin  -- process c
    if rising_edge(clk) then

      val1_reg <= val1;
      val2_reg <= val2;

      out_reg <= ("0" & val1_reg) + val2_reg;

      sum <= out_reg;
      
    end if;
  end process;


end Behavioral;

