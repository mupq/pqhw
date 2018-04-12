--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:44:21 03/15/2012
-- Design Name:   
-- Module Name:   C:/Users/thomas/SHA/Projekte/poly_FFT/code/poly_fft/bench/fft/fft_mar_tb_multi.vhd
-- Project Name:  poly_fft
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: fft_mar
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

entity fft_mar_tb_multi is
end fft_mar_tb_multi;

architecture behavior of fft_mar_tb_multi is


begin
  fft_mar_tb_c_8383489 : entity work.fft_mar_tb_c
    generic map(
      tb_data_width => 23,
      tb_prime      => 8383489
      );


  fft_mar_tb_c_17 : entity work.fft_mar_tb_c
    generic map(
      tb_data_width => 5,
      tb_prime      => 17
      );


  
  fft_mar_tb_c_257 : entity work.fft_mar_tb_c
    generic map(
      tb_data_width => 9,
      tb_prime      => 257
      );






end;
