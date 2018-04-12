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
-- Create Date:    18:40:05 02/23/2014 
-- Design Name: 
-- Module Name:    read_table_dual - Behavioral 
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


entity read_table_dual is
  generic (
    PARAM_SET : integer := 1
    );
  port (
    clk          : in  std_logic;
    --select byte
    read_ram     : in  std_logic                                                                            := '0';
    byte_1       : in  std_logic_vector(integer(ceil(log2(real(get_cdt_max_byte(PARAM_SET)))))-1 downto 0)  := (others => '0');
    index_1      : in  std_logic_vector(integer(ceil(log2(real(get_cdt_max_index(PARAM_SET)))))-1 downto 0) := (others => '0');
    value_1      : out std_logic_vector(7 downto 0);
    value_1_zero : out std_logic                                                                            := '0';
    valid        : out std_logic                                                                            := '0'
    );
end read_table_dual;

architecture Behavioral of read_table_dual is
  constant MAX_INDEX      : integer := get_cdt_max_index(PARAM_SET);
  constant MAX_BYTE_TABLE : integer := get_cdt_max_byte_table(PARAM_SET);

  component bliss_1_cdt_dual_and_exp_ram_1
    port (
      clka  : in  std_logic;
      addra : in  std_logic_vector(10 downto 0);
      douta : out std_logic_vector(7 downto 0)
      );
  end component;

  COMPONENT bliss_3_cdt_dual_rom
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
  
END COMPONENT;

COMPONENT bliss_4_cdt_dual_exp_ram
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;


  constant intervals     : intervals_type                  := get_intervals_table(PARAM_SET);
  constant max_tables    : intervals_type                  := get_intervals_table_max(PARAM_SET);
  signal   start_table_1 : integer range 0 to MAX_INTERVAL := 0;

  signal addra    : std_logic_vector(integer(ceil(log2(real(get_max_ram(PARAM_SET)))))-1 downto 0);
  signal douta    : std_logic_vector(7 downto 0);
  signal addra_in : std_logic_vector(addra'range);
  
begin

  param_sel_gen : if PARAM_SET = 1 generate
    bliss_1_cdt_dual_and_exp_ram : bliss_1_cdt_dual_and_exp_ram_1
      port map (
        clka  => clk,
        addra => addra,
        douta => douta
        );    
  end generate param_sel_gen;


   param_sel_gen_p3 : if PARAM_SET = 3 generate
    bliss_3_cdt_dual_and_exp_ram : bliss_3_cdt_dual_rom
      port map (
        clka  => clk,
        addra => addra,
        douta => douta
        );    
  end generate param_sel_gen_p3;

   param_sel_gen_p4 : if PARAM_SET = 4 generate
    bliss_4_cdt_dual_and_exp_ram : bliss_4_cdt_dual_exp_ram
      port map (
        clka  => clk,
        addra => addra,
        douta => douta
        );    
  end generate param_sel_gen_p4;
  


  start_table_1 <= intervals(to_integer(unsigned(byte_1(3 downto 0))));
  addra         <= std_logic_vector(to_unsigned(start_table_1 + to_integer(unsigned(index_1)), addra'length));
  value_1       <= douta;

  process(clk)
  begin  -- process
    if rising_edge(clk) then
      valid        <= read_ram;
      value_1_zero <= '1';

      if to_integer(unsigned(index_1)) < max_tables(to_integer(unsigned(byte_1(3 downto 0)))) then
        value_1_zero <= '0';
      end if;

    end if;
  end process;

  
end Behavioral;

