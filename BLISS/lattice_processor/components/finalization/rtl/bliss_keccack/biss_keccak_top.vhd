--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:41:05 02/10/2014 
-- Design Name: 
-- Module Name:    biss_keccak_top - Behavioral 
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




entity biss_keccak_top is
  generic (
    KECCAK_SLICES    : integer  := 32;
    --MODE : string :="BOTH"
    --------------------------General -----------------------------------------
    RAM_DEPTH        : integer  := 64;
    NUMBER_OF_BLOCKS : integer  := 16;
    N_ELEMENTS       : integer  := 512;
    PRIME_P_WIDTH    : integer  := 14;
    PRIME_P          : unsigned := to_unsigned(12289, 14);
    -----------------------  Sparse Mul Core ----------------------------------
    KAPPA            : integer  := 23;
    HASH_BLOCKS      : integer  := 4;
    HASH_WIDTH       : integer  := 64;
    USE_MOCKUP       : integer  := 0;
    MODULUS_P_BLISS  : unsigned := to_unsigned(24, 5)
    ---------------------------------------------------------------------------
    );
  port (
    clk : in std_logic;

    --We have to hash again due to rejection
    ext_rehash_message : in std_logic := '0';
    --We want to start a new signing operation
    ext_reset          : in std_logic := '0';

    --Signals that it accepts messages now  
    ready_message    : out std_logic := '0';
    --The message should be hashed now
    message_finished : in  std_logic := '0';

     message_absorbed :out std_logic:='0';

    --Now hash the u values and generate the positions
    --nerate_positions : in  std_logic := '0';
    positions_finished : out std_logic := '0';

    --Interface with the use to input messages
    message_din   : in std_logic_vector(HASH_WIDTH-1 downto 0) := (others => '0');
    message_valid : in std_logic                               := '0';

    c_pos_signature       : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    c_pos_signature_valid : out std_logic                                                          := '0';


    --Interface for the u values
    u_in    : in std_logic_vector(MODULUS_P_BLISS'length-1 downto 0) := (others => '0');
    u_wr_en : in std_logic                                           := '0';

    --Access the output of the hash function from a distributed RAM (simpler
    --than FIFO which is expensive in terms of area)
    c_addr : in  std_logic_vector(integer(ceil(log2(real(KAPPA))))-1 downto 0)      := (others => '0');
    c_out  : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0')
    );

end biss_keccak_top;

architecture Behavioral of biss_keccak_top is
  
  constant WIDTH_IN  : integer := MODULUS_P_BLISS'length;
  constant WIDTH_OUT : integer := HASH_WIDTH;

  signal pos_start        : std_logic                                                          := '0';
  signal pos_ready        : std_logic                                                          := '0';
  signal pos_hash_ready   : std_logic                                                          := '0';
  signal pos_hash_squeeze : std_logic                                                          := '0';
  signal pos_hash_in      : std_logic_vector(HASH_WIDTH-1 downto 0);
  signal pos_c_addr       : std_logic_vector(integer(ceil(log2(real(KAPPA))))-1 downto 0)      := (others => '0');
  signal pos_c_out        : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');

  signal storage_start        : std_logic                              := '0';
  signal storage_ready        : std_logic                              := '0';
  signal storage_absorb_ready : std_logic                              := '0';
  signal storage_absorb_block : std_logic                              := '0';
  signal storage_u_in         : std_logic_vector(WIDTH_IN-1 downto 0)  := (others => '0');
  signal storage_u_wr_en      : std_logic                              := '0';
  signal storage_dout         : std_logic_vector(WIDTH_OUT-1 downto 0) := (others => '0');
  signal storage_valid        : std_logic                              := '0';

  signal keccak_rst_n        : std_logic                               := '1';
  signal keccak_init         : std_logic                               := '0';
  signal keccak_go           : std_logic                               := '0';
  signal keccak_absorb       : std_logic                               := '0';
  signal keccak_squeeze      : std_logic                               := '0';
  signal keccak_din          : std_logic_vector(HASH_WIDTH-1 downto 0) := (others => '0');
  signal keccak_ready        : std_logic                               := '0';
  signal keccak_ready_intern : std_logic                               := '0';

  signal keccak_dout : std_logic_vector(HASH_WIDTH-1 downto 0) := (others => '0');

  signal mstore_message_din            : std_logic_vector(HASH_WIDTH-1 downto 0) := (others => '0');
  signal mstore_message_din_valid      : std_logic                               := '0';
  signal mstore_message_input_finished : std_logic                               := '0';
  signal mstore_absorb_message         : std_logic                               := '0';
  signal mstore_block_absorbed         : std_logic                               := '0';
  signal mstore_message_absorbed       : std_logic                               := '0';
  signal mstore_message_dout           : std_logic_vector(HASH_WIDTH-1 downto 0) := (others => '0');
  signal mstore_message_dout_valid     : std_logic                               := '0';

  signal select_keccak_input : std_logic := '0';

  signal ext_ready_message      : std_logic := '0';
  signal ext_message_finished   : std_logic := '0';
  signal ext_positions_finished : std_logic := '0';

  signal mstore_reset  : std_logic := '0';
  signal storage_reset : std_logic := '0';
  
begin

  

  ready_message        <= ext_ready_message;
  ext_message_finished <= message_finished;
  positions_finished   <= ext_positions_finished;

  keccak_ready_intern <= keccak_ready and (not keccak_go);

  bliss_keccak_fsm_1 : entity work.bliss_keccak_fsm
    port map (
      clk                           => clk,
       message_absorbed =>  message_absorbed,
      ext_rehash_message            => ext_rehash_message,
      ext_reset                     => ext_reset,
      ext_ready_message             => ext_ready_message,
      ext_message_finished          => ext_message_finished,
      select_keccak_input           => select_keccak_input,
      ext_positions_finished        => ext_positions_finished,
      mstore_message_input_finished => mstore_message_input_finished,
      mstore_absorb_message         => mstore_absorb_message,
      mstore_message_absorbed       => mstore_message_absorbed,
      mstore_block_absorbed         => mstore_block_absorbed,
      storage_start                 => storage_start,
      storage_absorb_ready          => storage_absorb_ready,
      storage_absorb_block          => storage_absorb_block,
      keccak_go                     => keccak_go,
      keccak_ready                  => keccak_ready_intern,
      keccak_rst_n                  => keccak_rst_n,
      keccak_init                   => keccak_init,
      pos_start                     => pos_start,
      pos_ready                     => pos_ready
      );


  --Message input to the RAM
  mstore_message_din       <= message_din;
  mstore_message_din_valid <= message_valid;
  mstore_reset             <= ext_reset;
  message_storage_1 : entity work.message_storage
    generic map (
      HASH_WIDTH => HASH_WIDTH
      )
    port map (
      clk                    => clk,
      reset                  => mstore_reset,
      message_din            => mstore_message_din,
      message_din_valid      => mstore_message_din_valid,
      message_input_finished => mstore_message_input_finished,
      absorb_message         => mstore_absorb_message,
      message_absorbed       => mstore_message_absorbed,
      block_absorbed         => mstore_block_absorbed,
      message_dout           => mstore_message_dout,
      message_dout_valid     => mstore_message_dout_valid
      );

  
  storage_u_in    <= u_in;
  storage_u_wr_en <= u_wr_en;
  storage_reset   <= ext_rehash_message or ext_reset;
  keccak_input_storage_1 : entity work.keccak_input_storage
    generic map (
      NUMBER_OF_BLOCKS => NUMBER_OF_BLOCKS,
      N_ELEMENTS       => N_ELEMENTS,
      WIDTH_IN         => WIDTH_IN,
      RAM_DEPTH        => RAM_DEPTH,
      WIDTH_OUT        => WIDTH_OUT
      )
    port map (
      clk          => clk,
      reset        => storage_reset,
      start        => storage_start,
      ready        => storage_ready,
      absorb_ready => storage_absorb_ready,
      absorb_block => storage_absorb_block,
      u_in         => storage_u_in,
      u_wr_en      => storage_u_wr_en,
      dout         => storage_dout,
      valid        => storage_valid
      );

  --Either the message RAM or the u value RAM can input stuff into the keccak core
  keccak_din    <= mstore_message_dout       when select_keccak_input = '0' else storage_dout;
  keccak_absorb <= mstore_message_dout_valid when select_keccak_input = '0' else storage_valid;


  USE_KECCAK_16 : if KECCAK_SLICES = 16 generate
    keccak_16 : entity work.keccak16
      port map (
        clk     => clk,
        rst_n   => keccak_rst_n ,
        init    => keccak_init,
        go      => keccak_go,
    absorb  => keccak_absorb,
       squeeze => keccak_squeeze,
        din     => keccak_din,
       ready   => keccak_ready,
        dout    => keccak_dout
        );
  end generate USE_KECCAK_16;


  USE_KECCAK_2 : if KECCAK_SLICES = 2 generate
    keccak_2 : entity work.keccak2
      port map (
        clk     => clk,
        rst_n   => keccak_rst_n ,
        init    => keccak_init,
        go      => keccak_go,
        absorb  => keccak_absorb,
        squeeze => keccak_squeeze,
        din     => keccak_din,
        ready   => keccak_ready,
        dout    => keccak_dout
        );
  end generate USE_KECCAK_2;


USE_KECCAK_32 : if KECCAK_SLICES = 32 generate
  keccak_32 : entity work.keccak32
  port map (
     clk     => clk,
       rst_n   => keccak_rst_n ,
      init    => keccak_init,
       go      => keccak_go,
       absorb  => keccak_absorb,
      squeeze => keccak_squeeze,
       din     => keccak_din,
       ready   => keccak_ready,
      dout    => keccak_dout
       );
 end generate USE_KECCAK_32;


  keccak_squeeze <= pos_hash_squeeze;
  pos_hash_ready <= keccak_ready;
  pos_hash_in    <= keccak_dout;
  pos_c_addr     <= c_addr;
  c_out          <= pos_c_out;

 
  get_positions_1 : entity work.get_positions
    generic map (
      N_ELEMENTS    => N_ELEMENTS,
      PRIME_P_WIDTH => PRIME_P_WIDTH,
      PRIME_P       => PRIME_P,
      KAPPA         => KAPPA,
      USE_MOCKUP    => USE_MOCKUP,
      HASH_BLOCKS   => HASH_BLOCKS,
      HASH_WIDTH    => HASH_WIDTH)
    port map (
      clk                   => clk,
      start                 => pos_start,
      ready                 => pos_ready,
      hash_ready            => pos_hash_ready,
      hash_squeeze          => pos_hash_squeeze,
      hash_in               => pos_hash_in,
      c_pos_signature       => c_pos_signature ,
      c_pos_signature_valid => c_pos_signature_valid,
      c_addr                => pos_c_addr,
      c_out                 => pos_c_out
      );

end Behavioral;

