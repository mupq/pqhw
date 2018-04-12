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
-- Create Date:   08:55:32 02/24/2014
-- Design Name:   
-- Module Name:   C:/Users/thomas/SHA/Projekte/BLISS/code/bliss_arithmetic/lattice_processor/cdt_sampler_dual_tb.vhd
-- Project Name:  lattice_processor
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: cdt_sampler_dual
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



entity cdt_sampler_dual_tb is
  generic (
    PARAM_SET : integer := 1
    );
  port (
    error_happened_out    : out std_logic := '0';
    end_of_simulation_out : out std_logic := '0'
    );
end cdt_sampler_dual_tb;

architecture behavior of cdt_sampler_dual_tb is
 
                         
 constant MAX_INDEX      : integer := get_cdt_max_index(PARAM_SET);
  constant MAX_BYTE_TABLE : integer := get_cdt_max_byte_table(PARAM_SET);
  constant MAX_BYTE       : integer := get_cdt_max_byte(PARAM_SET);
 
 signal end_of_simulation : std_logic := '0';
  signal error_happened    : std_logic := '0';

  --Inputs
  signal clk               : std_logic;
  signal gauss_fifo_full1  : std_logic                                                           := '1';
  signal gauss_fifo_wr_en1 : std_logic                                                           := '0';
  signal gauss_fifo_dout1  : std_logic_vector(integer(ceil(log2(real(MAX_INDEX))))-1+1 downto 0) := (others => '0');
  signal rand1_position    : std_logic_vector(6 downto 0)                                        := (others => '0');
  signal gauss_fifo_full2  : std_logic                                                           := '1';
  signal gauss_fifo_wr_en2 : std_logic                                                           := '0';
  signal gauss_fifo_dout2  : std_logic_vector(integer(ceil(log2(real(MAX_INDEX))))-1+1 downto 0) := (others => '0');
  signal rand2_position    : std_logic_vector(6 downto 0)                                        := (others => '0');
  signal rand1_addr_in     : std_logic_vector(6 downto 0)                                        := (others => '0');
  signal rand1_we          : std_logic                                                           := '0';
  signal rand1_din         : std_logic_vector(7 downto 0)                                        := (others => '0');
  signal rand2_addr_in     : std_logic_vector(6 downto 0)                                        := (others => '0');
  signal rand2_we          : std_logic                                                           := '0';
  signal rand2_din         : std_logic_vector(7 downto 0)                                        := (others => '0');

  -- Clock period definitions
  constant clk_period : time := 10 ns;
  --type     vector_type is array (0 to 18) of integer;
 type     vector_type is array (0 to 19) of integer;
 
  --constant tv : std_logic_vector := x"67297cc2765a663225ab0e82703e8f3832";
  --constant tv : std_logic_vector := x"67297cc2765a663225ab0e82703e8f3832af021afb75a805efca1f14733baad433bb0be1f898bcacbe";

  constant tv : std_logic_vector := x"67cd546331e954873e383c5443053cf9f1e5ca1f7364f2";
 constant res : vector_type := (22, 7, 26, 23, 35, 3, 26, 17, 31, 33, 32, 30, 62, 1, 2, 3, 41, 20, 23, 2);

 --constant tv : std_logic_vector := x"c251e5baab5e3231bb1057be29110109670ccf973ea8fd7f969e7c28";
 --constant res : vector_type := (8, 27, 3, 11, 24, 34, 9, 49, 9, 37, 49, 56, 52, 14, 31, 12, 0, 18, 14, 19);
 
 --constant tv : std_logic_vector := x"ece0d45514d53b1b7e00";


 --constant tv : std_logic_vector := x"e5bafdf2fca3defef0f5f5f4c2e0e4f4c1f8e4edefedeb";
 --constant res : vector_type := (3, 0, 2, 0, 4, 0, 2, 1, 1, 1, 4, 4, 1, 1, 4, 2, 2, 2, 3);
                         


 

  
begin
  cdt_sampler_dual_1 : entity work.cdt_sampler_dual
      port map (
      clk               => clk,
      gauss_fifo_full1  => gauss_fifo_full1,
      gauss_fifo_wr_en1 => gauss_fifo_wr_en1,
      gauss_fifo_dout1  => gauss_fifo_dout1,
      rand1_position    => rand1_position,
      gauss_fifo_full2  => gauss_fifo_full2,
      gauss_fifo_wr_en2 => gauss_fifo_wr_en2,
      gauss_fifo_dout2  => gauss_fifo_dout2,
      rand2_position    => rand2_position,
      rand1_addr_in     => rand1_addr_in,
      rand1_we          => rand1_we,
      rand1_din         => rand1_din,
      rand2_addr_in     => rand2_addr_in,
      rand2_we          => rand2_we,
      rand2_din         => rand2_din
      );


  -- Clock process definitions
  clk_process : process
  begin
    if end_of_simulation='0' then
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;   
    end if;
  end process;


  -- Stimulus process
  stim_proc : process
    variable j : integer := 0;
  begin
    -- hold reset state for 100 ns.
    wait for 100 ns;

    wait for clk_period*10;

    for i in tv'length/8-1 downto 0 loop
      rand1_addr_in <= std_logic_vector(to_unsigned(tv'length/8-1-i, rand1_addr_in'length));
      rand1_we      <= '1';
      rand1_din     <= std_logic_vector(resize(unsigned(tv) srl i*8, rand1_din'length));
      wait for clk_period;
    end loop;  -- i
    rand1_we <= '0';

    wait for clk_period*20;

    gauss_fifo_full1 <= '0';


    while j <res'length  loop
      while gauss_fifo_wr_en1= '0' loop
        wait for clk_period;
      end loop;

      if to_integer(unsigned(gauss_fifo_dout1)) /=res(j) then
        error_happened <= '1';
      end if;
      j:=j+1;
       wait for clk_period;
    end loop;


    if error_happened = '1' then
      report "ERROR";
    else
      report "OK";
    end if;

    end_of_simulation <= '1';
    wait;

    -- insert stimulus here 

    wait;
  end process;

end;
