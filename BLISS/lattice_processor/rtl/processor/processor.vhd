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
-- Create Date:    18:50:26 11/29/2012 
-- Design Name: 
-- Module Name:    processor - Behavioral 
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
use work.lattice_processor.all;
use ieee.math_real.all;


-- This is the core unit implementing operations on polynomials
entity processor is
  generic (
    PARAMETER_SET :integer :=1;
     INIT_ARRAY_VALUE_FFT: integer:=0;
    --FFT and general configuration
    MODE             : string     := "BOTH";
    SAMPLER          : string     := "uniform";
    GAUSS_SIGMA      : real       := 0.0;
    XN               : integer    := -1;  --ring (-1 or 1)
    N_ELEMENTS       : integer    := 32;
    PRIME_P_WIDTH    : integer    := 5;
    NUM_BER_SAMPLERS : integer    := 2;
    PRIME_P          : unsigned;
    PSI              : unsigned;
    OMEGA            : unsigned;
    PSI_INVERSE      : unsigned;
    OMEGA_INVERSE    : unsigned;
    N_INVERSE        : unsigned;
    --RAM configuration
    RAMS             : integer    := 2;
    INIT_ARRAY       : init_array_t;
    RAM_WIDTHs       : my_array_t := (10, 10, 10, 10, 23, 10, 10, 10, 10, 10)
    );
  port (
    clk : in std_logic;

    -- Control ports
    proc_ready : out std_logic                                   := '0';
    proc_start : in  std_logic                                   := '0';
    proc_op    : in  std_logic_vector(PROC_INST_SIZE-1 downto 0) := (others => '0');
    proc_arg0  : in  std_logic_vector(PROC_ARG1_SIZE-1 downto 0) := (others => '0');
    proc_arg1  : in  std_logic_vector(PROC_ARG2_SIZE-1 downto 0) := (others => '0');

    -- Port for the I/O RAM
    io_rd_addr   : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    io_rd_do     : in  std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');
    io_req_delay : out integer;

    io_wr_addr : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    io_wr_di   : out std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');
    io_wr_we   : out std_logic


    );
end processor;

