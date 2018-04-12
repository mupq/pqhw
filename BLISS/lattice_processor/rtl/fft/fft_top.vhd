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
-- Create Date:    13:31:08 03/20/2012 
-- Design Name: 
-- Module Name:    fft_top - Behavioral 
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


entity fft_top is
  generic (
    N_ELEMENTS    : integer := 512;
    PRIME_P_WIDTH : integer := 14;
    XN            : integer := -1
    );
  port (
    clk           : in  std_logic;
    usr_start     : in  std_logic;
    usr_inverse   : in  std_logic;      --0=normal FFT, 1=inverse FFT
    usr_finished  : out std_logic;
    --connection to w table
    w_psi_req     : out std_logic;
    w_inverse_req : out std_logic;
    w_index       : out unsigned(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0)         := (others => '0');
    w_out_val     : in  unsigned(PRIME_P_WIDTH-1 downto 0)                                 := (others => '0');
    w_delay       : in  integer;
    --connection to arithmetic unit
    a_w_in        : out unsigned(PRIME_P_WIDTH-1 downto 0)                                 := (others => '0');
    a_a_in        : out unsigned(PRIME_P_WIDTH-1 downto 0)                                 := (others => '0');
    a_b_in        : out unsigned(PRIME_P_WIDTH-1 downto 0)                                 := (others => '0');
    a_x_add_out   : in  unsigned(PRIME_P_WIDTH-1 downto 0)                                 := (others => '0');
    a_x_sub_out   : in  unsigned(PRIME_P_WIDTH-1 downto 0)                                 := (others => '0');
    a_delay       : in  integer                                                            := 1;
    --Storing/Requesting of coefficients
    bram_addra    : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    bram_doa      : in  std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');
    bram_addrb    : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    bram_dib      : out std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');
    bram_web      : out std_logic                                                          := '0';
    bram_addrc    : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    bram_dic      : out std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');
    bram_wec      : out std_logic                                                          := '0';
    bram_addrd    : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    bram_dod      : in  std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');



    bram_delay : in integer
    );
end fft_top;

