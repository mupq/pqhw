--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:43:35 02/05/2014 
-- Design Name: 
-- Module Name:    bernoulli_gauss_sampler_wrapper - Behavioral 
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


entity large_sigma_gauss_sampler_wrapper is
  generic (
    PARAMETER_SET    : integer  := 1;
    SAMPLER          : string   := "bernoulli";
    --Samples a uniform value between 0 and Sx_MAX
    PRIME_P          : unsigned := to_unsigned(12289, 14);
    --Address generator to fill RAM
    FIFO_ELEMENTS    : integer  := 512;
    GAUSS_SIGMA      : real     := 0.0;
    NUM_BER_SAMPLERS : integer  := 2;
    N_ELEMENTS       : integer  := 512
    -- MAX_PREC         : integer  := 79;
    -- CONST_K          : integer  := 253;
    -- MAX_X            : integer  := 10
    );
  port (
    clk : in std_logic;

    -- #### Control logic ####
    --Sampling can be enabled if ready is high
    ready : out std_logic;
    start : in  std_logic := '0';
    stop  : in  std_logic := '0';

    output_delay : in integer := 1;

    -- #### Output of sampled values ####
    --Output of the first sampler (buffered by FIFO)
    --dout_valid :     std_logic := '0';
    dout : out std_logic_vector(PRIME_P'length-1 downto 0);
    addr : in  std_logic_vector(integer(ceil(log2(real(FIFO_ELEMENTS))))-1 downto 0)
    );
end large_sigma_gauss_sampler_wrapper;


architecture Behavioral of large_sigma_gauss_sampler_wrapper is

  constant LIFO_DEPTH : integer := 2*FIFO_ELEMENTS;

  signal addr_d1  : std_logic_vector(addr'range) := (others => '0');
  signal ready_r1 : std_logic                    := '0';

  signal dout_r1 : std_logic_vector(PRIME_P'range) := (others => '0');

  signal fifo_rd_en        : std_logic                       := '0';
  signal fifo_dout         : std_logic_vector(PRIME_P'range) := (others => '0');
  signal fifo_empty        : std_logic                       := '0';
  signal fifo_almost_empty : std_logic                       := '0';
  signal fifo_valid        : std_logic                       := '0';
  signal fifo_data_count   : std_logic_vector(integer(ceil(log2(real(LIFO_DEPTH))))-1 downto 0);
  signal fifo_full         : std_logic                       := '0';
  signal fifo_almost_full  : std_logic                       := '0';
  
  
begin


  cdt_ber_selector_1 : entity work.cdt_ber_selector
    generic map (
      PARAMETER_SET    => PARAMETER_SET,
      PRIME_P          => PRIME_P,
      LIFO_DEPTH       => LIFO_DEPTH,
      GAUSS_SIGMA      => GAUSS_SIGMA,
      NUM_BER_SAMPLERS => NUM_BER_SAMPLERS,
      SAMPLER          => SAMPLER
      --MAX_PREC => MAX_PREC,
      --CONST_K  => CONST_K,
      --MAX_X   => MAX_X,
      )
    port map (
      clk          => clk,
      full         => fifo_full,
      almost_full  => fifo_almost_full,
      rd_en        => fifo_rd_en,
      dout         => fifo_dout,
      empty        => fifo_empty,
      almost_empty => fifo_almost_empty,
      valid        => fifo_valid,
      data_count   => fifo_data_count
      );

  process(clk)
  begin  -- process c
    if rising_edge(clk) then
      addr_d1 <= addr;

      --FIFO management logic
      ready_r1 <= '0';
      ready    <= ready_r1;
      --if fifo_full = '1' or fifo_almost_full = '1' then
      --  ready_r1 <= '1';
      --end if;

      if to_integer(unsigned(fifo_data_count)) >= N_ELEMENTS then
        ready_r1 <= '1';
      end if;

      fifo_rd_en <= '0';
      if addr_d1 /= addr then
        fifo_rd_en <= '1';
      end if;

      dout_r1 <= fifo_dout;
      dout    <= dout_r1;
      
    end if;
  end process;


end Behavioral;
