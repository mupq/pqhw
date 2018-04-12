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
-- Create Date:    13:37:47 07/02/2013 
-- Design Name: 
-- Module Name:    coeff_ops - Behavioral 
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

entity coeff_ops is
  generic (
    N_ELEMENTS    : integer  := 32;
    N_INVERSE     : unsigned := to_unsigned(33, 10);
    PRIME_P_WIDTH : integer  := 10;
    XN            : integer  := -1
    );
  port(
    clk                : in  std_logic;
    usr_inv_n_start    : in  std_logic := '0';
    usr_inv_n_finished : out std_logic := '0';

    usr_ipsi_start    : in  std_logic                                                          := '0';
    usr_ipsi_finished : out std_logic                                                          := '0';
    --Connection to W-Table
    w_psi_req         : out std_logic;
    w_inverse_req     : out std_logic;
    w_index           : out unsigned(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0)         := (others => '0');
    w_out_val         : in  unsigned(PRIME_P_WIDTH-1 downto 0);
    w_delay           : in  integer                                                            := 5;
    --connection to arithmetic unit
    a_op              : out std_logic_vector(0 downto 0)                                       := (others => '0');
    a_w_in            : out unsigned(PRIME_P_WIDTH-1 downto 0);
    a_a_in            : out unsigned(PRIME_P_WIDTH-1 downto 0);
    a_b_in            : out unsigned(PRIME_P_WIDTH-1 downto 0);
    a_x_out           : in  unsigned(PRIME_P_WIDTH-1 downto 0);
    a_delay           : in  integer                                                            := 35;
    --Connection to RAM
    bram_delay        : in  integer                                                            := 10;
    bram_addra        : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    bram_doa          : in  std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');

    bram_addrb : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    bram_dib   : out std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');
    bram_web   : out std_logic                                                          := '0'
    );
end coeff_ops;

architecture Behavioral of coeff_ops is

  --Define the address counters
  constant COUNTER_LENGTH   : integer                             := integer(ceil(log2(real(N_ELEMENTS))));
  constant COUNTER_OVERFLOW : unsigned(COUNTER_LENGTH-1 downto 0) := (others => '1');


  signal w_index_counter_en : std_logic                           := '0';
  signal w_index_counter    : unsigned(COUNTER_LENGTH-1 downto 0) := (others => '0');
  signal addr_a_counter_en  : std_logic                           := '0';
  signal addr_a_counter     : unsigned(COUNTER_LENGTH-1 downto 0) := (others => '0');
  signal addr_b_counter_en  : std_logic                           := '0';
  signal addr_b_counter     : unsigned(COUNTER_LENGTH-1 downto 0) := (others => '0');

  signal w_index_counter_en_delay : std_logic := '0';
  signal addr_a_counter_en_delay  : std_logic := '0';
  signal addr_b_counter_en_delay  : std_logic := '0';

  signal addr_a_counter_overflow  : std_logic := '0';
  signal w_index_counter_overflow : std_logic := '0';

  signal addr_a_counter_delay : integer range 0 to 60 := 0;
  signal addr_b_counter_delay : integer range 0 to 60 := 0;

  signal fin_reg_rin                      : std_logic_vector(0 downto 0) := (others => '0');
  signal addr_a_counter_delay_reg_in_vec  : std_logic_vector(0 downto 0) := (others => '0');
  signal addr_a_counter_delay_reg_out_vec : std_logic_vector(0 downto 0) := (others => '0');
  signal addr_b_counter_delay_reg_in_vec  : std_logic_vector(0 downto 0) := (others => '0');
  signal addr_b_counter_delay_reg_out_vec : std_logic_vector(0 downto 0) := (others => '0');

  signal working : std_logic := '0';
  signal waiting : std_logic := '0';

  signal addr_b_counter_delay_reg_reset : std_logic := '0';

  type eg_state is (IDLE, IPSI, INVN);

  signal state_reg : eg_state := IDLE;
