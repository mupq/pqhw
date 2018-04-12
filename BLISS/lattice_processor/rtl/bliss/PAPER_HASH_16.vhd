----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:56:55 02/28/2014 
-- Design Name: 
-- Module Name:    PAPER_HASH_16 - Behavioral 
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


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PAPER_HASH_16 is
  generic (
    KECCAK_SLICES    : integer  := 16;
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

end PAPER_HASH_16;

architecture Behavioral of PAPER_HASH_16 is

begin

  biss_keccak_top_1:entity work.biss_keccak_top
    generic map (
      KECCAK_SLICES    => KECCAK_SLICES,
      RAM_DEPTH        => RAM_DEPTH,
      NUMBER_OF_BLOCKS => NUMBER_OF_BLOCKS,
      N_ELEMENTS       => N_ELEMENTS,
      PRIME_P_WIDTH    => PRIME_P_WIDTH,
      PRIME_P          => PRIME_P,
      KAPPA            => KAPPA,
      HASH_BLOCKS      => HASH_BLOCKS,
      HASH_WIDTH       => HASH_WIDTH,
      USE_MOCKUP       => USE_MOCKUP,
      MODULUS_P_BLISS  => MODULUS_P_BLISS)
    port map (
      clk                   => clk,
      ext_rehash_message    => ext_rehash_message,
      ext_reset             => ext_reset,
      ready_message         => ready_message,
      message_finished      => message_finished,
      positions_finished    => positions_finished,
      message_din           => message_din,
      message_valid         => message_valid,
      c_pos_signature       => c_pos_signature,
      c_pos_signature_valid => c_pos_signature_valid,
      u_in                  => u_in,
      u_wr_en               => u_wr_en,
      c_addr                => c_addr,
      c_out                 => c_out
      );
end Behavioral;

