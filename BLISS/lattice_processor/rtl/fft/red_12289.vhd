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
-- Create Date:    20:02:14 07/22/2014 
-- Design Name: 
-- Module Name:    red_12289 - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity red_12289 is
    port (
    clk   : in  std_logic;
    val   : in  unsigned(2*14-1 downto 0) := (others => '0');
    red   : out unsigned(14-1 downto 0)   := (others => '0');
    delay : out integer                   := 3
    );
end red_12289;

architecture Behavioral of red_12289 is
signal val_V : STD_LOGIC_VECTOR (27 downto 0);
signal    red_V   :  STD_LOGIC_VECTOR(14-1 downto 0)   := (others => '0');

begin

  val_V <= STD_LOGIC_VECTOR(val);
  red <= unsigned(red_V);
  vivado_hls_mod_12289_1:entity work.vivado_hls_mod_12289
    port map (
      ap_clk    => clk,
      ap_rst    => '0',
      val_V     => val_V,
      ap_return => red_V
      );


end Behavioral;

