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


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity red_1061093377 is
  port (
    clk   : in  std_logic;
    val   : in  unsigned(2*30-1 downto 0) := (others => '0');
    red   : out unsigned(30-1 downto 0)   := (others => '0');
    delay : out integer                   := 19
    );
end red_1061093377;

architecture Behavioral of red_1061093377 is
  constant PRIME_P : unsigned := to_unsigned(1061093377, 30);

  signal temp1    : unsigned(60-1 downto 0) := (others => '0');
  signal temp1_r  : unsigned(60-1 downto 0) := (others => '0');
  signal temp1_r1 : unsigned(60-1 downto 0) := (others => '0');
  signal temp1_r2 : unsigned(60-1 downto 0) := (others => '0');


  signal temp2   : unsigned(60-1 downto 0) := (others => '0');
  signal temp2_r : unsigned(60-1 downto 0) := (others => '0');


  signal temp3   : unsigned(60-1 downto 0) := (others => '0');
  signal temp3_r : unsigned(60-1 downto 0) := (others => '0');


  signal sum1  : unsigned(60-1 downto 0) := (others => '0');
  signal sum2  : unsigned(60-1 downto 0) := (others => '0');
  signal sum3  : unsigned(60-1 downto 0) := (others => '0');
  signal sum4  : unsigned(60-1 downto 0) := (others => '0');
  signal sum5  : unsigned(60-1 downto 0) := (others => '0');
  signal sum6  : unsigned(60-1 downto 0) := (others => '0');
  signal sum7  : unsigned(60-1 downto 0) := (others => '0');
  signal sum8  : unsigned(60-1 downto 0) := (others => '0');
  signal sum9  : unsigned(60-1 downto 0) := (others => '0');
  signal sum10 : unsigned(60-1 downto 0) := (others => '0');


  signal temp_sum1 : unsigned(60-1 downto 0) := (others => '0');
  signal temp_sum2 : unsigned(60-1 downto 0) := (others => '0');

  signal sumsum1     : unsigned(60-1 downto 0) := (others => '0');
  signal sumsum1_reg : unsigned(60-1 downto 0) := (others => '0');

  signal sumsum2     : unsigned(60-1 downto 0) := (others => '0');
  signal sumsum2_reg : unsigned(60-1 downto 0) := (others => '0');

  signal xxxx : unsigned(60-1 downto 0) := (others => '0');


  signal temp4   : unsigned(60-1 downto 0) := (others => '0');
  signal temp4_r : unsigned(60-1 downto 0) := (others => '0');

  signal in_reg   : unsigned(60-1 downto 0) := (others => '0');
  signal in_reg_r : unsigned(60-1 downto 0) := (others => '0');

  signal temp2_r1 : unsigned(60-1 downto 0) := (others => '0');
  signal temp3_r1 : unsigned(60-1 downto 0) := (others => '0');
  signal temp4_r1 : unsigned(60-1 downto 0) := (others => '0');


  signal red_reg : unsigned(30-1 downto 0) := (others => '0');
  signal red_r   : unsigned(30-1 downto 0) := (others => '0');

