--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:58:23 02/06/2014
-- Design Name:   
-- Module Name:   C:/Users/thomas/SHA/Projekte/BLISS/code/sparse_mul/sparse_mul/bench/sparse_mul/sparse_mul_top_tb.vhd
-- Project Name:  sparse_mul
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: sparse_mul_top
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




entity sparse_mul_top_tb is

  generic (
    --FFT and general configuration
    CORES         : integer := 4;
    N_ELEMENTS    : integer := 512;
    KAPPA         : integer := 23;
    --probably either 2 (s1) or 3 (s2)
    WIDTH_S1       : integer := 2;
    WIDTH_S2       : integer := 3;
    --Used to initialize the right s (s1 or s2)
    INIT_TABLE    : integer := 0;
    MAX_RES_WIDTH : integer := 6
    );
  port (
    error_happened_out    : out std_logic := '0';
    end_of_simulation_out : out std_logic := '0'
    );
end sparse_mul_top_tb;


architecture behavior of sparse_mul_top_tb is
  signal end_of_simulation : std_logic := '0';
  signal error_happened    : std_logic := '0';


  signal clk             : std_logic;
  signal start           : std_logic                                                          := '0';
  signal ready           : std_logic                                                          := '0';
  signal s1_addr          : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal s1_in            : std_logic_vector(WIDTH_S1-1 downto 0)                               := (others => '0');
  signal s1_wr_en         : std_logic                                                          := '0';
  signal addr_c          : std_logic_vector(integer(ceil(log2(real(KAPPA))))-1 downto 0)      := (others => '0');
  signal data_c          : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal coeff_sc1_out   : std_logic_vector(MAX_RES_WIDTH-1 downto 0)                         := (others => '0');
  signal coeff_sc1_addr  : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal coeff_sc1_valid : std_logic                                                          := '0';

  signal coeff_sc2_out   : std_logic_vector(MAX_RES_WIDTH-1 downto 0)                         := (others => '0');
  signal coeff_sc2_addr  : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal coeff_sc2_valid : std_logic                                                          := '0';

  type   ram_type is array (0 to KAPPA-1) of unsigned(16-1 downto 0);
  signal c_ram : ram_type := (to_unsigned(480, 16), to_unsigned(152, 16), to_unsigned(292, 16), to_unsigned(258, 16), to_unsigned(462, 16), to_unsigned(374, 16), to_unsigned(508, 16), to_unsigned(441, 16), to_unsigned(229, 16), to_unsigned(70, 16), to_unsigned(190, 16), to_unsigned(28, 16), to_unsigned(300, 16), to_unsigned(118, 16), to_unsigned(502, 16), to_unsigned(378, 16), to_unsigned(321, 16), to_unsigned(19, 16), to_unsigned(34, 16), to_unsigned(31, 16), to_unsigned(276, 16), to_unsigned(369, 16), to_unsigned(48, 16));



  signal   cycle_counter : integer := 0;
  -- Clock period definitions
  constant clk_period    : time    := 10 ns;
  
begin


  process (clk)
  begin  -- process
    if rising_edge(clk) then
      data_c <= std_logic_vector(resize(c_ram(to_integer(unsigned(addr_c))), data_c'length));
    end if;
  end process;

-- Component Declaration for the Unit Under Test (UUT)
  sparse_mul_top_1 : entity work.sparse_mul_top
    generic map (
      CORES         => CORES,
      N_ELEMENTS    => N_ELEMENTS,
      KAPPA         => KAPPA,
      WIDTH_S1       => WIDTH_S1,
      WIDTH_S2       => WIDTH_S2,
      INIT_TABLE    => INIT_TABLE,
      MAX_RES_WIDTH => MAX_RES_WIDTH)
    port map (
      clk             => clk,
      start           => start,
      ready           => ready,
      s1_addr         => s1_addr,
      s1_in           => s1_in,
      s1_wr_en        => s1_wr_en,
      addr_c          => addr_c,
      data_c          => data_c,
      coeff_sc1_out   => coeff_sc1_out,
      coeff_sc1_addr  => coeff_sc1_addr,
      coeff_sc1_valid => coeff_sc1_valid,
      coeff_sc2_out   => coeff_sc2_out,
      coeff_sc2_addr  => coeff_sc2_addr,
      coeff_sc2_valid => coeff_sc2_valid
      );

  clk_process : process
  begin
    if end_of_simulation = '0' then
      clk           <= '0';
      wait for clk_period/2;
      clk           <= '1';
      wait for clk_period/2;
      cycle_counter <= cycle_counter+1;
    end if;
  end process;
  end_of_simulation_out <= end_of_simulation;



  -- Stimulus process
  stim_proc : process
  begin
    -- hold reset state for 100 ns.
    wait for 100 ns;

    wait for clk_period*10;

    -- insert stimulus here 
    start <= '1';
    wait for clk_period*1;
    start <= '0';

    wait for clk_period*100000;

       -- insert stimulus here 
    start <= '1';
    wait for clk_period*1;
    start <= '0';

        wait for clk_period*100000;

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
