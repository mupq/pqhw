--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/

---------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:16:36 08/06/2014 
-- Design Name: 
-- Module Name:    bliss_sign_huffman - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bliss_sign_huffman is
  generic (
    --Change to switch paramter set
    PARAMETER_SET : integer := 1;

    --Change to tune implementation
    KECCAK_SLICES : integer := 16;
    CORES         : integer := 2;

    --No effect, do not change
    HASH_WIDTH : integer := 64;

    N_ELEMENTS : integer  := 512;
    ZETA       : unsigned := to_unsigned(6145, 13);
    PRIME_P    : unsigned := to_unsigned(12289, 14)
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

    --Outputs the encoded message
    code_rst      : out std_logic := '0';
    code_V_din    : out std_logic_vector (31 downto 0);
    code_V_full_n : in  std_logic;
    code_V_write  : out std_logic


    );

end bliss_sign_huffman;

architecture Behavioral of bliss_sign_huffman is
  
  signal ap_rst   : std_logic := '1';
  signal ap_start : std_logic := '0';
  signal ap_done  : std_logic := '0';
  signal ap_idle  : std_logic := '0';
  signal ap_ready : std_logic := '0';

  signal ap_return : std_logic_vector (0 downto 0);


  signal z1_rst : std_logic := '0';
  signal z2_rst : std_logic := '0';



  signal z1_final          : std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
  signal z1_final_addr     : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal z1_final_addr_reg : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');

  signal z1_final_valid : std_logic := '0';

  --Final ports
  signal z2_final       : std_logic_vector(get_bliss_p_length(PARAMETER_SET)-1 downto 0)     := (others => '0');
  signal z2_final_addr  : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal z2_final_valid : std_logic                                                          := '0';

  signal cnt       : integer := 0;
  signal shift_reg : std_logic_vector(20 downto 0);

  signal z1_din     : std_logic_vector(13 downto 0);
  signal z1_wr_en   : std_logic;
  signal z1_rd_en   : std_logic;
  signal z1_dout    : std_logic_vector(13 downto 0);

  signal z1_full    : std_logic;
  signal z1_empty   : std_logic;
  signal z1_empty_n : std_logic;

  signal z2_din         : std_logic_vector(2 downto 0);
  signal z2_wr_en       : std_logic;
  signal z2_rd_en       : std_logic;
  signal z2_dout        : std_logic_vector(2 downto 0);
  signal z2_full        : std_logic;
  signal z2_almost_full : std_logic;
  signal z2_empty       : std_logic;
  signal z2_empty_n     : std_logic;

  signal z2_almost_empty : std_logic;



  signal debug                            : std_logic_vector (31 downto 0);
  signal debug_ap_vld                     : std_logic;
  signal signature_invalid_intern         : std_logic;
  signal signature_invalid_intern_delayed : std_logic_vector(29 downto 0) := (others => '0');

  signal encoder_finished : std_logic := '0';
  signal encoder_ok       : std_logic := '0';


  
