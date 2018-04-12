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
-- Create Date:    13:27:57 03/15/2012 
-- Design Name: 
-- Module Name:    dyn_shift_reg - Behavioral 
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

entity dyn_shift_reg is
  generic(
    width     : integer := 10;
    max_depth : integer := 63
    );
  port(clk    : in  std_logic;
       depth  : in  integer range 0 to 511             := 1;
       Input  : in  std_logic_vector(width-1 downto 0) := (others => '0');       
       Output : out std_logic_vector(width-1 downto 0) := (others => '0')
       );

end dyn_shift_reg;

architecture Behavioral of dyn_shift_reg is
  
  type   storage_type is array (max_depth downto 0) of std_logic_vector(width-1 downto 0);
  signal storage    : storage_type                       := (others => (others => '0'));
  signal output_sig : std_logic_vector(width-1 downto 0) := (others => '0');
begin

  --Output Signal
  Output <= Input when depth = 0 else storage(depth-1);

  process(clk)
  begin
    if rising_edge(clk) then
      for i in 0 to max_depth-1 loop
        storage(i+1) <= storage(i);
      end loop;
      storage(0) <= input;
    end if;

  end process;

end Behavioral;

