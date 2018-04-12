----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:02:53 02/28/2014 
-- Design Name: 
-- Module Name:    PAPER_BERNOULLI_SAMPLER - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.ber_sampler_pkg.all;


entity PAPER_BERNOULLI_SAMPLER_I is
  generic (
    PARAMETER_SET : integer := 1
    );

  port (
    clk              : in  std_logic;
    gauss_fifo_full  : in  std_logic := '0';
    gauss_fifo_wr_en : out std_logic;
    gauss_fifo_dout  : out std_logic_vector(integer(ceil(log2(real(get_ber_max_sigma(PARAMETER_SET)))))-1+1 downto 0)
    );
end PAPER_BERNOULLI_SAMPLER_I;



architecture Behavioral of PAPER_BERNOULLI_SAMPLER_I is
  signal gauss_fifo_full1  : std_logic := '0';
  signal gauss_fifo_wr_en1 : std_logic;
  signal gauss_fifo_dout1  : std_logic_vector(integer(ceil(log2(real(get_ber_max_sigma(PARAMETER_SET)))))-1+1 downto 0);
  
begin


  gauss_fifo_full1 <= gauss_fifo_full;
  gauss_fifo_wr_en <= gauss_fifo_wr_en1;
  gauss_fifo_dout  <= gauss_fifo_dout1;

  gauss_sampler_1 : entity work.ber_sampler
    generic map (
      PARAMETER_SET => PARAMETER_SET
      )
    port map (
      clk              => clk,
      gauss_fifo_full  => gauss_fifo_full1,
      gauss_fifo_wr_en => gauss_fifo_wr_en1,
      gauss_fifo_dout  => gauss_fifo_dout1
      );


end Behavioral;

