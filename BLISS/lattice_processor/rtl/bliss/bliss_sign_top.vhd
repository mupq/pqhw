--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/--fina---------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:37:26 02/12/2014 
-- Design Name: 
-- Module Name:    bliss_sign_top - Behavioral 
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
use work.lattice_processor.all;
use work.lyu512_pkg.all;



entity bliss_sign_top is
  generic (
    ---------------------------------------------------------------------------
    --Change to switch paramter set
    --Influences: d, \kappa, secret keys, public keys
    PARAMETER_SET : integer := 1;

    ------------------------------------------------------------------------------- 
    --Change to tune implementation
    KECCAK_SLICES    : integer               := 32;
    CORES            : integer               := 1;
    NUM_BER_SAMPLERS : integer               := 2;
    SAMPLER          : string                := "dual_cdt_gauss";
    ---------------------------------------------------------------------------
    --Do not change unless you want to break something
    RAM_DEPTH        : integer               := 64;
    NUMBER_OF_BLOCKS : integer               := 16;
    N_ELEMENTS       : integer               := 512;
    PRIME_P_WIDTH    : integer               := 14;
    PRIME_P          : unsigned              := to_unsigned(12289, 14);
    ZETA             : unsigned              := to_unsigned(6145, 13);
    HASH_BLOCKS      : integer               := 4;
    HASH_WIDTH       : integer               := 64;
    INIT_TABLE       : integer               := 0;
    USE_MOCKUP       : integer               := 0;
    c_delay          : integer range 0 to 16 := 2
    );
  port (
    clk : in std_logic;

    -- Control bits/signals
    ready : out std_logic;
    sign  : in  std_logic;

    ready_message    : out std_logic := '0';
    message_finished : in  std_logic := '0';

    stop_engine     : in  std_logic;
    engine_stoped   : out std_logic;
    load_public_key : in  std_logic;

    signature_ready   : out std_logic := '0';
    signature_valid   : out std_logic := '0';
    signature_invalid : out std_logic := '0';

    message_din   : in std_logic_vector(HASH_WIDTH-1 downto 0) := (others => '0');
    message_valid : in std_logic                               := '0';

    --Access to the key port (to change the secret key). Write only
    s1_addr  : in std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    s1_in    : in std_logic_vector(get_bliss_s1_length(PARAMETER_SET)-1 downto 0)    := (others => '0');
    s1_wr_en :    std_logic                                                          := '0';

    s2_addr  : in std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    s2_in    : in std_logic_vector(get_bliss_s2_length(PARAMETER_SET)-1 downto 0)    := (others => '0');
    s2_wr_en :    std_logic                                                          := '0';

    --Read out of different public key
    public_key_addr : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    public_key_data : in  std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');

    final_c_pos       : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    final_c_pos_valid : out std_logic                                                          := '0';

    encoder_finished : in std_logic := '1';
    encoder_ok       : in std_logic := '1';

    --The signature
    --Final ports
    z1_final       : out std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
    z1_final_addr  : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    z1_final_valid : out std_logic                                                          := '0';

    --Final ports
    z2_final       : out std_logic_vector(get_bliss_p_length(PARAMETER_SET)-1 downto 0)     := (others => '0');
    z2_final_addr  : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    z2_final_valid : out std_logic                                                          := '0'

    );


end bliss_sign_top;

