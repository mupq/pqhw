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
-- Create Date:    10:05:53 02/11/2014 
-- Design Name: 
-- Module Name:    bliss_keccak_fsm - Behavioral 
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




entity bliss_keccak_fsm is
  port (
    clk : in std_logic;

    --We have to hash again due to rejection
    ext_rehash_message : in std_logic := '0';
    --We want to start a new signing operation
    ext_reset          : in std_logic := '0';
    message_absorbed    : out std_logic := '0';

                  
    ext_ready_message      : out std_logic := '0';
    ext_message_finished   : in  std_logic := '0';
    ext_positions_finished : out std_logic := '0';

    mstore_message_input_finished : out std_logic := '0';
    mstore_absorb_message         : out std_logic := '0';
    mstore_message_absorbed       : in  std_logic := '0';
    mstore_block_absorbed         : in  std_logic := '0';

    storage_start        : out std_logic := '0';
    storage_absorb_ready : in  std_logic := '0';
    storage_absorb_block : out std_logic := '0';

    select_keccak_input : out std_logic := '0';


    keccak_go    : out std_logic := '0';
    keccak_ready : in  std_logic := '0';
    keccak_rst_n : out std_logic := '0';
    keccak_init  : out std_logic := '0';

    pos_start        : out std_logic := '0';
    pos_ready        : in  std_logic := '0'

    );
end bliss_keccak_fsm;

architecture Behavioral of bliss_keccak_fsm is

  type   eg_state is (RESET_KECCAK , INIT_KECCAK , IDLE, WAIT_FOR_MESSAGE, HASH_MESSAGE, WAIT_ABSORBED, WAIT_HASH_FINISHED, HASH_U, WAIT_ABSORB , SQUEEZE , WAIT_SQUEEZE, FINISHED);
  signal state_reg : eg_state := RESET_KECCAK;

  signal absorb_counter_u : integer := 0;

  signal mstore_message_absorbed_internal : std_logic := '0';
  signal pos_started                      : std_logic := '0';
  signal wait_absorb_cycle                : std_logic := '0';
begin



  
  process (clk)
  begin  -- process

    if rising_edge(clk) then            -- rising clock edge
      if mstore_message_absorbed = '1' then
        mstore_message_absorbed_internal <= '1';
      end if;

                    message_absorbed <= '0';
      keccak_init                   <= '0';
      storage_start                 <= '0';
      ext_ready_message             <= '0';
      mstore_message_input_finished <= '0';
      keccak_go                     <= '0';
      storage_absorb_block          <= '0';
      pos_start                     <= '0';

      mstore_absorb_message  <= '0';
      ext_positions_finished <= '0';

      case state_reg is
        when RESET_KECCAK =>
          keccak_rst_n <= '0';
          state_reg    <= INIT_KECCAK;

          when INIT_KECCAK => 
          state_reg    <= IDLE;
          keccak_rst_n <= '1';
          keccak_init <= '1';
          
        when IDLE =>
          keccak_rst_n                     <= '1';
          select_keccak_input              <= '0';
          --keccak_rst_n                     <= '0';
          storage_start                    <= '1';
          state_reg                        <= WAIT_FOR_MESSAGE;
          absorb_counter_u                 <= 0;
          mstore_message_absorbed_internal <= '0';
          
        when WAIT_FOR_MESSAGE =>
          ext_ready_message <= '1';

          if ext_message_finished = '1' then
            mstore_message_input_finished <= '1';
            state_reg                     <= HASH_MESSAGE;
          end if;


        when HASH_MESSAGE =>
          if keccak_ready = '1' then
            mstore_absorb_message <= '1';
            state_reg             <= WAIT_ABSORBED;
          end if;

          
        when WAIT_ABSORBED =>
          if mstore_block_absorbed = '1' then
            keccak_go <= '1';
            state_reg <= WAIT_HASH_FINISHED;
          end if;


        when WAIT_HASH_FINISHED =>
          if keccak_ready = '1' then
            if mstore_message_absorbed_internal = '1' then
              --The message is absorbed. We are finished
              state_reg <= HASH_U;
              message_absorbed <= '1';
            else
              --There is still some message. Hash this part
              state_reg <= HASH_MESSAGE;
            end if;
          end if;

        when HASH_U =>
          if storage_absorb_ready = '1' and keccak_ready = '1' and absorb_counter_u < 3 then
            select_keccak_input  <= '1';
            storage_absorb_block <= '1';
            absorb_counter_u     <= absorb_counter_u+1;
            state_reg            <= WAIT_ABSORB;
            wait_absorb_cycle    <= '1';
          end if;

          if absorb_counter_u = 3 and keccak_ready = '1' then
            state_reg <= SQUEEZE;
          end if;


        when WAIT_ABSORB =>
          wait_absorb_cycle <= '0';
          if storage_absorb_ready = '1' and wait_absorb_cycle = '0' then
            
            keccak_go <= '1';
            state_reg <= HASH_U;
          end if;

          
        when SQUEEZE =>
          if pos_ready = '1' then
            pos_start   <= '1';
            pos_started <= '1';
          end if;
          state_reg <= WAIT_SQUEEZE;

        when WAIT_SQUEEZE =>
          pos_started <= '0';
          if pos_ready = '1' and pos_started = '0' then
            state_reg   <= FINISHED;
            --Just reset Keccak. We do not need it anymore
            keccak_init <= '1';
            --keccak_rst_n                     <= '0';
          end if;


        when FINISHED =>
          ext_positions_finished <= '1';
          --Hash the message again from the message buffer (rejection)
          if ext_rehash_message = '1' then
            state_reg        <= HASH_MESSAGE;
            absorb_counter_u <= 0;
            select_keccak_input              <= '0';
            storage_start    <= '1';
          end if;

          --Hash a new message (new signature)
          if ext_reset = '1' then
            state_reg              <= IDLE;
            ext_positions_finished <= '0';
          end if;
          
      end case;
    end if;
  end process;



end Behavioral;

