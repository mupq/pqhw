-- TestBench Template 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processor_mul_poly_bench_tb is
end processor_mul_poly_bench_tb;

architecture behavior of processor_mul_poly_bench_tb is

  
  signal   end_of_simulation : std_logic := '0';
  signal   error_happened    : std_logic := '0';
  constant SIMULATIONS       : integer   := 6;

  signal error_vector   : std_logic_vector(SIMULATIONS-1 downto 0) := (others => '0');
  signal sim_fin_vector : std_logic_vector(SIMULATIONS-1 downto 0) := (others => '0');

  signal fullone : std_logic_vector(SIMULATIONS-1 downto 0) := (others => '1');

  type cycles_type is array (SIMULATIONS-1 downto 0) of unsigned(31 downto 0);

  signal cycles : cycles_type := (others => (others => '0'));
  
begin

  processor_pmul_tb_0 : entity work.processor_tb
    generic map (
      XN            => -1,
      N_ELEMENTS    => 128,
      PRIME_P_WIDTH => 17,
      PRIME_P       => to_unsigned(65537, 17),
      PSI           => to_unsigned(141, 17),
      OMEGA         => to_unsigned(19881, 17),
      PSI_INVERSE   => to_unsigned(63213, 17),
      OMEGA_INVERSE => to_unsigned(26942, 17),
      N_INVERSE     => to_unsigned(65025, 17),
      S1_MAX        =>  to_unsigned(65537, 17)--to_unsigned(37011, 16)
      )
    port map (
      cycles              => cycles(0),
      use_rand_input      => '0',
      simulation_runs     => 1,
      simulation_finished => sim_fin_vector(0),
      error_happened      => error_vector(0)
      );

  
  processor_pmul_tb_1 : entity work.processor_tb
    generic map (
      XN            => -1,
      N_ELEMENTS    => 128,
      PRIME_P_WIDTH => 9,
      PRIME_P       => to_unsigned(257, 9),
      PSI           => to_unsigned(3, 9),
      OMEGA         => to_unsigned(9, 9),
      PSI_INVERSE   => to_unsigned(86, 9),
      OMEGA_INVERSE => to_unsigned(200, 9),
      N_INVERSE     => to_unsigned(255, 9),
      S1_MAX        =>to_unsigned(257, 9)-- to_unsigned(10, 4)
      )
    port map (
      cycles              => cycles(1),
      use_rand_input      => '0',
      simulation_runs     => 1,
      simulation_finished => sim_fin_vector(1),
      error_happened      => error_vector(1)
      );

  processor_pmul_tb_2 : entity work.processor_tb
    generic map (
      XN            => -1,
      N_ELEMENTS    => 128,
      PRIME_P_WIDTH => 17,
      PRIME_P       => to_unsigned(65537, 17),
      --PSI           => to_unsigned(141, 17),
      --OMEGA         => to_unsigned(19881, 17),
      --PSI_INVERSE   => to_unsigned(63213, 17),
      --OMEGA_INVERSE => to_unsigned(26942, 17),

      
      PSI           => to_unsigned(282, 17),  
      OMEGA         => to_unsigned(13987, 17),
      
      PSI_INVERSE   => to_unsigned(64375, 17),
      OMEGA_INVERSE => to_unsigned(39504, 17),

      
      N_INVERSE     => to_unsigned(65025, 17),
      S1_MAX        => to_unsigned(65537, 17)--to_unsigned(37011, 16)
      )
    port map (
      cycles              => cycles(2),
      use_rand_input      => '1',
      simulation_runs     => 1,
      simulation_finished => sim_fin_vector(2),
      error_happened      => error_vector(2)
      );

  processor_pmul_tb_3 : entity work.processor_tb
    generic map (
      XN            => -1,
      N_ELEMENTS    => 512,
      PRIME_P_WIDTH => 23,
      PRIME_P       => to_unsigned(8383489, 23),
      PSI           => to_unsigned(42205, 23),
      OMEGA         => to_unsigned(3962357, 23),
      PSI_INVERSE   => to_unsigned(3933218, 23),
      OMEGA_INVERSE => to_unsigned(681022, 23),
      N_INVERSE     => to_unsigned(8367115, 23),
      S1_MAX        =>to_unsigned(8383489, 23) --to_unsigned(37011, 16)
      )
    port map (
      cycles              => cycles(3),
      use_rand_input      => '0',
      simulation_runs     => 1,
      simulation_finished => sim_fin_vector(3),
      error_happened      => error_vector(3)
      );

  
  processor_pmul_tb_4 : entity work.processor_tb
    generic map (
      XN            => -1,
      N_ELEMENTS    => 256,
      PRIME_P_WIDTH => 13,
      PRIME_P       => to_unsigned(7681, 13),
      PSI           => to_unsigned(62, 13),
      OMEGA         => to_unsigned(3844, 13),
      PSI_INVERSE   => to_unsigned(1115, 13),
      OMEGA_INVERSE =>  to_unsigned(6584, 13),
      N_INVERSE     =>  to_unsigned(7651, 13),
            S1_MAX        => to_unsigned(7681, 13)
      )
    port map (
      cycles              => cycles(4),
      use_rand_input      => '0',
      simulation_runs     => 1,
      simulation_finished => sim_fin_vector(4),
      error_happened      => error_vector(4)
      );

end;
