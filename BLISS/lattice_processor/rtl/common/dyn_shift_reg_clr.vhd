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
-- Create Date:    17:05:31 07/02/2013 
-- Design Name: 
-- Module Name:    dyn_shift_reg_clr - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dyn_shift_reg_clr is
  generic(
    width     : integer := 1;
    max_depth : integer := 128
    );
  port(clk    : in  std_logic;
       reset  : in  std_logic                          := '0';
       depth  : in  integer range 0 to 128             := 1;
       Input  : in  std_logic_vector(width-1 downto 0) := (others => '0');
       Output : out std_logic_vector(width-1 downto 0) := (others => '0')
       );
end dyn_shift_reg_clr;

architecture Behavioral of dyn_shift_reg_clr is
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

    if reset = '1' then
      storage <= (others => (others => '0'));
    end if;
    
  end process;

end Behavioral;

