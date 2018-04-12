--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:55:55 09/05/2011
-- Design Name:   
-- Module Name:   /home/thomasp/xilinx/DSPMU/hash_engine/hash_module_tb_c.vhd
-- Project Name:  DSP_Mul
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: hash_module
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
use work.HASH_ENGINE_DEFS.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

entity hash_module_tb_m is
end hash_module_tb_m;

architecture behavior of hash_module_tb_m is

  -- Component Declaration for the Unit Under Test (UUT)
  
  component hash_module
    port(
      clk            : in  std_logic;
      reset          : in  std_logic;
      start_hashing  : in  std_logic;
      finish_hashing : in  std_logic;
      din            : in  std_logic_vector(31 downto 0);
      src_ready      : in  std_logic;
      src_read       : out std_logic;
      dout           : out std_logic_vector(159 downto 0);
      hash_ready     : out std_logic;
      save_state     : in  std_logic;
      state_saved    : out std_logic;
      state_loaded   : out std_logic;
      load_state     : in  std_logic
      );
  end component;

  --End of simulation
  signal end_of_simulation : std_logic := '0';

  --Inputs
  signal clk            : std_logic                     := '0';
  signal reset          : std_logic                     := '0';
  signal start_hashing  : std_logic                     := '0';
  signal finish_hashing : std_logic                     := '0';
  signal din            : std_logic_vector(31 downto 0) := (others => '0');
  signal src_ready      : std_logic                     := '0';
  signal save_state     : std_logic                     := '0';
  signal load_state     : std_logic                     := '0';

  --Outputs
  signal src_read     : std_logic;
  signal dout         : std_logic_vector(159 downto 0);
  signal hash_ready   : std_logic;
  signal state_saved  : std_logic;
  signal state_loaded : std_logic;

  -- Clock period definitions
  constant clk_period : time := 10 ns;
  
