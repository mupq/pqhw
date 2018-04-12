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
-- Create Date:    12:06:36 12/04/2012 
-- Design Name: 
-- Module Name:    red_8383489_fft - Behavioral 
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
library UNISIM;
use UNISIM.VComponents.all;



entity red_8383489_fft is
  port (
    clk   : in  std_logic;
    val   : in  unsigned(2*23-1 downto 0) := (others => '0');
    red   : out unsigned(23-1 downto 0)   := (others => '0');
    delay : out integer                   := 8
    );
end red_8383489_fft;


architecture Behavioral of red_8383489_fft is

  constant PRIME_P : unsigned(22 downto 0) := to_unsigned(8383489, 23);
  signal   val_r1  : unsigned(val'length-1 downto 0);

  signal mul_res_1 : unsigned(35 downto 0);
  signal mul_reg_1 : unsigned(22 downto 0);

  signal add_res : unsigned(35 downto 0);

  signal mul_res_2 : unsigned(27 downto 0);
  signal mul_reg_2 : unsigned(22 downto 0);

  signal add_res2 : unsigned(25 downto 0);

  signal mul_res_3 : unsigned(17 downto 0);
  signal mul_reg_3 : unsigned(22 downto 0);

  signal add_res3 : unsigned(28 downto 0);

begin
-- Changed some vlaues 10.06.2013


  process(clk)
  begin
    if rising_edge(clk) then
      --Stage 1
      val_r1 <= val;

      --Stage 2
      mul_res_1 <= ((resize(val_r1(val_r1'length-1 downto 23), mul_res_1'length)) sll 13)-((resize(val_r1(val_r1'length-1 downto 23), mul_res_1'length)) sll 11)-((resize(val_r1(val_r1'length-1 downto 23), mul_res_1'length)) sll 10)-((resize(val_r1(val_r1'length-1 downto 23), mul_res_1'length)) sll 0);
      mul_reg_1 <= val_r1(22 downto 0);
      --Stage 3
      add_res   <= resize(mul_res_1, add_res'length) + mul_reg_1;
      --Stage 4
      mul_res_2 <= resize(((resize(add_res(add_res'length-1 downto 23), mul_res_2'length)) sll 13)-((resize(add_res(add_res'length-1 downto 23), add_res'length)) sll 11)-((resize(add_res(add_res'length-1 downto 23), add_res'length)) sll 10)-((resize(add_res(add_res'length-1 downto 23), add_res'length)) sll 0), mul_res_2'length);
      mul_reg_2 <= add_res(22 downto 0);
      --Stage 5
      add_res2  <= resize(mul_res_2, add_res2'length)+mul_reg_2;
      --Stage 6
      mul_res_3 <= resize(((resize(add_res2(add_res2'length-1 downto 23), mul_res_3'length)) sll 13)-((resize(add_res2(add_res2'length-1 downto 23), mul_res_3'length)) sll 11)-((resize(add_res2(add_res2'length-1 downto 23), mul_res_3'length)) sll 10)-((resize(add_res2(add_res2'length-1 downto 23), mul_res_3'length)) sll 0), mul_res_3'length);
      mul_reg_3 <= add_res2(22 downto 0);
      --Stage 7      
      add_res3  <= resize(mul_res_3, add_res3'length)+mul_reg_3;
      --Stage 8
      if add_res3 > PRIME_P then
        red <= resize(add_res3(red'length-1 downto 0)-PRIME_P, red'length);
        
      else
        red <= add_res3(red'length-1 downto 0);
      end if;
      
      
    end if;
  end process;





end Behavioral;