architecture Behavioral of processor is
  constant ADDR_WIDTH    : integer := integer(ceil(log2(real(N_ELEMENTS))));
  constant COL_WIDTH     : integer := PRIME_P_WIDTH;
  constant MAX_RAM_WIDTH : integer := PRIME_P_WIDTH;

  --Super Memory
  signal smem_rd_p1_addr        : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal smem_rd_p1_do          : std_logic_vector(MAX_RAM_WIDTH-1 downto 0) := (others => '0');
  signal smem_rd_p2_addr        : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal smem_rd_p2_do          : std_logic_vector(MAX_RAM_WIDTH-1 downto 0) := (others => '0');
  signal smem_wr_p1_addr        : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal smem_wr_p1_di          : std_logic_vector(MAX_RAM_WIDTH-1 downto 0) := (others => '0');
  signal smem_wr_p1_we          : std_logic;
  signal smem_rd_p1_ctl         : unsigned(3 downto 0)                       := (others => '0');
  signal smem_rd_p2_ctl         : unsigned(3 downto 0)                       := (others => '0');
  signal smem_wr_p1_ctl         : unsigned(3 downto 0)                       := (others => '0');
  signal smem_stable            : std_logic                                  := '0';
  signal smem_fft_ram0_rd_addr  : std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
  signal smem_fft_ram0_rd_do    : std_logic_vector(MAX_RAM_WIDTH-1 downto 0) := (others => '0');
  signal smem_fft_ram0_wr_addr  : std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
  signal smem_fft_ram0_wr_di    : std_logic_vector(MAX_RAM_WIDTH-1 downto 0) := (others => '0');
  signal smem_fft_ram0_wr_we    : std_logic;
  signal smem_fft_ram1_rd_addr  : std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
  signal smem_fft_ram1_rd_do    : std_logic_vector(MAX_RAM_WIDTH-1 downto 0) := (others => '0');
  signal smem_fft_ram1_wr_addr  : std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
  signal smem_fft_ram1_wr_di    : std_logic_vector(MAX_RAM_WIDTH-1 downto 0) := (others => '0');
  signal smem_fft_ram1_wr_we    : std_logic;
  signal smem_sampler_rd_addr   : std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
  signal smem_sampler_rd_do     : std_logic_vector(MAX_RAM_WIDTH-1 downto 0) := (others => '0');
  signal smem_delay             : integer                                    := 20;
  signal smem_enable_copy_to_io : std_logic                                  := '0';

  --Alu
  signal alu_delay                  : integer                                 := 1;
  signal alu_ram_super_memory_delay : integer                                 := 10;
  signal alu_ram_rd_p1_addr         : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal alu_ram_rd_p1_do           : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal alu_ram_rd_p2_addr         : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal alu_ram_rd_p2_do           : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal alu_ram_wr_p1_addr         : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal alu_ram_wr_p1_di           : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal alu_ram_wr_p1_we           : std_logic;
  signal alu_mar_w_in               : unsigned(COL_WIDTH-1 downto 0)          := (others => '0');
  signal alu_mar_a_in               : unsigned(COL_WIDTH-1 downto 0)          := (others => '0');
  signal alu_mar_b_in               : unsigned(COL_WIDTH-1 downto 0)          := (others => '0');
  signal alu_mar_x_add_out          : unsigned(COL_WIDTH-1 downto 0)          := (others => '0');
  signal alu_mar_x_sub_out          : unsigned(COL_WIDTH-1 downto 0)          := (others => '0');
  signal alu_mar_delay              : integer                                 := 20;
  signal alu_dec_ready              : std_logic                               := '0';
  signal alu_dec_start              : std_logic                               := '0';
  signal alu_dec_op                 : std_logic_vector(2 downto 0)            := (others => '0');

  --FFT
  signal ntt_ntt_ready        : std_logic                                                          := '0';
  signal ntt_ntt_start        : std_logic                                                          := '0';
  signal ntt_ntt_op           : std_logic_vector(NTT_INST_SIZE-1 downto 0)                         := (others => '0');
  signal ntt_fft_ram0_rd_addr : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal ntt_cycles           : unsigned(31 downto 0)                                              := (others => '0');
  signal ntt_fft_ram_delay    : integer                                                            := 20;

  --Sampler
  signal uni_samp_ready            : std_logic;
  signal uni_samp_start            : std_logic := '0';
  signal uni_samp_stop             : std_logic := '0';
  signal uni_samp_s1_dout          : std_logic_vector(PRIME_P_WIDTH-1 downto 0);
  signal uni_samp_s1_dout_p        : std_logic_vector(PRIME_P'length-1 downto 0);
  signal uni_samp_s1_addr          : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0);
  signal uni_samp_s1_dout_extended : std_logic_vector(COL_WIDTH-1 downto 0);

  signal a_in_V      : std_logic_vector (13 downto 0);
  signal b_in_V      : std_logic_vector (13 downto 0);
  signal x_add_out_V : std_logic_vector (13 downto 0);
  signal x_sub_out_V : std_logic_vector (13 downto 0);

  signal a_in_U      : unsigned(13 downto 0);
  signal b_in_U      : unsigned(13 downto 0);
  signal x_add_out_U : unsigned(13 downto 0);
  signal x_sub_out_U : unsigned(13 downto 0);

  signal mar_12289_delay : integer := 2;