architecture Behavioral of fft_top is

  signal addr_start    : std_logic;
  signal addr_finished : std_logic;
  signal addr_valid    : std_logic;
  signal addr_a        : unsigned(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal addr_b        : unsigned(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal addr_n        : unsigned(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');


  signal fft_fin_rin  : std_logic_vector(0 downto 0) := (others => '0');
  signal fft_fin_rout : std_logic_vector(0 downto 0) := (others => '0');

  signal wr_coeff_reg_rin : std_logic_vector(0 downto 0) := (others => '0');

  signal bram_addra_intern : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal bram_addrd_intern : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');

  signal working  : std_logic := '0';
  signal sel_addr : std_logic := '0';
  --signal addr_start_delayed : std_logic := '0';

  signal inverse : std_logic := '0';

  signal a_pre_mar : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal b_pre_mar : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');

  signal desr_val1_out : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal desr_val2_out : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal desr_rin      : std_logic_vector(0 downto 0)               := (others => '0');
  signal desr_rout     : std_logic_vector(0 downto 0)               := (others => '0');
  signal desr_en       : std_logic                                  := '0';

  signal max_in_delay     : integer := 1;
  signal w_table_delay    : integer := 0;
  signal bram_table_delay : integer := 0;

  signal max_in_delay_intern     : integer := 0;
  signal w_table_delay_intern    : integer := 0;
  signal bram_table_delay_intern : integer := 0;

  signal desr_reg_delay : integer := 5;
  signal op_delay       : integer := 0;

  signal wr_coeff_reg_delay : integer := 0;
  signal wr_coeff           : std_logic_vector(0 downto 0);

  signal addr_b_reg_delay   : integer := 0;
  signal finished_reg_delay : integer := 0;
  
begin



  max_in_delay_intern     <= bram_delay                     when bram_delay > w_delay               else w_delay;
  w_table_delay_intern    <= max_in_delay_intern-w_delay    when max_in_delay_intern-w_delay > 0    else 0;
  bram_table_delay_intern <= max_in_delay_intern-bram_delay when max_in_delay_intern-bram_delay > 0 else 0;

  max_in_delay     <= max_in_delay_intern     when (max_in_delay_intern mod 2) = 0 else max_in_delay_intern+1;
  w_table_delay    <= w_table_delay_intern    when (max_in_delay_intern mod 2) = 0 else w_table_delay_intern+1;
  bram_table_delay <= bram_table_delay_intern when (max_in_delay_intern mod 2) = 0 else bram_table_delay_intern+1;


  --TODO XXX HACK
  --  a_w_in <= unsigned(w_pre_mar);

  a_w_in <= unsigned(w_out_val);

  brama_reg_11 : entity work.dyn_shift_reg
    generic map (
      max_depth => 15,
      width     => bram_doa'length
      )
    port map (
      clk    => clk,
      depth  => bram_table_delay,
      Input  => bram_doa,
      Output => a_pre_mar
      );

  brama_reg_12 : entity work.dyn_shift_reg
    generic map (
      max_depth => 15,
      width     => bram_doa'length
      )
    port map (
      clk    => clk,
      depth  => bram_table_delay,
      Input  => bram_dod,
      Output => b_pre_mar
      );



  --de_ser_1 : entity work.de_ser
  --  generic map (
  --    WIDTH => PRIME_P_WIDTH
  --    )
  --  port map (
  --    clk      => clk,
  --    en       => desr_en,
  --    val_in   => ab_pre_mar,
  --    val1_out => desr_val1_out,
  --    val2_out => desr_val2_out
  --    );

  a_a_in <= unsigned(a_pre_mar);
  a_b_in <= unsigned(b_pre_mar);


  --desr_reg_delay <= max_in_delay;
  --desr_rin(0)    <= addr_valid;
  --desr_en        <= desr_rout(0);
  --desr_reg_1 : entity work.dyn_shift_reg
  --  generic map (
  --    width => 1
  --    )
  --  port map (
  --    clk    => clk,
  --    depth  => desr_reg_delay,
  --    Input  => desr_rin,
  --    Output => desr_rout
  --    );


  fft_addr_gen_1 : entity work.fft_addr_gen
    generic map (
      N_ELEMENTS => N_ELEMENTS
      )
    port map (
      clk      => clk,
      start    => addr_start,
      finished => addr_finished,
      valid    => addr_valid,
      a        => addr_a,
      b        => addr_b,
      n        => addr_n,
      op       => open
      );


  
  bram_addra_intern <= std_logic_vector(addr_a);
  bram_addra        <= bram_addra_intern;

  bram_addrd_intern <= std_logic_vector(addr_b);
  bram_addrd        <= bram_addrd_intern;

  bram_dib <= std_logic_vector(a_x_add_out);
  bram_web <= wr_coeff(0);

  bram_dic <= std_logic_vector(a_x_sub_out);
  bram_wec <= wr_coeff(0);

  wr_coeff_reg_delay  <= a_delay + max_in_delay;
  wr_coeff_reg_rin(0) <= addr_valid;
  wr_coeff_reg_1 : entity work.dyn_shift_reg
    generic map (
       max_depth => 25,
      width => 1
      
      )
    port map (
      clk    => clk,
      depth  => wr_coeff_reg_delay,
      Input  => wr_coeff_reg_rin,
      Output => wr_coeff
      );

  addr_b_reg_delay <= max_in_delay + a_delay;
  addr_b_reg_1 : entity work.dyn_shift_reg
    generic map (
       max_depth => 15,
      width => bram_addra_intern'length
      )
    port map (
      clk    => clk,
      depth  => addr_b_reg_delay,
      Input  => bram_addra_intern,
      Output => bram_addrb
      );


  addr_b_reg_2 : entity work.dyn_shift_reg
    generic map (
      max_depth => 15,
      width => bram_addra_intern'length
      )
    port map (
      clk    => clk,
      depth  => addr_b_reg_delay,
      Input  => bram_addrd_intern,
      Output => bram_addrc
      );

  
  

  finished_reg_delay <= max_in_delay + a_delay + bram_delay;
  finished_ref_reg_1 : entity work.dyn_shift_reg
    generic map (
      max_depth => 45,
      width     => 1
      )
    port map (
      clk    => clk,
      depth  => finished_reg_delay,
      Input  => fft_fin_rin,
      Output => fft_fin_rout
      );

  usr_finished <= fft_fin_rout(0);



  ----input register transfer
  process (clk)
  begin
    if rising_edge(clk) then
      w_psi_req      <= '0';            --FFT does not need psi
      fft_fin_rin(0) <= '0';


      --Trigger the beginning of the FFT
      if usr_start = '1' then
        working       <= '1';
        addr_start    <= '1';
        w_inverse_req <= usr_inverse;   --determine if we perform FFT or IFFT
      end if;


      --    --Do the work
      if working = '1' then
        addr_start <= '0';

        if addr_valid = '1' then
          w_index <= addr_n;
        else
        end if;
      end if;

      if addr_finished = '1' then
        working        <= '0';
        fft_fin_rin(0) <= '1';
      end if;

      
    end if;
  end process;


end Behavioral;

