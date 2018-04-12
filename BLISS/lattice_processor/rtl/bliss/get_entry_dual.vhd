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
-- Create Date:    18:51:38 02/23/2014 
-- Design Name: 
-- Module Name:    get_entry_dual - Behavioral 
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
use work.cdt_sampler_pkg.all;



entity get_entry_dual is
  generic (
    PARAM_SET : integer := 1
    );
  port (
    clk        : in  std_logic;
    --select byte
    byte_sel1  : in  std_logic_vector(integer(ceil(log2(real(get_cdt_max_byte(PARAM_SET)))))-1 downto 0)  := (others => '0');
    index_sel1 : in  std_logic_vector(integer(ceil(log2(real(get_cdt_max_index(PARAM_SET)))))-1 downto 0) := (others => '0');
    value_out1 : out std_logic_vector(7 downto 0)
    );
end get_entry_dual;

architecture Behavioral of get_entry_dual is
  constant MAX_INDEX      : integer := get_cdt_max_index(PARAM_SET);
  constant MAX_BYTE_TABLE : integer := get_cdt_max_byte_table(PARAM_SET);
  constant MAX_BYTE       : integer := get_cdt_max_byte(PARAM_SET);

  constant MAX_EXPONENT : integer := get_max_exponent(PARAM_SET);

  signal read_ram      : std_logic                                                         := '0';
  signal byte_1        : std_logic_vector(integer(ceil(log2(real(MAX_BYTE))))-1 downto 0)  := (others => '0');
  signal index_1       : std_logic_vector(integer(ceil(log2(real(MAX_INDEX))))-1 downto 0) := (others => '0');
  signal value_1       : std_logic_vector(7 downto 0);
  signal valid         : std_logic                                                         := '0';

  signal begin_1       : integer range -MAX_EXPONENT to MAX_BYTE                                    := 0;

  


  signal zero1 : std_logic := '0';

  signal value_1_zero : std_logic := '0';


  -- Exponent Table, length :262
 -- type exp_array_type is array (0 to  get_cdt_max_index(PARAM_SET)) of integer range 0 to 16;

  signal exponent1 : integer range 0 to MAX_EXPONENT := 0;
  constant exp_array : exp_array_type :=  get_exponent_table(PARAM_SET);
  attribute RAM_STYLE : string;
  attribute RAM_STYLE of exp_array: constant is "DISTRIBUTED";
  attribute RAM_STYLE of exponent1: signal is "DISTRIBUTED";

  
begin

  
  index_1 <= index_sel1;
  exponent1 <= exp_array(to_integer(unsigned(index_sel1)));
  begin_1 <= to_integer(signed("0"&byte_sel1)) - exponent1;

  byte_1 <= std_logic_vector(resize(unsigned(to_signed(begin_1, byte_1'length+1)), byte_1'length));
  value_out1 <= value_1 when (zero1 = '0') and (value_1_zero = '0') else (others => '0');

  process(clk)
  begin
    if rising_edge(clk) then      
      if (begin_1 < 0) or (begin_1 > MAX_BYTE_TABLE) then
        zero1 <= '1';
      else
        zero1 <= '0';
      end if;
    end if;
  end process;


  --value_out1 <= value_1 when (zero1 = '0' and zero2 = '0') or (zero1 = '0' and zero2 = '1') else (others => '0');

 
  read_table_dual_1 : entity work.read_table_dual
    generic map (
      PARAM_SET => PARAM_SET
      )
    port map (
      clk          => clk,
      read_ram     => read_ram,
      byte_1       => byte_1,
      index_1      => index_1,
      value_1      => value_1,
      value_1_zero => value_1_zero,
      valid        => valid
      );
end Behavioral;

