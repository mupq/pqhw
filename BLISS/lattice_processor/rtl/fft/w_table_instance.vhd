----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:38:35 03/19/2012 
-- Design Name: 
-- Module Name:    w_table_instance - Behavioral 
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


--Just an instantiation for Testing
entity w_table_instance is
  port (
    --ONLY TESTING - DO NOT INSTANTIATE
    clk         : in  std_logic;
    psi_req     : in  std_logic;
    inverse_req : in  std_logic;
    index       : in  unsigned(10 downto 0);
    out_val     : out unsigned(22 downto 0);
    delay       : out integer
    );
end w_table_instance;

architecture Behavioral of w_table_instance is

begin


  w_table_1 : entity work.w_table
    generic map (
      XN            => -1,
      N_ELEMENTS    => 2048,
      PRIME_P_WIDTH => 23,
      PRIME_P       => to_unsigned(17, 23),
      PSI           => to_unsigned(3, 23),
      OMEGA         => to_unsigned(9, 23),
      PSI_INVERSE   => to_unsigned(7, 23),
      OMEGA_INVERSE => to_unsigned(5, 23)
      )
    port map (
      clk         => clk,
      psi_req     => psi_req,
      inverse_req => inverse_req,
      index       => index,
      out_val     => out_val,
      delay       => delay
      );

end Behavioral;

