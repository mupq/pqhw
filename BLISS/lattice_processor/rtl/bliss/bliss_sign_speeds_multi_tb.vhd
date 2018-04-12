--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/

-- TestBench Template 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.lattice_processor.all;
use work.lyu512_pkg.all;



entity bliss_sign_speeds_multi_tb is
  generic (
    PARAMETER_SET : integer :=1;
    NUMBER_OF_SAMPLERS : integer := 1;
    KECCAK_SLICES      : integer := 32;
    CORES              : integer := 1
    );
end bliss_sign_speeds_multi_tb;

architecture behavior of bliss_sign_speeds_multi_tb is

  signal cycles_per_sig_two_bernoulli : unsigned(40 downto 0) := (others => '0');
  signal error_happened_out_bernoulli         : std_logic             := '0';
  signal end_of_simulation_out_bernoulli      : std_logic             := '0';

  signal cycles_per_sig_one_ccdt_1 : unsigned(40 downto 0) := (others => '0');
  signal error_happened_out_1    : std_logic             := '0';
  signal end_of_simulation_out_1 : std_logic             := '0';

   signal cycles_per_sig_one_ccdt_3 : unsigned(40 downto 0) := (others => '0');
  signal error_happened_out_3    : std_logic             := '0';
  signal end_of_simulation_out_3 : std_logic             := '0';

   signal cycles_per_sig_one_ccdt_4 : unsigned(40 downto 0) := (others => '0');
  signal error_happened_out_4    : std_logic             := '0';
  signal end_of_simulation_out_4 : std_logic             := '0';

  signal cycles_per_sig_one_ccdt_huff : unsigned(40 downto 0) := (others => '0');
  signal error_happened_out_huff    : std_logic             := '0';
  signal end_of_simulation_out_huff : std_logic             := '0';

begin


  

  two_bernoulli : entity work.bliss_sign_speed_tb
    generic map (
      PARAMETER_SET                     => PARAMETER_SET,
      GAUSS_SAMPLER          => "bernoulli_gauss",
      NUM_BER_SAMPLERS => 2,
      KECCAK_SLICES    => 16,
      CORES            => 8
     )
    port map (
      cycles_per_sig        => cycles_per_sig_two_bernoulli,
      error_happened_out    => error_happened_out_bernoulli,
      end_of_simulation_out => end_of_simulation_out_bernoulli
      );

 --one_CCDT1 : entity work.bliss_sign_speed_tb
 --   generic map (
 --     PARAMETER_SET => 1,
 --     GAUSS_SAMPLER       => "dual_cdt_gauss",
 --     KECCAK_SLICES => 16,
 --     CORES         => 8
 --     )
 --   port map (
 --     cycles_per_sig        => cycles_per_sig_one_ccdt_1,
 --     error_happened_out    => error_happened_out_1,
 --     end_of_simulation_out => end_of_simulation_out_1
 --     );
  
 -- one_CCDT3 : entity work.bliss_sign_speed_tb
 --   generic map (
 --     PARAMETER_SET => 3,
 --     GAUSS_SAMPLER       => "dual_cdt_gauss",
 --     KECCAK_SLICES => 16,
 --     CORES         => 8
 --     )
 --   port map (
 --     cycles_per_sig        => cycles_per_sig_one_ccdt_3,
 --     error_happened_out    => error_happened_out_3,
 --     end_of_simulation_out => end_of_simulation_out_3
 --     );


 -- one_CCDT4 : entity work.bliss_sign_speed_tb
 --   generic map (
 --     PARAMETER_SET => 4,
 --     GAUSS_SAMPLER       => "dual_cdt_gauss",
 --     KECCAK_SLICES => 16,
 --     CORES         => 8
 --     )
 --   port map (
 --     cycles_per_sig        => cycles_per_sig_one_ccdt_4,
 --     error_happened_out    => error_happened_out_4,
 --     end_of_simulation_out => end_of_simulation_out_4
 --     );

  --one_CCDT4 : entity work.bliss_sign_speed_tb
  --  generic map (
  --     USE_HUFF => 1,
  --    PARAMETER_SET => 1,
  --    GAUSS_SAMPLER       => "dual_cdt_gauss",
  --    KECCAK_SLICES => 16,
  --    CORES         => 8
  --    )
  --  port map (
  --    cycles_per_sig        => cycles_per_sig_one_ccdt_huff,
  --    error_happened_out    => error_happened_out_huff,
  --    end_of_simulation_out => end_of_simulation_out_huff
  --    );

end;
