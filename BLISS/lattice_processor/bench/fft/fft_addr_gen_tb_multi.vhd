--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:17:59 03/19/2012
-- Design Name:   
-- Module Name:   C:/Users/thomas/SHA/Projekte/poly_FFT/code/poly_fft/bench/fft/fft_addr_gen_tb_multi.vhd
-- Project Name:  poly_fft
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: fft_addr_gen
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

entity fft_addr_gen_tb_multi is
end fft_addr_gen_tb_multi;

architecture behavior of fft_addr_gen_tb_multi is


begin
  uut1 : entity work.fft_addr_gen_tb
    generic map (
      N_ELEMENTS => 16
      );

  uut2 : entity work.fft_addr_gen_tb
    generic map (
      N_ELEMENTS => 512
      );


  uut3 : entity work.fft_addr_gen_tb
    generic map (
      N_ELEMENTS => 128
      );



end;
