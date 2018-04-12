--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:23:21 02/13/2014 
-- Design Name: 
-- Module Name:    add_sub_sc_y - Behavioral 
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




entity add_sub_sc_y is
  generic (
    N_ELEMENTS             : integer  := 512;
    PRIME_P                : unsigned := to_unsigned(12289, 14);
    MAX_RES_WIDTH_COEFF_SC : integer  := 6

    );
  port (
    clk : in std_logic;

    bit_b       : in std_logic := '0';
    input_valid : in std_logic := '0';

    coeff_sc1 : in std_logic_vector(MAX_RES_WIDTH_COEFF_SC-1 downto 0) := (others => '0');
    coeff_sc2 : in std_logic_vector(MAX_RES_WIDTH_COEFF_SC-1 downto 0) := (others => '0');

    y1_data : in std_logic_vector(PRIME_P'length-1 downto 0) := (others => '0');
    y2_data : in std_logic_vector(PRIME_P'length-1 downto 0) := (others => '0');

    output_valid : out std_logic                                   := '0';
    z1_data      : out std_logic_vector(PRIME_P'length-1 downto 0) := (others => '0');
    z2_data      : out std_logic_vector(PRIME_P'length-1 downto 0) := (others => '0');

    coeff_sc1_out : out std_logic_vector(MAX_RES_WIDTH_COEFF_SC-1 downto 0) := (others => '0');
    coeff_sc2_out : out std_logic_vector(MAX_RES_WIDTH_COEFF_SC-1 downto 0) := (others => '0')

    );
end add_sub_sc_y;

architecture Behavioral of add_sub_sc_y is

  signal y1_data_modp : std_logic_vector(PRIME_P'length-1 downto 0) := (others => '0');
  signal y2_data_modp : std_logic_vector(PRIME_P'length-1 downto 0) := (others => '0');

  signal coeff_sc1_reg : std_logic_vector(coeff_sc1'range) := (others => '0');
  signal coeff_sc2_reg : std_logic_vector(coeff_sc2'range) := (others => '0');

  signal y_modp_valid : std_logic := '0';
begin
  process(clk)
  begin
    if rising_edge(clk) then
      y_modp_valid <= '0';


      --Stage 1
      coeff_sc1_reg <= coeff_sc1;
      coeff_sc2_reg <= coeff_sc2;
      if input_valid = '1' then
        if unsigned(y1_data) > PRIME_P/2 then
          y1_data_modp <= std_logic_vector(resize(signed("0"&y1_data) -signed("0"&PRIME_P), y1_data_modp'length));
        else
          y1_data_modp <= y1_data;
        end if;

        if unsigned(y2_data) > PRIME_P/2 then
          y2_data_modp <= std_logic_vector(resize(signed("0"&y2_data) -signed("0"&PRIME_P), y1_data_modp'length));
          else
            y2_data_modp <= y2_data;
        end if;
        y_modp_valid <= '1';
      end if;

      --Stage 2
      if bit_b = '0' then
        z1_data <= std_logic_vector(resize(signed(y1_data_modp) + signed(coeff_sc1_reg),z1_data'length));
        z2_data <= std_logic_vector(resize(signed(y2_data_modp) + signed(coeff_sc2_reg), z2_data'length));
      else
        z1_data <= std_logic_vector(resize(signed(y1_data_modp) - signed(coeff_sc1_reg), z1_data'length));
        z2_data <= std_logic_vector(resize(signed(y2_data_modp) - signed(coeff_sc2_reg), z2_data'length));
      end if;
      coeff_sc1_out <= coeff_sc1_reg;
      coeff_sc2_out <= coeff_sc2_reg;
      output_valid <= y_modp_valid;



      --y2_data_modp






      --if bit_b = '0' then
      --  z1_data <= signed("0"&y1_data + coeff_sc1;
      --  z2_data <= signed("0"&y2_data + coeff_sc2;
      --else
      --  z1_data <= signed("0"&y1_data - coeff_sc1;
      --  z2_data <= signed("0"&y2_data - coeff_sc2;          
      --end if;
      
      
      
    end if;
  end process;

end Behavioral;