architecture Behavioral of bliss_sign_top is
  --depends on parameter selection
  constant MODULUS_P_BLISS : unsigned := get_bliss_p(PARAMETER_SET);
  constant KAPPA           : integer  := get_bliss_kappa(PARAMETER_SET);
  constant D_BLISS         : integer  := get_bliss_d(PARAMETER_SET);

  constant WIDTH_S1 : integer := get_bliss_s1_length(PARAMETER_SET);
  constant WIDTH_S2 : integer := get_bliss_s2_length(PARAMETER_SET);

  constant GAUSS_SIGMA   : real    := 215.0;
  constant MAX_RES_WIDTH : integer := 7;



  signal proc_data_avail  : std_logic                                           := '0';
  signal proc_copy_data   : std_logic                                           := '0';
  signal proc_data_copied : std_logic                                           := '0';
  signal proc_data_out    : std_logic_vector(13 downto 0);
  signal proc_addr_out    : std_logic_vector(8 downto 0);
  signal proc_we_ayy      : std_logic;
  signal proc_we_y1       : std_logic;
  signal proc_we_y2       : std_logic;
  signal proc_ver_rd_fin  : std_logic                                           := '0';
  signal proc_command     : std_logic_vector(LYU_ARITH_COMMAND_SIZE-1 downto 0) := LYU_ARITH_SIGN_MODE;
  signal proc_finished    : std_logic;
  signal proc_data_in     : std_logic_vector(13 downto 0)                       := (others => '0');
  signal proc_addr_in     : std_logic_vector(8 downto 0);

  signal fin_start            : std_logic                                                          := '0';
  signal fin_ready            : std_logic                                                          := '0';
  signal fin_ready_message    : std_logic                                                          := '0';
  signal fin_message_finished : std_logic                                                          := '0';
  signal fin_message_din      : std_logic_vector(HASH_WIDTH-1 downto 0)                            := (others => '0');
  signal fin_message_valid    : std_logic                                                          := '0';
  signal fin_s1_addr          : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal fin_s1_in            : std_logic_vector(WIDTH_S1-1 downto 0)                              := (others => '0');
  signal fin_s1_wr_en         : std_logic                                                          := '0';
  signal fin_s2_addr          : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal fin_s2_in            : std_logic_vector(WIDTH_S2-1 downto 0)                              := (others => '0');
  signal fin_s2_wr_en         : std_logic                                                          := '0';
  signal fin_coeff_sc1_out    : std_logic_vector(MAX_RES_WIDTH-1 downto 0)                         := (others => '0');
  signal fin_coeff_sc1_addr   : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal fin_coeff_sc1_valid  : std_logic                                                          := '0';
  signal fin_coeff_sc2_out    : std_logic_vector(MAX_RES_WIDTH-1 downto 0)                         := (others => '0');
  signal fin_coeff_sc2_addr   : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal fin_coeff_sc2_valid  : std_logic                                                          := '0';
  signal fin_addr_in          : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal fin_data_in          : std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
  signal fin_ay1_wr_en        : std_logic                                                          := '0';
  signal fin_y1_wr_en         : std_logic                                                          := '0';
  signal fin_y2_wr_en         : std_logic                                                          := '0';

  signal reject_reset           : std_logic;
  signal reject_rejection       : std_logic;
  signal reject_coeff_sc_addr   : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal reject_coeff_sc1       : std_logic_vector(MAX_RES_WIDTH-1 downto 0)                         := (others => '0');
  signal reject_coeff_sc1_valid : std_logic                                                          := '0';
  signal reject_coeff_sc2       : std_logic_vector(MAX_RES_WIDTH-1 downto 0)                         := (others => '0');
  signal reject_coeff_sc2_valid : std_logic                                                          := '0';
  signal reject_delay_temp_ram  : integer range 0 to 63                                              := 10;
  signal reject_u_data          : std_logic_vector(PRIME_P'length+1-1 downto 0)                      := (others => '0');
  signal reject_u_addr          : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal reject_y1_data         : std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
  signal reject_y1_addr         : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal reject_y2_data         : std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
  signal reject_y2_addr         : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal reject_z1_final        : std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
  signal reject_z1_final_addr   : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal reject_z1_final_valid  : std_logic                                                          := '0';
  signal reject_z2_final        : std_logic_vector(z2_final'range)                                   := (others => '0');
  signal reject_z2_final_addr   : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal reject_z2_final_valid  : std_logic                                                          := '0';
  signal reject_finished        : std_logic                                                          := '0';

  signal fin_rehash_message : std_logic := '0';
  signal fin_reset          : std_logic := '0';


  

begin


  bliss_sign_fsm_1 : entity work.bliss_sign_fsm
    port map (
      clk                  => clk,
      ready                => ready,
      sign                 => sign,
      ready_message        => ready_message ,
      rehash_message       => fin_rehash_message,
      reset                => fin_reset,
      message_finished     => message_finished ,
      stop_engine          => stop_engine,
      engine_stoped        => engine_stoped,
      load_public_key      => load_public_key,
      signature_ready      => signature_ready,
      signature_valid      => signature_valid,
      signature_invalid    => signature_invalid,
      proc_data_avail      => proc_data_avail,
      proc_copy_data       => proc_copy_data,
      proc_data_copied     => proc_data_copied,
      proc_command         => proc_command,
      proc_finished        => proc_finished,
      fin_ready_message    => fin_ready_message,
      fin_message_finished => fin_message_finished,
      reject_finished      => reject_finished,
      reject_reset         => reject_reset,
      reject_rejection     => reject_rejection
      );


  real_proc : if USE_MOCKUP = 0 generate
    bliss_processor_1 : entity work.bliss_processor
      generic map (
        PARAMETER_SET    => PARAMETER_SET,
        SAMPLER          => SAMPLER,
        GAUSS_SIGMA      => GAUSS_SIGMA,
        NUM_BER_SAMPLERS => NUM_BER_SAMPLERS,
        MODE             => "BOTH"
        )
      port map (
        clk         => clk,
        data_avail  => proc_data_avail,
        copy_data   => proc_copy_data,
        data_copied => proc_data_copied,
        data_out    => proc_data_out,
        addr_out    => proc_addr_out,
        we_ayy      => proc_we_ayy,
        we_y1       => proc_we_y1,
        we_y2       => proc_we_y2,
        --ver_rd_fin  => proc_ver_rd_fin,
        command     => proc_command,
        finished    => proc_finished,
        data_in     => public_key_data,
        addr_in     => public_key_addr
        );
  end generate real_proc;

  mockup_proc : if USE_MOCKUP = 1 generate
    processor_testing_mock_up_1 : entity work.processor_testing_mock_up
      generic map (
        MODE => "BOTH"
        )
      port map (
        clk         => clk,
        data_avail  => proc_data_avail,
        copy_data   => proc_copy_data,
        data_copied => proc_data_copied,
        data_out    => proc_data_out,
        addr_out    => proc_addr_out,
        we_ayy      => proc_we_ayy,
        we_y1       => proc_we_y1,
        we_y2       => proc_we_y2,
        --ver_rd_fin  => proc_ver_rd_fin,
        command     => proc_command,
        finished    => proc_finished,
        data_in     => public_key_data,
        addr_in     => public_key_addr
        );
  end generate mockup_proc;

  fin_message_din   <= message_din;
  fin_message_valid <= message_valid;
  finalization_top_1 : entity work.finalization_top
    generic map (
      PARAMETER_SET    => PARAMETER_SET,
      RAM_DEPTH        => RAM_DEPTH,
      NUMBER_OF_BLOCKS => NUMBER_OF_BLOCKS,
      N_ELEMENTS       => N_ELEMENTS,
      PRIME_P_WIDTH    => PRIME_P_WIDTH,
      PRIME_P          => PRIME_P,
      KAPPA            => KAPPA,
      KECCAK_SLICES    => KECCAK_SLICES,
      HASH_BLOCKS      => HASH_BLOCKS,
      HASH_WIDTH       => HASH_WIDTH,
      ZETA             => ZETA,
      D_BLISS          => D_BLISS,
      MODULUS_P_BLISS  => MODULUS_P_BLISS,
      CORES            => CORES,
      WIDTH_S1         => WIDTH_S1,
      WIDTH_S2         => WIDTH_S2,
      INIT_TABLE       => INIT_TABLE,
      USE_MOCKUP       => USE_MOCKUP ,
      c_delay          => c_delay,
      MAX_RES_WIDTH    => MAX_RES_WIDTH
      )
    port map (
      clk                   => clk,
      --start            => fin_start,
      --ready            => fin_ready,
      rehash_message        => fin_rehash_message,
      reset                 => fin_reset,
      ready_message         => fin_ready_message,
      message_finished      => fin_message_finished,
      message_din           => fin_message_din,
      message_valid         => fin_message_valid,
      --Part of the signature
      c_pos_signature       => final_c_pos,
      c_pos_signature_valid => final_c_pos_valid,
      --Secret key goes directly to toplevel
      s1_addr               => s1_addr,
      s1_in                 => s1_in,
      s1_wr_en              => s1_wr_en,
      s2_addr               => s2_addr,
      s2_in                 => s2_in,
      s2_wr_en              => s2_wr_en,
      coeff_sc1_out         => fin_coeff_sc1_out,
      coeff_sc1_addr        => fin_coeff_sc1_addr,
      coeff_sc1_valid       => fin_coeff_sc1_valid,
      coeff_sc2_out         => fin_coeff_sc2_out,
      coeff_sc2_addr        => fin_coeff_sc2_addr,
      coeff_sc2_valid       => fin_coeff_sc2_valid,
      addr_in               => proc_addr_out,
      data_in               => proc_data_out,
      ay1_wr_en             => proc_we_ayy,
      y1_wr_en              => proc_we_y1,
      y2_wr_en              => proc_we_y2,

      u_out_data  => reject_u_data,
      u_out_addr  => reject_u_addr,
      y1_out_data => reject_y1_data,
      y1_out_addr => reject_y1_addr,
      y2_out_data => reject_y2_data,
      y2_out_addr => reject_y2_addr
      );


  
  rejection_module_1 : entity work.rejection_module
    generic map (
      PARAMETER_SET          => PARAMETER_SET,
      N_ELEMENTS             => N_ELEMENTS,
      PRIME_P_WIDTH          => PRIME_P_WIDTH,
      PRIME_P                => PRIME_P,
      ZETA                   => ZETA,
      D_BLISS                => D_BLISS,
      MODULUS_P_BLISS        => MODULUS_P_BLISS,
      MAX_RES_WIDTH_COEFF_SC => MAX_RES_WIDTH,
      CORES                  => CORES,
      KAPPA                  => KAPPA,
      WIDTH_S1               => WIDTH_S1,
      WIDTH_S2               => WIDTH_S2,
      INIT_TABLE             => INIT_TABLE,
      c_delay                => c_delay,
      MAX_RES_WIDTH          => MAX_RES_WIDTH
      )
    port map (
      clk             => clk,
      reset           => reject_reset,
      rejection       => reject_rejection,
      finished        => reject_finished,
      coeff_sc_addr   => fin_coeff_sc1_addr,
      coeff_sc1       => fin_coeff_sc1_out,
      coeff_sc1_valid => fin_coeff_sc1_valid,
      coeff_sc2       => fin_coeff_sc2_out,
      coeff_sc2_valid => fin_coeff_sc2_valid,
      delay_temp_ram  => reject_delay_temp_ram,
       encoder_finished =>        encoder_finished ,
    encoder_ok    =>     encoder_ok  ,
      u_data          => reject_u_data,
      u_addr          => reject_u_addr,
      y1_data         => reject_y1_data,
      y1_addr         => reject_y1_addr,
      y2_data         => reject_y2_data,
      y2_addr         => reject_y2_addr,
      z1_final        => z1_final,
      z1_final_addr   => z1_final_addr,
      z1_final_valid  => z1_final_valid,
      z2_final        => z2_final,
      z2_final_addr   => z2_final_addr,
      z2_final_valid  => z2_final_valid
      );

end Behavioral;

