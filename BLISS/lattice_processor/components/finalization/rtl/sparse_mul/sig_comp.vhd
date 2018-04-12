--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:20:05 02/06/2014 
-- Design Name: 
-- Module Name:    sig_comp - Behavioral 
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



entity sig_comp is
  generic (
    --------------------------General --------------------------------------
    N_ELEMENTS      : integer               := 512;
    PRIME_P_WIDTH   : integer               := 14;
    PRIME_P         : unsigned              := to_unsigned(12289, 14);
    ZETA            : unsigned              := to_unsigned(6145, 13);
    D_BLISS         : integer               := 10;
    MODULUS_P_BLISS : unsigned              := to_unsigned(24, 5);
    -----------------------  Sparse Mul Core ------------------------------------------
    CORES           : integer               := 8;
    KAPPA           : integer               := 23;
    WIDTH_S1        : integer               := 2;
    WIDTH_S2        : integer               := 3;
    --Used to initialize the right s (s1 or s2)
    INIT_TABLE      : integer               := 0;
    c_delay         : integer range 0 to 16 := 2;
    MAX_RES_WIDTH   : integer               := 6
    ---------------------------------------------------------------------------
    );
  port (
    clk : in std_logic;

    --start : in  std_logic := '0';
    --ready : out std_logic := '0';

    --Addr is used for all three ports (better sync)    
    addr_in : in std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    --Input is also used for all three ports (allows also to compute ay1+y2 on
    --the fly)
    data_in : in std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');

    --ay port (needs to be multiplied by zeta and y2 has to be added)
    ay1_wr_en :in std_logic := '0';
    --Y1 Port
    y1_wr_en  :in std_logic := '0';
    --Y2 Port
    y2_wr_en  : in std_logic := '0';


    --The u fifo
    u_keccak_data  : out std_logic_vector(MODULUS_P_BLISS'length-1 downto 0) := (others => '0');
    u_keccak_valid : out  std_logic                                           := '0';

    --The u ports
    u_out_data  : out std_logic_vector(PRIME_P'length+1-1 downto 0)                      := (others => '0');
    u_out_addr : in  std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');


    --The y ports
    y1_out_data : out std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
    y1_out_addr : in  std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');

    y2_out_data : out std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
    y2_out_addr : in  std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0')

    );
end sig_comp;

architecture Behavioral of sig_comp is

  constant ADDR_WIDTH          : integer                                       := integer(ceil(log2(real(N_ELEMENTS))));
  signal   data_in_intern      : std_logic_vector(data_in'range)               := (others => '0');
  signal   ay1_data_in_intern  : std_logic_vector(data_in'length+1-1 downto 0) := (others => '0');
  signal   ay1_data_out_intern : std_logic_vector(data_in'length+1-1 downto 0) := (others => '0');
  signal   ay1_data_out_intern_r1 : std_logic_vector(data_in'length+1-1 downto 0) := (others => '0');
  signal   ay1_data_out_intern_r2 : std_logic_vector(data_in'length+1-1 downto 0) := (others => '0');
  signal   ay1_data_out_intern_r3 : std_logic_vector(data_in'length+1-1 downto 0) := (others => '0');

  signal ay1_addr_intern : std_logic_vector(addr_in'range) := (others => '0');
  signal y1_addr_intern  : std_logic_vector(addr_in'range) := (others => '0');
  signal y2_addr_intern  : std_logic_vector(addr_in'range) := (others => '0');

  signal ay1_wr_en_intern : std_logic:= '0';
  signal y1_wr_en_intern  : std_logic:= '0';
  signal y2_wr_en_intern  : std_logic:= '0';

  signal zeta_valid_in  : std_logic:= '0';
  signal zeta_data_in   : std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
  signal zeta_addr_in   : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal zeta_valid_out : std_logic:= '0';
  signal zeta_data_out  : std_logic_vector(PRIME_P'length+1-1 downto 0)                      := (others => '0');
  signal zeta_addr_out  : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');


  signal drop_addr_in   : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal drop_ay_in     : std_logic_vector(PRIME_P'length+1-1 downto 0)                      := (others => '0');
  signal drop_y2_in     : std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
  signal drop_valid_out : std_logic;
  signal drop_data_out  : std_logic_vector(MODULUS_P_BLISS'length-1 downto 0)                := (others => '0');
  signal drop_addr_out  : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');

  signal drop_addr_in_r1   : std_logic_vector(drop_addr_in'range) := (others => '0');
  signal drop_addr_in_r2   : std_logic_vector(drop_addr_in'range) := (others => '0');
  signal drop_addr_in_r2_1 : std_logic_vector(drop_addr_in'range) := (others => '0');
  signal drop_addr_in_r2_2 : std_logic_vector(drop_addr_in'range) := (others => '0');

  signal drop_addr_in_r3   : std_logic_vector(drop_addr_in'range) := (others => '0');

  signal drop_y2_valid      : std_logic := '0';
  signal drop_y2_valid_r1   : std_logic := '0';
  signal drop_y2_valid_r2   : std_logic := '0';
  signal drop_y2_valid_r2_1 : std_logic := '0';
    signal drop_y2_valid_r2_2 : std_logic := '0';
  signal drop_y2_valid_r3   : std_logic := '0';

  signal drop_y2_in_r1   : std_logic_vector(drop_y2_in'range) := (others => '0');
  signal drop_y2_in_r2   : std_logic_vector(drop_y2_in'range) := (others => '0');
  signal drop_y2_in_r2_1 : std_logic_vector(drop_y2_in'range) := (others => '0');
  signal drop_y2_in_r2_2 : std_logic_vector(drop_y2_in'range) := (others => '0');
  signal drop_y2_in_r3   : std_logic_vector(drop_y2_in'range) := (others => '0');

  signal u_out_addr_intern         : std_logic_vector(drop_addr_in'range)        := (others => '0');
  signal ay1_data_in_port_b_intern : std_logic_vector(ay1_data_out_intern'range) := (others => '0');

  signal ay1_wr_en_port_b_intern : std_logic := '0';

  signal signed_drop_result : std_logic_vector(MODULUS_P_BLISS'length-1 downto 0);

 signal u_valid_out            : std_logic;
  signal u_data_out             : std_logic_vector(PRIME_P'length+1-1 downto 0)                := (others => '0');
  signal u_addr_out             : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
begin
  --If ay1_wr_en = 1 then wire data through the mulzeta unit
  --If y2_wr_en = 1 then also retrieve ay1 from RAM and add y1 and store u in RAM
  --If y1_wr_en = 1 then do no much


  --if drop_valid_out = '1' then
  --      ay1_wr_en_intern   <= drop_valid_out;
  --      ay1_data_in_intern <= std_logic_vector(resize(unsigned(drop_data_out), ay1_data_in_intern'length));
  --      ay1_addr_intern    <= drop_addr_out;
  --   end if;
  signed_drop_result <= drop_data_out;


  u_out_addr_intern         <= u_addr_out when u_valid_out = '1' else y2_out_addr;
  ay1_data_in_port_b_intern <= std_logic_vector(resize(unsigned(u_data_out), ay1_data_in_intern'length));
  ay1_wr_en_port_b_intern   <= u_valid_out;

  u_keccak_valid <= drop_valid_out;
  u_keccak_data  <= drop_data_out;



  mul_zeta_1 : entity work.mul_zeta
    generic map (
      N_ELEMENTS => N_ELEMENTS,
      PRIME_P    => PRIME_P,
      ZETA       => ZETA)
    port map (
      clk       => clk,
      valid_in  => zeta_valid_in,
      data_in   => zeta_data_in,
      addr_in   => zeta_addr_in,
      valid_out => zeta_valid_out,
      data_out  => zeta_data_out,
      addr_out  => zeta_addr_out
      );


  drop_bits_mod_p_1 : entity work.drop_bits_mod_p
    generic map (
      N_ELEMENTS      => N_ELEMENTS,
      PRIME_P         => PRIME_P,
      MODULUS_P_BLISS => MODULUS_P_BLISS,
      ZETA            => ZETA,
      D_BLISS         => D_BLISS
      )
    port map (
      clk       => clk,
      valid_in  => drop_y2_valid_r3,
      addr_in   => drop_addr_in_r3,
      ay_in     => ay1_data_out_intern,
      y2_in     => drop_y2_in_r3,
      valid_out => drop_valid_out,
      data_out  => drop_data_out,
      addr_out  => drop_addr_out,
        add_result_out       => u_data_out,
      add_result_addr_out  => u_addr_out,
      add_result_valid_out => u_valid_out 
      );


  
  
  process(clk)
  begin
    if rising_edge(clk) then

      zeta_valid_in      <= '0';
      ay1_wr_en_intern   <= '0';
      y1_wr_en_intern   <= '0';
      y2_wr_en_intern   <= '0';      
      drop_y2_valid      <= '0';
      drop_y2_valid_r1   <= drop_y2_valid;
      drop_y2_valid_r2   <= drop_y2_valid_r1;
      drop_y2_valid_r2_1 <= drop_y2_valid_r2;
 drop_y2_valid_r2_2 <=  drop_y2_valid_r2_1 ;
      drop_y2_valid_r3   <= drop_y2_valid_r2_2;

      drop_addr_in      <= (others => '0');
      drop_addr_in_r1   <= drop_addr_in;
      drop_addr_in_r2   <= drop_addr_in_r1;
      drop_addr_in_r2_1 <= drop_addr_in_r2;
drop_addr_in_r2_2 <= drop_addr_in_r2_1;
      drop_addr_in_r3   <= drop_addr_in_r2_2;

      drop_y2_in      <= (others => '0');
      drop_y2_in_r1   <= drop_y2_in;
      drop_y2_in_r2   <= drop_y2_in_r1;
      drop_y2_in_r2_1 <= drop_y2_in_r2;
      drop_y2_in_r2_2 <= drop_y2_in_r2_1;
      drop_y2_in_r3   <= drop_y2_in_r2_2;

      data_in_intern     <= data_in;
      ay1_data_in_intern <= std_logic_vector(resize(unsigned(data_in), ay1_data_in_intern'length));
      ay1_addr_intern    <= addr_in;
      y1_addr_intern     <= addr_in;
      y2_addr_intern     <= addr_in;



 ay1_data_out_intern_r2 <=      ay1_data_out_intern_r1;
       ay1_data_out_intern_r3 <=  ay1_data_out_intern_r2;
      ay1_data_out_intern <=        ay1_data_out_intern_r3;

        
      if zeta_valid_out = '1' then
        --If there is valid Zeta data we write it into the u/ay1 block RAM
        ay1_wr_en_intern   <= '1';
        ay1_data_in_intern <= std_logic_vector(resize(unsigned(zeta_data_out), ay1_data_in_intern'length));
        ay1_addr_intern    <= zeta_addr_out;
      end if;

      if ay1_wr_en = '1' then
        --Input has to go through the mulZenta module
        zeta_data_in  <= data_in;
        zeta_valid_in <= '1';
        zeta_addr_in  <= addr_in;
      end if;

      if y1_wr_en = '1' then
        --Simplest case. Just write the polynomial into the block ram. Nothing to do.
        y1_addr_intern  <= addr_in;
        y1_wr_en_intern <= y1_wr_en;
        data_in_intern  <= data_in;
      end if;



      if y2_wr_en = '1' then
        --Read out ay1 and the put ay1 and y2 into the dropBits module

        --write y2 (easy)
        y2_wr_en_intern <= y2_wr_en;
        y2_addr_intern  <= addr_in;
        data_in_intern  <= data_in;

        --Put y2 into the drop bits module
        drop_y2_valid <= y2_wr_en;
        drop_addr_in  <= addr_in;
        drop_y2_in    <= data_in;

        --read ay from the memory
        ay1_addr_intern <= addr_in;
        drop_y2_valid   <= '1';         --To signal that the value is good


        -- data will arrive on ay1_data_out_intern

      end if;

    end if;
  end process;


  --A port is connected to the input to the module
  bram_u1 : entity work.bram_with_delay
    generic map (
      SIZE       => N_ELEMENTS,
      ADDR_WIDTH => ADDR_WIDTH,
      COL_WIDTH  => PRIME_P_WIDTH+1,
      add_reg_a  => 0,
      add_reg_b  => 0,
      InitFile   => ""
      )
    port map (
      clka  => clk,
      clkb  => clk,
      ena   => '1',
      enb   => '1',
      wea   => ay1_wr_en_intern,
      web   => ay1_wr_en_port_b_intern,
      addra => ay1_addr_intern,
      addrb => u_out_addr_intern,
      dia   => ay1_data_in_intern,
      dib   => ay1_data_in_port_b_intern,
      doa   => ay1_data_out_intern_r1,
      dob   => u_out_data
      );


  --A port is connected to the input to the module
  bram_y1 : entity work.bram_with_delay
    generic map (
      SIZE       => N_ELEMENTS,
      ADDR_WIDTH => ADDR_WIDTH,
      COL_WIDTH  => PRIME_P_WIDTH,
      add_reg_a  => 0,
      add_reg_b  => 0,
      InitFile   => ""
      )
    port map (
      clka  => clk,
      clkb  => clk,
      ena   => '1',
      enb   => '1',
      wea   => y1_wr_en_intern,
      web   => '0',
      addra => y1_addr_intern,
      addrb => y1_out_addr,
      dia   => data_in_intern,
      dib   => open,
      doa   => open,
      dob   => y1_out_data
      );


  --A port is connected to the input to the module
  bram_y2 : entity work.bram_with_delay
    generic map (
      SIZE       => N_ELEMENTS,
      ADDR_WIDTH => ADDR_WIDTH,
      COL_WIDTH  => PRIME_P_WIDTH,
      add_reg_a  => 0,
      add_reg_b  => 0,
      InitFile   => ""
      )
    port map (
      clka  => clk,
      clkb  => clk,
      ena   => '1',
      enb   => '1',
      wea   => y2_wr_en_intern,
      web   => '0',
      addra => y2_addr_intern,
      addrb => y2_out_addr,
      dia   => data_in_intern,
      dib   => open,
      doa   => open,
      dob   => y2_out_data
      );


end Behavioral;

