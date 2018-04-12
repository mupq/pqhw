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
-- Create Date:    15:25:21 09/29/2011 
-- Design Name: 
-- Module Name:    bram_with_delay - Behavioral 
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


entity delay_rom is
  generic (
    SIZE       : integer  := 512;
    ADDR_WIDTH : integer  := 9;
    COL_WIDTH  : integer  := 23;
    add_reg_a  : integer  := 0;
    add_reg_b  : integer  := 0;
    PRIME_P    : unsigned := to_unsigned(12289, 14);
    N_ELEMENTS : integer  := 512;
    init_vector : std_logic_vector      --(natural range <>)
    );
  port(clk   : in  std_logic;
       ena   : in  std_logic                               := '1';
       enb   : in  std_logic                               := '1';
       addra : in  std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
       addrb : in  std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
       doa   : out std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
       dob   : out std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0')
       );

end delay_rom;

architecture Behavioral of delay_rom is
  signal addra_in : std_logic_vector(addra'length-1 downto 0);
  signal addrb_in : std_logic_vector(addrb'length-1 downto 0);
  signal doa_out  : std_logic_vector(doa'length-1 downto 0);
  signal dob_out  : std_logic_vector(dob'length-1 downto 0);
  signal web_in   : std_logic;
  signal wea_in   : std_logic;

  signal wea_delayed : std_logic_vector(0 downto 0);
  signal web_delayed : std_logic_vector(0 downto 0);

  signal wea_grr : std_logic_vector(0 downto 0);
  signal web_grr : std_logic_vector(0 downto 0);

  component rom_w_table_12289
    port (
      clka  : in  std_logic;
      addra : in  std_logic_vector(10 downto 0);
      douta : out std_logic_vector(13 downto 0)
      );
  end component;

begin

  addra_register : entity work.shift_reg_new
    generic map(
      width => addra'length,
      depth => add_reg_a
      )
    port map(
      input  => addra,
      output => addra_in,
      clk    => clk
      );

  addrb_register : entity work.shift_reg_new
    generic map(
      width => addrb'length,
      depth => add_reg_b
      )
    port map(
      input  => addrb,
      output => addrb_in,
      clk    => clk
      );

  doa_register : entity work.shift_reg_new
    generic map(
      width => doa'length,
      depth => add_reg_a
      )
    port map(
      input  => doa_out,
      output => doa,
      clk    => clk
      );

  dob_register : entity work.shift_reg_new
    generic map(
      width => doa'length,
      depth => add_reg_b
      )
    port map(
      input  => dob_out,
      output => dob,
      clk    => clk
      );

  w_table_12289 : if PRIME_P = to_unsigned(12289, PRIME_P'length) and N_ELEMENTS = 512 generate
    your_instance_name : rom_w_table_12289
      port map (
        clka  => clk,
        addra =>  addra_in,
        douta =>doa_out
        );
  end generate w_table_12289;


  w_table_generic : if PRIME_P /= to_unsigned(12289, PRIME_P'length) or N_ELEMENTS /= 512 generate
    rom_1 : entity work.rom
      generic map (
        SIZE        => SIZE,
        ADDR_WIDTH  => ADDR_WIDTH,
        COL_WIDTH   => COL_WIDTH,
        init_vector => init_vector
        )
      port map (
        clk   => clk,
        ena   => ena,
        enb   => enb,
        addra => addra_in,
        addrb => addrb_in,
        doa   => doa_out,
        dob   => dob_out
        );
  end generate w_table_generic;

  
  


end Behavioral;

