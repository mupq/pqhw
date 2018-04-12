----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:01:35 03/30/2012 
-- Design Name: 
-- Module Name:    inv_n_mul_add - Behavioral 
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



entity inv_n_mul_add is
  generic (
    N_ELEMENTS    : integer := 32;
    N_INVERSE     : unsigned := to_unsigned(33,10);
    PRIME_P_WIDTH : integer := 10;
    XN            : integer := -1
    );
  port(
    clk          : in  std_logic;
    usr_start    : in  std_logic                                                          := '0';
    usr_finished : out std_logic                                                          := '0';
     --connection to arithmetic unit
    a_op         : out std_logic_vector(0 downto 0)                                       := (others => '0');
    a_w_in       : out unsigned(PRIME_P_WIDTH-1 downto 0);
    a_a_in       : out unsigned(PRIME_P_WIDTH-1 downto 0);
    a_b_in       : out unsigned(PRIME_P_WIDTH-1 downto 0);
    a_x_out      : in  unsigned(PRIME_P_WIDTH-1 downto 0);
    a_delay      : in  integer                                                            := 35;
    --Connection to RAM
    bram_delay   : in  integer                                                            := 10;
    bram_addra   : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    bram_doa     : in  std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');

    bram_addrb : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    bram_dib   : out std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');
    bram_web   : out std_logic                                                          := '0'
    );

end inv_n_mul_add;

architecture Behavioral of inv_n_mul_add is
  constant GEN_ADDR_WIDTH : integer                         := integer(ceil(log2(real(N_ELEMENTS))));
  signal   Working        : std_logic                       := '0';
  signal   counter        : integer range 0 to N_ELEMENTS-1 := 0;


  signal coeff_pre_mar : std_logic_vector(PRIME_P_WIDTH-1 downto 0);

  --Registers + delays
  signal max_in_delay     : integer := 10;
  signal bram_table_delay : integer := 0;

  signal max_in_delay_intern     : integer := 5;
  signal bram_table_delay_intern : integer := 5;


  signal bram_addrb_rin : std_logic_vector(GEN_ADDR_WIDTH-1 downto 0) := (others => '0');
  signal bram_web_rin   : std_logic_vector(0 downto 0)                := (others => '0');
  signal bram_web_rout  : std_logic_vector(0 downto 0)                := (others => '0');

  signal fin_reg_rout : std_logic_vector(0 downto 0) := (others => '0');
  signal fin_reg_rin  : std_logic_vector(0 downto 0) := (others => '0');

  signal coeff_reg_rout : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');

  signal bram_addrb_reg_depth : integer := 0;
  signal bram_web_reg_depth   : integer := 0;
  signal fin_reg_depth        : integer := 0;
  signal coeff_reg_delay      : integer := 0;
begin


  --Input of MAR
  a_op(0) <= '0';
  a_w_in  <= N_INVERSE;
  a_b_in  <= unsigned(coeff_pre_mar);
  a_a_in  <= (others => '0');

  bram_dib <= std_logic_vector(a_x_out);

  max_in_delay    <= bram_delay;
  brama_reg_11 : entity work.dyn_shift_reg
    generic map (
      width => bram_doa'length
      )
    port map (
      clk    => clk,
      depth  => bram_table_delay,
      Input  => bram_doa,
      Output => coeff_pre_mar
      );


  bram_addrb_reg_depth <= max_in_delay + a_delay;
  bramc_addrc_reg_1 : entity work.dyn_shift_reg
    generic map (
      width => bram_addrb'length
      )
    port map (
      clk    => clk,
      depth  => bram_addrb_reg_depth,
      Input  => bram_addrb_rin,
      Output => bram_addrb
      );


  bram_web_reg_depth <= max_in_delay + a_delay;
  bram_web           <= bram_web_rout(0);
  bramc_wec_reg_1 : entity work.dyn_shift_reg
    generic map (
      width => 1
      )
    port map (
      clk    => clk,
      depth  => bram_web_reg_depth,
      Input  => bram_web_rin,
      Output => bram_web_rout
      );

  
  fin_reg_depth <= max_in_delay + a_delay;
  usr_finished  <= fin_reg_rout(0);
  fin_reg_1 : entity work.dyn_shift_reg
    generic map (
      width => 1
      )
    port map (
      clk    => clk,
      depth  => fin_reg_depth,
      Input  => fin_reg_rin,
      Output => fin_reg_rout
      );

  --Wire connection between  W_TABLE/BRAM into MAR

  process (clk)
  begin
    if rising_edge(clk) then
      bram_web_rin(0) <= '0';
      fin_reg_rin(0)  <= '0';

      if usr_start = '1' then
        working <= '1';
      end if;

      if (usr_start = '1' or working = '1')  then
        bram_addra      <= std_logic_vector(to_unsigned(counter, bram_addra'length));
        bram_addrb_rin  <= std_logic_vector(to_unsigned(counter, bram_addrb_rin'length));
        bram_web_rin(0) <= '1';

        if counter = N_ELEMENTS-1 then
          working        <= '0';
          counter        <= 0;
          fin_reg_rin(0) <= '1';
        else
          counter <= counter+1;
        end if;
      end if;
    end if;
  end process;

end Behavioral;

