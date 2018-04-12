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
-- Create Date:    08:42:31 02/26/2014 
-- Design Name: 
-- Module Name:    rejecter - Behavioral 
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
use work.ber_sampler_pkg.all;
use work.cdt_sampler_pkg.all;
use work.lyu512_pkg.all;

--TODO TEST NORMS

entity rejecter is
  generic (
    PARAMETER_SET     : integer  := 1;
    --------------------------General --------------------------------------
    SCALAR_PROD_WIDTH : integer  := 32;
    NORM_WIDTH        : integer  := 32;
    N_ELEMENTS        : integer  := 512;
    PRIME_P           : unsigned := to_unsigned(12289, 14)
    ---------------------------------------------------------------------------
    );
  port(

    clk : in std_logic;

    reset     : in  std_logic;
    rejection : out std_logic;
    finished  : out std_logic;

    scalar_prod       : in std_logic_vector(SCALAR_PROD_WIDTH-1 downto 0) := (others => '0');
    scalar_prod_valid : in std_logic                                      := '0';


    encoder_finished : in std_logic := '0';
    encoder_ok       : in std_logic := '0';


    norm       : in std_logic_vector(NORM_WIDTH-1 downto 0) := (others => '0');
    norm_valid : in std_logic                               := '0'

    );
end rejecter;

