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
-- Create Date:   12:49:36 02/24/2014
-- Design Name:   
-- Module Name:   C:/Users/thomas/SHA/Projekte/BLISS/code/bliss_arithmetic/lattice_processor/cdt_dual_sampler_top_tb.vhd
-- Project Name:  lattice_processor
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: cdt_sampler_dual_top
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
use work.cdt_sampler_pkg.all;
use work.ber_sampler_pkg.all;



entity test_gaussian_sampler_tb is
  generic (
    MAX_RUNS        : integer := 5000000;
    UPDATE_INTERVAL : integer := 50000;
    --SAMPLER         : string  := "dual_cdt_gauss";  --bernoulli_gauss";  --"none", "bernoulli_gauss", "dual_cdt_gauss"
    SAMPLER         : string  :="bernoulli_gauss";  --"none", "bernoulli_gauss", "dual_cdt_gauss"
    PARAM_SET       : integer := 1      --Bliss 1,2,3,4
    );
  port (
    std_deviation          : out real;
    computed_mean          : out real;
    computed_std_deviation : out real;
    computed_distance      : out real;
    cycles_per_sample      : out real
    );
end test_gaussian_sampler_tb;

architecture behavior of test_gaussian_sampler_tb is
  constant MAX_OUTPUT : integer := get_max_sigma(PARAM_SET);


  -- Component Declaration for the Unit Under Test (UUT)

  signal clk : std_logic;

  signal gauss_fifo_full  : std_logic := '0';
  signal gauss_fifo_wr_en : std_logic;
  signal gauss_fifo_dout  : std_logic_vector(integer(ceil(log2(real(MAX_OUTPUT))))-1+1 downto 0);

  signal gauss_fifo_dout_ber : std_logic_vector(integer(ceil(log2(real((get_ber_max_sigma(PARAM_SET))))))-1+1 downto 0);



  -- Clock period definitions
  constant clk_period : time := 10 ns;

  signal end_of_simulation : std_logic := '0';

  --Test the distribution
  type vector_type is array (-MAX_OUTPUT to MAX_OUTPUT) of real;

  signal values       : vector_type := (others => real(0));
  signal probs        : vector_type := (others => real(0));
  signal probs_target : vector_type := (others => real(0));

  signal output_counter   : integer := 0;
  signal interval_counter : integer := 0;

  constant CONST_K : integer := 253;
  constant MAX_X   : integer := 10;

  signal target_std_deviation : real    := 0.0;
  signal cycle_cnt            : integer := 0;
  signal gauss_cnt            : integer := 0;

  
