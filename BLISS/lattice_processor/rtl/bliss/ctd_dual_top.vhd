----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:44:39 02/26/2014 
-- Design Name: 
-- Module Name:    ctd_dual_top - Behavioral 
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
use work.cdt_sampler_pkg.all;



entity PAPER_CDT_SAMPLER_I is
  generic (
    PARAM_SET  : integer := 1;
    MAX_OUTPUT : integer := get_max_sigma(1)
    );
  port (
    clk               : in  std_logic;
    gauss_fifo_full1  : in  std_logic := '1';
    gauss_fifo_wr_en1 : out std_logic;
    gauss_fifo_dout1  : out std_logic_vector(integer(ceil(log2(real(MAX_OUTPUT))))-1+1 downto 0)
    );
end PAPER_CDT_SAMPLER_I;

architecture Behavioral of PAPER_CDT_SAMPLER_I is

  signal gauss_fifo_full  : std_logic := '1';
  signal gauss_fifo_wr_en : std_logic;
  signal gauss_fifo_dout  : std_logic_vector(integer(ceil(log2(real(MAX_OUTPUT))))-1+1 downto 0);
  
begin

  
  
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

  process(clk)
  begin  -- process
    if rising_edge(clk) then
      gauss_fifo_full   <= gauss_fifo_full1;
      gauss_fifo_wr_en1 <= gauss_fifo_wr_en;
      gauss_fifo_dout1  <= gauss_fifo_dout;
    end if;
  end process;

end Behavioral;

