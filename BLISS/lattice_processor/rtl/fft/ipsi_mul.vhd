----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:24:03 03/30/2012 
-- Design Name: 
-- Module Name:    ipsi_mul - Behavioral 
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



entity ipsi_mul is
  generic (
    N_ELEMENTS    : integer := 256;
    PRIME_P_WIDTH : integer := 13;
    XN            : integer := -1
    );
  port(
    clk : in std_logic;

    usr_start     : in  std_logic                                                          := '0';
    usr_finished  : out std_logic                                                          := '0';
    --Table Psi
    w_psi_req     : out std_logic;
    w_inverse_req : out std_logic;
    w_index       : out unsigned(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0)         := (others => '0');
    w_out_val     : in  unsigned(PRIME_P_WIDTH-1 downto 0);
    w_delay       : in  integer                                                            := 5;
    --connection to arithmetic unit
    a_op          : out std_logic_vector(0 downto 0)                                       := (others => '0');
    a_w_in        : out unsigned(PRIME_P_WIDTH-1 downto 0);
    a_a_in        : out unsigned(PRIME_P_WIDTH-1 downto 0);
    a_b_in        : out unsigned(PRIME_P_WIDTH-1 downto 0);
    a_x_out       : in  unsigned(PRIME_P_WIDTH-1 downto 0);
    a_delay       : in  integer                                                            := 35;
    --Connection to RAM
    bram_delay    : in  integer                                                            := 10;
    bram_addra    : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    bram_doa      : in  std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');

    bram_addrb : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    bram_dib   : out std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');
    bram_web   : out std_logic                                                          := '0'
    );
end ipsi_mul;

architecture Behavioral of ipsi_mul is
  constant GEN_ADDR_WIDTH : integer                         := integer(ceil(log2(real(N_ELEMENTS))));
  signal   Working        : std_logic                       := '0';
  signal   counter        : integer range 0 to N_ELEMENTS-1 := 0;

  signal w_pre_mar     : std_logic_vector(w_out_val'length-1 downto 0) := (others => '0');
  signal coeff_pre_mar : std_logic_vector(w_out_val'length-1 downto 0) := (others => '0');


  --Registers + delays
  signal max_in_delay     : integer := 10;
  signal w_table_delay    : integer := 0;
  signal bram_table_delay : integer := 0;

  signal max_in_delay_intern     : integer := 5;
  signal w_table_delay_intern    : integer := 5;
  signal bram_table_delay_intern : integer := 5;


  signal bram_addrb_rin : std_logic_vector(GEN_ADDR_WIDTH-1 downto 0) := (others => '0');
  signal bram_web_rin   : std_logic_vector(0 downto 0)                := (others => '0');
  signal bram_web_rout  : std_logic_vector(0 downto 0)                := (others => '0');

  signal fin_reg_rout : std_logic_vector(0 downto 0) := (others => '0');
  signal fin_reg_rin  : std_logic_vector(0 downto 0) := (others => '0');

  signal bram_addrb_reg_depth : integer := 0;
  signal bram_web_reg_depth   : integer := 0;
  signal fin_reg_depth        : integer := 0;

  
begin

  max_in_delay_intern     <= bram_delay                     when bram_delay > w_delay               else w_delay;
  w_table_delay_intern    <= max_in_delay_intern-w_delay    when max_in_delay_intern-w_delay > 0    else 0;
  bram_table_delay_intern <= max_in_delay_intern-bram_delay when max_in_delay_intern-bram_delay > 0 else 0;

  max_in_delay     <= max_in_delay_intern     when (max_in_delay_intern mod 2) = 0 else max_in_delay_intern+1;
  w_table_delay    <= w_table_delay_intern    when (max_in_delay_intern mod 2) = 0 else w_table_delay_intern+1;
  bram_table_delay <= bram_table_delay_intern when (max_in_delay_intern mod 2) = 0 else bram_table_delay_intern+1;

  --Input of MAR
  a_op   <= (others => '0');
  a_w_in <= unsigned(w_pre_mar);
  a_b_in <= unsigned(coeff_pre_mar);
  a_a_in <= (others => '0');

  bram_dib <= std_logic_vector(a_x_out);

  w_table_reg_1 : entity work.dyn_shift_reg
    generic map (
      width => w_out_val'length
      )
    port map (
      clk    => clk,
      depth  => w_table_delay,
      Input  => std_logic_vector(w_out_val),
      Output => w_pre_mar
      );

  
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

  --Wire connection betweenof  W_TABLE/BRAM into MAR

  process (clk)
  begin
    if rising_edge(clk) then
      w_psi_req       <= '1';
      w_inverse_req   <= '1';
      bram_web_rin(0) <= '0';
      fin_reg_rin(0)  <= '0';

      if usr_start = '1' or working = '1' then
        working         <= '1';
        w_index         <= to_unsigned(counter, w_index'length);
        bram_addra      <= std_logic_vector(to_unsigned(counter, w_index'length));
        bram_addrb_rin  <= std_logic_vector(to_unsigned(counter, w_index'length));
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

