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
-- Create Date:    14:05:23 02/03/2012 
-- Design Name: 
-- Module Name:    gen_reducer - Behavioral 
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

entity gen_reducer is
  generic (
    --VAL_WIDTH       : integer;
    --REDUCTION_PRIME : unsigned;
    --USE_GENERIC     : std_logic := '1'

    VAL_WIDTH       : integer := 28;
    REDUCTION_PRIME : unsigned :=to_unsigned(12289,14);
    USE_GENERIC     : std_logic := '0'
    );
  port (
    clk   : in  std_logic;
    val   : in  unsigned(VAL_WIDTH-1 downto 0)              := (others => '0');
    red   : out unsigned(REDUCTION_PRIME'length-1 downto 0) := (others => '0');
    delay : out integer                                     := 10
    );
end gen_reducer;


architecture Behavioral of gen_reducer is
  --Necessary for larger parameter set
  constant prime_144 : unsigned(57 downto 0) := (to_unsigned(1, 58)sll 13)+(to_unsigned(1, 58)sll 16)+(to_unsigned(1, 58)sll 17)+(to_unsigned(1, 58)sll 57)+(to_unsigned(1, 58));
   
begin

  red_1061093377 : if REDUCTION_PRIME = 1061093377 and USE_GENERIC = '0' generate
    red_1061093377_1 : entity work.red_1061093377
      port map (
        clk   => clk,
        val   => val,
        red   => red,
        delay => delay);
  end generate red_1061093377;


  red_1049089 : if REDUCTION_PRIME = 1049089 and USE_GENERIC = '0' generate
    red_1049089_1 : entity work.red_1049089
      port map (
        clk   => clk,
        val   => val,
        red   => red,
        delay => delay
        );
  end generate red_1049089;


  red_65537 : if REDUCTION_PRIME = 65537 and USE_GENERIC = '0' generate
    red_65537_1 : entity work.red_65537
      port map (
        clk   => clk,
        val   => val,
        red   => red,
        delay => delay
        );
  end generate red_65537;


  red_144115188076060673 : if REDUCTION_PRIME = prime_144 and USE_GENERIC = '0' generate
    red_144115188076060673_1 : entity work.red_144115188076060673
      port map (
        clk   => clk,
        val   => val,
        red   => red,
        delay => delay
        );
  end generate red_144115188076060673;

  
  red_8383489_fft_1 : if REDUCTION_PRIME = 8383489 and USE_GENERIC = '0' generate
    red_8383489_1 : entity work.red_8383489_fft
      port map (
        clk   => clk,
        val   => val,
        red   => red,
        delay => delay
        );
  end generate red_8383489_fft_1;

 red_12289_1 : if REDUCTION_PRIME = 12289 and USE_GENERIC = '0' generate
    red_12289_1 : entity work.red_12289
      port map (
        clk   => clk,
        val   => val,
        red   => red,
        delay => delay
        );
  end generate red_12289_1;

  
  NOT_red_1049089 : if (REDUCTION_PRIME /= 1049089 and REDUCTION_PRIME /= 65537 and REDUCTION_PRIME /= 1061093377 and REDUCTION_PRIME /= prime_144 and REDUCTION_PRIME /= 8383489 and REDUCTION_PRIME /= 12289) or USE_GENERIC = '1' generate
    red_subtract_1 : entity work.red_subtract
      generic map (
        PRIME_P_WIDTH => REDUCTION_PRIME'length,
        PRIME_P       => REDUCTION_PRIME,
        VAL_IN_WIDTH  => VAL_WIDTH
        )
      port map (
        clk   => clk,
        val   => val,
        red   => red,
        delay => delay
        );
  end generate NOT_red_1049089;



end Behavioral;

