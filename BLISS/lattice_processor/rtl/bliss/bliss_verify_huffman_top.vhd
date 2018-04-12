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



entity bliss_verify_huffman_top is

  generic (
    ---------------------------------------------------------------------------
    --Change to switch paramter set
    --Influences: d, \kappa, secret keys, public keys
    PARAMETER_SET : integer := 1;

    ------------------------------------------------------------------------------- 
    --Change to tune implementation
    KECCAK_SLICES    : integer               := 32;
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
    WIDTH_S1         : integer               := 2;
    WIDTH_S2         : integer               := 3;
    INIT_TABLE       : integer               := 0;
    USE_MOCKUP       : integer               := 0;
    c_delay          : integer range 0 to 16 := 2;
    MAX_RES_WIDTH    : integer               := 6
    );
  port (
    clk : in std_logic;

    -- Control bits/signals
    ready           : out std_logic;
    verify          : in  std_logic:='0';
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
    sig_delay  : in  integer                                                                                := 1;
    --TODO Kappa
    c_sig_addr : out std_logic_vector(integer(ceil(log2(real(get_bliss_kappa(PARAMETER_SET)))))-1 downto 0) := (others => '0');
    c_sig_data : in  std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0)                     := (others => '0');

    code_V_dout    : in  std_logic_vector (31 downto 0);
    code_V_empty_n : in  std_logic;
    code_V_read    : out std_logic;
code_V_rst    : out std_logic :='0'
    

    );

end bliss_verify_huffman_top;


architecture Behavioral of bliss_verify_huffman_top is
  signal start_verify : std_logic := '0';

 constant ADDR_WIDTH : integer := 9;
  constant COL_WIDTH  : integer := PRIME_P_WIDTH;


  signal ap_rst        : std_logic:='1';
  signal ap_start      : std_logic :='0';
  signal ap_done       : std_logic:='0';
  signal ap_idle       : std_logic:='0';
  signal ap_ready      : std_logic:='0';
  signal   ap_return :  STD_LOGIC_VECTOR (0 downto 0);
       
  signal z1_V_V_din    : std_logic_vector (13 downto 0);
  signal z1_V_V_full_n : std_logic:='1';
  signal z1_V_V_write  : std_logic:='0';
  signal z2_V_V_din    : std_logic_vector (2 downto 0);
  signal z2_V_V_full_n : std_logic:='1';
  signal z2_V_V_write  : std_logic:='0';

  signal z1_sig_data : std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
  signal z1_sig_addr : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal z2_sig_data : std_logic_vector(get_bliss_p_length(PARAMETER_SET)-1 downto 0)     := (others => '0');
  signal z2_sig_addr : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');

  signal ram_z1_wea   : std_logic                               := '0';
  signal ram_z1_web   : std_logic                               := '0';
  signal ram_z1_addra : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal ram_z1_addrb : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal ram_z1_dia   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal ram_z1_dib   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal ram_z1_doa   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal ram_z1_dob   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');

  signal ram_z2_wea   : std_logic                               := '0';
  signal ram_z2_web   : std_logic                               := '0';
  signal ram_z2_addra : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal ram_z2_addrb : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal ram_z2_dia   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal ram_z2_dib   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal ram_z2_doa   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal ram_z2_dob   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');

  signal cnt : integer := 0;

   signal cycle_cnt: integer := 0;
   signal cycles_decode_start: integer := 0;
   signal cycles_decode: integer := 0;
   signal decode_cnt: integer := 0;
   signal decode_sum: integer := 0;
