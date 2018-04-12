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


entity bram_with_delay is
  generic (
    SIZE       : integer := 512;
    ADDR_WIDTH : integer := 9;
    COL_WIDTH  : integer := 23;
    add_reg_a  : integer := 0;
    add_reg_b  : integer := 0;
    InitFile   : string  := ""
    );
  port(clka  : in  std_logic;
       clkb  : in  std_logic;
       ena   : in  std_logic                               := '1';
       enb   : in  std_logic                               := '1';
       wea   : in  std_logic                               := '0';
       web   : in  std_logic                               := '0';
       addra : in  std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
       addrb : in  std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
       dia   : in  std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
       dib   : in  std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
       doa   : out std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
       dob   : out std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0')
       );

end bram_with_delay;

architecture Behavioral of bram_with_delay is
  signal addra_in : std_logic_vector(addra'length-1 downto 0);
  signal addrb_in : std_logic_vector(addrb'length-1 downto 0);
  signal dia_in   : std_logic_vector(dia'length-1 downto 0);
  signal dib_in   : std_logic_vector(dib'length-1 downto 0);
  signal doa_out  : std_logic_vector(doa'length-1 downto 0);
  signal dob_out  : std_logic_vector(dob'length-1 downto 0);
  signal web_in   : std_logic;
  signal wea_in   : std_logic;

  signal wea_delayed : std_logic_vector(0 downto 0);
  signal web_delayed : std_logic_vector(0 downto 0);

  signal wea_grr : std_logic_vector(0 downto 0);
  signal web_grr : std_logic_vector(0 downto 0);
begin

  addra_register : entity work.shift_reg_new
    generic map(
      width => addra'length,
      depth => add_reg_a
      )
    port map(
      input  => addra,
      output => addra_in,
      clk    => clka
      );

  addrb_register : entity work.shift_reg_new
    generic map(
      width => addrb'length,
      depth => add_reg_b
      )
    port map(
      input  => addrb,
      output => addrb_in,
      clk    => clkb
      );

  dia_register : entity work.shift_reg_new
    generic map(
      width => dia'length,
      depth => add_reg_a
      )
    port map(
      input  => dia,
      output => dia_in,
      clk    => clka
      );

  dib_register : entity work.shift_reg_new
    generic map(
      width => dib'length,
      depth => add_reg_b
      )
    port map(
      input  => dib,
      output => dib_in,
      clk    => clkb
      );

  doa_register : entity work.shift_reg_new
    generic map(
      width => doa'length,
      depth => add_reg_a
      )
    port map(
      input  => doa_out,
      output => doa,
      clk    => clka
      );

  dob_register : entity work.shift_reg_new
    generic map(
      width => doa'length,
      depth => add_reg_b
      )
    port map(
      input  => dob_out,
      output => dob,
      clk    => clkb
      );

  
  wea_register : entity work.shift_reg_new
    generic map(
      width => wea_grr'length,
      depth => add_reg_a

      )
    port map(
      Input  => wea_grr,
      output => wea_delayed,
      clk    => clka
      );
  wea_grr(0) <= wea;
  wea_in     <= wea_delayed(0);

  web_register : entity work.shift_reg_new
    generic map(
      width => web_grr'length,
      depth => add_reg_b
      )
    port map(
      Input  => web_grr,
      output => web_delayed,
      clk    => clkb
      );
  web_grr(0) <= web;
  web_in     <= web_delayed(0);


  bram_in_delay : entity work.dp_bram
    generic map (
      SIZE       => SIZE,
      ADDR_WIDTH => ADDR_WIDTH,
      COL_WIDTH  => COL_WIDTH,
      InitFile   => InitFile
      )

    port map (
      clka  => clka,                    --XXX
      clkb  => clkb,
      ena   => ena,
      enb   => enb,
      wea   => wea_in,
      web   => web_in,
      addra => addra_in,
      addrb => addrb_in,
      dia   => dia_in,
      dib   => dib_in,
      doa   => doa_out,
      dob   => dob_out
      );


end Behavioral;