begin

  signature_invalid <= signature_invalid_intern;
  process(clk)
  begin  -- process
    if rising_edge(clk) then
      z1_rst           <= '0';
      z2_rst           <= '0';
      code_rst         <= '0';
      encoder_finished <= '0';
      encoder_ok       <= '0';

      signature_invalid_intern_delayed <= signature_invalid_intern & signature_invalid_intern_delayed(signature_invalid_intern_delayed'length-1 downto 1);
      if signature_invalid_intern_delayed(0) = '1' then
        code_rst <= '1';
        z1_rst <= '1';
        z2_rst <= '1';
      end if;

      if cnt < 15 then
        cnt <= cnt+1;
      else
        ap_rst <= '0';
      end if;

      shift_reg <= shift_reg(shift_reg'length-2 downto 0) & ap_done;

      if shift_reg(shift_reg'length-1) = '1' then
        --ap_rst <= '1';
      end if;

      if ap_done = '1' then
        encoder_finished <= '1';
        if ap_return = "1" then
          encoder_ok <= '1';
        else
          encoder_ok <= '0';
        end if;
        --z1_rst <= '1';
        --z2_rst <= '1';
      end if;

      z1_final_addr_reg <= z1_final_addr;
      ap_start          <= '0';
      if unsigned(z1_final_addr_reg) = 0 and unsigned(z1_final_addr) = 1 then
        ap_start <= '1';
      end if;
    end if;
  end process;

  z1_empty_n <= z1_empty xor '1';
  z2_empty_n <= z2_empty xor '1';
  
  huffman_encoder_2 : entity work.huffman_encoder
    port map (
      ap_clk          => clk,
      ap_rst          => ap_rst,
      ap_start        => ap_start,
      ap_done         => ap_done,
      ap_idle         => ap_idle,
      ap_ready        => ap_ready,
      z1_V_V_dout     => z1_dout,
      z1_V_V_empty_n  => z1_empty_n,
      z1_V_V_read     => z1_rd_en,
      z2_V_V_dout     => z2_dout,
      z2_V_V_empty_n  => z2_empty_n,
      z2_V_V_read     => z2_rd_en,
      code_V_V_din    => code_V_din,
      code_V_V_full_n => code_V_full_n,
      code_V_V_write  => code_V_write,
      --debug          => debug,
      --debug_ap_vld   => debug_ap_vld ,
      ap_return       => ap_return
      );


  z1_wr_en <= z1_final_valid;
  z1_din   <= std_logic_vector(resize(signed(z1_final), z1_din'length));
  --No used: z1_full should never be raised
  --assert z1_full /= '1' report "Z1 Overflow" severity error;
  z1_fifo_1 : entity work.z1_fifo
    port map (
      clk   => clk,
      din   => z1_din,
      rst   => z1_rst,
      wr_en => z1_wr_en,
      rd_en => z1_rd_en,
      dout  => z1_dout,
      full  => z1_full,
      empty => z1_empty
      );


  z2_wr_en <= z2_final_valid;
  z2_din   <= std_logic_vector(resize(signed(z2_final), z2_din'length));
  --assert z2_full /= '1' report "Z2 Overflow" severity error;
  z2_fifo_2 : entity work.z2_fifo
    port map (
      clk          => clk,
      rst          => z2_rst,
      din          => z2_din,
      wr_en        => z2_wr_en,
      rd_en        => z2_rd_en,
      dout         => z2_dout,
      full         => z2_full,
      almost_full  => z2_almost_full,
      empty        => z2_empty,
      almost_empty => z2_almost_empty
      );


  bliss_sign_top_1 : entity work.bliss_sign_top
    generic map (
      PARAMETER_SET => PARAMETER_SET,
      KECCAK_SLICES => KECCAK_SLICES,
      CORES         => CORES,
      PRIME_P       => PRIME_P ,
      ZETA          => ZETA
      )
    port map (
      clk               => clk,
      ready             => ready,
      sign              => sign,
      ready_message     => ready_message,
      message_finished  => message_finished,
      stop_engine       => stop_engine,
      engine_stoped     => engine_stoped,
      load_public_key   => load_public_key,
      signature_ready   => signature_ready,
      signature_valid   => signature_valid,
      signature_invalid => signature_invalid_intern,
      message_din       => message_din,
      message_valid     => message_valid,
      s1_addr           => s1_addr,
      s1_in             => s1_in,
      s1_wr_en          => s1_wr_en,
      s2_addr           => s2_addr,
      s2_in             => s2_in,
      s2_wr_en          => s2_wr_en,
      public_key_addr   => public_key_addr,
      public_key_data   => public_key_data,
      final_c_pos       => final_c_pos,
      final_c_pos_valid => final_c_pos_valid,
      encoder_finished  => encoder_finished,
      encoder_ok        => encoder_ok ,
      z1_final          => z1_final,
      z1_final_addr     => z1_final_addr,
      z1_final_valid    => z1_final_valid,
      z2_final          => z2_final,
      z2_final_addr     => z2_final_addr,
      z2_final_valid    => z2_final_valid
      );

end Behavioral;

