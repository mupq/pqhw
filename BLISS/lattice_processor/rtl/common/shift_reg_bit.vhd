----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:53:13 07/26/2011 
-- Design Name: 
-- Module Name:    shift_register - Behavioral 
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

entity Shift_reg_bit is
  generic(
    depth : integer:=1
    );
  port(clk     : in  std_logic;
        Output : out std_logic;
        Input  : in  std_logic
       );

end Shift_reg_bit;

architecture Behavioral of Shift_reg_bit is
    type storage_type is array (depth downto 0) of std_logic;
    signal storage : storage_type := (others =>('0'));
begin
  process(clk)
  begin
    if rising_edge(clk) then
      for i in 0 to depth-1 loop
        storage(i) <= storage(i+1);
      end loop;
      
      storage(depth) <= input;
    end if;
  end process;
  Output <= storage(0);
end Behavioral;
