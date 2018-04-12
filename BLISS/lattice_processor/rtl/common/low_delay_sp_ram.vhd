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
-- Create Date:    14:42:25 02/14/2014 
-- Design Name: 
-- Module Name:    low_delay_sp_ram - Behavioral 
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


entity low_delay_sp_bram is
  generic (
    SIZE       : integer := 512;
    ADDR_WIDTH : integer := 9;
    COL_WIDTH  : integer := 23;
    InitFile   : string  := ""

    );
  port(clk  : in  std_logic;
       ena   : in  std_logic                               := '0';
       wea   : in  std_logic                               := '0';
       addra : in  std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
       dia   : in  std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
       doa   : out std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0')
       );
end low_delay_sp_bram;

architecture Behavioral of low_delay_sp_bram is
type ram_type is array (SIZE-1 downto 0) of std_logic_vector(COL_WIDTH-1 downto 0);


  -- Initializes the RAM from a file
  impure function InitRamFromFile (RamFileName : in string) return Ram_Type is
    file RamFile         : text is in RamFileName;
    variable RamFileLine : line;
    variable RAM         : Ram_Type;
  begin
    --Default value 
    for I in Ram_Type'range loop
      readline (RamFile, RamFileLine);
      read (RamFileLine, RAM(I));
    end loop;

    return RAM;
  end function;


  --Wrapper for the RAM initialization. In case of empty string the RAM is
  --initialized with zeros. Necesarry because declaration in function above
  --wants to open a ffile directy (mismatch in behavior modelsim vs xst)
  impure function default_init (RamFileName : in string) return Ram_Type is
    variable RAM      : Ram_Type;
    variable comp_val : string(1 to RamFileName'length);
  begin
    --Default value
    
    if RamFileName = "" then
      --report "Initializing" severity failure;
      
      for I in Ram_Type'range loop
        RAM(I) := (others => '0');
      end loop;
    else
      --Initialize
      RAM := InitRamFromFile(InitFile);
    end if;

    return RAM;
  end function;


  --signal RAM : RamType := InitRamFromFile("rams_20c.data");

  -- shared variable RAM : ram_type := (others => (others => '0'));
  shared variable RAM : ram_type := default_init(InitFile);

 attribute ram_style: string;
attribute ram_style of ram : variable is "distributed";

begin

  process (clk)
  begin
    if rising_edge(clk) then
      if wea = '1' then
        ram(conv_integer(addra)) := dia;
      end if;

      doa <= ram(conv_integer(addra));
      
    end if;
  end process;

 


end Behavioral;