begin

  io_req_delay <= smem_delay;

  --Decode instruction and configure other modules
  decoder_1 : entity work.decoder
    port map (
      clk        => clk,
      proc_ready => proc_ready,
      proc_start => proc_start,
      proc_op    => proc_op,
      proc_arg0  => proc_arg0,
      proc_arg1  => proc_arg1,

      smem_rd_p1_ctl         => smem_rd_p1_ctl,
      smem_rd_p2_ctl         => smem_rd_p2_ctl,
      smem_wr_p1_ctl         => smem_wr_p1_ctl,
      smem_stable            => smem_stable,
      smem_enable_copy_to_io => smem_enable_copy_to_io,

      ntt_ready => ntt_ntt_ready,
      ntt_start => ntt_ntt_start,
      ntt_op    => ntt_ntt_op,

      uni_samp_ready => uni_samp_ready,
      uni_samp_start => uni_samp_start,
      uni_samp_stop  => uni_samp_stop,

      alu_dec_ready => alu_dec_ready,
      alu_dec_start => alu_dec_start,
      alu_dec_op    => alu_dec_op
      );

  --Contains the memory array
  super_memory_1 : entity work.super_memory
    generic map (
      MODE => MODE,
      ADDR_WIDTH    => ADDR_WIDTH,
      ELEMENTS      => N_ELEMENTS,
      RAMS          => RAMS,
      MAX_RAM_WIDTH => MAX_RAM_WIDTH,
      INIT_ARRAY    => INIT_ARRAY,
      RAM_WIDTHs    => RAM_WIDTHs
      )
    port map (
      clk        => clk,
      delay      => smem_delay,
      rd_p1_addr => alu_ram_rd_p1_addr,
      rd_p1_do   => alu_ram_rd_p1_do,
      rd_p2_addr => alu_ram_rd_p2_addr,
      rd_p2_do   => alu_ram_rd_p2_do,
      wr_p1_addr => alu_ram_wr_p1_addr,
      wr_p1_di   => alu_ram_wr_p1_di,
      wr_p1_we   => alu_ram_wr_p1_we,

      rd_p1_ctl              => smem_rd_p1_ctl,
      rd_p2_ctl              => smem_rd_p2_ctl,
      wr_p1_ctl              => smem_wr_p1_ctl,
      stable                 => smem_stable,
      smem_enable_copy_to_io => smem_enable_copy_to_io,

      fft_ram0_rd_addr => smem_fft_ram0_rd_addr,
      fft_ram0_rd_do   => smem_fft_ram0_rd_do,
      fft_ram0_wr_addr => smem_fft_ram0_wr_addr,
      fft_ram0_wr_di   => smem_fft_ram0_wr_di,
      fft_ram0_wr_we   => smem_fft_ram0_wr_we,
      fft_ram1_rd_addr => smem_fft_ram1_rd_addr,
      fft_ram1_rd_do   => smem_fft_ram1_rd_do,
      fft_ram1_wr_addr => smem_fft_ram1_wr_addr,
      fft_ram1_wr_di   => smem_fft_ram1_wr_di,
      fft_ram1_wr_we   => smem_fft_ram1_wr_we,

      sampler_rd_addr => uni_samp_s1_addr,
      sampler_rd_do   => uni_samp_s1_dout_extended,
      io_rd_addr      => io_rd_addr,
      io_rd_do        => io_rd_do,
      io_wr_addr      => io_wr_addr,
      io_wr_di        => io_wr_di,
      io_wr_we        => io_wr_we
      );

  

  use_12289 : if PRIME_P = 12289 generate
    alu_ram_super_memory_delay <= smem_delay;
    main_alu_1 : entity work.main_alu
      generic map (
        ADDR_WIDTH  => ADDR_WIDTH,
        COL_WIDTH   => COL_WIDTH,
        ELEMENTS    => N_ELEMENTS,
        CONNECTIONS => RAMS
        )
      port map (
        clk                    => clk,
        delay                  => alu_delay,
        ram_super_memory_delay => alu_ram_super_memory_delay,
        ram_rd_p1_addr         => alu_ram_rd_p1_addr,
        ram_rd_p1_do           => alu_ram_rd_p1_do,
        ram_rd_p2_addr         => alu_ram_rd_p2_addr,
        ram_rd_p2_do           => alu_ram_rd_p2_do,
        ram_wr_p1_addr         => alu_ram_wr_p1_addr,
        ram_wr_p1_di           => alu_ram_wr_p1_di,
        ram_wr_p1_we           => alu_ram_wr_p1_we,
        mar_w_in               => open,
        mar_a_in               => a_in_U,
        mar_b_in               => b_in_U,
        mar_x_add_out          => x_add_out_U,
        mar_x_sub_out          => x_sub_out_U,
        mar_delay              => mar_12289_delay,
        dec_ready              => alu_dec_ready,
        dec_start              => alu_dec_start,
        dec_op                 => alu_dec_op
        );

    a_in_V      <= std_logic_vector(a_in_U);
    b_in_V      <= std_logic_vector(b_in_U);
    x_add_out_U <= unsigned(x_add_out_U);
    x_sub_out_U <= unsigned(x_sub_out_U);

  --  fft_mar_12289_no_mul_1 : entity work.fft_mar_12289_no_mul
  --    port map (
  --      ap_clk      => clk,
  --      ap_rst      => '0',
  --      a_in_V      => a_in_V,
  --      b_in_V      => b_in_V,
  --      x_add_out_V => x_add_out_V,
  --      x_sub_out_V => x_sub_out_V
  --      );
  end generate use_12289;


    
  --Core of the FFT/NTT multiplier. Exports its butterfly for use by main_alu
  proc_fft_1 : entity work.proc_fft
    generic map (
      
       INIT_ARRAY_VALUE_FFT =>  INIT_ARRAY_VALUE_FFT,
      XN            => XN,
      N_ELEMENTS    => N_ELEMENTS,
      PRIME_P_WIDTH => PRIME_P_WIDTH,
      PRIME_P       => PRIME_P,
      PSI           => PSI,
      OMEGA         => OMEGA,
      PSI_INVERSE   => PSI_INVERSE,
      OMEGA_INVERSE => OMEGA_INVERSE,
      N_INVERSE     => N_INVERSE
      )
    port map (
      clk              => clk,
      ntt_ready        => ntt_ntt_ready,
      ntt_start        => ntt_ntt_start,
      ntt_op           => ntt_ntt_op,
      fft_ram0_rd_addr => smem_fft_ram0_rd_addr,
      fft_ram0_rd_do   => smem_fft_ram0_rd_do,
      fft_ram0_wr_addr => smem_fft_ram0_wr_addr,
      fft_ram0_wr_di   => smem_fft_ram0_wr_di,
      fft_ram0_wr_we   => smem_fft_ram0_wr_we ,
      fft_ram1_rd_addr => smem_fft_ram1_rd_addr,
      fft_ram1_rd_do   => smem_fft_ram1_rd_do,
      fft_ram1_wr_addr => smem_fft_ram1_wr_addr,
      fft_ram1_wr_di   => smem_fft_ram1_wr_di ,
      fft_ram1_wr_we   => smem_fft_ram1_wr_we,
      fft_ram_delay    => ntt_fft_ram_delay,
      cycles           => ntt_cycles
      );


  --Implements Gaussian sampling
  sampler_gen_ber : if SAMPLER = "bernoulli_gauss" or SAMPLER = "dual_cdt_gauss" generate
    large_sigma_gauss_sampler_wrapper_1 : entity work.large_sigma_gauss_sampler_wrapper
      generic map (
        PARAMETER_SET => PARAMETER_SET,
        PRIME_P          => PRIME_P,
        N_ELEMENTS       => N_ELEMENTS,
        GAUSS_SIGMA      => GAUSS_SIGMA,
        SAMPLER          => SAMPLER,
        NUM_BER_SAMPLERS => NUM_BER_SAMPLERS,
        FIFO_ELEMENTS    => N_ELEMENTS
        )
      port map (
        clk          => clk,
        ready        => uni_samp_ready,
        start        => uni_samp_start,
        stop         => uni_samp_stop,
        output_delay => open,
        dout         => uni_samp_s1_dout,
        addr         => uni_samp_s1_addr
        );
    uni_samp_s1_dout_extended <= std_logic_vector(resize(unsigned(uni_samp_s1_dout), uni_samp_s1_dout_extended'length));

  end generate sampler_gen_ber;


  --Set wires to default if no sampler is needed
  no_sampler : if SAMPLER = "none" generate
    uni_samp_ready            <= '1';
    uni_samp_s1_dout          <= (others => '0');
    uni_samp_s1_dout_extended <= (others => '0');
  end generate no_sampler;

  
end Behavioral;
