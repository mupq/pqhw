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
-- Create Date:    12:12:57 03/19/2012 
-- Design Name: 
-- Module Name:    rom - Behavioral 
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
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use std.textio.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_textio.all;




entity rom is
  generic (
    SIZE        : integer := 512;
    ADDR_WIDTH  : integer := 9;
    COL_WIDTH   : integer := 23;
    init_vector : std_logic_vector

    );
  port(clk   : in  std_logic;
       ena   : in  std_logic;
       enb   : in  std_logic;
       addra : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
       addrb : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
       doa   : out std_logic_vector(COL_WIDTH-1 downto 0) := (others => '0');
       dob   : out std_logic_vector(COL_WIDTH-1 downto 0) := (others => '0')
       );
end rom;

architecture Behavioral of rom is
  -- Initializes the RAM from a file
  type ram_type is array (SIZE-1 downto 0) of std_logic_vector(COL_WIDTH-1 downto 0);
  impure function InitRamFromFile (init_vector : std_logic_vector(SIZE*COL_WIDTH-1 downto 0)) return Ram_Type is

    variable RAM         : Ram_Type;
  begin
    
    --Default value 
    for I in Ram_Type'range loop
      RAM(I):=init_vector(I*RAM(0)'length+RAM(0)'length-1 downto I*RAM(0)'length);
    end loop;

    return RAM;
  end function;



  shared variable RAM : ram_type :=InitRamFromFile(init_vector);


  -- output registers
  signal s_a : std_logic_vector(COL_WIDTH-1 downto 0) := (others => '0');
  signal s_b : std_logic_vector(COL_WIDTH-1 downto 0) := (others => '0');
  
begin

  process (clk)
  begin
    if rising_edge(clk) then
      s_a <= ram(conv_integer(addra));
      s_b <= ram(conv_integer(addrb));
    end if;
  end process;


  process (clk)
  begin
    if rising_edge(clk) then
      if ena = '1' then
        doa <= s_a;
      end if;
      if enb = '1' then
        dob <= s_b;
      end if;
    end if;
  end process;


end Behavioral;

