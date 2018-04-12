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
-- Create Date:    08:54:55 02/24/2014 
-- Design Name: 
-- Module Name:    cdt_sampler_dual_top - Behavioral 
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


entity cdt_sampler_dual_top is

  generic (
    PARAM_SET : integer := 1            --Bliss 1,2,3,4
    );
  port (
    clk                       : in  std_logic;
    --Only used for debuggi
    cdt_gauss_fifo_wr_en1_out : out std_logic                                                                          := '0';
    cdt_gauss_fifo_dout1_out  : out std_logic_vector(integer(ceil(log2(real(get_max_sigma(PARAM_SET)))))-1+1 downto 0) := (others => '0');
    ---------------------------------------------------------------------------
    gauss_fifo_full1          : in  std_logic                                                                          := '1';
    gauss_fifo_wr_en1         : out std_logic;
    gauss_fifo_dout1          : out std_logic_vector(integer(ceil(log2(real(get_max_sigma(PARAM_SET)))))-1+1 downto 0)
    );

end cdt_sampler_dual_top;

architecture Behavioral of cdt_sampler_dual_top is
  --Some definitions
  --Maximum value sampled by the smaller sampler
  constant MAX_INDEX      : integer := get_cdt_max_index(PARAM_SET);
  --Always sample bytes
  constant UNIFORM_BITS   : integer := 8;
  --Determines size of the buffer
  constant MAX_RAND_BYTES : integer := 64;


  signal trivium1_rst    : std_logic                     := '1';
  signal trivium1_clk_en : std_logic                     := '1';
  signal trivium1_key    : std_logic_vector(79 downto 0) := x"67c6697351ff4aec29cd";
  signal trivium1_IV     : std_logic_vector(79 downto 0) := x"baabf2fbe3457cc254f8";
  signal trivium1_o_vld  : std_logic;
  signal trivium1_z      : std_logic;


  signal trivium2_rst    : std_logic                     := '1';
  signal trivium2_clk_en : std_logic                     := '1';
  signal trivium2_key    : std_logic_vector(79 downto 0) := x"1be1e78d765a2e63339f";
  signal trivium2_IV     : std_logic_vector(79 downto 0) := x"c99a66320db43158a35a";
  signal trivium2_o_vld  : std_logic;
  signal trivium2_z      : std_logic;

  signal trivium3_rst    : std_logic                     := '1';
  signal trivium3_clk_en : std_logic                     := '1';
  signal trivium3_key    : std_logic_vector(79 downto 0) := x"255d051758e95ed4abb2";
  signal trivium3_IV     : std_logic_vector(79 downto 0) := x"cdc69bb454160e827441";
  signal trivium3_o_vld  : std_logic;
  signal trivium3_z      : std_logic;


  signal cdt_gauss_fifo_full1  : std_logic                                                           := '1';
  signal cdt_gauss_fifo_wr_en1 : std_logic                                                           := '0';
  signal cdt_gauss_fifo_dout1  : std_logic_vector(integer(ceil(log2(real(MAX_INDEX))))-1+1 downto 0) := (others => '0');
  signal cdt_rand1_position    : std_logic_vector(5 downto 0)                                        := (others => '0');
  signal cdt_gauss_fifo_full2  : std_logic                                                           := '1';
  signal cdt_gauss_fifo_wr_en2 : std_logic                                                           := '0';
  signal cdt_gauss_fifo_dout2  : std_logic_vector(integer(ceil(log2(real(MAX_INDEX))))-1+1 downto 0) := (others => '0');
  signal cdt_rand2_position    : std_logic_vector(5 downto 0)                                        := (others => '0');
  signal cdt_rand1_addr_in     : std_logic_vector(5 downto 0)                                        := (others => '0');
  signal cdt_rand1_we          : std_logic                                                           := '0';
  signal cdt_rand1_din         : std_logic_vector(7 downto 0)                                        := (others => '0');
  signal cdt_rand2_addr_in     : std_logic_vector(5 downto 0)                                        := (others => '0');
  signal cdt_rand2_we          : std_logic                                                           := '0';
  signal cdt_rand2_din         : std_logic_vector(7 downto 0)                                        := (others => '0');

  signal uni_rand_rd_en        : std_logic;
  signal uni_rand_empty        : std_logic := '0';
  signal uni_rand_valid        : std_logic;
  signal uni_dout              : std_logic_vector(UNIFORM_BITS-1 downto 0);
  signal uni_full              : std_logic;
  signal uni_wr_en             : std_logic;
  signal uni_fifo_rd_en        : std_logic;
  signal uni_fifo_empty        : std_logic;
  signal uni_fifo_almost_empty : std_logic;
  signal uni_fifo_dout         : std_logic_vector(0 downto 0);

  type   eg_state is (IDLE , FILL, SAMPLE);
  signal state_reg   : eg_state := IDLE;
  signal counter     : integer  := 0;
  signal out_counter : integer  := 0;

  signal sampled_dual_counter       : integer                                                   := 0;
  signal cdt_gauss_fifo_dout1_dual1 : signed(integer(ceil(log2(real(MAX_INDEX))))-1+1 downto 0) := (others => '0');
  signal cdt_gauss_fifo_dout1_dual2 : signed(integer(ceil(log2(real(MAX_INDEX))))-1+1 downto 0) := (others => '0');

  signal wait_1     : std_logic := '1';
  signal uni_clk_en : std_logic := '0';

  signal uni_bits        : integer := 0;  --Measure random numbers used
  signal uni_bytes       : integer := 0;  --Measure random numbers used
  signal cycles          : integer := 0;
  signal samples_counter : integer := 0;

  signal write_sample_1 : std_logic;
