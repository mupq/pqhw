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
-- Create Date:    13:43:36 02/04/2014 
-- Design Name: 
-- Module Name:    z_sampler - Behavioral 
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



entity z_sampler is
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

    fifo_z_empty : in  std_logic;
    fifo_z_rd_en : out std_logic;
    fifo_z_valid : in  std_logic;
    fifo_z_in    : in  std_logic_vector(integer(ceil(log2(real((CONST_K)*(MAX_X)+CONST_K-1))))-1 downto 0);

    gauss_dout  : out std_logic_vector(integer(ceil(log2(real((CONST_K)*(MAX_X)+CONST_K-1))))-1+1 downto 0) := (others => '0');
    gauss_full  : in  std_logic;
    gauss_wr_en : out std_logic
    );
end z_sampler;

architecture Behavioral of z_sampler is

  type   eg_state is (IDLE, WAIT_CYCLE, STORE, CHECK, WAIT_CYCLE2, CHECK_REJECT, OUTPUT);
  signal state_reg : eg_state := IDLE;

  signal z_val    : std_logic_vector(fifo_z_in'range);
  signal neg_flag : std_logic := '0';

  signal throw_away_counter : integer  range 0 to 4096 :=0;
begin


  process(clk)
  begin  -- process c
    if rising_edge(clk) then
      gauss_wr_en  <= '0';
      rand_rd_en   <= '0';
      fifo_z_rd_en <= '0';

      case state_reg is
        when IDLE =>
          neg_flag <= '0';

          if fifo_z_empty = '0' and rand_empty = '0' then
            state_reg    <= WAIT_CYCLE;
            fifo_z_rd_en <= '1';
            rand_rd_en   <= '1';
          end if;

        when WAIT_CYCLE =>
          state_reg <= STORE;

          
        when STORE =>
          if fifo_z_valid = '1' and rand_valid = '1' then
            neg_flag  <= rand_din;
            z_val     <= fifo_z_in;
            state_reg <= CHECK;
          end if;

        when CHECK =>
          if unsigned(z_val) /= 0 then
            state_reg <= OUTPUT;
          elsif rand_empty = '0' then
            state_reg  <= WAIT_CYCLE2;
            rand_rd_en <= '1';
          end if;

        when WAIT_CYCLE2 =>
          state_reg <= CHECK_REJECT;

        when CHECK_REJECT =>
          if rand_valid = '1' then
            if rand_din = '1' then
              --Reject the zero value
              state_reg <= IDLE;
            else
              state_reg <= OUTPUT;
            end if;
          end if;

        when OUTPUT =>
          if throw_away_counter < 1024 then
            state_reg <= IDLE;
            --Do notihing
            throw_away_counter <= throw_away_counter+1;
            else
            if gauss_full = '0' then
              gauss_wr_en <= '1';
              if neg_flag = '0' then
                gauss_dout <= std_logic_vector(-signed("0"&z_val));
              else
                gauss_dout <= std_logic_vector(unsigned("0"&z_val));
              end if;
              state_reg <= IDLE;
            end if;
          end if;
      end case;
    end if;
  end process;

  
end Behavioral;