begin
  process (clk)
  begin
    if rising_edge(clk) then


      in_reg_r <= val;
      in_reg   <= in_reg_r;


      sum1 <= (resize(in_reg(59 downto 44), 60)sll 16) +
              (resize(in_reg(59 downto 44), 60)sll (16+7)) +
              (resize(in_reg(59 downto 44), 60)sll (16+8));
      sum2 <= (resize(in_reg(59 downto 44), 60)sll (16+12)) +
              (resize(in_reg(59 downto 44), 60)sll (16+15));

      
      sum5 <= resize((2*PRIME_P- (
        (resize(in_reg(59 downto 44), 60)sll (0)) +
        (resize(in_reg(59 downto 44), 60)sll (6)) +
        (resize(in_reg(59 downto 44), 60)sll (7)) +
        ((resize(in_reg(59 downto 44), 48))sll 14))), temp1'length); 
      sum6 <= resize(((resize(in_reg(43 downto 30), 46))sll 16)+((resize(in_reg(43 downto 30), 46))sll (16+6)) , temp1'length);
      sum7 <= resize(((resize(in_reg(43 downto 30), 46))sll (16+7)) +(PRIME_P-in_reg(43 downto 30))+in_reg(29 downto 0), temp1'length);


      sumsum1 <= sum1+sum2;
      sumsum2 <= sum5+sum6+sum7;


      sumsum1_reg <= sumsum1;
      sumsum2_reg <= sumsum2;
      -- temp1_r1 <= sumsum2+sumsum1;
      xxxx        <= sumsum1_reg+sumsum2_reg;
      temp1       <= xxxx;


      temp_sum1 <= resize(((resize(temp1(52 downto 30), 30+17)) sll 23)+((resize(temp1(52 downto 30), 30+17)) sll 22) , temp2'length);
      temp_sum2 <= resize(((resize(temp1(52 downto 30), 30+17)) sll 16) +(PRIME_P- temp1(52 downto 30))+temp1(29 downto 0), temp2'length);

      temp2_r1 <= temp_sum1+temp_sum2;
      temp2    <= temp2_r1;

      temp3_r <= resize(((resize(temp2(47 downto 30), 30+17)) sll 23)+((resize(temp2(47 downto 30), 30+17)) sll 22)+((resize(temp2(47 downto 30), 30+17)) sll 16) +(PRIME_P- temp2(47 downto 30))+temp2(29 downto 0) , temp3'length);

      temp3_r1 <= temp3_r;
      temp3    <= temp3_r1;

      temp4_r <= resize(((resize(temp3(37 downto 30), 30+17)) sll 23)+((resize(temp3(37 downto 30), 30+17)) sll 22)+((resize(temp3(37 downto 30), 30+17)) sll 16) +(PRIME_P- temp3(37 downto 30))+temp3(29 downto 0) , temp4'length);

      temp4_r1 <= temp4_r;
      temp4    <= temp4_r1;

      assert (temp4 < 3*PRIME_P) report "TOOO BIIIIGG" severity failure;

      if temp4 >= 3*PRIME_P then
        red_reg <= resize(temp4 - 3*PRIME_P, red'length);
      elsif temp4 >= 2*PRIME_P then
        red_reg <= resize(temp4 - 2*PRIME_P, red'length);
      elsif temp4 >= PRIME_P then
        red_reg <= resize(temp4 - PRIME_P, red'length);
      else
        red_reg <= resize(temp4, red'length);
      end if;

      red_r <= red_reg;
      red   <= red_r;
    end if;
  end process;

end Behavioral;















--temp1_r2 <= resize(
--       (resize(in_reg(59 downto 44), 60)sll 16) +
--       (resize(in_reg(59 downto 44), 60)sll (16+7)) +
--       (resize(in_reg(59 downto 44), 60)sll (16+8)) +
--       (resize(in_reg(59 downto 44), 60)sll (16+12)) +
--       (resize(in_reg(59 downto 44), 60)sll (16+15)) +
--       (2*PRIME_P- (
--        (resize(in_reg(59 downto 44), 60)sll (0)) +
--         (resize(in_reg(59 downto 44), 60)sll (6)) +
--         (resize(in_reg(59 downto 44), 60)sll (7)) +
--         ((resize(in_reg(59 downto 44), 48))sll 14))) + ((resize(in_reg(43 downto 30), 46))sll 16)+((resize(in_reg(43 downto 30), 46))sll (16+6))+((resize(in_reg(43 downto 30), 46))sll (16+7)) +(PRIME_P-in_reg(43 downto 30))+in_reg(29 downto 0) , temp1'length);



--     temp1_r1 <= temp1_r2;
--     temp1_r  <= temp1_r1;
--     temp1    <= temp1_r;