begin

  -- Instantiate the Unit Under Test (UUT)
  uut : hash_module port map (
    clk            => clk,
    reset          => reset,
    start_hashing  => start_hashing,
    finish_hashing => finish_hashing,
    din            => din,
    src_ready      => src_ready,
    src_read       => src_read,
    dout           => dout,
    hash_ready     => hash_ready,
    save_state     => save_state,
    state_saved    => state_saved,
    state_loaded   => state_loaded,
    load_state     => load_state
    );

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
    wait for 10 ns;

    wait until rising_edge(clk);
    wait for 1 ns;
    wait for clk_period;
    start_hashing <= '1';
    wait for clk_period;
    src_ready     <= '1';
    wait for clk_period;
    din           <= "01111010101010101010101010101010";
    wait for clk_period;
    wait for clk_period;
    assert src_read = '1' report "Error" severity error;
    din           <= "00111010101010101010101010101010";
    wait for clk_period;
    wait for clk_period;
    assert src_read = '1' report "Error" severity error;
    din           <= "00011010101010101010101010101010";
    wait for clk_period;
    wait for clk_period;
    assert src_read = '1' report "Error" severity error;
    din           <= "00001010101010101010101010101010";
    wait for clk_period;
    wait for clk_period;
    assert src_read = '1' report "Error" severity error;
    din           <= "00000010101010101010101010101010";
    src_ready     <= '0';
    wait for clk_period;
    wait for clk_period;
    din           <= (others => '1');

    wait for clk_period;
    assert src_read = '0' report "Error" severity error;

    wait for clk_period;
    wait for clk_period;
    wait for clk_period;

    save_state <= '1';
    wait until state_saved = '1';
    load_state <= '1';
    wait until state_loaded = '1';
    load_state <= '0';
    wait for 1 ns;

    finish_hashing <= '1';
    wait until hash_ready = '1';
    wait for 1 ns;
    assert dout = "0000001010101010101010101010101000001010101010101010101010101010000110101010101010101010101010100011101010101010101010101010101001111010101010101010101010101010" report "Error" severity error;

    wait for clk_period;
    wait for clk_period;
    finish_hashing <= '0';
    save_state     <= '0';
    wait for clk_period;

    save_state     <= '1';
    wait until state_saved = '1';
    wait for 1ns;
    src_ready      <= '1';
    wait for clk_period;
    assert src_read = '1' report "Error" severity error;
    src_ready <= '0';
    din            <= "11111111111111101010101010101010";    
    wait for clk_period;
    wait for clk_period;
    
    src_ready      <= '0';
    load_state     <= '1';
    wait for clk_period;
    wait until state_loaded = '1';
    load_state <= '0';
    wait for 1 ns;
    finish_hashing <= '1';
    wait until hash_ready = '1';
    wait for 1 ns;
 
    assert dout = "0000001010101010101010101010101000001010101010101010101010101010000110101010101010101010101010100011101010101010101010101010101001111010101010101010101010101010" report "Error" severity error;

    wait for clk_period;
    wait for clk_period;
    finish_hashing <= '0';
    save_state     <= '0';
    wait for clk_period;

    save_state     <= '1';
    wait until state_saved = '1';
    wait for 1ns;
    src_ready      <= '1';
    wait for clk_period;
    assert src_read = '1' report "Error" severity error;
    src_ready <= '0';
    din            <= "11111111111111101010101010101010";    
    wait for clk_period;
    wait for clk_period;
    
    src_ready      <= '0';
    load_state     <= '1';
    wait for clk_period;
    wait until state_loaded = '1';
    load_state <= '0';
    wait for 1 ns;
    finish_hashing <= '1';
    wait until hash_ready = '1';
    wait for 1 ns;
    assert dout = "0000001010101010101010101010101000001010101010101010101010101010000110101010101010101010101010100011101010101010101010101010101001111010101010101010101010101010" report "Error" severity error;



    
    --Let the hash putput something - then reload old value
        wait for clk_period;
    wait for clk_period;
    finish_hashing <= '0';
    save_state     <= '0';
    wait for clk_period;

    save_state     <= '1';
    wait until state_saved = '1';
    wait for 1ns;
    src_ready      <= '1';
    wait for clk_period;
    assert src_read = '1' report "Error" severity error;
    src_ready <= '0';
    din            <= "11111111111111101010101010101010";
                     --  01111010101010101010101010101010
                     --  10000101010101000000000000000000
    wait for clk_period;
    wait for clk_period;
    
    src_ready      <= '0';
     wait for clk_period;
     finish_hashing <= '1';
    wait until hash_ready = '1';
    wait for 1 ns;
    --report to_string_std_logic_vector(dout);
    assert dout = "0000001010101010101010101010101000001010101010101010101010101010000110101010101010101010101010100011101010101010101010101010101010000101010101000000000000000000" report "Error" severity error;

    wait for clk_period;
    wait for clk_period;
    finish_hashing <= '0';
    save_state     <= '0';
    wait for clk_period;

      wait for 1ns;
    src_ready      <= '1';
    wait for clk_period;
    assert src_read = '1' report "Error" severity error;
    src_ready <= '0';
    din            <= "11111111111111101010101010101010";    
    wait for clk_period;
    wait for clk_period;
    
    src_ready      <= '0';
    load_state     <= '1';
    wait for clk_period;
    wait until state_loaded = '1';
    load_state <= '0';
    wait for 1 ns;
    finish_hashing <= '1';
    wait until hash_ready = '1';
    wait for 1 ns;
    --report to_string_std_logic_vector(dout);
    assert dout = "0000001010101010101010101010101000001010101010101010101010101010000110101010101010101010101010100011101010101010101010101010101001111010101010101010101010101010" report "Error" severity error;
    


    end_of_simulation <= '1';

    --assert signal='1' report "Error" severity error;

    -- insert stimulus here 

    wait;
  end process;

end;
