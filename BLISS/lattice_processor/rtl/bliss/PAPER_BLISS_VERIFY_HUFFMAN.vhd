----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:21:03 08/11/2014 
-- Design Name: 
-- Module Name:    PAPER_BLISS_VERIFY_HUFFMAN - Behavioral 
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
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.lattice_processor.all;
use work.lyu512_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity PAPER_BLISS_VERIFY_HUFFMAN_I is
  generic (
    ---------------------------------------------------------------------------
    --Change to switch paramter set
    --Influences: d, \kappa, secret keys, public keys
    PARAMETER_SET : integer := 1;

    ------------------------------------------------------------------------------- 
    --Change to tune implementation
    KECCAK_SLICES    : integer               := 32;
    ---------------------------------------------------------------------------
    --Do not change unless you want to break something
    RAM_DEPTH        : integer               := 64;
    NUMBER_OF_BLOCKS : integer               := 16;
    N_ELEMENTS       : integer               := 512;
    PRIME_P_WIDTH    : integer               := 14;
    PRIME_P          : unsigned              := to_unsigned(12289, 14);
    ZETA             : unsigned              := to_unsigned(6145, 13);
    HASH_BLOCKS      : integer               := 4;
    HASH_WIDTH       : integer               := 64;
    WIDTH_S1         : integer               := 2;
    WIDTH_S2         : integer               := 3;
    INIT_TABLE       : integer               := 0;
    USE_MOCKUP       : integer               := 0;
    c_delay          : integer range 0 to 16 := 2;
    MAX_RES_WIDTH    : integer               := 6
    );
  port (
    clk : in std_logic;

    -- Control bits/signals
    ready           : out std_logic;
    verify          : in  std_logic := '0';
    load_public_key : in  std_logic;

    --Result of verification
    signature_verified : out std_logic := '0';
    signature_valid    : out std_logic := '0';
    signature_invalid  : out std_logic := '0';

    --Message interface
    ready_message    : out std_logic                               := '0';
    message_finished : in  std_logic                               := '0';
    message_din      : in  std_logic_vector(HASH_WIDTH-1 downto 0) := (others => '0');
    message_valid    : in  std_logic                               := '0';

    --Read out of different public key
    public_key_addr : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    public_key_data : in  std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');

    --The signature   
    sig_delay  : in  integer                                                                                := 1;
    --TODO Kappa
    c_sig_addr : out std_logic_vector(integer(ceil(log2(real(get_bliss_kappa(PARAMETER_SET)))))-1 downto 0) := (others => '0');
    c_sig_data : in  std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0)                     := (others => '0');

    code_V_dout    : in  std_logic_vector (31 downto 0);
    code_V_empty_n : in  std_logic;
    code_V_read    : out std_logic;
    code_V_rst     : out std_logic := '0'

    );
end PAPER_BLISS_VERIFY_HUFFMAN_I;


architecture Behavioral of PAPER_BLISS_VERIFY_HUFFMAN_I is

begin

  bliss_verify_huffman_top_1 : entity work.bliss_verify_huffman_top
    generic map (
      PARAMETER_SET    => PARAMETER_SET,
      KECCAK_SLICES    => KECCAK_SLICES,
      RAM_DEPTH        => RAM_DEPTH,
      NUMBER_OF_BLOCKS => NUMBER_OF_BLOCKS,
      N_ELEMENTS       => N_ELEMENTS,
      PRIME_P_WIDTH    => PRIME_P_WIDTH,
      PRIME_P          => PRIME_P,
      ZETA             => ZETA,
      HASH_BLOCKS      => HASH_BLOCKS,
      HASH_WIDTH       => HASH_WIDTH,
      WIDTH_S1         => WIDTH_S1,
      WIDTH_S2         => WIDTH_S2,
      INIT_TABLE       => INIT_TABLE,
      USE_MOCKUP       => USE_MOCKUP,
      c_delay          => c_delay,
      MAX_RES_WIDTH    => MAX_RES_WIDTH)
    port map (
      clk                => clk,
      ready              => ready,
      verify             => verify,
      load_public_key    => load_public_key,
      signature_verified => signature_verified,
      signature_valid    => signature_valid,
      signature_invalid  => signature_invalid,
      ready_message      => ready_message,
      message_finished   => message_finished,
      message_din        => message_din,
      message_valid      => message_valid,
      public_key_addr    => public_key_addr,
      public_key_data    => public_key_data,
      sig_delay          => sig_delay,
      c_sig_addr         => c_sig_addr,
      c_sig_data         => c_sig_data,
      code_V_dout        => code_V_dout,
      code_V_empty_n     => code_V_empty_n,
      code_V_read        => code_V_read,
      code_V_rst         => code_V_rst
      );

end Behavioral;

