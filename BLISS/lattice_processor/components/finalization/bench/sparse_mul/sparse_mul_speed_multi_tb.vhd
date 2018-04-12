--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/



--Obtain runtime (cycles) of sparse mul core 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity sparse_mul_speed_multi_tb is
   generic (
    --FFT and general configuration
    N_ELEMENTS    : integer               := 512;
    KAPPA         : integer               := 23;
    WIDTH_S1      : integer               := 2;
    WIDTH_S2      : integer               := 3;
    --Used to initialize the right s (s1 or s2)
    INIT_TABLE    : integer               := 0;
    c_delay       : integer range 0 to 16 := 2;
    MAX_RES_WIDTH : integer               := 6
    );
end sparse_mul_speed_multi_tb;

architecture behavior of sparse_mul_speed_multi_tb is
  
constant MAX_CORES : integer := 6;
type     ram_type is array (0 to MAX_CORES) of integer;
signal cycles :ram_type ;--:=(others =>(others => '0'));

signal end_of_simulation : std_logic_vector(MAX_CORES downto 0);
begin

  cores_test : for i in 0 to MAX_CORES-1 generate
    sparse_mul_speed_tb_1 : entity work.sparse_mul_speed_tb
      generic map (
        CORES         => 2**i,
        N_ELEMENTS    => N_ELEMENTS,
        KAPPA         => KAPPA,
        WIDTH_S1      => WIDTH_S1,
        WIDTH_S2      => WIDTH_S2,
        INIT_TABLE    => INIT_TABLE,
        c_delay       => c_delay,
        MAX_RES_WIDTH => MAX_RES_WIDTH
        )
      port map (
        cycles_out            => cycles(i),
        --error_happened_out    => error_happened_out,
        end_of_simulation_out => end_of_simulation(i)
        );

  end generate cores_test;
  
end;
