--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/

--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:41:19 02/14/2014
-- Design Name:   
-- Module Name:   C:/Users/thomas/SHA/Projekte/BLISS/code/bliss_arithmetic/lattice_processor/components/finalization/bench/finalization/bliss_sign_top_tb.vhd
-- Project Name:  lattice_processor
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: bliss_sign_top
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.lattice_processor.all;
use work.lyu512_pkg.all;



entity bliss_sign_speed_tb is
  generic (
    --Change to switch paramter set.
    USE_HUFF         : integer := 0;
    PARAMETER_SET    : integer := 1;
    NUM_BER_SAMPLERS : integer := 2;
    GAUSS_SAMPLER    : string  := "none";

    --Change to tune implementation
    KECCAK_SLICES : integer := 16;
    CORES         : integer := 2;

    --No effect, do not change
    HASH_WIDTH : integer  := 64;
    N_ELEMENTS : integer  := 512;
    ZETA       : unsigned := to_unsigned(6145, 13);
    PRIME_P    : unsigned := to_unsigned(12289, 14)
    );
  port (
    cycles_per_sig        : buffer unsigned(40 downto 0) := (others => '0');
    error_happened_out    : out    std_logic             := '0';
    end_of_simulation_out : out    std_logic           := '0'
    );

end bliss_sign_speed_tb;

