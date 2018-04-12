----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:26:50 04/13/2012 
-- Design Name: 
-- Module Name:    poly_mul_shared_w - Behavioral 
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



entity poly_mul_shared_w is

  generic (
    UNIT_CNT      : integer  := 1;
    XN            : integer  := -1;     --ring (-1 or 1)
    N_ELEMENTS    : integer  := 512;
    PRIME_P_WIDTH : integer  := 23;
    PRIME_P       : unsigned := to_unsigned(8383489, 23);
    PSI           : unsigned := to_unsigned(42205, 23);
    OMEGA         : unsigned := to_unsigned(3962357, 23);
    PSI_INVERSE   : unsigned := to_unsigned(3933218, 23);
    OMEGA_INVERSE : unsigned := to_unsigned(681022, 23);
    N_INVERSE     : unsigned := to_unsigned(8367115, 23)
    );
  port (
    clk        : in  std_logic;
    start      : in  std_logic;
    finished   : out std_logic := '0';
    a_constant : in  std_logic;

    --flow control
    a_ready  : out std_logic := '0';
    a_filled : out std_logic := '0';
    b_ready  : out std_logic := '0';
    b_filled : out std_logic := '0';


    --Used to input coefficients into the polynomial multiplier
    din_valid       : in  std_logic := '0';
    din_coefficient : in  unsigned(UNIT_CNT*PRIME_P_WIDTH-1 downto 0);
    din_finished    : out std_logic := '0';

    --Used as output
    dout_valid       : out std_logic;
    dout_coefficient : out unsigned(UNIT_CNT*PRIME_P_WIDTH-1 downto 0)
    );


end poly_mul_shared_w;

architecture Behavioral of poly_mul_shared_w is
  signal w_master_w_out_val      : unsigned(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal w_master_w_delay_intern : integer                            := 0;
begin

  poly_mul_top_1 : entity work.poly_mul_top
    generic map (
      XN            => XN,
      N_ELEMENTS    => N_ELEMENTS,
      PRIME_P_WIDTH => PRIME_P_WIDTH,
      PRIME_P       => PRIME_P,
      PSI           => PSI,
      OMEGA         => OMEGA,
      PSI_INVERSE   => PSI_INVERSE,
      OMEGA_INVERSE => OMEGA_INVERSE,
      W_TABLE_SLAVE => '0',
      N_INVERSE     => N_INVERSE
      )
    port map (
      clk      => clk,
      start    => start,
      finished => finished,

      a_constant => a_constant,
      a_ready    => a_ready,
      a_filled   => a_filled,
      b_ready    => b_ready,
      b_filled   => b_filled,

      din_valid               => din_valid,
      din_coefficient         => din_coefficient(PRIME_P_WIDTH-1 downto 0),
      din_finished            => din_finished,
      dout_valid              => dout_valid,
      dout_coefficient        => dout_coefficient(PRIME_P_WIDTH-1 downto 0),
      w_master_w_out_val      => w_master_w_out_val,
      w_master_w_delay_intern => w_master_w_delay_intern
      );


  Slaves : for cnt in 1 to UNIT_CNT-1 generate
    poly_mul_top_2 : entity work.poly_mul_top
      generic map (
        XN            => XN,
        N_ELEMENTS    => N_ELEMENTS,
        PRIME_P_WIDTH => PRIME_P_WIDTH,
        PRIME_P       => PRIME_P,
        PSI           => PSI,
        OMEGA         => OMEGA,
        PSI_INVERSE   => PSI_INVERSE,
        OMEGA_INVERSE => OMEGA_INVERSE,
        W_TABLE_SLAVE => '1',
        N_INVERSE     => N_INVERSE)
      port map (
        clk                    => clk,
        start                  => start,
        a_constant             => a_constant,
        din_valid              => din_valid,
        din_coefficient        => din_coefficient(cnt*PRIME_P_WIDTH+PRIME_P_WIDTH-1 downto cnt*PRIME_P_WIDTH),
        dout_coefficient       => dout_coefficient(cnt*PRIME_P_WIDTH+PRIME_P_WIDTH-1 downto cnt*PRIME_P_WIDTH),
        w_slave_w_out_val      => w_master_w_out_val,
        w_slave_w_delay_intern => w_master_w_delay_intern
        );   
  end generate Slaves;
  
end Behavioral;

