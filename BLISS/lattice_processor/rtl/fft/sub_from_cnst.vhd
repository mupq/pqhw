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
-- Create Date:    18:11:57 02/02/2012 
-- Design Name: 
-- Module Name:    sub_from_cnst - Behavioral 
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
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.math_REAL.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


-------------------------------------------------------------------------------
-- Substracts input val from the squared constant. Assure that the input is
-- never greater that the squared constant
-------------------------------------------------------------------------------
entity sub_from_cnst is
    generic (
    VAL_IN_WIDTH : integer := 23;
    VAL_OUT_WIDTH :integer:=23;
    CONST_VAL : Unsigned 
    );
  port (
    clk      : in  std_logic;
    val      : in  unsigned(VAL_IN_WIDTH-1 downto 0);
    res      :  out unsigned(VAL_OUT_WIDTH-1 downto 0)
    );

end sub_from_cnst;

architecture Behavioral of sub_from_cnst is
  
  signal in_reg : unsigned(val'length-1 downto 0);
  signal out_reg : unsigned(res'length-1 downto 0);
   
begin
    process(clk)
  begin  -- process c
    if rising_edge(clk) then
      in_reg <= val;

      out_reg <= resize(unsigned(CONST_VAL) - unsigned(in_reg),out_reg'length);

      res <= out_reg;
    end if;
  end process;

end Behavioral;

