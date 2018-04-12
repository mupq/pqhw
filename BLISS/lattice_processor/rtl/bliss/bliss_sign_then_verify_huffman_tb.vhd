--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/

--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:49:54 03/01/2014
-- Design Name:   
-- Module Name:   C:/Users/thomas/SHA/Projekte/BLISS/code/bliss_arithmetic/lattice_processor/bliss_sign_then_verify.vhd
-- Project Name:  lattice_processor
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: trivium
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
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.lyu512_pkg.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

entity bliss_sign_then_verify_huffman_tb is
  generic (
    --Change to switch paramter set
    PARAMETER_SET : integer := 1;

    --Change to tune implementation
    KECCAK_SLICES    : integer := 16;
    CORES            : integer := 8;
    NUM_BER_SAMPLERS : integer := 2;
    SAMPLER          : string  := "dual_cdt_gauss";

    --No effect, do not change
    HASH_WIDTH    : integer  := 64;
    --WIDTH_S1        : integer  := get_bliss_s1_length(PARAMETER_SET);
    -- WIDTH_S2        : integer  := 3;
    N_ELEMENTS    : integer  := 512;
    ZETA          : unsigned := to_unsigned(6145, 13);
    PRIME_P       : unsigned := to_unsigned(12289, 14);
    PRIME_P_WIDTH : integer  := 14
    );
end bliss_sign_then_verify_huffman_tb;

