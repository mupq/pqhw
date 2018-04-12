----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:11:56 04/17/2013 
-- Design Name: 
-- Module Name:    large_shift_reg - Behavioral 
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
use ieee.math_real.all;

-- Implements a pipelined large shift register. The input can be shifted by "shift" bits
-- to the right. The output is the lowest bits of the shifted value.

entity large_shift_reg is
  generic (
    IN_WIDTH  : integer := 100;
    OUT_WIDTH : integer := 20
    );
  port (
    clk    : in  std_logic;
    delay  : out integer := 4;
    input  : in  std_logic_vector(IN_WIDTH-1 downto 0);
    output : out std_logic_vector(OUT_WIDTH-1 downto 0);
    shift  : in  unsigned(ceil(log2(real(IN_WIDTH)))-1 downto 0)
    );  
end large_shift_reg;

architecture Behavioral of large_shift_reg is

begin

  

end Behavioral;

