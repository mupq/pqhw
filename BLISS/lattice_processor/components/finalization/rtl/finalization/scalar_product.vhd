--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:23:08 02/12/2014 
-- Design Name: 
-- Module Name:    scalar_product - Behavioral 
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




entity scalar_product is
  generic(
    Y_WIDTH      : integer := 14;
    SC_WIDTH     : integer := 14;
    OUTPUT_WIDTH : integer := 33;
        DEPTH         : integer  := 512
    );  
  port(
    clk : in std_logic := '0';


    reset : in std_logic := '0';

    y1_data     : in std_logic_vector(Y_WIDTH-1 downto 0) := (others => '0');

    y2_data     : in std_logic_vector(Y_WIDTH-1 downto 0) := (others => '0');

    coeff_sc1_out   : in  std_logic_vector(SC_WIDTH-1 downto 0)       := (others => '0');
    coeff_sc1_valid : in  std_logic                                   := '0';
    coeff_sc2_out   : in  std_logic_vector(SC_WIDTH-1 downto 0)       := (others => '0');
    coeff_sc2_valid : in  std_logic                                   := '0';

    scalar_prod       : out std_logic_vector(OUTPUT_WIDTH-1 downto 0) := (others => '0');
    scalar_prod_valid : out std_logic                                 := '0'
    );

end scalar_product;

architecture Behavioral of scalar_product is

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

  signal scalar1_ce   : std_logic                     := '0';
  signal scalar1_sclr : std_logic                     := '0';
  signal scalar1_a    : std_logic_vector(15 downto 0) := (others => '0');
  signal scalar1_b    : std_logic_vector(15 downto 0) := (others => '0');
  signal scalar1_res  : std_logic_vector(47 downto 0) := (others => '0');

  signal scalar2_ce   : std_logic                     := '0';
  signal scalar2_sclr : std_logic                     := '0';
  signal scalar2_a    : std_logic_vector(15 downto 0) := (others => '0');
  signal scalar2_b    : std_logic_vector(15 downto 0) := (others => '0');
  signal scalar2_res  : std_logic_vector(47 downto 0) := (others => '0');

  signal counter : integer range 0 to DEPTH := 0;

  
begin

  process (clk)
  begin  -- process
    if rising_edge(clk) then
      scalar1_sclr <= '0';
          scalar2_sclr <= '0';

        scalar_prod_valid <= '0';

      if reset = '1' then
        scalar1_sclr <= '1';
        counter <= 0;
      else
        if counter = DEPTH then
          --if ripple_out_counter < RIPPLE_OUT_CYCLES then
          --  scalar1_ce           <= '1';
          --  scalar2_ce           <= '1';
          --  ripple_out_counter <= ripple_out_counter+1;
          --else
          scalar_prod_valid <= '1';
          scalar_prod       <= std_logic_vector(resize(signed(scalar1_res)+signed(scalar2_res) , scalar_prod'length));
          scalar1_sclr <= '1';
          scalar2_sclr <= '1';
          
          --  ripple_out_counter <= 0;
          --end if;
        end if;

        if coeff_sc1_valid = '1' then
          counter  <= counter+1;
          
        end if;

        if coeff_sc2_valid = '1' then
          
        end if;

        
      end if;
    end if;
  end process;

  scalar1_ce <=coeff_sc1_valid ;

  scalar2_ce <=coeff_sc2_valid;

  scalar1_a <= std_logic_vector(resize(signed(y1_data), scalar1_a'length));
  scalar1_b <= std_logic_vector(resize(signed(coeff_sc1_out), scalar1_b'length));

  mac_core_1 : norm_mac_core
    port map (
      clk  => clk,
      ce   => scalar1_ce,
      sclr => scalar1_sclr,
      a    => scalar1_a,
      b    => scalar1_b,
      s    => scalar1_res
      );

  scalar2_a <= std_logic_vector(resize(signed(y2_data), scalar2_a'length));
  scalar2_b <= std_logic_vector(resize(signed(coeff_sc2_out), scalar2_b'length));

  mac_core_2 : norm_mac_core
    port map (
      clk  => clk,
      ce   => scalar2_ce,
      sclr => scalar2_sclr,
      a    => scalar2_a,
      b    => scalar2_b,
      s    => scalar2_res
      );




end Behavioral;