begin

  --When verify is asserted, the huffman decoder runs. Verification core not yet
  --write data in BRAM
  --Verification core is started

  huffman_decoder_1 : entity work.huffman_decoder
    port map (
      ap_clk         => clk,
      ap_rst         => ap_rst,
      ap_start       => ap_start,
      ap_done        => ap_done,
      ap_idle        => ap_idle,
      ap_ready       => ap_ready,
      ap_return =>  ap_return,
      code_V_V_dout    => code_V_dout,
      code_V_V_empty_n => code_V_empty_n,
      code_V_V_read    => code_V_read,
      z1_V_V_din     => z1_V_V_din,
      z1_V_V_full_n  => z1_V_V_full_n,
      z1_V_V_write   => z1_V_V_write,
      z2_V_V_din     => z2_V_V_din,
      z2_V_V_full_n  => z2_V_V_full_n,
      z2_V_V_write   => z2_V_V_write
      );


  

  process(clk)
  begin  -- process
    if rising_edge(clk) then
      cycle_cnt <= cycle_cnt +1;
        code_V_rst <= '0';
      
      if ap_start='1' then
        cycles_decode_start <= cycle_cnt;
      end if;

      if ap_done='1' then
        cycles_decode <=  cycle_cnt- cycles_decode_start;
        decode_cnt <= decode_cnt +1;
        decode_sum <=   decode_sum+ cycle_cnt- cycles_decode_start;
        code_V_rst <= '1';
      end if;

      if cnt<5 then
        cnt <= cnt+1;
       else
      ap_rst <= '0';         
      end if;

      
      --Start huffman first, then the verification
      start_verify <= '0';
      ap_start      <= '0';
      if verify = '1' then
        ap_start <= '1';
      end if;

      if ap_done = '1' then
        start_verify <= '1';
      end if;

      if z1_V_V_write = '1' then
        ram_z1_addra <= std_logic_vector(unsigned(ram_z1_addra) +1 mod 512);
      end if;

      if z2_V_V_write = '1' then
        ram_z2_addra <= std_logic_vector(unsigned(ram_z2_addra) +1 mod 512);
      end if;
      
    end if;
  end process;

  ram_z1_wea   <= z1_V_V_write;
  ram_z1_dia   <= std_logic_vector(resize(signed(z1_V_V_din), ram_z1_dia'length));

  bram_z1 : entity work.bram_with_delay
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
      wea   => ram_z1_wea,
      web   => ram_z1_web,
      addra => ram_z1_addra,
      addrb => ram_z1_addrb,
      dia   => ram_z1_dia,
      dib   => ram_z1_dib,
      doa   => ram_z1_doa,
      dob   => ram_z1_dob
      );

  ram_z2_wea   <= z2_V_V_write;
  ram_z2_dia   <= std_logic_vector(resize(signed(z2_V_V_din), ram_z2_dia'length));
  bram_z2 : entity work.bram_with_delay
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
      wea   => ram_z2_wea,
      web   => ram_z2_web,
      addra => ram_z2_addra,
      addrb => ram_z2_addrb,
      dia   => ram_z2_dia,
      dib   => ram_z2_dib,
      doa   => ram_z2_doa,
      dob   => ram_z2_dob
      );


  --The big core
--Connect the verification core to the Huffman decoder core
  z1_sig_data  <= ram_z1_dob;
  ram_z1_addrb <= z1_sig_addr;
  z2_sig_data  <= std_logic_vector(resize(signed(ram_z2_dob), z2_sig_data'length));
  ram_z2_addrb <= z2_sig_addr;

  bliss_verify_top_1 : entity work.bliss_verify_top
    generic map (
      PARAMETER_SET    => PARAMETER_SET,
      KECCAK_SLICES    => KECCAK_SLICES,
      RAM_DEPTH        => RAM_DEPTH,
      NUMBER_OF_BLOCKS => NUMBER_OF_BLOCKS,
      N_ELEMENTS       => N_ELEMENTS,
      PRIME_P_WIDTH    => PRIME_P_WIDTH,
      PRIME_P          => PRIME_P,
      ZETA             => ZETA,
      HASH_BLOCKS      => HASH_BLOCKS,
      HASH_WIDTH       => HASH_WIDTH,
      WIDTH_S1         => WIDTH_S1,
      WIDTH_S2         => WIDTH_S2,
      INIT_TABLE       => INIT_TABLE,
      USE_MOCKUP       => USE_MOCKUP,
      c_delay          => c_delay,
      MAX_RES_WIDTH    => MAX_RES_WIDTH)
    port map (
      clk                => clk,
      ready              => ready,
      verify             => start_verify,
      load_public_key    => load_public_key,
      signature_verified => signature_verified,
      signature_valid    => signature_valid,
      signature_invalid  => signature_invalid,
      ready_message      => ready_message,
      message_finished   => message_finished,
      message_din        => message_din,
      message_valid      => message_valid,
      public_key_addr    => public_key_addr,
      public_key_data    => public_key_data,
      sig_delay          => sig_delay,
      c_sig_addr         => c_sig_addr,
      c_sig_data         => c_sig_data,
      z1_sig_data        => z1_sig_data,
      z1_sig_addr        => z1_sig_addr,
      z2_sig_data        => z2_sig_data,
      z2_sig_addr        => z2_sig_addr
      );




end Behavioral;