architecture Behavioral of rejecter is
  constant MAX_PREC : integer := get_ber_precision(PARAMETER_SET);
  constant CONST_K  : integer := get_ber_k(PARAMETER_SET);
  constant MAX_X    : integer := get_ber_max_x(PARAMETER_SET);



  signal   ber_fifo_ber_in : std_logic_vector(integer(ceil(log2(real((CONST_K-1)*((CONST_K-1)+2*CONST_K*MAX_X)))))-1 downto 0);
  constant paramM          : unsigned := to_unsigned(get_bliss_M(PARAMETER_SET), ber_fifo_ber_in'length);

  signal trivium_rst    : std_logic                     := '1';
  signal trivium_clk_en : std_logic                     := '1';
  signal trivium_key    : std_logic_vector(79 downto 0) := (others => '1');
  signal trivium_IV     : std_logic_vector(79 downto 0) := (others => '1');
  signal trivium_o_vld  : std_logic;
  signal trivium_z      : std_logic;

  signal ber_rand_rd_en     : std_logic;
  signal ber_rand_din       : std_logic;
  signal ber_rand_empty     : std_logic;
  signal ber_rand_valid     : std_logic;
  signal ber_fifo_ber_empty : std_logic;
  signal ber_fifo_ber_rd_en : std_logic;
  signal ber_fifo_ber_valid : std_logic;

  signal ber_fifo_z_empty   : std_logic;
  signal ber_fifo_z_rd_en   : std_logic;
  signal ber_fifo_z_valid   : std_logic;
  signal ber_fifo_z_in      : std_logic_vector(integer(ceil(log2(real((CONST_K)*(MAX_X)+CONST_K-1))))-1 downto 0);
  signal ber_z_dout         : std_logic_vector(integer(ceil(log2(real((CONST_K)*(MAX_X)+CONST_K-1))))-1 downto 0) := (others => '0');
  signal ber_z_full         : std_logic;
  signal ber_z_wr_en        : std_logic;
  signal ber_rejected_value : std_logic;

  type   eg_state is (IDLE, TEST_NORM, TEST_SCALAR, REJECTION_STATE, ACCEPTANCE, SAMPLE_BER_EXP_SHIFT, SAMPLE_BER_EXP_SHIFT_SECOND, WAIT_BER_EXP_SHIFT, WAIT_BER_EXP_SHIFT_SECOND);
  signal state_reg : eg_state := IDLE;

  signal scalar_prod_intern : unsigned(ber_fifo_ber_in'range) := (others => '0');
    signal encoder_has_finished : std_logic:='0';
    signal encoder_was_ok : std_logic:='0';

begin





  trivium_1 : entity work.trivium
    port map (
      clk    => clk,
      rst    => trivium_rst,
      clk_en => trivium_clk_en,
      key    => trivium_key,
      IV     => trivium_IV,
      o_vld  => trivium_o_vld,
      z      => trivium_z
      );

  ber_eval_1 : entity work.ber_eval
    generic map (
      PARAM_SET => PARAMETER_SET,
      MAX_PREC  => MAX_PREC,
      CONST_K   => CONST_K,
      MAX_X     => MAX_X
      )
    port map (
      clk            => clk,
      rand_rd_en     => ber_rand_rd_en,
      rand_din       => ber_rand_din,
      rand_empty     => ber_rand_empty,
      rand_valid     => ber_rand_valid,
      rejected_value => ber_rejected_value,
      fifo_ber_empty => ber_fifo_ber_empty,
      fifo_ber_rd_en => ber_fifo_ber_rd_en,
      fifo_ber_valid => ber_fifo_ber_valid,
      fifo_ber_in    => ber_fifo_ber_in,
      fifo_z_empty   => ber_fifo_z_empty,
      fifo_z_rd_en   => ber_fifo_z_rd_en,
      fifo_z_valid   => ber_fifo_z_valid,
      fifo_z_in      => (others => '0'),
      z_dout         => open,
      z_full         => ber_z_full,
      z_wr_en        => ber_z_wr_en
      );


--begin with the norm
  process(clk)
  begin  -- process
    if rising_edge(clk) then
      --Reset Trivium during startup
      trivium_rst <= '0';
    end if;
  end process;

  process(clk)
  begin  -- process
    if rising_edge(clk) then
      ber_fifo_ber_empty <= '1';
      ber_fifo_z_empty   <= '1';
      ber_z_full         <= '0';
      ber_fifo_ber_valid <= '0';
      ber_fifo_z_valid   <= '0';
      rejection          <= '0';
      finished           <= '0';
      ber_rand_valid     <= '0';

      ber_rand_din   <= trivium_z;
      ber_rand_empty <= '0';

      if ber_rand_rd_en = '1' then
        ber_rand_valid <= '1';
      end if;

      --Immitate the FIFO
      if ber_fifo_ber_rd_en = '1' and ber_fifo_z_rd_en = '1' then
        ber_fifo_ber_valid <= '1';
        ber_fifo_z_valid   <= '1';
      end if;

      if encoder_finished = '1' then
        encoder_has_finished <= '1';
        if encoder_ok = '1' then
          encoder_was_ok <= '1';
        else
          encoder_was_ok <= '0';
        end if;
      end if;

      case state_reg is
        when IDLE =>
          if norm_valid = '1' and scalar_prod_valid = '1' and encoder_has_finished='1' then
            state_reg          <= TEST_NORM;
            ber_fifo_ber_empty <= '0';
            ber_fifo_z_empty   <= '0';
            ber_fifo_ber_in    <= std_logic_vector(resize(paramM-unsigned(norm), ber_fifo_ber_in'length));
            scalar_prod_intern <= resize(unsigned(abs(signed(scalar_prod))), ber_fifo_ber_in'length);
          end if;

        when TEST_NORM =>
          if ber_rejected_value = '1' or encoder_was_ok='0' then
            state_reg <= REJECTION_STATE;
          end if;

          if ber_z_wr_en = '1' then
            state_reg <= TEST_SCALAR;
          end if;


        when TEST_SCALAR =>
          state_reg <= SAMPLE_BER_EXP_SHIFT;

          
        when SAMPLE_BER_EXP_SHIFT =>
          ber_fifo_ber_empty <= '0';
          ber_fifo_z_empty   <= '0';
          ber_fifo_ber_in    <= std_logic_vector(scalar_prod_intern sll 1);
          state_reg          <= WAIT_BER_EXP_SHIFT;

        when WAIT_BER_EXP_SHIFT =>
          if ber_z_wr_en = '1' then
            state_reg <= ACCEPTANCE;
          end if;

          if ber_rejected_value = '1' then
            if trivium_z = '1' then
              state_reg <= SAMPLE_BER_EXP_SHIFT_SECOND;
            else
              state_reg <= SAMPLE_BER_EXP_SHIFT;
            end if;
          end if;


        when SAMPLE_BER_EXP_SHIFT_SECOND =>
          ber_fifo_ber_empty <= '0';
          ber_fifo_z_empty   <= '0';
          ber_fifo_ber_in    <= std_logic_vector(scalar_prod_intern sll 1);
          state_reg          <= WAIT_BER_EXP_SHIFT_SECOND;
          
        when WAIT_BER_EXP_SHIFT_SECOND =>

          if ber_rejected_value = '1' then
            state_reg <= REJECTION_STATE;
          end if;

          if ber_z_wr_en = '1' then
            state_reg <= SAMPLE_BER_EXP_SHIFT;
          end if;

          
        when REJECTION_STATE =>
          rejection <= '1';
          --rejection <= '0';
          finished  <= '1';
          encoder_has_finished <= '0';
             encoder_was_ok <= '0';
          state_reg <= IDLE;

          
        when ACCEPTANCE =>
          rejection <= '0';
          finished  <= '1';
           encoder_has_finished <= '0';
             encoder_was_ok <= '0';
          state_reg <= IDLE;




      end case;

    end if;
  end process;
  
end Behavioral;

