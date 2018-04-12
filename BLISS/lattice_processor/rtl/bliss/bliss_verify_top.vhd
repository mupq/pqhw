--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:50:11 02/22/2014 
-- Design Name: 
-- Module Name:    bliss_verify_top - Behavioral 
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




entity bliss_verify_top is
  generic (
    ---------------------------------------------------------------------------
    --Change to switch paramter set
    --Influences: d, \kappa, secret keys, public keys
    PARAMETER_SET : integer := 1;

    ------------------------------------------------------------------------------- 
    --Change to tune implementation
    KECCAK_SLICES      : integer               := 32;
    ---------------------------------------------------------------------------
    --Do not change unless you want to break something
    RAM_DEPTH          : integer               := 64;
    NUMBER_OF_BLOCKS   : integer               := 16;
    N_ELEMENTS         : integer               := 512;
    PRIME_P_WIDTH      : integer               := 14;
    PRIME_P            : unsigned              := to_unsigned(12289, 14);
    ZETA               : unsigned              := to_unsigned(6145, 13);
    HASH_BLOCKS        : integer               := 4;
    HASH_WIDTH         : integer               := 64;
    WIDTH_S1           : integer               := 2;
    WIDTH_S2           : integer               := 3;
    INIT_TABLE         : integer               := 0;
    USE_MOCKUP         : integer               := 0;
    c_delay            : integer range 0 to 16 := 2;
    MAX_RES_WIDTH      : integer               := 6
    );
  port (
    clk : in std_logic;

    -- Control bits/signals
    ready           : out std_logic;
    verify          : in  std_logic;
    load_public_key : in  std_logic;

    --Result of verification
    signature_verified : out std_logic := '0';
    signature_valid    : out std_logic := '0';
    signature_invalid  : out std_logic := '0';

    --Message interface
    ready_message    : out std_logic                               := '0';
    message_finished : in  std_logic                               := '0';
    message_din      : in  std_logic_vector(HASH_WIDTH-1 downto 0) := (others => '0');
    message_valid    : in  std_logic                               := '0';

    --Read out of different public key
    public_key_addr : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    public_key_data : in  std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');

    --The signature   
    sig_delay  : in  integer                                                            := 1;
    --TODO Kappa
    c_sig_addr : out std_logic_vector(integer(ceil(log2(real(get_bliss_kappa(PARAMETER_SET)))))-1 downto 0)      := (others => '0');
    c_sig_data : in  std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');

    z1_sig_data : in  std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
    z1_sig_addr : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');

    z2_sig_data : in  std_logic_vector(get_bliss_p_length(PARAMETER_SET)-1 downto 0)                                       := (others => '0');
    z2_sig_addr : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0')

    );

end bliss_verify_top;

