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
-- Create Date:    18:33:43 02/01/2012 
-- Design Name: 
-- Module Name:    gen_mul - Behavioral 
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



entity gen_mul is
  generic (
    VAL1_WIDTH : integer := 48;
    VAL2_WIDTH : integer := 48
    );
  port (
    clk       : in  std_logic;
    v1        : in  unsigned(VAL1_WIDTH-1 downto 0)              := (others => '0');
    v2        : in  unsigned(VAL2_WIDTH-1 downto 0)              := (others => '0');
    res       : out unsigned((VAL1_WIDTH+VAL2_WIDTH)-1 downto 0) := (others => '0');
    mul_delay : out integer                                      := 0
    );
end gen_mul;


architecture Behavioral of gen_mul is
  
  constant test    : integer := 9;
  signal   res_val : std_logic_vector(res'length-1 downto 0);

  signal v1_64     : std_logic_vector(63 downto 0)  := (others => '0');
  signal v2_64     : std_logic_vector(63 downto 0)  := (others => '0');
  signal res_64x64 : std_logic_vector(127 downto 0) := (others => '0');


  signal v1_34     : std_logic_vector(33 downto 0) := (others => '0');
  signal v2_34     : std_logic_vector(33 downto 0) := (others => '0');
  signal res_34x34 : std_logic_vector(67 downto 0) := (others => '0');


  signal v1_17     : std_logic_vector(16 downto 0) := (others => '0');
  signal v2_17     : std_logic_vector(16 downto 0) := (others => '0');
  signal res_17x17 : std_logic_vector(33 downto 0) := (others => '0');
begin
  --delay <= test;  res <= unsigned(res_val);



  mul_core_17x17 : if (VAL1_WIDTH < 18 and VAL2_WIDTH < 18) generate
    v1_17     <= std_logic_vector(resize(unsigned(v1), v1_17'length));
    v2_17     <= std_logic_vector(resize(unsigned(v2), v2_17'length));
    res       <= unsigned(resize(unsigned(res_17x17), res'length));
    mul_delay <= 2;
    mul_17x17_1 : entity work.mul_17x17
      port map (
        clk => clk,
        a   => std_logic_vector(v1_17),
        b   => std_logic_vector(v2_17),
        p   => res_17x17
        );
  end generate mul_core_17x17;


  not_1818 : if not(VAL1_WIDTH < 18 and VAL2_WIDTH < 18) generate

    mul_core_34x34 : if (VAL1_WIDTH < 35 and VAL2_WIDTH < 35) generate

      v1_34     <= std_logic_vector(resize(unsigned(v1), v1_34'length));
      v2_34     <= std_logic_vector(resize(unsigned(v2), v2_34'length));
      res       <= unsigned(resize(unsigned(res_34x34), res'length));
      mul_delay <= 8;
      mul_34x34_1 : entity work.mul_34_34
        port map (
          clk => clk,
          a   => std_logic_vector(v1_34),
          b   => std_logic_vector(v2_34),
          p   => res_34x34
          );
    end generate mul_core_34x34;


    not_1818_34x34 : if not(VAL1_WIDTH < 35 and VAL2_WIDTH < 35) generate
      mul_core_64x64 : if (VAL1_WIDTH < 65 and VAL2_WIDTH < 65) generate
        v1_64     <= std_logic_vector(resize(unsigned(v1), v1_64'length));
        v2_64     <= std_logic_vector(resize(unsigned(v2), v2_64'length));
        res       <= unsigned(resize(unsigned(res_64x64), res'length));
        mul_delay <= 24;
        mul_64x64_1 : entity work.mul_64x64
          port map (
            clk => clk,
            a   => std_logic_vector(v1_64),
            b   => std_logic_vector(v2_64),
            p   => res_64x64
            );
      end generate mul_core_64x64;
    end generate not_1818_34x34;

    
  end generate not_1818;
end Behavioral;

