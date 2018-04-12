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
-- Create Date:    17:20:56 02/10/2014 
-- Design Name: 
-- Module Name:    keccak_input_storage - Behavioral 
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


--This modules reads in all the u values (512 a 5 bits) and stores them in a
--LUT Memory.

--When the absorb_burst is triggered, 16 blocks a 64 bits are outputted. The
--third time absorb burst is triggered, the padding to the hash is applied.

entity keccak_input_storage is
  generic(
    NUMBER_OF_BLOCKS : integer := 16;
    N_ELEMENTS       : integer := 512;
    WIDTH_IN         : integer := 5;
    WIDTH_OUT        : integer := 64;
    RAM_DEPTH        : integer := 64
    );
  port (
    clk          : in  std_logic;
    reset        : in  std_logic;
    --Control logic. Start makes the system ready for u values
    start        : in  std_logic;
    ready        : out std_logic;
    --Output 16 blocks so that they can get absorbed
    absorb_ready : out std_logic;
    absorb_block : in  std_logic;
    --The u values
    u_in         : in  std_logic_vector(WIDTH_IN-1 downto 0)  := (others => '0');
    u_wr_en      : in  std_logic;
    --The output to the hash
    dout         : out std_logic_vector(WIDTH_OUT-1 downto 0) := (others => '0');
    valid        : out std_logic                              := '0'
    );
end keccak_input_storage;

architecture Behavioral of keccak_input_storage is
  constant MAX_RAM_ELEMENTS : integer := 64;
  constant MAX_VALS         : integer := MAX_RAM_ELEMENTS/WIDTH_IN;

  component keccak_in_core
    port (
      a    : in  std_logic_vector(5 downto 0);
      d    : in  std_logic_vector(63 downto 0);
      clk  : in  std_logic;
      we   : in  std_logic;
      qspo : out std_logic_vector(63 downto 0)
      );
  end component;

  signal ram_din   : std_logic_vector(WIDTH_OUT-1 downto 0)                            := (others => '0');
  signal ram_dout  : std_logic_vector(WIDTH_OUT-1 downto 0)                            := (others => '0');
  signal ram_wr_en : std_logic                                                         := '0';
  signal ram_addr  : std_logic_vector(integer(ceil(log2(real(RAM_DEPTH))))-1 downto 0) := (others => '0');

  type   eg_state is (IDLE, READ_U, WAIT_HASHING, OUTPUT_BLOCKS);
  signal state_reg : eg_state := IDLE;

  signal buf_temp : std_logic_vector(ram_din'range) := (others => '0');
  signal buf_cnt  : integer                         := 0;
  signal addr_cnt : integer                         := 0;
  signal valid_r  : std_logic                       := '0';


  signal u_hash : std_logic_vector(u_in'range):=(others => '0');
begin


  dout <= ram_dout;


  process (clk)
  begin  -- process
    if rising_edge(clk) then            -- rising clock edge
      if reset = '1' then
        state_reg <= IDLE;
        buf_cnt <= 0;
          addr_cnt <= 0;
      else

        ready        <= '0';
        ram_wr_en    <= '0';
        absorb_ready <= '0';
        valid_r      <= '0';
        valid        <= valid_r;

        case state_reg is
          when IDLE =>
            u_hash <= (others => '0');
            buf_cnt <= 0;
            ready   <= '1';

            if Start = '1' then
              ready     <= '0';
              state_reg <= READ_U;
            end if;

          when READ_U =>
            if u_wr_en = '1' then
              u_hash <= u_hash xor u_in;
              if buf_cnt < MAX_VALS-1 then
                buf_temp(buf_cnt*WIDTH_IN+WIDTH_IN-1 downto buf_cnt*WIDTH_IN) <= u_in;
                buf_cnt                                                       <= buf_cnt+1;
              end if;

              if buf_cnt = MAX_VALS-1 then
                ram_addr                                                               <= std_logic_vector(to_unsigned(addr_cnt, ram_addr'length));
                ram_din                                                                <= buf_temp;
                ram_din((MAX_VALS-1)*WIDTH_IN+WIDTH_IN-1 downto (MAX_VALS-1)*WIDTH_IN) <= u_in;
                ram_wr_en                                                              <= '1';
                addr_cnt                                                               <= addr_cnt+1;
                buf_cnt                                                                <= 0;
              end if;

              if addr_cnt = N_ELEMENTS/MAX_VALS and buf_cnt = (N_ELEMENTS mod MAX_VALS)-1 then
                --Write the last block
                ram_addr <= std_logic_vector(to_unsigned(addr_cnt, ram_addr'length));

                ram_din                                                                                                  <= (others => '0');
                ram_din                                                                                                  <= buf_temp;
                ram_din(((N_ELEMENTS mod MAX_VALS)-1)*WIDTH_IN+WIDTH_IN-1 downto ((N_ELEMENTS mod MAX_VALS)-1)*WIDTH_IN) <= u_in;
                ram_wr_en                                                                                                <= '1';
                state_reg                                                                                                <= WAIT_HASHING;
                addr_cnt                                                                                                 <= 0;
              end if;
              
            end if;


          when WAIT_HASHING =>
            absorb_ready <= '1';
            buf_cnt      <= 0;
            if absorb_block = '1' then
              absorb_ready <= '0';
              state_reg    <= OUTPUT_BLOCKS;
            end if;
            

          when OUTPUT_BLOCKS =>
            ram_addr <= std_logic_vector(to_unsigned(addr_cnt, ram_addr'length));
            valid_r  <= '1';
            addr_cnt <= addr_cnt+1;
            buf_cnt  <= buf_cnt+1;
            if buf_cnt = NUMBER_OF_BLOCKS-1 then
              state_reg <= WAIT_HASHING;
              buf_cnt   <= 0;
              addr_cnt  <= addr_cnt+1;
            end if;


        end case;
        
      end if;
      
      
    end if;
  end process;



  keccak_u_input_buff_inst :entity work.keccak_in_core_new
    port map (
      clk  => clk,
      a    => ram_addr,
      d    => ram_din,
      we   => ram_wr_en,
      qspo => ram_dout
      );


end Behavioral;



--ram_wr_en <= '0';
--    valid_r1     <= '1';
--    valid <= valid_r1;

--    if u_in = '1' then
--      if buf_cnt < MAX_VALS then
--        buf_temp(buf_cnt*WIDTH_IN+WIDTH_IN-1 downto buf_cnt*WIDTH_IN) <= din;
--        buf_cnt                                                       <= buf_cnt+1;
--      end if;

--      if buf_cnt = MAX_VALS-1 then
--        ram_addr  <= std_logic_vector(to_unsigned(data_cnt, ram_addr'length));
--        ram_din   <= buf_temp;
--        ram_wr_en <= '1';
--        buf_cnt   <= 0;
--      end if;
--    end if;


--    if absorb_burst = '1' then
--      absorbing <= '1';
--    end if;

--    if absorb_cnt=15 then
--      absorb_cnt <= 0;
--      absorbing <=  '0';
--    end if;

--    if absorb_burst = '1' or absorbing = '1' then
--      ram_addr <= std_logic_vector(to_unsigned(data_cnt, ram_addr'length));
--      valid_r1    <= '1';
--      data_cnt <= data_cnt-1;
--      absorb_cnt <= absorb_cnt+1;
--    end if;
