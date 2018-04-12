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
-- Create Date:    10:25:43 02/11/2014 
-- Design Name: 
-- Module Name:    message_storage - Behavioral 
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


entity message_storage is
  generic(
    MAX_RAM_DEPTH : integer := 64;
    HASH_WIDTH    : integer := 64
    );
  port (
    clk   : in std_logic;
    reset : in std_logic;
    --message_input_mode  : in std_logic;
    --message_output_mode : in std_logic;

    message_din            : in std_logic_vector(HASH_WIDTH-1 downto 0) := (others => '0');
    message_din_valid      : in std_logic                               := '0';
    message_input_finished : in std_logic                               := '0';

    absorb_message   : in  std_logic := '0';
    block_absorbed   : out std_logic := '0';
    message_absorbed : out std_logic := '0';

    message_dout       : out std_logic_vector(HASH_WIDTH-1 downto 0) := (others => '0');
    message_dout_valid : out std_logic                               := '0'

    );

end message_storage;

architecture Behavioral of message_storage is
  component message_RAM
    port (
      a    : in  std_logic_vector(5 downto 0);
      d    : in  std_logic_vector(63 downto 0);
      clk  : in  std_logic;
      we   : in  std_logic;
      qspo : out std_logic_vector(63 downto 0)
      );
  end component;


  signal message_ram_addr : std_logic_vector(5 downto 0)  := (others => '0');
  signal message_ram_din  : std_logic_vector(63 downto 0) := (others => '0');
  signal message_ram_we   : std_logic                     := '0';
  signal message_ram_dout : std_logic_vector(63 downto 0) := (others => '0');

  signal message_cnt        : integer range 0 to MAX_RAM_DEPTH := 0;
  signal message_absorb_cnt : integer range 0 to MAX_RAM_DEPTH := 0;

  signal message_dout_valid_r1 : std_logic := '0';

  --type   eg_state is (IDLE, MESSAGE_INPUT, OUTPUT_MODE, ABSORBING, FINISHED);
  --signal state_reg : eg_state := IDLE;

  type   eg_state is (IDLE, MESSAGE_INPUT, OUTPUT_MODE, ABSORBING_MODE, FINISHED);
  signal state_reg : eg_state := IDLE;
  
begin

  message_dout <= message_ram_dout;

  MAX_RAM_DEPTH_INST : if MAX_RAM_DEPTH <= 64 generate
    message_ram_inst : message_RAM
      port map (
        clk  => clk,
        a    => message_ram_addr,
        d    => message_ram_din,
        we   => message_ram_we,
        qspo => message_ram_dout
        );
  end generate MAX_RAM_DEPTH_INST;


  process (clk)
  begin  -- process
    if rising_edge(clk) then            -- rising clock edge
      
      message_dout_valid_r1 <= '0';
      message_dout_valid    <= message_dout_valid_r1;
      message_ram_we        <= '0';
      block_absorbed        <= '0';
      message_absorbed      <= '0';


      case state_reg is
        when IDLE =>
          state_reg          <= MESSAGE_INPUT;
          message_absorb_cnt <= 0;
          message_cnt        <= 0;

          -------------------------------------------------------------------------------
        when MESSAGE_INPUT =>
          if message_din_valid = '1' then
            message_ram_addr <= std_logic_vector(to_unsigned(message_cnt, message_ram_addr'length));
            message_ram_din  <= message_din;
            message_ram_we   <= '1';
            message_cnt      <= message_cnt+1;
            
          elsif message_input_finished = '1' then
            state_reg <= OUTPUT_MODE;
          end if;

          ------------------------------------------------------------------------------
        when OUTPUT_MODE =>
          --We have to output 16 blocks from the RAM (we assume that we just get 16
          --blocks input. Max amount is four blocks)
          if absorb_message = '1' then
            message_absorb_cnt <= 0;
            state_reg          <= ABSORBING_MODE;
          end if;

          if message_absorb_cnt = message_cnt then
            message_absorbed <= '1';
            state_reg        <= FINISHED;
          end if;

          -----------------------------------------------------------------------
        when ABSORBING_MODE =>
          message_ram_addr      <= std_logic_vector(to_unsigned(message_absorb_cnt, message_ram_addr'length));
          message_dout_valid_r1 <= '1';
          message_absorb_cnt    <= message_absorb_cnt+1;

          if message_absorb_cnt mod 16 = 15 then
            state_reg      <= OUTPUT_MODE;
            block_absorbed <= '1';
          end if;

        when FINISHED =>
          if reset = '1' then
            state_reg <= IDLE;
          end if;

          if absorb_message = '1' then
            state_reg          <= ABSORBING_MODE;
            message_absorb_cnt <= 0;
          end if;
          
          

          
      end case;
      
    end if;
  end process;


end Behavioral;





--LEADS to wired error
--message_dout_valid_r1 <= '1';
--      message_dout_valid    <= message_dout_valid_r1;
--      message_absorbed      <= '0';
--      message_ram_we        <= '0';

--      case state_reg is
--        when IDLE =>
--          state_reg          <= MESSAGE_INPUT;
--          message_absorb_cnt <= 0;
--          message_cnt        <= 0;

--        when MESSAGE_INPUT =>
--          if message_din_valid = '1' then
--            message_ram_addr <=std_logic_vector(to_unsigned(message_cnt,message_ram_addr'length));
--            message_ram_din <= message_din;
--            message_ram_we  <= '1';
--            message_cnt     <= message_cnt+1;
--          end if;

--          if message_input_finished = '1' then
--            state_reg <= OUTPUT_MODE;
--          end if;

--        when OUTPUT_MODE =>
--          --We have to output 16 blocks from the RAM (we assume that we just get 16
--          --blocks input. Max amount is four blocks)
--          if absorb_message = '1' then
--            message_absorb_cnt <= 0;
--            state_reg          <= ABSORBING;
--          end if;

--          if message_absorb_cnt = message_cnt then
--            state_reg <= FINISHED;
--          end if;


--        when ABSORBING =>
--          message_ram_addr      <= std_logic_vector(to_unsigned(message_absorb_cnt, message_ram_addr'length));
--          message_dout_valid_r1 <= '1';
--          message_absorb_cnt    <= message_absorb_cnt+1;

--          if message_absorb_cnt mod 16 = 15 then
--            state_reg <= OUTPUT_MODE;
--          end if;

--        when FINISHED =>
--          message_absorbed <= '1';
--          state_reg        <= IDLE;
--   end case;
