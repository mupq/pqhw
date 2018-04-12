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
-- Create Date:    09:28:31 02/13/2014 
-- Design Name: 
-- Module Name:    drop_bits - Behavioral 
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
use ieee.math_real.all;




entity drop_bits is
  generic (
    N_ELEMENTS      : integer  := 512;
    PRIME_P         : unsigned := to_unsigned(12289, 14);
    MODULUS_P_BLISS : unsigned := to_unsigned(24, 5);
    D_BLISS         : integer  := 10
    );
  port (
    clk : in std_logic;

    delay    : out integer range 0 to 7                          := 3;
    --Input to the pipeline
    valid_in : in  std_logic;
    data_in  : in  std_logic_vector(PRIME_P'length+1-1 downto 0) := (others => '0');

    --Output of the pipeline
    valid_out : out std_logic;
    data_out  : out std_logic_vector(PRIME_P'length+1-1-D_BLISS downto 0) := (others => '0')
    );
end drop_bits;

architecture Behavioral of drop_bits is

     signal data_in_reg : unsigned(data_in'range):= (others => '0');

  signal dropped_result : unsigned(data_out'range):= (others => '0');

  signal valid_in_reg   : std_logic := '0';
  signal valid_in_reg1  : std_logic := '0';
  
begin

  process(clk)
  begin
    if rising_edge(clk) then


      valid_in_reg <= valid_in;
      data_in_reg  <= unsigned(data_in);

      --Stage 2
      valid_in_reg1  <= valid_in_reg;
      dropped_result <= resize(((to_unsigned(2, PRIME_P'length+2)*resize(data_in_reg, PRIME_P'length+2)+((to_unsigned(1, 2*(PRIME_P'length)) sll D_BLISS))) srl (D_BLISS+1)), dropped_result'length);

      data_out  <= std_logic_vector(dropped_result);
      valid_out <= valid_in_reg1;
      
    end if;
  end process;

end Behavioral;