signal sample_cnt : integer :=0;
  
begin

  cdt_gauss_fifo_wr_en1_out <= write_sample_1;
  cdt_gauss_fifo_dout1_out  <= std_logic_vector(resize(cdt_gauss_fifo_dout1_dual1, cdt_gauss_fifo_dout1_out'length));


  process(clk)
  begin  -- process
    if rising_edge(clk) then
      cycles <= cycles+1;
      if write_sample_1 = '1' then
        sample_cnt <= sample_cnt+1;
      end if;
    end if;
  end process;



  process(clk)
  begin  -- process
    if rising_edge(clk) then
      if cdt_gauss_fifo_wr_en1 = '1' then
        sampled_dual_counter <= sampled_dual_counter+1;
      end if;
    end if;
  end process;


  process(clk)
  begin  -- process
    if rising_edge(clk) then
      if uni_fifo_rd_en = '1' then
        uni_bits <= uni_bits +1;
      end if;
    end if;
  end process;


  process(clk)
  begin  -- process
    if rising_edge(clk) then
      if uni_wr_en = '1' then
        uni_bytes <= uni_bytes +1;
      end if;
    end if;
  end process;


  trivium_1 : entity work.trivium
    port map (
      clk    => clk,
      rst    => trivium1_rst,
      clk_en => trivium1_clk_en,
      key    => trivium1_key,
      IV     => trivium1_IV,
      o_vld  => trivium1_o_vld,
      z      => trivium1_z
      );

  
  trivium_2 : entity work.trivium
    port map (
      clk    => clk,
      rst    => trivium2_rst,
      clk_en => trivium2_clk_en,
      key    => trivium2_key,
      IV     => trivium2_IV,
      o_vld  => trivium2_o_vld,
      z      => trivium2_z
      );

  trivium_3 : entity work.trivium
    port map (
      clk    => clk,
      rst    => trivium3_rst,
      clk_en => trivium3_clk_en,
      key    => trivium3_key,
      IV     => trivium3_IV,
      o_vld  => trivium3_o_vld,
      z      => trivium3_z
      );

  
  uniform_sampler_dual_1 : entity work.uniform_sampler_dual
    generic map (
      UNIFORM_BITS => UNIFORM_BITS
      )
    port map (
      clk        => clk,
      clk_en     => uni_clk_en,
      rand_rd_en => uni_rand_rd_en,
      rand_empty => uni_rand_empty,
      rand_valid => uni_rand_valid,

      rand_din1 => trivium1_z,
      rand_din2 => trivium2_z,
      rand_din3 => trivium3_z,

      fifo_bit_rd_en        => uni_fifo_rd_en,
      fifo_bit_empty        => uni_fifo_empty,
      fifo_bit_almost_empty => uni_fifo_almost_empty,
      fifo_bit_dout         => uni_fifo_dout,

      dout  => uni_dout,
      full  => uni_full,
      wr_en => uni_wr_en
      );



  process(clk)
  begin  -- process cc
    if rising_edge(clk) then
      --Refill the ring buffer when data has been used
      cdt_rand1_we <= '0';

      case state_reg is
        when IDLE =>
          cdt_gauss_fifo_full1 <= '1';
          --Wait so that the Trivium gets ready to output random values
          if trivium1_o_vld = '1' and trivium2_o_vld = '1' and trivium3_o_vld = '1' then
            state_reg  <= FILL;
            uni_clk_en <= '1';
          end if;

        when FILL =>
          --Fill the buffer for the first time completely.
          if uni_wr_en = '1' then
            
            
            cdt_rand1_addr_in <= std_logic_vector(to_unsigned(counter, cdt_rand1_addr_in'length));
            cdt_rand1_din     <= uni_dout;
            cdt_rand1_we      <= '1';
            if counter < MAX_RAND_BYTES-1 then
              counter <= counter+1;
            else
              state_reg <= SAMPLE;
              counter   <= 0;
            end if;
          end if;


        when SAMPLE =>
          cdt_gauss_fifo_full1 <= '0';
          --Prevent that the ringer buffer is read too fasts
          if abs(to_integer(unsigned(cdt_rand1_position))-counter) > 10 then
            cdt_gauss_fifo_full1 <= '1';
          end if;

          if counter /= to_integer(unsigned(cdt_rand1_position)) then
            uni_clk_en <= '1';
            if uni_wr_en = '1' then
              cdt_rand1_addr_in <= std_logic_vector(to_unsigned(counter, cdt_rand1_addr_in'length));
              cdt_rand1_din     <= uni_dout;
              cdt_rand1_we      <= '1';
              if counter < MAX_RAND_BYTES-1 then
                counter <= counter+1;
              else
                counter <= 0;
              end if;
            end if;
          else
            uni_clk_en <= '0';
            
          end if;
      end case;
    end if;
  end process;


  process(clk)
  begin  -- process
    if rising_edge(clk) then
      wait_1 <= '0';

      if wait_1 = '0' then
        trivium1_rst <= '0';
        trivium2_rst <= '0';
        trivium3_rst <= '0';
      end if;

      uni_rand_empty <= '0';
      uni_rand_valid <= '0';
      uni_full       <= '0';

      if uni_rand_rd_en = '1' then
        uni_rand_valid <= '1';
      end if;
      
    end if;
  end process;



  --We just use one port of the dual sampler as this is fast enough for the scheme
  cdt_sampler_dual_1 : entity work.cdt_sampler_dual
    generic map (
      PARAM_SET => PARAM_SET
      )
    port map (
      clk               => clk,
      gauss_fifo_full1  => cdt_gauss_fifo_full1,
      gauss_fifo_wr_en1 => cdt_gauss_fifo_wr_en1,
      gauss_fifo_dout1  => cdt_gauss_fifo_dout1,
      rand1_position    => cdt_rand1_position,
      rand1_addr_in     => cdt_rand1_addr_in,
      rand1_we          => cdt_rand1_we,
      rand1_din         => cdt_rand1_din
      );


  process(clk)
  begin  -- process
    if rising_edge(clk) then
      --Construct the final sample
      gauss_fifo_wr_en1 <= '0';
      uni_fifo_rd_en    <= '0';
      write_sample_1    <= '0';

      if cdt_gauss_fifo_wr_en1 = '1' and out_counter = 0 then
        uni_fifo_rd_en <= '1';

        write_sample_1 <= '1';

        if uni_fifo_dout(0) = '1' then
          cdt_gauss_fifo_dout1_dual1 <= resize((signed("0"&cdt_gauss_fifo_dout1)), cdt_gauss_fifo_dout1_dual1'length);
        else
          cdt_gauss_fifo_dout1_dual1 <= resize((0-signed("0000"&cdt_gauss_fifo_dout1)), cdt_gauss_fifo_dout1_dual1'length);
        end if;
        out_counter <= out_counter+1;
      end if;

      if cdt_gauss_fifo_wr_en1 = '1' and out_counter = 1 then
        uni_fifo_rd_en <= '1';
        if uni_fifo_dout(0) = '1' then
          cdt_gauss_fifo_dout1_dual2 <= resize(signed("000"&cdt_gauss_fifo_dout1), cdt_gauss_fifo_dout1_dual2'length);
        else
          cdt_gauss_fifo_dout1_dual2 <= resize(0-signed("000"&cdt_gauss_fifo_dout1), cdt_gauss_fifo_dout1_dual2'length);
        end if;
        out_counter <= out_counter+1;
      end if;

      if out_counter = 2 and gauss_fifo_full1 = '0' then
        out_counter       <= 0;
        samples_counter   <= samples_counter+1;
        gauss_fifo_wr_en1 <= '1';

        --Final combination of both Gauss values
        if get_get_mul_factor(PARAM_SET) = 11 then
          gauss_fifo_dout1 <= std_logic_vector(resize(cdt_gauss_fifo_dout1_dual1 + cdt_gauss_fifo_dout1_dual2+2* cdt_gauss_fifo_dout1_dual2+8*cdt_gauss_fifo_dout1_dual2, gauss_fifo_dout1'length));
        elsif get_get_mul_factor(PARAM_SET) = 12 then
          --dual1 + k(=12) *dual2
          gauss_fifo_dout1 <= std_logic_vector(resize(cdt_gauss_fifo_dout1_dual1 + 4*cdt_gauss_fifo_dout1_dual2+8*cdt_gauss_fifo_dout1_dual2, gauss_fifo_dout1'length));
        end if;

      end if;
      
    end if;
  end process;
  
end Behavioral;




















