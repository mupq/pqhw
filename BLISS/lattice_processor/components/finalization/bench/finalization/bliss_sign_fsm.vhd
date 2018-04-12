--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:13:16 02/13/2014 
-- Design Name: 
-- Module Name:    bliss_sign_fsm - Behavioral 
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
use work.lattice_processor.all;
use work.lyu512_pkg.all;



entity bliss_sign_fsm is
  port (
    clk : in std_logic;

    --These signals are used to talk with toplevel
    ready : out std_logic;
    sign  : in  std_logic;

    ready_message    : out std_logic := '0';
    message_finished : in  std_logic := '0';

    reset          : out std_logic := '0';
    rehash_message : out std_logic := '0';

    stop_engine     : in  std_logic := '0';
    engine_stoped   : out std_logic := '0';
    load_public_key : in  std_logic := '0';

    signature_ready   : out std_logic := '0';
    signature_valid   : out std_logic := '0';
    signature_invalid : out std_logic := '0';

    --These signals are used to talk with the subcomponents
    proc_data_avail  : in  std_logic;
    proc_copy_data   : out std_logic                                           := '0';
    proc_data_copied : in  std_logic;
    proc_command     : out std_logic_vector(LYU_ARITH_COMMAND_SIZE-1 downto 0) := LYU_ARITH_SIGN_MODE;
    proc_finished    : in  std_logic;

    fin_ready_message    : in  std_logic := '0';
    --fin_start            : out std_logic := '0';
    --fin_ready            : in  std_logic := '0';
    fin_message_finished : out std_logic := '0';

    reject_finished  : in  std_logic := '0';
    reject_reset     : out std_logic := '0';
    reject_rejection : in  std_logic := '0'

    );

end bliss_sign_fsm;

architecture Behavioral of bliss_sign_fsm is

  type   eg_state is (IDLE, WAIT_MESSAGE, WAIT_SIGN, WAIT_FINISHED, SIGN_MESSAGE);
  signal state_reg : eg_state := IDLE;

  signal count_rejections : integer := 0;
    signal count_acceptance : integer := 0;
begin

  process (clk)
  begin  -- process

    if rising_edge(clk) then            -- rising clock edge
      ready_message        <= '0';
      proc_copy_data       <= '0';
      fin_message_finished <= '0';
      ready                <= '0';
      reset                <= '0';
      rehash_message       <= '0';
      signature_ready      <= '0';
      signature_valid      <= '0';
      reject_reset         <= '0';
signature_invalid <= '0';
      
      case state_reg is
        when IDLE =>
          state_reg <= WAIT_MESSAGE;

          -----------------------------------------------------------------------    
        when WAIT_MESSAGE =>
          if fin_ready_message = '1' then
            ready_message <= '1';
          end if;

          if message_finished = '1' then
            state_reg            <= WAIT_SIGN;
            fin_message_finished <= '1';
          end if;

          -----------------------------------------------------------------------
        when WAIT_SIGN =>
          ready <= '1';

          if sign = '1' then
            state_reg <= SIGN_MESSAGE;
          end if;

          ---------------------------------------------------------------------
        when SIGN_MESSAGE =>
          if proc_data_avail = '1' then
            proc_copy_data <= '1';
            state_reg      <= WAIT_FINISHED;
          end if;

        when WAIT_FINISHED =>
          if reject_finished = '1' then
            if reject_rejection = '1' then
              -- Bad - signature was rejected
              count_rejections <= count_rejections+1;
              rehash_message <= '1';
              reject_reset   <= '1';
              signature_invalid <= '1';
              --Message is beeing rehashed. Input new poly
              state_reg <= SIGN_MESSAGE;
            else
              count_acceptance <= count_acceptance+1;
              state_reg       <= IDLE;
              signature_ready <= '1';
              signature_valid <= '1';
              reset           <= '1';
              reject_reset    <= '1';
            end if;
          end if;
          
          
          
      end case;
    end if;
  end process;



  
end Behavioral;

