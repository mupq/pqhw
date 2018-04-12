----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:12:29 11/16/2012 
-- Design Name: 
-- Module Name:    low_delay_dp_bram - Behavioral 
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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity low_delay_dp_bram is
   generic (
    SIZE       : integer              := 512;
    ADDR_WIDTH : integer              := 9;
    COL_WIDTH  : integer              := 23;
    InitFile   : string               := ""

    );
  port(clka  : in  std_logic;
       clkb  : in  std_logic;
       ena   : in  std_logic;
       enb   : in  std_logic;
       wea   : in  std_logic;
       web   : in  std_logic;
       addra : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
       addrb : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
       dia   : in  std_logic_vector(COL_WIDTH-1 downto 0);
       dib   : in  std_logic_vector(COL_WIDTH-1 downto 0);
       doa   : out std_logic_vector(COL_WIDTH-1 downto 0) := (others => '0');
       dob   : out std_logic_vector(COL_WIDTH-1 downto 0) := (others => '0')
       );
end low_delay_dp_bram;

architecture low_dual_port_bram of low_delay_dp_bram is
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
    
    if RamFileName = comp_val then
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

  -- output registers
  signal s_a : std_logic_vector(COL_WIDTH-1 downto 0) := (others => '0');
  signal s_b : std_logic_vector(COL_WIDTH-1 downto 0) := (others => '0');
  
begin

  process (clka)
  begin
    if rising_edge(clka) then
      if wea = '1' then
        ram(conv_integer(addra)) := dia;
      end if;

      doa <= ram(conv_integer(addra));
      
    end if;
  end process;

  process (clkb)
  begin
    if rising_edge(clkb) then
      if web = '1' then
        ram(conv_integer(addrb)) := dib;
      end if;

      dob <= ram(conv_integer(addrb));
      
    end if;
  end process;



end   low_dual_port_bram ;


