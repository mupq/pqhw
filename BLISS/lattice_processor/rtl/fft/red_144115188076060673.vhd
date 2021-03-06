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

entity red_144115188076060673 is
  port (
    clk   : in  std_logic;
    val   : in  unsigned(2*58-1 downto 0) := (others => '0');
    red   : out unsigned(58-1 downto 0)   := (others => '0');
    delay : out integer                   := 7
    );
end red_144115188076060673;

architecture Behavioral of red_144115188076060673 is
  constant PRIME_P : unsigned(57 downto 0) := (to_unsigned(1, 58)sll 13)+(to_unsigned(1, 58)sll 16)+(to_unsigned(1, 58)sll 17)+(to_unsigned(1, 58)sll 57)+(to_unsigned(1, 58));



  constant LNGT : integer := 2*58;

  signal temp1    : unsigned(LNGT-1 downto 0) := (others => '0');
  signal temp1_r  : unsigned(LNGT-1 downto 0) := (others => '0');
  signal temp1_r1 : unsigned(LNGT-1 downto 0) := (others => '0');
  signal temp1_r2 : unsigned(LNGT-1 downto 0) := (others => '0');


  signal temp2   : unsigned(LNGT-1 downto 0) := (others => '0');
  signal temp2_r : unsigned(LNGT-1 downto 0) := (others => '0');


  signal temp3   : unsigned(LNGT-1 downto 0) := (others => '0');
  signal temp3_r : unsigned(LNGT-1 downto 0) := (others => '0');


  signal temp4   : unsigned(LNGT-1 downto 0) := (others => '0');
  signal temp4_r : unsigned(LNGT-1 downto 0) := (others => '0');

  signal in_reg   : unsigned(LNGT-1 downto 0) := (others => '0');
  signal in_reg_r : unsigned(LNGT-1 downto 0) := (others => '0');


  signal red_reg : unsigned(LNGT/2-1 downto 0) := (others => '0');
  signal red_r   : unsigned(LNGT/2-1 downto 0) := (others => '0');


  constant PRIME_P_WIDTH : integer := 58;


  constant PSI : unsigned(PRIME_P_WIDTH-1 downto 0) := resize((to_unsigned(13, 58)) *((to_unsigned(50131281, 58))*to_unsigned(100000000, 58) +(to_unsigned(84962861, 58))) mod PRIME_P, 58);

  constant OMEGA : unsigned(PRIME_P_WIDTH-1 downto 0) := resize((to_unsigned(2, 58))*(to_unsigned(29, 58))*(to_unsigned(773, 58))*((to_unsigned(15463884, 58)*to_unsigned(10000, 58)+to_unsigned(6647, 58)))mod PRIME_P, 58);

  constant PSI_INVERSE   : unsigned(PRIME_P_WIDTH-1 downto 0) := resize((to_unsigned(2, 58))*(to_unsigned(3, 58))*(to_unsigned(263, 58))*(to_unsigned(2953, 58))*(to_unsigned(833874, 58)*to_unsigned(10000, 58)+to_unsigned(1199, 58))mod PRIME_P, 58);
  constant OMEGA_INVERSE : unsigned(PRIME_P_WIDTH-1 downto 0) := resize(to_unsigned(3**2, 58) * to_unsigned(7, 58)*to_unsigned(17, 58)*to_unsigned(491, 58)* ((to_unsigned(1768298, 58)*to_unsigned(100000, 58)+to_unsigned(76403, 58)))mod PRIME_P, 58);
  constant N_INVERSE     : unsigned(PRIME_P_WIDTH-1 downto 0) := resize(to_unsigned(5, 58)*to_unsigned(4159, 58)*to_unsigned(261061, 58)*to_unsigned(26520671, 58)mod PRIME_P, 58);


  constant psipsi : unsigned(PRIME_P_WIDTH-1 downto 0) := (PSI*unsigned(resize(PSI, 160))) mod PRIME_P;

begin
  process (clk)
  begin
    if rising_edge(clk) then

      in_reg <= val;

      assert (resize(in_reg(115 downto 57), 77)sll 13)+(resize(in_reg(115 downto 57), 77)sll 16)+(resize(in_reg(115 downto 57), 77)sll 17)+(resize(in_reg(115 downto 57), 77)) < (2021440*PRIME_P) report "negative" severity note;

      temp1_r2 <= resize(1048576*PRIME_P - ((resize(in_reg(115 downto 57), 78)sll 13)+(resize(in_reg(115 downto 57), 77)sll 16)+(resize(in_reg(115 downto 57), 78)sll 17)+(resize(in_reg(115 downto 57), 77))) +in_reg(56 downto 0), temp1'length);

      temp1 <= temp1_r2;

      temp2_r <= resize(PRIME_P - ((resize(temp1(78 downto 57), 77)sll 13)+(resize(temp1(78 downto 57), 77)sll 16)+(resize(temp1(78 downto 57), 77)sll 17)+(resize(temp1(78 downto 57), 77))) +temp1(56 downto 0) , temp2_r'length);

      temp4 <= temp2_r;

      assert (temp4 < 3*PRIME_P) report "TOOO BIIIIGG" severity failure;

      if temp4 >= 2*PRIME_P then
        red_reg <= resize(temp4 - 2*PRIME_P, red'length);
      elsif temp4 >= PRIME_P then
        red_reg <= resize(temp4 - PRIME_P, red'length);
      else
        red_reg <= resize(temp4, red'length);
      end if;

      red <= red_reg;
    end if;
  end process;

end Behavioral;

