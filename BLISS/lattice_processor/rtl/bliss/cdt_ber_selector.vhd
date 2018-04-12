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
-- Create Date:    11:48:09 02/15/2014 
-- Design Name: 
-- Module Name:    bernoulli_gauss_module_multiple_sampler - Behavioral 
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
use work.ber_sampler_pkg.all;

entity cdt_ber_selector is
  generic (
    --USE_CDT            : integer  := 1;
    PARAMETER_SET : integer := 1;
    SAMPLER       : string  := "bernoulli";
    GAUSS_SIGMA   : real    := 215.0;
    LIFO_DEPTH    : integer := 512;

    NUM_BER_SAMPLERS : integer  := 2;
    PRIME_P          : unsigned := to_unsigned(12289, 14)
    );
  port (
    clk          : in  std_logic;
    full         : out std_logic                       := '0';
    almost_full  : out std_logic                       := '0';
    rd_en        : in  std_logic                       := '0';
    dout         : out std_logic_vector(PRIME_P'range) := (others => '0');
    empty        : out std_logic                       := '0';
    almost_empty : out std_logic                       := '0';
    valid        : out std_logic                       := '0';
    data_count   : out std_logic_vector(integer(ceil(log2(real(LIFO_DEPTH))))-1 downto 0)
    );
end cdt_ber_selector;

architecture Behavioral of cdt_ber_selector is

  constant MAX_PREC : integer := get_ber_precision(PARAMETER_SET);
  constant CONST_K  : integer := get_ber_k(PARAMETER_SET);
  constant MAX_X    : integer := get_ber_max_x(PARAMETER_SET);


  constant OUT_PORTS   : integer := NUM_BER_SAMPLERS;
  constant GAUSS_WIDTH : integer := integer(ceil(log2(real(get_max_sigma(PARAMETER_SET)))))+1;  -- integer(ceil(log2(real((CONST_K)*(MAX_X)+CONST_K-1))))+1;
  constant DEPTH       : integer := LIFO_DEPTH;

  signal fifo_wr_en        : std_logic_vector(OUT_PORTS-1 downto 0)   := (others => '0');
  signal fifo_full         : std_logic;
  signal fifo_almost_full  : std_logic;
  signal fifo_rd_en        : std_logic                                := '0';
  signal fifo_dout         : std_logic_vector(GAUSS_WIDTH-1 downto 0) := (others => '0');
  signal fifo_empty        : std_logic                                := '0';
  signal fifo_almost_empty : std_logic                                := '0';
  signal fifo_valid        : std_logic                                := '0';
  signal fifo_data_count   : std_logic_vector(integer(ceil(log2(real(DEPTH))))-1 downto 0);


  signal gauss_fifo_din   : std_logic_vector(OUT_PORTS*GAUSS_WIDTH-1 downto 0) := (others => '0');
  signal gauss_fifo_full  : std_logic_vector(OUT_PORTS-1 downto 0)             := (others => '0');
  signal gauss_fifo_wr_en : std_logic_vector(OUT_PORTS-1 downto 0)             := (others => '0');


  signal cdt_gauss_fifo_din   : std_logic_vector(GAUSS_WIDTH-1 downto 0) := (others => '0');
  signal cdt_gauss_fifo_full  : std_logic_vector(0 downto 0)             := (others => '0');
  signal cdt_gauss_fifo_wr_en : std_logic_vector(0 downto 0)             := (others => '0');
  --   signal cdt_fifo_wr_en        : std_logic_vector(OUT_PORTS-1 downto 0)   := (others => '0');

begin


  full         <= fifo_full;
  almost_full  <= fifo_almost_full;
  fifo_rd_en   <= rd_en;
  empty        <= fifo_empty;
  almost_empty <= fifo_almost_empty;
  valid        <= fifo_valid;
  data_count   <= fifo_data_count;
  dout         <= std_logic_vector(resize(unsigned("0"&fifo_dout), dout'length)) when signed(fifo_dout) >= 0 else std_logic_vector(resize(unsigned(signed("0"&PRIME_P)+resize(signed(fifo_dout), dout'length)), dout'length));




  USE_BER_SAMPLER : if SAMPLER = "bernoulli_gauss" generate
    samplers : for i in 0 to NUM_BER_SAMPLERS-1 generate
      ber_sampler_top_1 : entity work.ber_sampler
        generic map (
          PARAMETER_SET => PARAMETER_SET,
          INIT_VAL      => i
          )
        port map (
          clk              => clk,
          gauss_fifo_full  => gauss_fifo_full(i),
          gauss_fifo_wr_en => gauss_fifo_wr_en(i),
          gauss_fifo_dout  => gauss_fifo_din(GAUSS_WIDTH*i+GAUSS_WIDTH-1 downto GAUSS_WIDTH*i)
          );
    end generate samplers;

    lifo_n_to_1_1 : entity work.lifo_n_to_1
      generic map (
        OUT_PORTS => NUM_BER_SAMPLERS,
        WIDTH     => GAUSS_WIDTH,
        DEPTH     => DEPTH
        )
      port map (
        clk                  => clk,
        din                  => gauss_fifo_din,
        wr_en                => gauss_fifo_wr_en,
        full                 => open,
        almost_full          => gauss_fifo_full,
        rd_en                => fifo_rd_en,
        dout                 => fifo_dout,
        empty                => fifo_empty,
        out_lifo_full        => fifo_full,
        out_lifo_almost_full => fifo_almost_full,
        almost_empty         => fifo_almost_empty,
        data_count           => fifo_data_count,
        valid                => fifo_valid
        );
  end generate USE_BER_SAMPLER;


  USE_CDT_SAMPLER : if SAMPLER = "dual_cdt_gauss" generate
    cdt_sampler_dual_top_1 : entity work.cdt_sampler_dual_top
      generic map (
        PARAM_SET => PARAMETER_SET
        )
      port map (
        clk               => clk,
        gauss_fifo_full1  => cdt_gauss_fifo_full(0),
        gauss_fifo_wr_en1 => cdt_gauss_fifo_wr_en(0),
        gauss_fifo_dout1  => cdt_gauss_fifo_din(GAUSS_WIDTH-1 downto 0)
        );

    
    lifo_n_to_1_1 : entity work.lifo_n_to_1
      generic map (
        OUT_PORTS => 1,
        WIDTH     => GAUSS_WIDTH,
        DEPTH     => DEPTH
        )
      port map (
        clk                  => clk,
        din                  => cdt_gauss_fifo_din,
        wr_en                => cdt_gauss_fifo_wr_en,
        full                 => open,
        almost_full          => cdt_gauss_fifo_full,
        rd_en                => fifo_rd_en,
        dout                 => fifo_dout,
        empty                => fifo_empty,
        out_lifo_full        => fifo_full,
        out_lifo_almost_full => fifo_almost_full,
        almost_empty         => fifo_almost_empty,
        data_count           => fifo_data_count,
        valid                => fifo_valid
        );

  end generate USE_CDT_SAMPLER;




end Behavioral;

