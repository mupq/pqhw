--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:37:56 02/11/2014
-- Design Name:   
-- Module Name:   C:/Users/thomas/SHA/Projekte/BLISS/code/sparse_mul/sparse_mul/bench/bliss_keccak/bliss_keccak_top_tb.vhd
-- Project Name:  sparse_mul
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: biss_keccak_top
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


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

entity bliss_keccak_top_tb is
  generic (
    --------------------------General -----------------------------------------
    N_ELEMENTS      : integer  := 512;
    PRIME_P_WIDTH   : integer  := 14;
    PRIME_P         : unsigned := to_unsigned(12289, 14);
    -----------------------  Sparse Mul Core ----------------------------------
    KAPPA           : integer  := 23;
    HASH_BLOCKS     : integer  := 4;
    HASH_WIDTH      : integer  := 64;
    MODULUS_P_BLISS : unsigned := to_unsigned(24, 5)
    ---------------------------------------------------------------------------
    );
end bliss_keccak_top_tb;

architecture behavior of bliss_keccak_top_tb is
  signal clk                : std_logic;
  signal ready_message      : std_logic                                                          := '0';
  signal message_finished   : std_logic                                                          := '0';
  signal generate_positions : std_logic                                                          := '0';
  signal positions_finished : std_logic                                                          := '0';
  signal message_din        : std_logic_vector(HASH_WIDTH-1 downto 0)                            := (others => '0');
  signal message_valid      : std_logic                                                          := '0';
  signal u_in               : std_logic_vector(MODULUS_P_BLISS'length-1 downto 0)                := (others => '0');
  signal u_wr_en            : std_logic                                                          := '0';
  signal c_addr             : std_logic_vector(integer(ceil(log2(real(KAPPA))))-1 downto 0)      := (others => '0');
  signal c_out              : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');

  -- Clock period definitions
  constant clk_period : time := 10 ns;
  
begin

  -- Instantiate the Unit Under Test (UUT)
  biss_keccak_top_1 : entity work.biss_keccak_top
    generic map (
      N_ELEMENTS      => N_ELEMENTS,
      PRIME_P_WIDTH   => PRIME_P_WIDTH,
      PRIME_P         => PRIME_P,
      KAPPA           => KAPPA,
      HASH_BLOCKS     => HASH_BLOCKS,
      HASH_WIDTH      => HASH_WIDTH,
      MODULUS_P_BLISS => MODULUS_P_BLISS)
    port map (
      clk                => clk,
      ready_message      => ready_message,
      message_finished   => message_finished,
      positions_finished => positions_finished,
      message_din        => message_din,
      message_valid      => message_valid,
      u_in               => u_in,
      u_wr_en            => u_wr_en,
      c_addr             => c_addr,
      c_out              => c_out);

  -- Clock process definitions
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;


  -- Stimulus process
  stim_proc : process
  begin
    -- hold reset state for 100 ns.
    wait for 100 ns;

    wait for clk_period*10;
    --Check that the core is ready to eat the message
    if ready_message = '0' then
      wait for clk_period;
    end if;

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

    --Now wait a bit
    wait for clk_period*500;

    --Now input the u values (erstmal alles zero)
    for i in 0 to 511 loop
      u_in <= (others => '0');
      u_wr_en  <= '1';
        wait for clk_period;  
    end loop;  -- i
    u_wr_en  <= '0';
    wait for clk_period;

    --Now wait until the positions of c are generated
    wait for clk_period*1000;
    
    -- insert stimulus here 

    wait;
  end process;

end;
