--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:02:09 04/13/2012
-- Design Name:   
-- Module Name:   C:/Users/thomas/SHA/Projekte/poly_FFT/code/poly_fft/bench/fft/fft_mul_poly_benc_tb.vhd
-- Project Name:  poly_fft
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: fft_top
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

entity fft_mul_poly_benc_tb is
end fft_mul_poly_benc_tb;

architecture behavior of fft_mul_poly_benc_tb is

  -- Component Declaration for the Unit Under Test (UUT)


  -- Clock period definitions
  
  signal   end_of_simulation : std_logic := '0';
  signal   error_happened    : std_logic := '0';
  signal   clk               : std_logic;
  constant clk_period        : time      := 10 ns;
  constant SIMULATIONS       : integer   := 7;

  signal error_vector   : std_logic_vector(SIMULATIONS-1 downto 0) := (others => '0');
  signal sim_fin_vector : std_logic_vector(SIMULATIONS-1 downto 0) := (others => '0');

  signal fullone : std_logic_vector(SIMULATIONS-1 downto 0) := (others => '1');

  type cycles_type is array (SIMULATIONS-1 downto 0) of unsigned(31 downto 0);

  signal cycles : cycles_type := (others => (others => '0'));
begin

  poly_mul_top_gen_tb_1 : entity work.poly_mul_top_gen_tb
    generic map (
      XN            => -1,
      N_ELEMENTS    => 512,
      PRIME_P_WIDTH => 23,
      PRIME_P       => to_unsigned(8383489, 23),
      PSI           => to_unsigned(42205, 23),
      OMEGA         => to_unsigned(3962357, 23),
      PSI_INVERSE   => to_unsigned(3933218, 23),
      OMEGA_INVERSE => to_unsigned(681022, 23),
      N_INVERSE     => to_unsigned(8367115, 23)
      )
    port map (
      cycles              => cycles(0),
      use_rand_input      => '1',
      simulation_runs     => 2,
      simulation_finished => sim_fin_vector(0),
      error_happened      => error_vector(0)
      );


  
  poly_mul_top_gen_tb_2 : entity work.poly_mul_top_gen_tb
    generic map (
      XN            => -1,
      N_ELEMENTS    => 128,
      PRIME_P_WIDTH => 9,
      PRIME_P       => to_unsigned(257, 9),
      PSI           => to_unsigned(3, 9),
      OMEGA         => to_unsigned(9, 9),
      PSI_INVERSE   => to_unsigned(86, 9),
      OMEGA_INVERSE => to_unsigned(200, 9),
      N_INVERSE     => to_unsigned(255, 9)
      )
    port map (
      cycles              => cycles(1),
      use_rand_input      => '1',
      simulation_runs     => 1,
      simulation_finished => sim_fin_vector(1),
      error_happened      => error_vector(1)
      );


  
  poly_mul_top_gen_tb_3 : entity work.poly_mul_top_gen_tb
    generic map (
      XN            => -1,
      N_ELEMENTS    => 128,
      PRIME_P_WIDTH => 9,
      PRIME_P       => to_unsigned(257, 9),
      PSI           => to_unsigned(3, 9),
      OMEGA         => to_unsigned(9, 9),
      PSI_INVERSE   => to_unsigned(86, 9),
      OMEGA_INVERSE => to_unsigned(200, 9),
      N_INVERSE     => to_unsigned(255, 9)
      )
    port map (
      a_constant_in       => '1',
      cycles              => cycles(2),
      use_rand_input      => '1',
      simulation_runs     => 2,
      simulation_finished => sim_fin_vector(2),
      error_happened      => error_vector(2)
      );
  poly_mul_top_gen_tb_4 : entity work.poly_mul_top_gen_tb
    generic map (
      XN            => -1,
      N_ELEMENTS    => 512,
      PRIME_P_WIDTH => 23,
      PRIME_P       => to_unsigned(8383489, 23),
      PSI           => to_unsigned(42205, 23),
      OMEGA         => to_unsigned(3962357, 23),
      PSI_INVERSE   => to_unsigned(3933218, 23),
      OMEGA_INVERSE => to_unsigned(681022, 23),
      N_INVERSE     => to_unsigned(8367115, 23)
      )
    port map (
      a_constant_in       => '1',
      cycles              => cycles(3),
      use_rand_input      => '1',
      simulation_runs     => 2,
      simulation_finished => sim_fin_vector(3),
      error_happened      => error_vector(3)
      );


  poly_mul_top_gen_tb_5 : entity work.poly_mul_top_gen_tb
    generic map (
      XN            => -1,
      N_ELEMENTS    => 256,
      PRIME_P_WIDTH => 21,
      PRIME_P       => to_unsigned(1049089, 21),
      PSI           => to_unsigned(2016, 21),
      OMEGA         => to_unsigned(916989, 21),
      PSI_INVERSE   => to_unsigned(998612, 21),
      OMEGA_INVERSE => to_unsigned(739437, 21),
      N_INVERSE     => to_unsigned(1044991, 21)
      )
    port map (
      cycles              => cycles(4),
      use_rand_input      => '1',
      simulation_runs     => 5,
      simulation_finished => sim_fin_vector(4),
      error_happened      => error_vector(4)
      );

  poly_mul_top_gen_tb_6 : entity work.poly_mul_top_gen_tb
    generic map (
      XN            => -1,
      N_ELEMENTS    => 128,
      PRIME_P_WIDTH => 17,
      PRIME_P       => to_unsigned(65537, 17),
      PSI           => to_unsigned(141, 17),
      OMEGA         => to_unsigned(19881, 17),
      PSI_INVERSE   => to_unsigned(63213, 17),
      OMEGA_INVERSE => to_unsigned(26942, 17),
      N_INVERSE     => to_unsigned(65025, 17)
      )
    port map (
      cycles              => cycles(5),
      use_rand_input      => '0',
      simulation_runs     => 4,
      simulation_finished => sim_fin_vector(5),
      error_happened      => error_vector(5)
      );

   poly_mul_top_gen_tb_7 : entity work.poly_mul_top_gen_tb
    generic map (
      XN            => -1,
      N_ELEMENTS    => 256,
      PRIME_P_WIDTH => 13,
      PRIME_P       => to_unsigned(7681, 13),
      PSI           => to_unsigned(62, 13),
      OMEGA         => to_unsigned(3844, 13),
      PSI_INVERSE   => to_unsigned(1115, 13),
      OMEGA_INVERSE =>  to_unsigned(6584, 13),
      N_INVERSE     =>  to_unsigned(7651, 13)
      )
    port map (
      cycles              => cycles(5),
      use_rand_input      => '0',
      simulation_runs     => 4,
      simulation_finished => sim_fin_vector(6),
      error_happened      => error_vector(6)
      ); 


  --poly_mul_top_gen_tb_7 : entity work.poly_mul_top_gen_tb
  --  generic map (
  --    XN            => -1,
  --    N_ELEMENTS    => 256,
  --    PRIME_P_WIDTH => 17,
  --    PRIME_P       => to_unsigned(65537, 17),
  --    PSI           => to_unsigned(157, 17),
  --    OMEGA         => to_unsigned(24649, 17),
  --    PSI_INVERSE   => to_unsigned(12523, 17),
  --    OMEGA_INVERSE => to_unsigned(61025, 17),
  --    N_INVERSE     => to_unsigned(65281, 17)
  --    )
  --  port map (
  --    cycles              => cycles(6),
  --    use_rand_input      => '1',
  --    simulation_runs     => 4,
  --    simulation_finished => sim_fin_vector(6),
  --    error_happened      => error_vector(6)
  --    );


  --poly_mul_top_gen_tb_8 : entity work.poly_mul_top_gen_tb
  --  generic map (
  --    XN            => -1,
  --    N_ELEMENTS    => 1024,
  --    PRIME_P_WIDTH => 30,
  --    PRIME_P       => to_unsigned(1061093377, 30),
  --    PSI           => to_unsigned(248390058, 30),
  --    OMEGA         => to_unsigned(591137462, 30),
  --    PSI_INVERSE   => to_unsigned(457488391, 30),
  --    OMEGA_INVERSE => to_unsigned(541153008, 30),
  --    N_INVERSE     => to_unsigned(1060057153, 30)
  --    )
  --  port map (
  --    cycles              => cycles(7),
  --    use_rand_input      => '1',
  --    simulation_runs     => 4,
  --    simulation_finished => sim_fin_vector(7),
  --    error_happened      => error_vector(7)
  --    );

  ----poly_mul_top_gen_tb_9 : entity work.poly_mul_top_gen_tb
  ----  generic map (
  ----    XN            => -1,
  ----    N_ELEMENTS    => 1024,
  ----    PRIME_P_WIDTH => 58,
  ----    PRIME_P       => (to_unsigned(1, 58)sll 13)+(to_unsigned(1, 58)sll 16)+(to_unsigned(1, 58)sll 17)+(to_unsigned(1, 58)sll 57)+(to_unsigned(1, 58)),
  ----    --65170666404517193 = 13 * 5013128184962861
  ----    PSI           => (to_unsigned(13, 58)) *((to_unsigned(50131281, 58))*to_unsigned(100000000, 58)
  ----                                       +(to_unsigned(84962861, 58))),
  ----    OMEGA         => (to_unsigned(2, 58))*(to_unsigned(29, 58))*(to_unsigned(773, 58))*((to_unsigned(15463884, 58)*to_unsigned(10000, 58)+to_unsigned(6647, 58))),

  ----    PSI_INVERSE   => (to_unsigned(2, 58))*(to_unsigned(3, 58))*(to_unsigned(263, 58))*(to_unsigned(2953, 58))*(to_unsigned(833874, 58)*to_unsigned(10000, 58)+to_unsigned(1199, 58)),
  ----    --92987935635157983 = 3^2 * 7 * 17 * 491 * 176829876403
  ----    OMEGA_INVERSE => to_unsigned(3**2, 58) * to_unsigned(7, 58)*to_unsigned(17, 58)*to_unsigned(491, 58)*
  ----    ((to_unsigned(1768298, 58)*to_unsigned(100000, 58)+to_unsigned(76403, 58))),
  ----    --143974450587705145 = 5 * 4159 * 261061 * 26520671
  ----    N_INVERSE     => resize(to_unsigned(5, 58)*to_unsigned(4159, 58)*to_unsigned(261061, 58)*to_unsigned(26520671, 58), 58)
  ----    )
  ----  port map (
  ----    cycles              => cycles(8),
  ----    use_rand_input      => '0',
  ----    simulation_runs     => 4,
  ----    simulation_finished => sim_fin_vector(8),
  ----    error_happened      => error_vector(8)
  ----    );



  ------DANGER PARAMETR CHANGES
  --poly_mul_top_gen_tb_9 : entity work.poly_mul_top_gen_tb
  --  generic map (
  --    XN            => -1,
  --    N_ELEMENTS    => 1024,
  --    PRIME_P_WIDTH => 58,

  --    PRIME_P       => (to_unsigned(1, 58)sll 13)+(to_unsigned(1, 58)sll 16)+(to_unsigned(1, 58)sll 17)+(to_unsigned(1, 58)sll 57)+(to_unsigned(1, 58)),
  --    --65170666404517193 = 13 * 5013128184962861
  --    PSI           => (to_unsigned(13, 58)) *((to_unsigned(50131281, 58))*to_unsigned(100000000, 58)
  --                                       +(to_unsigned(84962861, 58))),
  --    OMEGA         => (to_unsigned(2, 58))*(to_unsigned(29, 58))*(to_unsigned(773, 58))*((to_unsigned(15463884, 58)*to_unsigned(10000, 58)+to_unsigned(6647, 58))),
  --    PSI_INVERSE   => (to_unsigned(2, 58))*(to_unsigned(3, 58))*(to_unsigned(263, 58))*(to_unsigned(2953, 58))*(to_unsigned(833874, 58)*to_unsigned(10000, 58)+to_unsigned(1199, 58)),
  --    --92987935635157983 = 3^2 * 7 * 17 * 491 * 176829876403
  --    OMEGA_INVERSE => to_unsigned(3**2, 58) * to_unsigned(7, 58)*to_unsigned(17, 58)*to_unsigned(491, 58)*
  --    ((to_unsigned(1768298, 58)*to_unsigned(100000, 58)+to_unsigned(76403, 58))),
  --    --143974450587705145 = 5 * 4159 * 261061 * 26520671
  --    N_INVERSE     => resize(to_unsigned(5, 58)*to_unsigned(4159, 58)*to_unsigned(261061, 58)*to_unsigned(26520671, 58), 58)
  --    )
  --  port map (
  --    cycles              => cycles(8),
  --    use_rand_input      => '0',
  --    simulation_runs     => 4,
  --    simulation_finished => sim_fin_vector(8),
  --    error_happened      => error_vector(8)
  --    );


  --poly_mul_top_gen_tb_10 : entity work.poly_mul_top_gen_tb
  --  generic map (
  --    XN            => -1,
  --    N_ELEMENTS    => 2048,
  --    PRIME_P_WIDTH => 30,
  --    PRIME_P       => to_unsigned(1061093377, 30),
  --    PSI           => to_unsigned(335836596, 30),
  --    OMEGA         => to_unsigned(248390058, 30),


  --    PSI_INVERSE   => to_unsigned(542388543, 30),
  --    OMEGA_INVERSE => to_unsigned(457488391, 30),

  --    N_INVERSE => to_unsigned(1060575265, 30)
  --    )
  --  port map (
  --    cycles              => cycles(9),
  --    use_rand_input      => '1',
  --    simulation_runs     => 4,
  --    simulation_finished => sim_fin_vector(9),
  --    error_happened      => error_vector(9)
  --    );



  
  --poly_mul_top_gen_tb_11 : entity work.poly_mul_top_gen_tb
  --  generic map (
  --    XN            => -1,
  --    N_ELEMENTS    => 512,
  --    PRIME_P_WIDTH => 23,
  --    PRIME_P       => to_unsigned(5941249, 23),
  --    PSI           => to_unsigned(19475, 23),
  --    OMEGA         => to_unsigned(4976938, 23),
  --    PSI_INVERSE   => to_unsigned(99453, 23),
  --    OMEGA_INVERSE => to_unsigned(4660873, 23),
  --    N_INVERSE     => to_unsigned(5929645, 23)
  --    )
  --  port map (
  --    cycles              => cycles(10),
  --    use_rand_input      => '0',
  --    simulation_runs     => 4,
  --    simulation_finished => sim_fin_vector(10),
  --    error_happened      => error_vector(10)
  --    );




  -- Clock process definitions
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
    if end_of_simulation = '1' then
      wait;
    end if;
  end process;

  -- Stimulus process
  stim_proc : process
  begin
    -- hold reset state for 100 ns.
    wait for 100 ns;

    if unsigned(error_vector) /= 0 then
      error_happened <= '1';
    end if;


    if sim_fin_vector = fullone then
      
      wait for 100000 ns;

      if unsigned(error_vector) = 0 then
        report "OK" severity note;
      else
        report "ERROR" severity note;
      end if;

      end_of_simulation <= '1';

      wait;
    end if;

    
    
    
    
  end process;

end;