architecture behavior of bliss_sign_speed_tb is
  constant MODULUS_P_BLISS : unsigned := get_bliss_p(PARAMETER_SET);
  constant KAPPA           : integer  := get_bliss_kappa(PARAMETER_SET);
  constant D_BLISS         : integer  := get_bliss_d(PARAMETER_SET);

  constant WIDTH_S1 : integer := get_bliss_s1_length(PARAMETER_SET);
  constant WIDTH_S2 : integer := get_bliss_s2_length(PARAMETER_SET);




  -- Component Declaration for the Unit Under Test (UUT)

  signal clk : std_logic;

  signal end_of_simulation : std_logic := '0';
  signal error_happened    : std_logic := '0';


  signal message_din       : std_logic_vector(HASH_WIDTH-1 downto 0)                            := (others => '0');
  signal message_valid     : std_logic                                                          := '0';
  signal ready             : std_logic;
  signal sign              : std_logic                                                          := '0';
  signal ready_message     : std_logic                                                          := '0';
  signal message_finished  : std_logic                                                          := '0';
  signal stop_engine       : std_logic                                                          := '0';
  signal engine_stoped     : std_logic                                                          := '0';
  signal load_public_key   : std_logic                                                          := '0';
  signal signature_ready   : std_logic                                                          := '0';
  signal signature_valid   : std_logic                                                          := '0';
  signal signature_invalid : std_logic                                                          := '0';
  signal s1_addr           : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal s1_in             : std_logic_vector(WIDTH_S1-1 downto 0)                              := (others => '0');
  signal s1_wr_en          : std_logic                                                          := '0';
  signal s2_addr           : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal s2_in             : std_logic_vector(WIDTH_S2-1 downto 0)                              := (others => '0');
  signal s2_wr_en          : std_logic                                                          := '0';
  signal public_key_addr   : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal public_key_data   : std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
  signal z1_final          : std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
  signal z1_final_addr     : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal z1_final_valid    : std_logic                                                          := '0';
  signal z2_final          : std_logic_vector(MODULUS_P_BLISS'length-1 downto 0)                := (others => '0');
  signal z2_final_addr     : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal z2_final_valid    : std_logic                                                          := '0';
  signal final_c_pos       : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal final_c_pos_valid : std_logic                                                          := '0';

  -- Clock period definitions
  constant clk_period : time := 10 ns;

  signal   counter     : integer               := 0;
  constant runs        : integer               := 400;
  signal   clk_counter : unsigned(40 downto 0) := (others => '0');
  signal   start_clk   : unsigned(40 downto 0) := (others => '0');
  signal   end_clk     : unsigned(40 downto 0) := (others => '0');
  signal   sig_cycles  : unsigned(40 downto 0) := (others => '0');

  signal counter_valid               : integer := 0;
  signal counter_invalid             : integer := 0;
  signal counter_signatures_computed : integer := 0;

  signal code_rst          : std_logic                                                          := '0';
  signal code_V_din        : std_logic_vector (31 downto 0);
  signal code_V_full_n     : std_logic;
  signal code_V_write      : std_logic;
  
begin

  -- Clock process definitions
  clk_process : process
  begin
    if end_of_simulation = '0' then
      clk <= '0';
      wait for clk_period/2;
      clk <= '1';
      wait for clk_period/2;
    end if;
  end process;
  end_of_simulation_out <= end_of_simulation;


  process (clk)
  begin  -- process
    if rising_edge(clk) then
      clk_counter <= clk_counter+1;

      if signature_valid = '1' then
        counter_valid <= counter_valid+1;
      end if;

      if signature_invalid = '1' then
        counter_invalid <= counter_invalid+1;
      end if;

      if signature_valid = '1' or signature_invalid = '1' then
        counter_signatures_computed <= counter_signatures_computed+1;
      end if;
      
    end if;
  end process;


  no_huff : if USE_HUFF = 0 generate
    bliss_sign_top_1 : entity work.bliss_sign_top
      generic map (
        NUM_BER_SAMPLERS => NUM_BER_SAMPLERS,
        SAMPLER          => GAUSS_SAMPLER,
        PARAMETER_SET    => PARAMETER_SET,
        KECCAK_SLICES    => KECCAK_SLICES,
        CORES            => CORES,
        PRIME_P          => PRIME_P ,
        ZETA             => ZETA
        )
      port map (
        clk               => clk,
        ready             => ready,
        sign              => sign,
        final_c_pos       => final_c_pos,
        final_c_pos_valid => final_c_pos_valid,
        ready_message     => ready_message,
        message_finished  => message_finished,
        message_din       => message_din ,
        message_valid     => message_valid,
        stop_engine       => stop_engine,
        engine_stoped     => engine_stoped,
        load_public_key   => load_public_key,
        signature_ready   => signature_ready,
        signature_valid   => signature_valid,
        signature_invalid => signature_invalid,
        s1_addr           => s1_addr,
        s1_in             => s1_in,
        s1_wr_en          => s1_wr_en,
        s2_addr           => s2_addr,
        s2_in             => s2_in,
        s2_wr_en          => s2_wr_en,
        public_key_addr   => public_key_addr,
        public_key_data   => public_key_data,
        z1_final          => z1_final,
        z1_final_addr     => z1_final_addr,
        z1_final_valid    => z1_final_valid,
        z2_final          => z2_final,
        z2_final_addr     => z2_final_addr,
        z2_final_valid    => z2_final_valid);

  end generate no_huff;


  USE_HUFF_GEN : if USE_HUFF = 1 generate
    code_V_full_n <= '1';
    
    bliss_sign_huffman_1: entity work.bliss_sign_huffman
      generic map (
        PARAMETER_SET => PARAMETER_SET,
        KECCAK_SLICES => KECCAK_SLICES,
        CORES         => CORES,
        HASH_WIDTH    => HASH_WIDTH,
        N_ELEMENTS    => N_ELEMENTS,
        ZETA          => ZETA,
        PRIME_P       => PRIME_P
        )
      port map (
        clk               => clk,
        ready             => ready,
        sign              => sign,
        ready_message     => ready_message,
        message_finished  => message_finished,
        stop_engine       => stop_engine,
        engine_stoped     => engine_stoped,
        load_public_key   => load_public_key,
        signature_ready   => signature_ready,
        signature_valid   => signature_valid,
        signature_invalid => signature_invalid,
        message_din       => message_din,
        message_valid     => message_valid,
        s1_addr           => s1_addr,
        s1_in             => s1_in,
        s1_wr_en          => s1_wr_en,
        s2_addr           => s2_addr,
        s2_in             => s2_in,
        s2_wr_en          => s2_wr_en,
        public_key_addr   => public_key_addr,
        public_key_data   => public_key_data,
        final_c_pos       => final_c_pos,
        final_c_pos_valid => final_c_pos_valid,
        code_rst          => code_rst,
        code_V_din        => code_V_din,
        code_V_full_n     => code_V_full_n,
        code_V_write      => code_V_write
        );

  end generate USE_HUFF_GEN;


  -- Stimulus process
  stim_proc : process
  begin
    -- hold reset state for 100 ns.
    wait for 100 ns;

    wait for clk_period*10000;

    while counter < runs loop
      counter   <= counter+1;
      start_clk <= clk_counter;

      while ready_message = '0' loop
        wait for clk_period;
      end loop;

      wait for clk_period;

      --Write the message
      for i in 0 to 15 loop
        message_din   <= (others => '1');
        message_valid <= '1';
        wait for clk_period;
      end loop;  -- i
      message_valid <= '0';

      --State that the message is finished
      message_finished <= '1';
      wait for clk_period;
      message_finished <= '0';

      wait for clk_period*10;
      sign <= '1';
      wait for clk_period;
      sign <= '0';
      wait for clk_period*10;

      while signature_ready = '0' loop
        wait for clk_period;
      end loop;

      --Finnish cunting cycles
      end_clk <= clk_counter;
      wait for clk_period;

      --Calculate the cycle count
      sig_cycles     <= sig_cycles + end_clk - start_clk;
      wait for clk_period;
      cycles_per_sig <= sig_cycles/counter;

      
    end loop;


    wait for clk_period*5000000;


    if error_happened = '1' then
      report "ERROR";
    else
      report "OK";
    end if;

    end_of_simulation <= '1';
    wait;

  end process;

  
end;