begin


  dual_cdt_gauss : if SAMPLER = "dual_cdt_gauss" generate
    target_std_deviation <= get_sigma(PARAM_SET);
    cdt_sampler_dual_top_1 : entity work.cdt_sampler_dual_top
      generic map (
        PARAM_SET => PARAM_SET
        )
      port map (
        clk               => clk,
        gauss_fifo_full1  => gauss_fifo_full,
        gauss_fifo_wr_en1 => gauss_fifo_wr_en,
        gauss_fifo_dout1  => gauss_fifo_dout
        );
  end generate dual_cdt_gauss;


  dual_cdt_gauss_single : if SAMPLER = "dual_cdt_gauss_single" generate
    target_std_deviation <= get_sigma(PARAM_SET)/SQRT(1.0+ real(get_get_mul_factor(PARAM_SET))**2.0);
    cdt_sampler_dual_top_1 : entity work.cdt_sampler_dual_top
      generic map (
        PARAM_SET => PARAM_SET
        )
      port map (
        clk                       => clk,
        gauss_fifo_full1          => '0',
        cdt_gauss_fifo_wr_en1_out => gauss_fifo_wr_en,
        cdt_gauss_fifo_dout1_out  => gauss_fifo_dout
        );
  end generate dual_cdt_gauss_single;



  bernoulli_sampler : if SAMPLER = "bernoulli_gauss" generate
    target_std_deviation <= get_sigma(PARAM_SET);
    gauss_fifo_dout      <= std_logic_vector(resize(signed(gauss_fifo_dout_ber), gauss_fifo_dout'length));
    ber_sampler_1 : entity work.ber_sampler
      generic map (
        PARAMETER_SET => PARAM_SET
        )
      port map (
        clk              => clk,
        gauss_fifo_full  => gauss_fifo_full,
        gauss_fifo_wr_en => gauss_fifo_wr_en,
        gauss_fifo_dout  => gauss_fifo_dout_ber
        );

  end generate bernoulli_sampler;


  -- Clock process definitions
  clk_process : process
  begin
    if end_of_simulation = '0' then
      clk <= '0';
      wait for clk_period/2;
      clk <= '1';
      if output_counter > 10000 then
        cycle_cnt <= cycle_cnt+1;
      end if;
      wait for clk_period/2;
    else
      clk <= '0';
    end if;
  end process;


  process(clk)
  begin  -- process
    if rising_edge(clk) then
      if gauss_fifo_wr_en = '1' and output_counter > 10000 then
        gauss_cnt <= gauss_cnt+1;
      end if;
    end if;
  end process;

  -- Stimulus process
  stim_proc : process

    variable mean : real := 0.0;
    variable var  : real := 0.0;
    variable dist : real := 0.0;

  begin
    -- hold reset state for 100 ns.
    wait for 100 ns;




    wait for clk_period*10;
    gauss_fifo_full <= '0';

    --Wait a bit so that init values get out
    wait for clk_period*70000;


    --Compute prograbilities
    for i in values'left+1 to values'right-1 loop
      probs_target(i) <= get_gauss_prob(real(i), target_std_deviation);
      wait for clk_period;
    end loop;  -- i



    while (output_counter < MAX_RUNS) loop
      interval_counter <= 0;
      while (interval_counter < UPDATE_INTERVAL) loop
        if gauss_fifo_wr_en = '1' and output_counter < MAX_RUNS then
          interval_counter                              <= interval_counter+1;
          output_counter                                <= output_counter+1;
          values((to_integer(signed(gauss_fifo_dout)))) <= values((to_integer(signed(gauss_fifo_dout))))+real(1);
        end if;
        wait for clk_period;
      end loop;


      ---------------------------------------------------------------------------
      -- Now the sampling is finished and we do the evaluation
      ---------------------------------------------------------------------------
      wait for clk_period*1000;
      var  := 0.0;
      mean := 0.0;
      dist := 0.0;
      wait for clk_period;


      ----Compute the means
      --for i in 0 to values'length-1 loop
      for i in values'left+1 to values'right-1 loop
        mean := mean + values(i)*real(i);
      end loop;  -- i
      mean := mean / real(output_counter);

      --for i in values'left+1 to values'right-1 loop
      for i in values'left+1 to values'right-1 loop
        var := var + real(values(i))*(real(i)-mean)*(real(i)-mean);
      end loop;  -- i

      var := SQRT(var/(real(output_counter)-1.0));  --corrected sample standard deviation

      computed_std_deviation <= var;
      computed_mean          <= mean;
      cycles_per_sample      <= real(cycle_cnt)/real(gauss_cnt);

      --Compute: Total variation distance of probability measures
      -- 1/2*\sum_{i}|(P(i)-Q(i))|
      for i in values'left+1 to values'right-1 loop
        dist := dist + get_absolute(values(i)/real(output_counter) - probs_target(i));
      end loop;  -- i
      dist              := dist/2.0;
      computed_distance <= dist;

      
    end loop;  -- i

    wait for clk_period*1000;


    --Now compute the probabilities
    for i in values'left+1 to values'right-1 loop
      probs(i) <= values(i)/real(output_counter);
    end loop;  -- i

    wait for clk_period*1000;
    report "End of Simulation";
    end_of_simulation <= '1';


    wait;
  end process;

end;
