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
-- Create Date:   09:25:51 02/18/2014
-- Design Name:   
-- Module Name:   C:/Users/thomas/SHA/Projekte/BLISS/code/bliss_arithmetic/lattice_processor/get_positions_tb.vhd
-- Project Name:  lattice_processor
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: get_positions
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

entity get_positions_tb is
  generic (
    --------------------------General --------------------------------------
    N_ELEMENTS    : integer  := 512;
    PRIME_P_WIDTH : integer  := 14;
    PRIME_P       : unsigned := to_unsigned(12289, 14);
    -----------------------  Sparse Mul Core ------------------------------------------
    KAPPA         : integer  := 23;
    HASH_BLOCKS   : integer  := 4;
    USE_MOCKUP    : integer  := 0;
    HASH_WIDTH    : integer  := 64
    ---------------------------------------------------------------------------

    );
  port (
    error_happened_out    : out std_logic := '0';
    end_of_simulation_out : out std_logic := '0'
    );
end get_positions_tb;

architecture behavior of get_positions_tb is

  -- Component Declaration for the Unit Under Test (UUT)
  signal end_of_simulation : std_logic := '0';
  signal error_happened    : std_logic := '0';


  signal clk                   : std_logic;
  signal start                 : std_logic                                                          := '0';
  signal ready                 : std_logic                                                          := '0';
  signal hash_ready            : std_logic                                                          := '0';
  signal hash_squeeze          : std_logic                                                          := '0';
  signal hash_in               : std_logic_vector(HASH_WIDTH-1 downto 0)                            := (others => '0');
  signal c_pos_signature       : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal c_pos_signature_valid : std_logic                                                          := '0';
  signal c_addr                : std_logic_vector(integer(ceil(log2(real(KAPPA))))-1 downto 0)      := (others => '0');
  signal c_out                 : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');

  -- Clock period definitions
  constant clk_period : time    := 10 ns;
  signal   cnt        : integer := 0;

  signal counter : unsigned(63 downto 0) := to_unsigned(3342432, 64);

  type   ram_type is array (0 to 6) of integer;
  signal test : ram_type := (0, 96, 48, 24, 12, 6, 3);
begin

  -- Instantiate the Unit Under Test (UUT)
  get_positions_1 : entity work.get_positions
    generic map (
      N_ELEMENTS    => N_ELEMENTS,
      PRIME_P_WIDTH => PRIME_P_WIDTH,
      PRIME_P       => PRIME_P,
      KAPPA         => KAPPA,
      HASH_BLOCKS   => HASH_BLOCKS,
      USE_MOCKUP    => USE_MOCKUP,
      HASH_WIDTH    => HASH_WIDTH
      )
    port map (
      clk                   => clk,
      start                 => start,
      ready                 => ready,
      hash_ready            => hash_ready,
      hash_squeeze          => hash_squeeze,
      hash_in               => hash_in,
      c_pos_signature       => c_pos_signature,
      c_pos_signature_valid => c_pos_signature_valid,
      c_addr                => c_addr,
      c_out                 => c_out
      );



  -- Clock process definitions
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  process(clk)
  begin  -- process
    if rising_edge(clk) then
      if c_pos_signature_valid = '1' and cnt < 6 then
        if to_integer(unsigned(c_pos_signature)) /= test(cnt) then
          error_happened <= '1';
          
        end if;
        cnt <= cnt+1;
        
        
      end if;
    end if;
  end process;


  -- Stimulus process
  stim_proc : process
  begin
    -- hold reset state for 100 ns.
    wait for 100 ns;

    wait for clk_period*10;
    start      <= '1';
    hash_ready <= '1';
    wait for clk_period;
    start      <= '0';
    wait for clk_period;

    while ready = '0' loop
      if hash_squeeze = '1' then
        hash_in <= std_logic_vector(counter);
        counter <= resize(counter*4343325, counter'length);
      end if;
      wait for clk_period;
    end loop;

    wait for clk_period*10;

    if error_happened = '1' then
      report "ERROR";
    else
      report "OK";
    end if;

    end_of_simulation <= '1';
    wait;


    wait;
  end process;

end;
