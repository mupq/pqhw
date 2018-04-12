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
-- Create Date:    17:42:56 08/13/2014 
-- Design Name: 
-- Module Name:    trivium - Behavioral 
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
use IEEE.std_logic_1164.all;
use IEEE.std_logic_ARITH.all;
use IEEE.std_logic_UNSIGNED.all;


entity trivium_rub is
  port (clk          : in  std_logic;
        reset        : in  std_logic;
        clk_en       : in  std_logic;   --will cause pause when '0'     
        KEY          : in  std_logic_vector(79 downto 0);  --key meant as LE input 
        IV           : in  std_logic_vector(79 downto 0);  --IV meant as LE input 
        stream_ready : out std_logic := '0';  --when '0' stream should be ignored
        stream       : out std_logic);              
end trivium_rub;

architecture Behavioral of trivium_rub is

  function bit_flip (b : std_logic_vector) return std_logic_vector is  --for easy implementation of the state calculations
    variable result : std_logic_vector(79 downto 0);
    
  begin
    for i in 0 to 79 loop
      result(i) := b(79-i);
    end loop;
    return result;
  end;



  signal a_reg      : std_logic_vector(92 downto 0)  := "0000000000000" & bit_flip(KEY);  --no reset necessary, user may start with setting clk_en high
  signal b_reg      : std_logic_vector(83 downto 0)  := X"0" & bit_flip(IV);
  signal c_reg      : std_logic_vector(110 downto 0) := "111" & X"000000000000000000000000000";
  signal clock_cntr : std_logic_vector(16 downto 0)  := (others => '0');

  signal r1, r2, r3 : std_logic := '0';



begin

  calc_stream : process (clk, reset)  --state calculations according to the specs
  begin
    if(clk'event and clk = '1') then
      if (reset = '1') then
        a_reg        <= "0000000000000" & bit_flip(KEY);
        b_reg        <= X"0" & bit_flip(IV);
        c_reg        <= "111" & X"000000000000000000000000000";
        clock_cntr   <= (others => '0');
        stream_ready <= '0';
      elsif (clk_en = '1') then
        
        
        
        a_reg      <= a_reg(91 downto 0) & (r3 xor ((c_reg(108) and c_reg(109)) xor a_reg(68)));
        b_reg      <= b_reg(82 downto 0) & (r1 xor ((a_reg(90) and a_reg(91)) xor b_reg(77)));
        c_reg      <= c_reg(109 downto 0) & (r2 xor ((b_reg(81) and b_reg(82)) xor c_reg(86)));
        clock_cntr <= clock_cntr + 1;



        if (unsigned(clock_cntr) = 1151) then
          stream_ready <= '1';
        end if;
      else
        null;
      end if;
    end if;
  end process;


  r1 <= a_reg(65) xor a_reg(92);
  r2 <= b_reg(68) xor b_reg(83);
  r3 <= c_reg(65) xor c_reg(110);

  stream <= r1 xor r2 xor r3;

end Behavioral;