architecture Behavioral of bliss_verify_top is
   constant MODULUS_P_BLISS : unsigned := get_bliss_p(PARAMETER_SET);
  constant KAPPA           : integer  := get_bliss_kappa(PARAMETER_SET);
  constant D_BLISS         : integer  := get_bliss_d(PARAMETER_SET);

  
  signal proc_data_avail   : std_logic := '0';
  signal proc_copy_data    : std_logic := '0';
  signal proc_data_copied  : std_logic := '0';
  signal proc_data_out     : std_logic_vector(13 downto 0);
  signal proc_data_out_reg : std_logic_vector(13 downto 0);
  signal proc_addr_out     : std_logic_vector(8 downto 0);

  signal proc_we_ayy     : std_logic;
  signal proc_we_ayy_reg : std_logic;
  signal proc_we_y1      : std_logic;
  signal proc_we_y2      : std_logic;
  signal proc_ver_rd_fin : std_logic                                           := '0';
  signal proc_command    : std_logic_vector(LYU_ARITH_COMMAND_SIZE-1 downto 0) := LYU_ARITH_SIGN_MODE;
  signal proc_finished   : std_logic;
  signal proc_data_in    : std_logic_vector(13 downto 0)                       := (others => '0');
  signal proc_addr_in    : std_logic_vector(8 downto 0);

  signal hash_ext_rehash_message    : std_logic                                                          := '0';
  signal hash_ext_reset             : std_logic                                                          := '0';
  signal hash_ready_message         : std_logic                                                          := '0';
  signal hash_message_finished      : std_logic                                                          := '0';
  signal hash_positions_finished    : std_logic                                                          := '0';
  signal hash_message_din           : std_logic_vector(HASH_WIDTH-1 downto 0)                            := (others => '0');
  signal hash_message_valid         : std_logic                                                          := '0';
  signal hash_c_pos_signature       : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal hash_c_pos_signature_valid : std_logic                                                          := '0';
  signal hash_u_in                  : std_logic_vector(get_bliss_p_length(PARAMETER_SET)-1 downto 0)                := (others => '0');
  signal hash_u_wr_en               : std_logic                                                          := '0';
  signal hash_c_addr                : std_logic_vector(integer(ceil(log2(real(KAPPA))))-1 downto 0)      := (others => '0');
  signal hash_c_out                 : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');


  signal c_ram_c_signature_delay : integer                                                            := 1;
  signal c_ram_c_module_delay    : integer                                                            := 1;
  signal c_ram_ready             : std_logic                                                          := '0';
  signal c_ram_read_c            : std_logic                                                          := '0';
  signal c_ram_c_sig_addr        : std_logic_vector(integer(ceil(log2(real(KAPPA))))-1 downto 0)      := (others => '0');
  signal c_ram_c_sig_data        : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal c_ram_addr              : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal c_ram_dout              : std_logic_vector(1-1 downto 0)                                     := (others => '0');


  signal fin_az1_data : std_logic_vector(PRIME_P'length-1 downto 0)         := (others => '0');
  signal fin_c_data   : std_logic_vector(0 downto 0)                        := "0";
  signal fin_z2_data  : std_logic_vector(z2_sig_data'range)                        := (others => '0');
  signal fin_coeff_we : std_logic                                           := '0';
  signal fin_u_out    : std_logic_vector(get_bliss_p_length(PARAMETER_SET)-1 downto 0) := (others => '0');
  signal fin_u_wr_en  : std_logic                                           := '0';

  signal hash_message_absorbed : std_logic := '0';


  signal fsm_message_absorbed : std_logic := '0';
  signal fsm_az1_ready        : std_logic := '0';
  signal fsm_output_az1       : std_logic := '0';
  signal fsm_hash_equal       : std_logic := '0';
  signal fsm_hash_no_equal    : std_logic := '0';
  signal fsm_start_c_module   : std_logic := '0';
  signal fsm_start_processor  : std_logic := '0';

  signal fsm_proc_command : std_logic_vector(LYU_ARITH_COMMAND_SIZE-1 downto 0) := (others => '0');

    signal fsm_norm_invalid  : std_logic := '0';
      signal fsm_reset_norm  : std_logic := '0';

signal reset_c_ram_module :  std_logic := '0';



  
begin

  

  --process(clk)
  --begin  -- process
  --  if rising_edge(clk) then
  --    if hash_u_wr_en ='1' then
  --      if signed(hash_u_in) /= to_signed(u_ref(u_counter),hash_u_in'length) then
  --        report "bad VERIFY kkk";
  --      end if;
  --      u_counter <= (u_counter+1)mod 512;
  --    end if;
  --  end if;
  --end process;



  
  fsm_message_absorbed <= hash_message_absorbed;
  fsm_az1_ready        <= proc_data_avail;
  proc_copy_data       <= fsm_output_az1;
  proc_command         <= fsm_proc_command;
  c_ram_read_c         <= fsm_start_c_module;
  bliss_verify_fsm_1 : entity work.bliss_verify_fsm
    port map (
      clk                => clk,
      ready              => ready,
      verify             => verify,
      load_public_key    => load_public_key,
      signature_verified => signature_verified,
      signature_valid    => signature_valid,
      proc_command       => fsm_proc_command,
      signature_invalid  => signature_invalid,
      reset_c_ram_module => reset_c_ram_module,
      norm_invalid => fsm_norm_invalid,
      reset_norm => fsm_reset_norm,
      message_absorbed   => fsm_message_absorbed,
      az1_ready          => fsm_az1_ready,
      output_az1         => fsm_output_az1,
      hash_equal         => fsm_hash_equal,
      hash_no_equal      => fsm_hash_no_equal,
hash_positions_finished => hash_positions_finished,
      hash_ext_reset             => hash_ext_reset,
      
      start_c_module     => fsm_start_c_module,
      start_processor    => fsm_start_processor
      );


  c_ram_module_1 : entity work.c_ram_module
    generic map (
      N_ELEMENTS => N_ELEMENTS,
      ADDR_WIDTH => integer(ceil(log2(real(N_ELEMENTS)))),
      KAPPA      => KAPPA
      )
    port map (
      clk               => clk,
      c_signature_delay => c_ram_c_signature_delay,
      c_module_delay    => c_ram_c_module_delay,
      ready             => c_ram_ready,
      read_c            => c_ram_read_c,
      reset_c_ram_module =>  reset_c_ram_module,
      hash_c_in => hash_c_pos_signature,
      hash_c_valid =>  hash_c_pos_signature_valid,
      c_sig_addr        => c_sig_addr,
      c_sig_data        => c_sig_data,
      hash_equal        => fsm_hash_equal,
      hash_no_equal     => fsm_hash_no_equal,
      addr              => c_ram_addr,
      dout              => c_ram_dout
      );



  --Connect the processor to the address port which requests the signature
  proc_data_in <= z1_sig_data;
  z1_sig_addr  <= proc_addr_in when proc_we_ayy='0' else  proc_addr_out;

  --Z2 to Finalization
  z2_sig_addr <= proc_addr_out;
  fin_z2_data <= z2_sig_data;

  --c to finalization
  c_ram_addr <= proc_addr_out;
  fin_c_data <= c_ram_dout;


  process(clk)
  begin  -- process
    if rising_edge(clk) then
      proc_data_out_reg <= proc_data_out;
      proc_we_ayy_reg   <= proc_we_ayy;

      fin_az1_data <= proc_data_out_reg;
      fin_coeff_we <= proc_we_ayy_reg;
    end if;
  end process;


  bliss_processor_1 : entity work.bliss_processor
    generic map (
      PARAMETER_SET => PARAMETER_SET,
       SAMPLER          => "none",
      MODE               => "VERIFY"
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
      ver_rd_fin  => proc_ver_rd_fin,
      command     => proc_command,
      finished    => proc_finished,
      data_in     => proc_data_in,
      addr_in     => proc_addr_in
      );


  verification_finalization_1 : entity work.verification_finalization
    generic map (
      PARAMETER_SET => PARAMETER_SET,
      MODULUS_P_BLISS => MODULUS_P_BLISS,
      PRIME_P         => PRIME_P,
      ZETA            => ZETA,
      D_BLISS         => D_BLISS
      )
    port map (
      clk      => clk,
      az1_data => fin_az1_data,
      reset_norms=> fsm_reset_norm,
      norm_invalid => fsm_norm_invalid,
      z1_data => proc_data_in,
      c_data   => fin_c_data,
      z2_data  => fin_z2_data,
      coeff_we => fin_coeff_we,
      u_out    => fin_u_out,
      u_wr_en  => fin_u_wr_en
      );

  
  hash_message_din      <= message_din;
  hash_message_valid    <= message_valid;
  hash_message_finished <= message_finished;
  ready_message         <= hash_ready_message;

  hash_u_in    <= fin_u_out;
  hash_u_wr_en <= fin_u_wr_en;
  biss_keccak_top_1 : entity work.biss_keccak_top
    generic map (
      KECCAK_SLICES    => KECCAK_SLICES,
      RAM_DEPTH        => RAM_DEPTH,
      NUMBER_OF_BLOCKS => NUMBER_OF_BLOCKS,
      N_ELEMENTS       => N_ELEMENTS,
      PRIME_P_WIDTH    => PRIME_P_WIDTH,
      PRIME_P          => PRIME_P,
      KAPPA            => KAPPA,
      HASH_BLOCKS      => HASH_BLOCKS,
      HASH_WIDTH       => HASH_WIDTH,
      USE_MOCKUP       => USE_MOCKUP,
      MODULUS_P_BLISS  => MODULUS_P_BLISS
      )
    port map (
      clk                   => clk,
      ext_rehash_message    => hash_ext_rehash_message,
      ext_reset             => hash_ext_reset,
      ready_message         => hash_ready_message,
      message_finished      => hash_message_finished,
      positions_finished    => hash_positions_finished,
      message_din           => hash_message_din,
      message_absorbed      => hash_message_absorbed,
      message_valid         => hash_message_valid,
      c_pos_signature       => hash_c_pos_signature,
      c_pos_signature_valid => hash_c_pos_signature_valid,
      u_in                  => hash_u_in,
      u_wr_en               => hash_u_wr_en,
      c_addr                => hash_c_addr,
      c_out                 => hash_c_out
      );



--process
--begin  -- process
--  if rising_edge(clk) then
--     if hash_c_pos_signature_valid
--  end if;

--end process;


end Behavioral;

