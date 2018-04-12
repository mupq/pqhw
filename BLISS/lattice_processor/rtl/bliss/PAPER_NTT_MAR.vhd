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
-- Create Date:    17:44:41 08/14/2014 
-- Design Name: 
-- Module Name:    PAPER_NTT_MAR - Behavioral 
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
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PAPER_NTT_MAR is
  port (
    ap_clk : IN STD_LOGIC;
    ap_rst : IN STD_LOGIC;
    w_in_V : IN STD_LOGIC_VECTOR (13 downto 0);
    a_in_V : IN STD_LOGIC_VECTOR (13 downto 0);
    b_in_V : IN STD_LOGIC_VECTOR (13 downto 0);
    x_add_out_V : OUT STD_LOGIC_VECTOR (13 downto 0);
    x_sub_out_V : OUT STD_LOGIC_VECTOR (13 downto 0) );
end PAPER_NTT_MAR;

architecture Behavioral of PAPER_NTT_MAR is

begin

  fft_mar_12289_1:entity work.fft_mar_12289
    port map (
      ap_clk      => ap_clk,
      ap_rst      => ap_rst,
      w_in_V      => w_in_V,
      a_in_V      => a_in_V,
      b_in_V      => b_in_V,
      x_add_out_V => x_add_out_V,
      x_sub_out_V => x_sub_out_V);
  


end Behavioral;