begin

  --Default config for psi req
  w_psi_req     <= '1';
  w_inverse_req <= '1';

  --Input to MAR
  a_op(0) <= '0';
  a_w_in  <= N_INVERSE when state_reg = INVN else w_out_val;  --INVN or IPSI
  a_b_in  <= unsigned(bram_doa);
  a_a_in  <= (others => '0');

  --Output of MAR
  bram_dib <= std_logic_vector(a_x_out);

  --Use counter in order to generate the addresses
  bram_addra <= std_logic_vector(addr_a_counter);
  bram_addrb <= std_logic_vector(addr_b_counter);
  w_index    <= w_index_counter;


  --Counter Address B Delay Mechanisms
  --addr_a_counter_delay               <= bram_delay + a_delay;
  addr_a_counter_delay_reg_in_vec(0) <= addr_a_counter_en_delay;
  addr_a_counter_delay_reg : entity work.dyn_shift_reg
    generic map (width => 1)
    port map (clk    => clk,
              depth  => addr_a_counter_delay,
              Input  => addr_a_counter_delay_reg_in_vec,
              Output => addr_a_counter_delay_reg_out_vec
              );
  addr_a_counter_en <= addr_a_counter_delay_reg_out_vec(0);

  --Counter Address B Delay Mechanisms
  --addr_b_counter_delay               <= bram_delay + a_delay;
  addr_b_counter_delay_reg_in_vec(0) <= addr_b_counter_en_delay;
  addr_b_counter_delay_reg : entity work.dyn_shift_reg_clr
    generic map (width => 1)
    port map (clk    => clk,
              depth  => addr_b_counter_delay,
              reset  => addr_b_counter_delay_reg_reset,
              Input  => addr_b_counter_delay_reg_in_vec,
              Output => addr_b_counter_delay_reg_out_vec
              );
  addr_b_counter_en <= addr_b_counter_delay_reg_out_vec(0);
  bram_web          <= addr_b_counter_en;  --Write atomatically

  --Counter W_index Delay Mechanisms
  -- Not necessary, as the delay of the w table is larger than that of the bram
  -- However, this may change
  w_index_counter_en <= w_index_counter_en_delay;

  --Check without delay if an overflow happened
  process (addr_a_counter, w_index_counter)
  begin  -- process
    if addr_a_counter = (COUNTER_OVERFLOW) then
      addr_a_counter_overflow <= '1';
    else
      addr_a_counter_overflow <= '0';
    end if;

    if w_index_counter = (COUNTER_OVERFLOW) then
      w_index_counter_overflow <= '1';
    else
      w_index_counter_overflow <= '0';
    end if;
  end process;


  process (clk)
  begin
    if rising_edge(clk) then
      --Defaults
      addr_b_counter_delay_reg_reset <= '0';
      addr_a_counter_en_delay        <= '0';
      w_index_counter_en_delay       <= '0';
      addr_b_counter_en_delay        <= '0';
      usr_inv_n_finished             <= '0';
      usr_ipsi_finished              <= '0';

      --The Counters
      if addr_a_counter_en = '1' then
        addr_a_counter <= addr_a_counter+1;
      end if;

      if addr_b_counter_en = '1' then
        addr_b_counter <= addr_b_counter+1;
      end if;

      if w_index_counter_en = '1' then
        w_index_counter <= w_index_counter+1;
      end if;

      --Check that the unit is now going to do something
      if usr_inv_n_start = '1' then
        working <= '1';                 --Keep on going
      end if;


      case state_reg is
        --##############################################################
        --   IDLE
        --##############################################################
        when IDLE =>
          if usr_inv_n_start = '1' then
            working   <= '1';
            state_reg <= INVN;
          end if;
          if usr_ipsi_start = '1' then
            working   <= '1';
            state_reg <= IPSI;
          end if;

          --##############################################################
          --   INVN
          --##############################################################
        when INVN =>
          --Set the delays for inv n
          addr_b_counter_delay <= bram_delay + a_delay;
          addr_a_counter_delay <= 0;

          if working = '1' then
            --Start counter a (coefficient request)
            addr_a_counter_en_delay <= '1';

            --Start counter b with a delay (coefficient save)
            addr_b_counter_en_delay <= '1';

            if addr_a_counter_overflow = '1' then
              addr_a_counter_en_delay <= '0';
              addr_b_counter_en_delay <= '0';
              working                 <= '0';
              waiting                 <= '1';
            end if;
          end if;

          if waiting = '1' then
            if addr_b_counter_en = '0' then
              addr_a_counter                 <= (others => '0');
              waiting                        <= '0';
              usr_inv_n_finished             <= '1';
              addr_b_counter_delay_reg_reset <= '1';
              state_reg                      <= IDLE;
            end if;
          end if;

          --##############################################################
          --   IPSI
          --##############################################################
        when IPSI =>
          addr_b_counter_delay <= w_delay + a_delay;
          addr_a_counter_delay <= w_delay-bram_delay;

          if working = '1' then
            --Start counter a (coefficient request)
            addr_a_counter_en_delay  <= '1';
            addr_b_counter_en_delay  <= '1';
            w_index_counter_en_delay <= '1';

            if w_index_counter_overflow = '1' then
              addr_a_counter_en_delay  <= '0';
              addr_b_counter_en_delay  <= '0';
              w_index_counter_en_delay <= '0';
              working                  <= '0';
              waiting                  <= '1';
            end if;
          end if;

          if waiting = '1' then
            if addr_b_counter_en = '0' then
              w_index_counter                <= (others => '0');
              addr_a_counter                 <= (others => '0');
              waiting                        <= '0';
              usr_ipsi_finished              <= '1';
              addr_b_counter_delay_reg_reset <= '1';
              state_reg                      <= IDLE;
            end if;
          end if;
      end case;
    end if;
  end process;

end Behavioral;

