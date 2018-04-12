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
-- Create Date:    15:03:20 04/17/2012 
-- Design Name: 
-- Module Name:    four_port_Bram - Behavioral 
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



entity four_port_Bram is
  generic (
    SIZE       : integer := 512;
    ADDR_WIDTH : integer := 9;
    COL_WIDTH  : integer := 14;
    add_reg_a  : integer := 0;
    add_reg_b  : integer := 0;
    InitFile   : string  := ""
    );
  port(clk   : in  std_logic;
       --Four Port Block RAM
       --input/output
       addra : in  std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
       wea   : in  std_logic                               := '0';
       dia   : in  std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
       doa   : out std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
       --input/output
       addrb : in  std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
       web   : in  std_logic                               := '0';
       dib   : in  std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
       dob   : out std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');

       --input
       addrc : in std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
       dic   : in std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
       wec   : in std_logic                               := '0';

       --output
       addrd : in  std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
       dod   : out std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0')
       );
end four_port_Bram;

architecture Behavioral of four_port_Bram is

  constant REGISTER_COUNT : integer := 0;

  --Registers
  signal addra_reg : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal wea_reg   : std_logic                               := '0';
  signal dia_reg   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal doa_reg   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');

  signal addrb_reg : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal web_reg   : std_logic                               := '0';
  signal dib_reg   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal dob_reg   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');

  signal addrc_reg : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal dic_reg   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal wec_reg   : std_logic                               := '0';

  signal addrd_reg : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal dod_reg   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');

  --Signals
  signal bram_e_wea   : std_logic                               := '0';
  signal bram_e_web   : std_logic                               := '0';
  signal bram_e_addra : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal bram_e_addrb : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal bram_e_dia   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal bram_e_dib   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal bram_e_doa   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal bram_e_dob   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');

  signal bram_u_wea   : std_logic                               := '0';
  signal bram_u_web   : std_logic                               := '0';
  signal bram_u_addra : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal bram_u_addrb : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal bram_u_dia   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal bram_u_dib   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal bram_u_doa   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal bram_u_dob   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');


  signal trigger : std_logic := '0';

  type   ram_type is array (SIZE-1 downto 0) of std_logic_vector(COL_WIDTH-1 downto 0);
  signal ram_e : ram_type;              --equal parity
  signal ram_u : ram_type;              --unequal parity

  signal parity_a    : std_logic := '0';
  signal parity_b    : std_logic := '0';
  signal parity_a_s1 : std_logic := '0';
  signal parity_a_s2 : std_logic := '0';
  signal parity_a_s3 : std_logic := '0';
  signal parity_a_s4 : std_logic := '0';

  signal parity_b_s1 : std_logic := '0';
  signal parity_b_s2 : std_logic := '0';
  signal parity_b_s3 : std_logic := '0';

begin

  process (addra)
    variable par_a : std_logic;
  begin
    par_a := '0';
    for i in ADDR_WIDTH-1 downto 0 loop
      par_a := par_a xor addra(i);
    end loop;
    parity_a <= par_a;
  end process;

  process (addrb)
    variable par_b : std_logic;
  begin
    par_b := '0';
    for i in ADDR_WIDTH-1 downto 0 loop
      par_b := par_b xor addrb(i);
    end loop;
    parity_b <= par_b;
  end process;




  bram_e : entity work.bram_with_delay
    generic map (
      SIZE       => SIZE/2,
      ADDR_WIDTH => ADDR_WIDTH-1,
      COL_WIDTH  => COL_WIDTH,
      add_reg_a  => 0,
      add_reg_b  => 0,
      InitFile   => ""
      )
    port map (
      clka  => clk,
      clkb  => clk,
      ena   => '1',
      enb   => '1',
      wea   => bram_e_wea,
      web   => bram_e_web,
      addra => bram_e_addra(bram_e_addra'length-2 downto 0),
      addrb => bram_e_addrb(bram_e_addrb'length-2 downto 0),
      dia   => bram_e_dia,
      dib   => bram_e_dib,
      doa   => bram_e_doa,
      dob   => bram_e_dob
      );

  
  bram_u : entity work.bram_with_delay
    generic map (
      SIZE       => SIZE/2,
      ADDR_WIDTH => ADDR_WIDTH-1,
      COL_WIDTH  => COL_WIDTH,
      add_reg_a  => 0,
      add_reg_b  => 0,
      InitFile   => ""
      )
    port map (
      clka  => clk,
      clkb  => clk,
      ena   => '1',
      enb   => '1',
      wea   => bram_u_wea,
      web   => bram_u_web,
      addra => bram_u_addra(bram_u_addra'length-2 downto 0),
      addrb => bram_u_addrb(bram_u_addrb'length-2 downto 0),
      dia   => bram_u_dia,
      dib   => bram_u_dib,
      doa   => bram_u_doa,
      dob   => bram_u_dob
      );




  process (clk)
  begin  -- process
    if rising_edge(clk) then

      parity_a_s1 <= parity_a;
      parity_a_s2 <= parity_a_s1;
      parity_a_s3 <= parity_a_s2;
      parity_a_s4 <= parity_a_s3;

      if parity_a_s3 = '0' then
        doa <= bram_e_doa;
        dod <= bram_u_doa;
      else
        doa <= bram_u_doa;
        dod <= bram_e_doa;

      end if;


      parity_b_s1 <= parity_b;
      parity_b_s2 <= parity_b_s1;
      parity_b_s3 <= parity_b_s2;

      if parity_b_s1 = '0' then
        dob <= bram_e_dob;
      else
        dob <= bram_u_dob;
      end if;


      --port a and d are used in FFT for reading
      if parity_a = '0' then
        bram_e_addra <= addra;
        bram_e_dia   <= dia;
        bram_e_wea   <= wea;

        bram_u_addra <= addrd;
        bram_u_wea   <= '0';
        
      else
        bram_u_addra <= addra;
        bram_u_dia   <= dia;
        bram_u_wea   <= wea;

        bram_e_addra <= addrd;
        bram_e_wea   <= '0';
      end if;


      if parity_b = '0' then
        bram_e_addrb <= addrb;
        bram_e_dib   <= dib;
        bram_e_web   <= web;

        bram_u_addrb <= addrc;
        bram_u_dib   <= dic;
        bram_u_web   <= wec;

      else
        bram_u_addrb <= addrb;
        bram_u_dib   <= dib;
        bram_u_web   <= web;

        bram_e_addrb <= addrc;
        bram_e_dib   <= dic;
        bram_e_web   <= wec;
      end if;

      
    end if;
  end process;

end Behavioral;

