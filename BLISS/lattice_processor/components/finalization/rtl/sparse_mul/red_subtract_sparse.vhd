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
-- Create Date:    18:09:22 02/06/2014 
-- Design Name: 
-- Module Name:    red_subtract_sparse - Behavioral 
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


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

--Generic modular and pipelined reduction circuit
entity red_subtract_sparse is
  generic (
    PRIME_P_WIDTH : integer;
    PRIME_P       : unsigned;
    VAL_IN_WIDTH  : integer
    );
  port (
    clk   : in  std_logic;
    val   : in  unsigned(VAL_IN_WIDTH-1 downto 0)  := (others => '0');
    red   : out unsigned(PRIME_P_WIDTH-1 downto 0) := (others => '0');
    delay : out integer                            := VAL_IN_WIDTH-PRIME_P_WIDTH+1
    );
end red_subtract_sparse;

architecture Behavioral of red_subtract_sparse is
  --calculate the number of steps necessary
  constant MAX_IN_VAL : unsigned(VAL_IN_WIDTH-1 downto 0) := (others => '1');
  constant STEPS      : integer                           := VAL_IN_WIDTH-PRIME_P_WIDTH;
  type   register_type is array (STEPS-1 downto 0) of unsigned(VAL_IN_WIDTH-1 downto 0);
  signal pipeline_reg : register_type := (others => (others => '0'));
begin

  process (clk)
  begin
    if rising_edge(clk) then
      pipeline_reg(STEPS-1) <= val;

      for i in STEPS-1 downto 1 loop    --!: -2
        if pipeline_reg(i) >= (resize(PRIME_P, VAL_IN_WIDTH) sll i) then
          pipeline_reg(i-1) <= pipeline_reg(i)-(resize(PRIME_P, VAL_IN_WIDTH) sll i);
        else
          pipeline_reg(i-1) <= pipeline_reg(i);
        end if;
      end loop;  -- i

      if pipeline_reg(0) >= PRIME_P then
        red <= resize(pipeline_reg(0)-PRIME_P, red'length);
      else
        red <= resize(pipeline_reg(0), red'length);
      end if;

    end if;
  end process;

end Behavioral;
