--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:37:08 03/01/2014 
-- Design Name: 
-- Module Name:    bliss_verify_fsm - Behavioral 
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


entity bliss_verify_fsm is
  port (
    clk : in std_logic;

    -- Control bits/signals
    ready           : out std_logic;
    verify          : in  std_logic;
    load_public_key : in  std_logic;

    signature_verified : out std_logic                                           := '0';
    signature_valid    : out std_logic                                           := '0';
    signature_invalid  : out std_logic                                           := '0';
    proc_command       : out std_logic_vector(LYU_ARITH_COMMAND_SIZE-1 downto 0) := (others => '0');


    norm_invalid : in  std_logic := '0';
    reset_norm   : out std_logic := '0';

    hash_ext_reset : out std_logic := '0';
 reset_c_ram_module : out std_logic := '0';

 
    --See that message is hashed
    message_absorbed : in std_logic := '0';

    az1_ready               : in std_logic := '0';
    hash_positions_finished : in std_logic := '0';

    output_az1 : out std_logic := '0';

    --The has is ready
    hash_equal    : in std_logic := '0';
    hash_no_equal : in std_logic := '0';

    start_c_module  : out std_logic := '0';
    start_processor : out std_logic := '0'
    );

end bliss_verify_fsm;

architecture Behavioral of bliss_verify_fsm is

  type   eg_state is (STOP_SIGN, IDLE, WAIT_MUL_FIN, WAIT_HASH_READY, RESET_HASH);
  signal state_reg : eg_state := STOP_SIGN;

  signal az1_ready_triggered        : std_logic := '0';
  signal message_absorbed_triggered : std_logic := '0';

  
begin

  process (clk)
  begin  -- process
    if rising_edge(clk) then            -- rising clock edge
      ready          <= '0';
      start_c_module <= '0';
      output_az1     <= '0';
      reset_norm     <= '0';
      hash_ext_reset <= '0';
          reset_c_ram_module <= '0';
      
      signature_verified <= '0';
      signature_valid    <= '0';
      signature_invalid  <= '0';
      proc_command       <= (others => '0');

      if az1_ready = '1' then
        az1_ready_triggered <= '1';
      end if;

      if message_absorbed = '1' then
        message_absorbed_triggered <= '1';
      end if;


      case state_reg is

        when STOP_SIGN =>
          proc_command <= LYU_ARITH_STOP_SIGN;
          state_reg    <= IDLE;
          
        when IDLE =>
          ready <= '1';

          if verify = '1' then
            ready          <= '0';
            start_c_module <= '1';
            proc_command   <= LYU_ARITH_COMP_AZ1;
            state_reg      <= WAIT_MUL_FIN;
          end if;

        when WAIT_MUL_FIN =>
          if message_absorbed_triggered = '1' then  --= '1' and az1_ready_triggered = '1' then
            --   output_az1 <= '1';
            state_reg <= WAIT_HASH_READY;
          end if;

        when WAIT_HASH_READY =>
          if hash_equal = '1' and norm_invalid = '0' then
            signature_verified <= '1';
            signature_valid    <= '1';
            state_reg          <= RESET_HASH;
          end if;


          if hash_no_equal = '1' or norm_invalid = '1' then
            signature_verified <= '1';
            signature_invalid  <= '1';
            state_reg          <= RESET_HASH;
          end if;


        when RESET_HASH =>
          message_absorbed_triggered <= '0';
          az1_ready_triggered        <= '0';
          reset_norm                 <= '1';
          reset_c_ram_module <= '1';
          if hash_positions_finished = '1' then
            hash_ext_reset <= '1';
            state_reg      <= IDLE;
          end if;
          

          
      end case;
    end if;
  end process;

end Behavioral;

