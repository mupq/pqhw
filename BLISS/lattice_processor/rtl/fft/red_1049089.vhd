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
-- Create Date:    16:46:23 04/24/2012 
-- Design Name: 
-- Module Name:    red_1049089 - Behavioral 
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




entity red_1049089 is
  port (
    clk   : in  std_logic;
    val   : in  unsigned(2*21-1 downto 0) := (others => '0');
    red   : out unsigned(21-1 downto 0)   := (others => '0');
    delay : out integer                   := 12
    );
end red_1049089;

architecture Behavioral of red_1049089 is
  constant PRIME_P : unsigned := to_unsigned(1049089, 21);

  signal temp    : unsigned(42-1 downto 0) := (others => '0');
  signal temp_r  : unsigned(42-1 downto 0) := (others => '0');
  signal temp2_r : unsigned(42-1 downto 0) := (others => '0');
  signal temp2_x : unsigned(42-1 downto 0) := (others => '0');

  signal temp2 : unsigned(42-1 downto 0) := (others => '0');
  signal temp3 : unsigned(42-1 downto 0) := (others => '0');

  signal temp3_r : unsigned(42-1 downto 0) := (others => '0');
  signal diff    : unsigned(42-1 downto 0) := (others => '0');

  signal sum : unsigned(20 downto 0) := (others => '0');

  signal temp2_r1 : unsigned(42-1 downto 0) := (others => '0');


  signal in_reg  : unsigned(42-1 downto 0) := (others => '0');
  signal red_reg : unsigned(21-1 downto 0) := (others => '0');

begin
  process (clk)
  begin
    if rising_edge(clk) then

      in_reg <= val;


      diff <= resize(PRIME_P*2048-((resize(in_reg(41 downto 21), 34) sll 10)+ (2*in_reg(41 downto 21))), diff'length);
      sum  <= in_reg(20 downto 0);

      temp_r <= diff + sum;

      temp2_x <= temp_r;
      temp    <= temp2_x;

      temp2_r <= temp(20 downto 0) + (8*PRIME_P-((temp(41 downto 21) sll 10)+ (((("0"&temp(41 downto 21))sll 1)))));

      temp2_r1 <= temp2_r;
      temp2    <= temp2_r1;

      temp3_r <= temp2(20 downto 0) + (2*PRIME_P-((temp2(41 downto 21) sll 10)+ ((("0"&temp2(41 downto 21)sll 1)))));

      temp3 <= temp3_r;

      assert (temp3 < 4*PRIME_P) report "TOOO BIIIIGG" severity failure;

      if temp3 >= 3*PRIME_P then
        red_reg <= resize(temp3 - 3*PRIME_P, red'length);
      elsif temp3 >= 2*PRIME_P then
        red_reg <= resize(temp3 - 2*PRIME_P, red'length);
      elsif temp3 >= PRIME_P then
        red_reg <= resize(temp3 - PRIME_P, red'length);
      else
        red_reg <= resize(temp3, red'length);
      end if;


      red <= red_reg;
    end if;
  end process;

end Behavioral;

