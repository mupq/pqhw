--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:29:01 02/12/2014 
-- Design Name: 
-- Module Name:    norm - Behavioral 
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


entity norm is
  generic (
    --Samples a uniform value between 0 and Sx_MAX
    NORM2_ACTIVE  : integer  := 1;
    PRIME_P       : unsigned := to_unsigned(12289, 14);
    MAX_RES_WIDTH : integer  := 10;
    OUTPUT_WIDTH  : integer  := 33;
    DEPTH         : integer  := 512
    );
  port(
    clk : in std_logic := '0';

    --Results of the multiplication
    reset : in std_logic := '0';

    coeff_sc1_out   : in std_logic_vector(MAX_RES_WIDTH-1 downto 0) := (others => '0');
    coeff_sc1_valid : in std_logic                                  := '0';

    coeff_sc2_out   : in std_logic_vector(MAX_RES_WIDTH-1 downto 0) := (others => '0');
    coeff_sc2_valid : in std_logic                                  := '0';

    norm       : out std_logic_vector(OUTPUT_WIDTH-1 downto 0) := (others => '0');
    --Valid in the sense of: computation finished
    norm_valid : out std_logic                                 := '0'  
    );

end norm;

architecture Behavioral of norm is

  component norm_mac_core
    port (
      clk  : in  std_logic;
      ce   : in  std_logic;
      sclr : in  std_logic;
      a    : in  std_logic_vector(15 downto 0);
      b    : in  std_logic_vector(15 downto 0);
      s    : out std_logic_vector(47 downto 0)
      );
  end component;

  signal norm1_ce   : std_logic                     := '0';
  signal norm1_sclr : std_logic                     := '0';
  signal norm1_a    : std_logic_vector(15 downto 0) := (others => '0');
  signal norm1_b    : std_logic_vector(15 downto 0) := (others => '0');
  signal norm1_res  : std_logic_vector(47 downto 0) := (others => '0');

  signal norm2_ce   : std_logic                     := '0';
  signal norm2_sclr : std_logic                     := '0';
  signal norm2_a    : std_logic_vector(15 downto 0) := (others => '0');
  signal norm2_b    : std_logic_vector(15 downto 0) := (others => '0');
  signal norm2_res  : std_logic_vector(47 downto 0) := (others => '0');

  signal counter : integer range 0 to DEPTH := 0;


  
begin

  process (clk)
  begin  -- process
    if rising_edge(clk) then
      norm1_sclr <= '0';
      norm2_sclr <= '0';
      norm_valid <= '0';

      if reset = '1' then
        norm1_sclr <= '1';
        counter    <= 0;
      else
        if counter = DEPTH then
          --if ripple_out_counter < RIPPLE_OUT_CYCLES then
          --  norm1_ce           <= '1';
          --  norm2_ce           <= '1';
          --  ripple_out_counter <= ripple_out_counter+1;
          --else
          norm_valid <= '1';
          norm1_sclr <= '1';
          norm2_sclr <= '1';

          norm <= std_logic_vector(resize(signed(norm1_res)+signed(norm2_res) , norm'length));
          --  ripple_out_counter <= 0;
          --end if;
        end if;

        if coeff_sc1_valid = '1' then
          counter <= counter+1;
          
        end if;

        if coeff_sc2_valid = '1' then
          --norm2_ce <= '1';
        end if;

        
      end if;
    end if;
  end process;

  norm1_ce <= coeff_sc1_valid;
  norm2_ce <= coeff_sc2_valid;

  norm1_a <= std_logic_vector(resize(signed(coeff_sc1_out), norm1_a'length));
  norm1_b <= std_logic_vector(resize(signed(coeff_sc1_out), norm1_b'length));

  mac_core_1 : norm_mac_core
    port map (
      clk  => clk,
      ce   => norm1_ce,
      sclr => norm1_sclr,
      a    => norm1_a,
      b    => norm1_b,
      s    => norm1_res
      );


  NORM2_ACTIVE_GEN : if NORM2_ACTIVE = 1 generate
    norm2_a <= std_logic_vector(resize(signed(coeff_sc2_out), norm2_a'length));
    norm2_b <= std_logic_vector(resize(signed(coeff_sc2_out), norm2_b'length));
    mac_core_2 : norm_mac_core
      port map (
        clk  => clk,
        ce   => norm2_ce,
        sclr => norm2_sclr,
        a    => norm2_a,
        b    => norm2_b,
        s    => norm2_res
        );
  end generate NORM2_ACTIVE_GEN;

  
  NORM2_ACTIVE_GEN_NOT: if NORM2_ACTIVE=0 generate
     norm2_res <= (others => '0');     
  end generate NORM2_ACTIVE_GEN_NOT;

  

end Behavioral;

