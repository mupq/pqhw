----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:53:41 03/03/2014 
-- Design Name: 
-- Module Name:    PAPER_BLISS_SIGN_DUAL_BERNOULLI - Behavioral 
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
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.lattice_processor.all;
use work.lyu512_pkg.all;



entity PAPER_BLISS_SIGN_DUAL_BERNOULLI_I is
    generic (
        --Change to switch paramter set
    PARAMETER_SET : integer := 1;

    --Change to tune implementation
    KECCAK_SLICES    : integer := 16;
    CORES            : integer := 2;
    SAMPLER : string :="bernoulli_gauss";
     NUM_BER_SAMPLERS : integer               := 2;

    --No effect, do not change
    HASH_WIDTH      : integer  := 64;
    WIDTH_S1        : integer  := 2;
    WIDTH_S2        : integer  := 3;
    N_ELEMENTS      : integer  := 512;
    ZETA            : unsigned := to_unsigned(6145, 13);
    PRIME_P         : unsigned := to_unsigned(12289, 14)
    );
  port (
    clk : in std_logic;

    -- Control bits/signals
    ready : out std_logic;
    sign  : in  std_logic;

    ready_message    : out std_logic := '0';
    message_finished : in  std_logic := '0';

    stop_engine     : in  std_logic;
    engine_stoped   : out std_logic;
    load_public_key : in  std_logic;

    signature_ready   : out std_logic := '0';
    signature_valid   : out std_logic := '0';
    signature_invalid : out std_logic := '0';

    message_din   : in std_logic_vector(HASH_WIDTH-1 downto 0) := (others => '0');
    message_valid : in std_logic                               := '0';

    --Access to the key port (to change the secret key). Write only
    s1_addr  : in std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    s1_in    : in std_logic_vector(WIDTH_S1-1 downto 0)                              := (others => '0');
    s1_wr_en :    std_logic                                                          := '0';

    s2_addr  : in std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    s2_in    : in std_logic_vector(WIDTH_S2-1 downto 0)                              := (others => '0');
    s2_wr_en :    std_logic                                                          := '0';

    --Read out of different public key
    public_key_addr : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    public_key_data : in  std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');

    final_c_pos       : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    final_c_pos_valid : out std_logic                                                          := '0';

    --The signature
    --Final ports
    z1_final       : out std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
    z1_final_addr  : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    z1_final_valid : out std_logic                                                          := '0';

    --Final ports
    z2_final       : out std_logic_vector(get_bliss_p_length(PARAMETER_SET)-1 downto 0)                                       := (others => '0');
    z2_final_addr  : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    z2_final_valid : out std_logic                                                          := '0'

    );

end PAPER_BLISS_SIGN_DUAL_BERNOULLI_I;

architecture Behavioral of PAPER_BLISS_SIGN_DUAL_BERNOULLI_I is

begin


   bliss_sign_top_1 : entity work.bliss_sign_top
    generic map (
      SAMPLER => SAMPLER,
      NUM_BER_SAMPLERS => NUM_BER_SAMPLERS,
      PARAMETER_SET   => PARAMETER_SET,
      KECCAK_SLICES   => KECCAK_SLICES,
      CORES           => CORES,
      PRIME_P         => PRIME_P ,
      ZETA            => ZETA
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
      z1_final          => z1_final,
      z1_final_addr     => z1_final_addr,
      z1_final_valid    => z1_final_valid,
      z2_final          => z2_final,
      z2_final_addr     => z2_final_addr,
      z2_final_valid    => z2_final_valid
      );

end Behavioral;

