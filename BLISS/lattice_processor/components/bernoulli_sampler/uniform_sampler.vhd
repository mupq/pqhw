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
-- Create Date:    16:57:23 02/03/2014 
-- Design Name: 
-- Module Name:    uniform_sampler - Behavioral 
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



entity uniform_sampler is
  generic (
    MAX_PREC : integer := 79;
    CONST_K  : integer := 253;
    MAX_X    : integer := 10
    );
  port (
    clk : in std_logic;

    --Fifo interface to get randomness
    rand_rd_en : out std_logic;
    rand_din   : in  std_logic;
    rand_empty : in  std_logic;
    rand_valid : in  std_logic;
    --Uniform output
    dout       : out std_logic_vector(integer(ceil(log2(real((CONST_K-1)))))-1 downto 0);
    full       : in  std_logic;
    wr_en      : out std_logic
    );



end uniform_sampler;

architecture Behavioral of uniform_sampler is
  signal value   : unsigned(dout'range) := (others => '0');
  signal counter : integer  range 0 to  value'length            := 0;
begin
  process(clk)
  begin  -- process c
    if rising_edge(clk) then
      rand_rd_en <= '0';
      wr_en      <= '0';


      if counter = value'length then
        --Wait till buffer gets free or reject
        if value < CONST_K and full = '0' then        
          --Wait until the FIFO has free space
          wr_en   <= '1';
          dout    <= std_logic_vector(value);
          counter <= 0;
        elsif value >= CONST_K then
          --Reject
          counter <= 0;
        end if;
      else
        --Continue sampling
        if counter < value'length then
          if rand_empty = '0' then
            rand_rd_en <= '1';
          end if;

          if rand_valid = '1' then
            value(counter) <= rand_din;
            counter        <= counter+1;
          end if;
        end if;
      end if;

      
      
    end if;
  end process;



end Behavioral;

