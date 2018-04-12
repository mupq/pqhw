-- ==============================================================
-- File generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC
-- Version: 2013.4
-- Copyright (C) 2013 Xilinx Inc. All rights reserved.
-- 
-- ==============================================================

library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity huffman_decoder_bit_cnt_table_rom is 
    generic(
             dwidth     : integer := 5; 
             awidth     : integer := 6; 
             mem_size    : integer := 64
    ); 
    port (
          addr0      : in std_logic_vector(awidth-1 downto 0); 
          ce0       : in std_logic; 
          q0         : out std_logic_vector(dwidth-1 downto 0);
          clk       : in std_logic
    ); 
end entity; 


architecture rtl of huffman_decoder_bit_cnt_table_rom is 

signal addr0_tmp : std_logic_vector(awidth-1 downto 0); 
type mem_array is array (0 to mem_size-1) of std_logic_vector (dwidth-1 downto 0); 
signal mem : mem_array := (
    0 => "00011", 1 to 2=> "00101", 3 => "00111", 4 => "00011", 5 to 6=> "00101", 
    7 => "00111", 8 => "00101", 9 to 10=> "00111", 11 to 12=> "01001", 13 => "01011", 
    14 => "01100", 15 => "01110", 16 => "00011", 17 to 18=> "00101", 19 => "00111", 
    20 => "00011", 21 to 22=> "00101", 23 => "00111", 24 => "00101", 25 to 26=> "00111", 
    27 to 28=> "01001", 29 to 30=> "01011", 31 => "01110", 32 => "00101", 33 to 34=> "00111", 
    35 => "01001", 36 => "00101", 37 to 38=> "00111", 39 => "01001", 40 => "00111", 
    41 => "01010", 42 => "01001", 43 to 44=> "01100", 45 to 46=> "01110", 47 => "10001", 
    48 => "01001", 49 to 50=> "01011", 51 => "01110", 52 => "01001", 53 to 54=> "01011", 
    55 => "01110", 56 => "01100", 57 => "01110", 58 => "01111", 59 to 60=> "10001", 
    61 => "10010", 62 to 63=> "10011" );


attribute EQUIVALENT_REGISTER_REMOVAL : string;
begin 


memory_access_guard_0: process (addr0) 
begin
      addr0_tmp <= addr0;
--synthesis translate_off
      if (CONV_INTEGER(addr0) > mem_size-1) then
           addr0_tmp <= (others => '0');
      else 
           addr0_tmp <= addr0;
      end if;
--synthesis translate_on
end process;

p_rom_access: process (clk)  
begin 
    if (clk'event and clk = '1') then
        if (ce0 = '1') then 
            q0 <= mem(CONV_INTEGER(addr0_tmp)); 
        end if;
    end if;
end process;

end rtl;


Library IEEE;
use IEEE.std_logic_1164.all;

entity huffman_decoder_bit_cnt_table is
    generic (
        DataWidth : INTEGER := 5;
        AddressRange : INTEGER := 64;
        AddressWidth : INTEGER := 6);
    port (
        reset : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        address0 : IN STD_LOGIC_VECTOR(AddressWidth - 1 DOWNTO 0);
        ce0 : IN STD_LOGIC;
        q0 : OUT STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0));
end entity;

architecture arch of huffman_decoder_bit_cnt_table is
    component huffman_decoder_bit_cnt_table_rom is
        port (
            clk : IN STD_LOGIC;
            addr0 : IN STD_LOGIC_VECTOR;
            ce0 : IN STD_LOGIC;
            q0 : OUT STD_LOGIC_VECTOR);
    end component;




begin
    huffman_decoder_bit_cnt_table_rom_U :  component huffman_decoder_bit_cnt_table_rom
    port map (
        clk => clk,
        addr0 => address0,
        ce0 => ce0,
        q0 => q0);

end architecture;