architecture behavior of bliss_sign_then_verify_huffman_tb is
  constant WIDTH_S1 : integer := get_bliss_s1_length(PARAMETER_SET);
  constant WIDTH_S2 : integer := get_bliss_s2_length(PARAMETER_SET);

  -- Component Declaration for the Unit Under Test (UUT)
  constant KAPPA                  : integer                                                            := get_bliss_kappa(PARAMETER_SET);
  signal   clk                    : std_logic;
  signal   ver_ready              : std_logic                                                          := '0';
  signal   ver_verify             : std_logic                                                          := '0';
  signal   ver_load_public_key    : std_logic                                                          := '0';
  signal   ver_signature_verified : std_logic                                                          := '0';
  signal   ver_signature_valid    : std_logic                                                          := '0';
  signal   ver_signature_invalid  : std_logic                                                          := '0';
  signal   ver_ready_message      : std_logic                                                          := '0';
  signal   ver_message_finished   : std_logic                                                          := '0';
  signal   ver_message_din        : std_logic_vector(HASH_WIDTH-1 downto 0)                            := (others => '0');
  signal   ver_message_valid      : std_logic                                                          := '0';
  signal   ver_public_key_addr    : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal   ver_public_key_data    : std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
  signal   ver_sig_delay          : integer                                                            := 1;
  signal   ver_c_sig_addr         : std_logic_vector(integer(ceil(log2(real(KAPPA))))-1 downto 0)      := (others => '0');
  signal   ver_c_sig_data         : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');

  constant ADDR_WIDTH : integer := 9;
  constant COL_WIDTH  : integer := PRIME_P_WIDTH;


  signal ram_c_wea   : std_logic                               := '0';
  signal ram_c_web   : std_logic                               := '0';
  signal ram_c_addra : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal ram_c_addrb : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal ram_c_dia   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal ram_c_dib   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal ram_c_doa   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal ram_c_dob   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');


  signal sign_ready             : std_logic;
  signal sign_sign              : std_logic;
  signal sign_ready_message     : std_logic                                                          := '0';
  signal sign_message_finished  : std_logic                                                          := '0';
  signal sign_stop_engine       : std_logic;
  signal sign_engine_stoped     : std_logic;
  signal sign_load_public_key   : std_logic;
  signal sign_signature_ready   : std_logic                                                          := '0';
  signal sign_signature_valid   : std_logic                                                          := '0';
  signal sign_signature_invalid : std_logic                                                          := '0';
  signal sign_message_din       : std_logic_vector(HASH_WIDTH-1 downto 0)                            := (others => '0');
  signal sign_message_valid     : std_logic                                                          := '0';
  signal sign_s1_addr           : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal sign_s1_in             : std_logic_vector(WIDTH_S1-1 downto 0)                              := (others => '0');
  signal sign_s1_wr_en          : std_logic                                                          := '0';
  signal sign_s2_addr           : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal sign_s2_in             : std_logic_vector(WIDTH_S2-1 downto 0)                              := (others => '0');
  signal sign_s2_wr_en          : std_logic                                                          := '0';
  signal sign_public_key_addr   : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal sign_public_key_data   : std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
  signal sign_final_c_pos       : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal sign_final_c_pos_valid : std_logic                                                          := '0';
  signal sign_z1_final          : std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
  signal sign_z1_final_addr     : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal sign_z1_final_valid    : std_logic                                                          := '0';
  signal sign_z2_final          : std_logic_vector(get_bliss_p_length(PARAMETER_SET)-1 downto 0)     := (others => '0');
  signal sign_z2_final_addr     : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal sign_z2_final_valid    : std_logic                                                          := '0';

  signal test_mask_z1 : std_logic_vector(PRIME_P'length-1 downto 0) := (others => '0');


  signal   error_happened : std_logic := '0';
  signal   pos_c_counter  : integer   := 0;
                                        -- Clock period definitions
  constant clk_period     : time      := 10 ns;

  type   message_ram is array (0 to 15) of std_logic_vector(HASH_WIDTH-1 downto 0);
  signal message_buf : message_ram;
signal stop_clock : std_logic := '0';

------------------------------------------------------------------------------  function get_rand_message(seed : in positive) return message_ram ;

  function get_rand_message(seed : in positive) return message_ram is
    variable seed1 : positive := 1;     -- Seed values for random generato
    variable seed2 : positive := 1;     -- Seed values for random generato

    variable rand       : real;  -- Random real-number value in range 0 to 1.0
    variable int_rand   : integer;  -- Random integer value in range 0..4095
    variable stim       : std_logic_vector(HASH_WIDTH-1 downto 0);  -- Random 12-bit stimulus
    variable temp_m_ram : message_ram;
  begin

    seed1 := seed1+seed;
    for i in 0 to 15 loop
      UNIFORM(seed1, seed2, rand);      -- generate random number
      rand     := rand*2147483648.0;
      int_rand := integer(CEIL(rand));  -- rescale to 0..4096, find integer part
      stim     := std_logic_vector(to_unsigned(int_rand, stim'length));  -- convert to std_logic_vector
      seed1    := seed1+1;

      temp_m_ram(i) := stim;
    end loop;  -- i
    return temp_m_ram;
    
    
  end get_rand_message;


  signal code_din          : std_logic_vector(31 downto 0);
  signal code_wr_en        : std_logic;
  signal code_rd_en        : std_logic;
  signal code_dout         : std_logic_vector(31 downto 0);
  signal code_full         : std_logic;
  signal code_almost_full  : std_logic;
  signal code_empty        : std_logic;
  signal code_almost_empty : std_logic;

  signal code_rst      : std_logic := '0';
  signal code_V_rst    : std_logic := '0';
  signal code_fifo_rst : std_logic := '0';
  
begin
  

  ver_c_sig_data <= ram_c_dob(ver_c_sig_data'range);
  ram_c_addrb    <= std_logic_vector(resize(unsigned(ver_c_sig_addr), ram_c_addrb'length));

  code_fifo_rst <= code_rst or code_V_rst;


  bliss_verify_huffman_top_1 : entity work.bliss_verify_huffman_top
    generic map (
      PARAMETER_SET => PARAMETER_SET,
      KECCAK_SLICES => KECCAK_SLICES,
      PRIME_P       => PRIME_P,
      ZETA          => ZETA
      )
    port map (
      clk                => clk,
      ready              => ver_ready,
      verify             => ver_verify,
      load_public_key    => ver_load_public_key,
      signature_verified => ver_signature_verified,
      signature_valid    => ver_signature_valid,
      signature_invalid  => ver_signature_invalid,
      ready_message      => ver_ready_message,
      message_finished   => ver_message_finished,
      message_din        => ver_message_din,
      message_valid      => ver_message_valid,
      public_key_addr    => ver_public_key_addr,
      public_key_data    => ver_public_key_data,
      sig_delay          => ver_sig_delay,
      c_sig_addr         => ver_c_sig_addr,
      c_sig_data         => ver_c_sig_data,
      code_V_dout        => code_dout,
      code_V_empty_n     => '1',
      code_V_read        => code_rd_en,
      code_V_rst         => code_V_rst
      );


  coded_sig_fifo_1 : entity work.bliss_code_ram
    port map (
      clk          => clk,
      rst          => code_fifo_rst,
      din          => code_din,
      wr_en        => code_wr_en,
      rd_en        => code_rd_en,
      dout         => code_dout,
      full         => code_full,
      almost_full  => code_almost_full,
      empty        => code_empty,
      almost_empty => code_almost_empty
      );


  bliss_sign_huffman_1 : entity work.bliss_sign_huffman
    generic map (
      PARAMETER_SET => PARAMETER_SET,
      KECCAK_SLICES => KECCAK_SLICES,
      CORES         => CORES,
      HASH_WIDTH    => HASH_WIDTH,
      N_ELEMENTS    => N_ELEMENTS,
      ZETA          => ZETA,
      PRIME_P       => PRIME_P)
    port map (
      clk               => clk,
      ready             => sign_ready,
      sign              => sign_sign,
      ready_message     => sign_ready_message,
      message_finished  => sign_message_finished,
      stop_engine       => sign_stop_engine,
      engine_stoped     => sign_engine_stoped,
      load_public_key   => sign_load_public_key,
      signature_ready   => sign_signature_ready,
      signature_valid   => sign_signature_valid,
      signature_invalid => sign_signature_invalid,
      message_din       => sign_message_din,
      message_valid     => sign_message_valid,
      s1_addr           => sign_s1_addr,
      s1_in             => sign_s1_in,
      s1_wr_en          => sign_s1_wr_en,
      s2_addr           => sign_s2_addr,
      s2_in             => sign_s2_in,
      s2_wr_en          => sign_s2_wr_en,
      public_key_addr   => sign_public_key_addr,
      public_key_data   => sign_public_key_data,
      final_c_pos       => sign_final_c_pos,
      final_c_pos_valid => sign_final_c_pos_valid,
      code_rst          => code_rst,
      code_V_din        => code_din,
      code_V_full_n     => '1',
      code_V_write      => code_wr_en
      );


  process(clk)
  begin  -- process
    if rising_edge(clk) then
      
      if sign_final_c_pos_valid = '1' then
        ram_c_wea     <= sign_final_c_pos_valid;
        ram_c_addra   <= std_logic_vector(to_unsigned(pos_c_counter, ram_c_addra'length));
        ram_c_dia     <= std_logic_vector(resize(unsigned(sign_final_c_pos), ram_c_dia'length));
        pos_c_counter <= (pos_c_counter+1) mod get_bliss_kappa(PARAMETER_SET);
      end if;
    end if;

                                        -- purpose: 

  end process;

  bram_c : entity work.bram_with_delay
    generic map (
      SIZE       => N_ELEMENTS,
      ADDR_WIDTH => ADDR_WIDTH,
      COL_WIDTH  => COL_WIDTH,
      add_reg_a  => 0,
      add_reg_b  => 0,
      InitFile   => ""
      )
    port map (
      clka  => clk,
      clkb  => clk,
      ena   => '1',
      enb   => '1',
      wea   => ram_c_wea,
      web   => ram_c_web,
      addra => ram_c_addra,
      addrb => ram_c_addrb,
      dia   => ram_c_dia,
      dib   => ram_c_dib,
      doa   => ram_c_doa,
      dob   => ram_c_dob
      );



                                        -- Clock process definitions
  clk_process : process
  begin
    if stop_clock /= '1' then
      clk <= '0';
      wait for clk_period/2;
      clk <= '1';
      wait for clk_period/2;
    end if;
  end process;


                                        -- Stimulus process
  stim_proc : process
  begin
                                        -- hold reset state for 100 ns.

    wait for 100 ns;

    wait for clk_period*10;

    ---- Test correct signatures
    -----------------------------------------------------------------------------
    while error_happened = '0' loop
      message_buf <= get_rand_message(1);


      while sign_ready_message = '0' loop
        wait for clk_period;
      end loop;

      wait for clk_period;

                                        --Write the message
      for i in 0 to 15 loop
        sign_message_din   <= message_buf(i);
        sign_message_valid <= '1';
        wait for clk_period;
      end loop;  -- i
      sign_message_valid    <= '0';
                                        --State that the message is finished
      sign_message_finished <= '1';
      wait for clk_period;
      sign_message_finished <= '0';
      wait for clk_period*10;
      sign_sign             <= '1';
      wait for clk_period;
      sign_sign             <= '0';
      wait for clk_period*10;



      while sign_signature_ready = '0' loop
        wait for clk_period;
      end loop;


                                        --report "Signature Ready" severity note;
      wait for clk_period*10;

      wait for clk_period;

      ver_verify <= '1';
      wait for clk_period;
      ver_verify <= '0';
                                        --Write the message

      for i in 0 to 15 loop
        ver_message_din   <= message_buf(i);
        ver_message_valid <= '1';
        wait for clk_period;
      end loop;  -- i
      ver_message_valid    <= '0';
                                        --State that the message is finished
      ver_message_finished <= '1';
      wait for clk_period;
      ver_message_finished <= '0';
                                        --Wait till signature is finished
      while ver_signature_verified = '0' loop
        wait for clk_period;
      end loop;
      if ver_signature_invalid = '1' then
        error_happened <= '1';
        report "VERIFICATION ERROR";
      end if;
      if ver_signature_valid = '1' then
        report "VERIFICATION CORRECT";
      end if;
      wait for clk_period*10000;
    end loop;

    stop_clock <= '1';
    report "Signature verification FAILED" severity error;
    
    
  end process;

end;
