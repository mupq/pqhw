----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:19:35 08/11/2014 
-- Design Name: 
-- Module Name:    PAPER_BLISS_SIGN_HUFFMAN - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.lattice_processor.all;
use work.lyu512_pkg.all;



entity PAPER_BLISS_SIGN_HUFFMAN_I is
    generic (
    --Change to switch paramter set
    PARAMETER_SET : integer := 1;

    --Change to tune implementation
    KECCAK_SLICES : integer := 16;
    CORES         : integer := 2;

    --No effect, do not change
    HASH_WIDTH : integer := 64;

    N_ELEMENTS : integer  := 512;
    ZETA       : unsigned := to_unsigned(6145, 13);
    PRIME_P    : unsigned := to_unsigned(12289, 14)
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
    s1_in    : in std_logic_vector(get_bliss_s1_length(PARAMETER_SET)-1 downto 0)    := (others => '0');
    s1_wr_en :    std_logic                                                          := '0';

    s2_addr  : in std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    s2_in    : in std_logic_vector(get_bliss_s2_length(PARAMETER_SET)-1 downto 0)    := (others => '0');
    s2_wr_en :    std_logic                                                          := '0';

    --Read out of different public key
    public_key_addr : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    public_key_data : in  std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');

    final_c_pos       : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    final_c_pos_valid : out std_logic                                                          := '0';

    --Outputs the encoded message
    code_rst      : out std_logic := '0';
    code_V_din    : out std_logic_vector (31 downto 0);
    code_V_full_n : in  std_logic;
    code_V_write  : out std_logic


    );
end PAPER_BLISS_SIGN_HUFFMAN_I;

architecture Behavioral of PAPER_BLISS_SIGN_HUFFMAN_I is

begin

  bliss_sign_huffman_1:entity work.bliss_sign_huffman
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

end Behavioral;

