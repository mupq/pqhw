--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lattice_processor.all;
use ieee.math_real.all;
use work.lyu512_pkg.all;



entity bliss_processor_tb is
  port (
    error_happened_out    : out std_logic := '0';
    end_of_simulation_out : out std_logic := '0'
    );

end bliss_processor_tb;

architecture behavior of bliss_processor_tb is
  signal end_of_simulation : std_logic := '0';
  signal error_happened    : std_logic := '0';


-- Clock period definitions
  constant clk_period : time := 10 ns;
  signal   clk        : std_logic;

  signal data_avail  : std_logic                                           := '0';
  signal copy_data   : std_logic                                           := '0';
  signal data_copied : std_logic                                           := '0';
  signal data_out    : std_logic_vector(13 downto 0)                       := (others => '0');
  signal addr_out    : std_logic_vector(8 downto 0)                        := (others => '0');
  signal we_ayy      : std_logic                                           := '0';
  signal we_y1       : std_logic                                           := '0';
  signal we_y2       : std_logic                                           := '0';
  signal ver_rd_fin  : std_logic                                           := '0';
  signal command     : std_logic_vector(LYU_ARITH_COMMAND_SIZE-1 downto 0) := LYU_ARITH_SIGN_MODE;
  signal finished    : std_logic                                           := '0';
  signal data_in     : std_logic_vector(13 downto 0)                       := (others => '0');
  signal addr_in     : std_logic_vector(8 downto 0)                        := (others => '0');

begin


  -- Clock process definitions
  clk_process : process
  begin
    if end_of_simulation = '0' then
      clk <= '0';
      wait for clk_period/2;
      clk <= '1';
      wait for clk_period/2;
    end if;
  end process;
  end_of_simulation_out <= end_of_simulation;



  bliss_processor_1 : entity work.bliss_processor
    generic map (
      MODE => "BOTH"
      )
    port map (
      clk         => clk,
      data_avail  => data_avail,
      copy_data   => copy_data,
      data_copied => data_copied,
      data_out    => data_out,
      addr_out    => addr_out,
      we_ayy      => we_ayy,
      we_y1       => we_y1,
      we_y2       => we_y2,
      ver_rd_fin  => ver_rd_fin,
      command     => command,
      finished    => finished,
      data_in     => data_in,
      addr_in     => addr_in
      );


  --signal fsm_arith_command : std_logic_vector(LYU_ARITH_COMMAND_SIZE-1 downto 0) := LYU_ARITH_SIGN_MODE;



  -- Stimulus process
  stim_proc : process
  begin
    -- hold reset state for 100 ns.
    wait for 100 ns;

    wait for clk_period*100;


    while data_avail = '0' loop
      wait for clk_period;
    end loop;

    wait for clk_period;
    wait for clk_period;
    wait for clk_period;
    copy_data <= '1';
    wait for clk_period;
    copy_data <= '0';

    wait for clk_period*50;

    while data_avail = '0' loop
      wait for clk_period;
    end loop;

    wait for clk_period;
    wait for clk_period;
    wait for clk_period;
    copy_data <= '1';
    wait for clk_period;
    copy_data <= '0';


    wait for clk_period*50;

    while data_avail = '0' loop
      wait for clk_period;
    end loop;

    wait for clk_period;
    wait for clk_period;
    wait for clk_period;
    copy_data <= '1';
    wait for clk_period;
    copy_data <= '0';

    wait for clk_period*50;

    while data_avail = '0' loop
      wait for clk_period;
    end loop;

    wait for clk_period;
    wait for clk_period;
    wait for clk_period;
    copy_data <= '1';
    wait for clk_period;
    copy_data <= '0';

    wait for clk_period*100000;



    if error_happened = '1' then
      report "ERROR";
    else
      report "OK";
    end if;

    end_of_simulation <= '1';
    wait;

  end process;
  
end behavior;
