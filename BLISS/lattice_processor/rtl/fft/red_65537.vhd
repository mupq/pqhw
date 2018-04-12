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
-- Create Date:    18:42:58 04/24/2012 
-- Design Name: 
-- Module Name:    red_65537 - Behavioral 
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


entity red_65537 is
  port (
    clk   : in  std_logic;
    val   : in  unsigned(2*17-1 downto 0) := (others => '0');
    red   : out unsigned(17-1 downto 0)   := (others => '0');
    delay : out integer                   := 4
    );
end red_65537;

architecture Behavioral of red_65537 is
  constant PRIME_P : unsigned                  := to_unsigned(65537, 17);
  signal   temp    : unsigned(17 downto 0)     := (others => '0');
  signal   red_reg : unsigned(17-1 downto 0)   := (others => '0');
  signal   in_reg  : unsigned(2*17-1 downto 0) := (others => '0');

begin

  process(clk)
  begin
    if rising_edge(clk) then
      in_reg <= val;

      temp <= in_reg(15 downto 0) + (PRIME_P -in_reg(33 downto 16));

      if temp >= PRIME_P then
        red_reg <= resize(temp -PRIME_P, red'length);
      else
        red_reg <= resize(temp, red'length);
      end if;

      red <= red_reg;
      
    end if;
  end process;


end Behavioral;

