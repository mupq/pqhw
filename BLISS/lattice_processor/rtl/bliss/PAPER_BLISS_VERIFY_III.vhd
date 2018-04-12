----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:17:44 03/02/2014 
-- Design Name: 
-- Module Name:    PAPER_VERIFY - Behavioral 
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


entity PAPER_BLISS_VERIFY_III is
  generic (
    --Change to switch paramter set
    PARAMETER_SET : integer := 3;

    --Change to tune implementation
    KECCAK_SLICES    : integer := 16;
 
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
    ready           : out std_logic;
    verify          : in  std_logic;
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
    sig_delay  : in  integer                                                            := 1;

 c_sig_addr : out std_logic_vector(integer(ceil(log2(real(get_bliss_kappa(PARAMETER_SET)))))-1 downto 0)      := (others => '0');
    c_sig_data : in  std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');

    z1_sig_data : in  std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
    z1_sig_addr : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');

    z2_sig_data : in  std_logic_vector(get_bliss_p_length(PARAMETER_SET)-1 downto 0)                := (others => '0');
    z2_sig_addr : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0')
    );
end PAPER_BLISS_VERIFY_III;

architecture Behavioral of PAPER_BLISS_VERIFY_III is

begin
  

  bliss_verify_top_1 : entity work.bliss_verify_top
    generic map (
      PARAMETER_SET    => PARAMETER_SET,
      KECCAK_SLICES    => KECCAK_SLICES,
      PRIME_P          => PRIME_P ,
      ZETA             => ZETA
      )
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
      z1_sig_data        => z1_sig_data,
      z1_sig_addr        => z1_sig_addr,
      z2_sig_data        => z2_sig_data,
      z2_sig_addr        => z2_sig_addr);

end Behavioral;

