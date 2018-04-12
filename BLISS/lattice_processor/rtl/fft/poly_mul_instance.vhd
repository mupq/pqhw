----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:36:13 03/29/2012 
-- Design Name: 
-- Module Name:    poly_mul_instance - Behavioral 
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

-- Uncomment the following li
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity poly_mul_instance is
  generic(
    XN            : integer := -1;      --ring (-1 or 1)
    PRIME_P_WIDTH : integer := 23;
    N_ELEMENTS    : integer := 512
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
    din_coefficient : in  unsigned(PRIME_P_WIDTH-1 downto 0);
    din_finished    : out std_logic := '0';

    --Used as output
    dout_valid       : out std_logic;
    dout_coefficient : out unsigned(PRIME_P_WIDTH-1 downto 0)

    );
end poly_mul_instance;

architecture Behavioral of poly_mul_instance is
 -- constant PRIME_P : unsigned(PRIME_P_WIDTH-1 downto 0) := to_unsigned(257, PRIME_P_WIDTH);
 -- constant PSI           : unsigned(PRIME_P_WIDTH-1 downto 0) := to_unsigned(3, PRIME_P_WIDTH);
 -- constant OMEGA         : unsigned(PRIME_P_WIDTH-1 downto 0) := to_unsigned(9, PRIME_P_WIDTH);
 -- constant PSI_INVERSE   : unsigned(PRIME_P_WIDTH-1 downto 0) := to_unsigned(5, PRIME_P_WIDTH);
--  constant OMEGA_INVERSE : unsigned(PRIME_P_WIDTH-1 downto 0) := to_unsigned(25, PRIME_P_WIDTH);
--  constant N_INVERSE : unsigned(PRIME_P_WIDTH-1 downto 0) := to_unsigned(255, PRIME_P_WIDTH);

  constant PRIME_P : unsigned(PRIME_P_WIDTH-1 downto 0) := to_unsigned(8383489, PRIME_P_WIDTH);
  constant PSI           : unsigned(PRIME_P_WIDTH-1 downto 0) := to_unsigned(42205, PRIME_P_WIDTH);
  constant OMEGA         : unsigned(PRIME_P_WIDTH-1 downto 0) := to_unsigned(3962357, PRIME_P_WIDTH);
  constant PSI_INVERSE   : unsigned(PRIME_P_WIDTH-1 downto 0) := to_unsigned(3933218, PRIME_P_WIDTH);
  constant OMEGA_INVERSE : unsigned(PRIME_P_WIDTH-1 downto 0) := to_unsigned(681022, PRIME_P_WIDTH);
  constant N_INVERSE : unsigned(PRIME_P_WIDTH-1 downto 0) := to_unsigned(8367115, PRIME_P_WIDTH);

begin
  poly_mul_top_1 : entity work.poly_mul_top
    generic map (
      N_ELEMENTS    => N_ELEMENTS,
      PRIME_P_WIDTH => PRIME_P_WIDTH,
      XN            => -1 ,
      PRIME_P       => PRIME_P,
      PSI           => PSI,
      OMEGA         => OMEGA,
      PSI_INVERSE   => PSI_INVERSE,
      OMEGA_INVERSE => OMEGA_INVERSE,
      N_INVERSE => N_INVERSE
      )
    port map (
      clk      => clk,
      start    => start,
      finished => finished,
      a_ready  => a_ready ,
      a_filled => a_filled,
      b_ready  => b_ready ,
      b_filled => b_filled ,

      a_constant       => a_constant,
      din_valid        => din_valid,
      din_coefficient  => din_coefficient,
      din_finished     => din_finished,
      dout_valid       => dout_valid,
      dout_coefficient => dout_coefficient
      );




  --poly_mul_top_1 : entity work.poly_mul_top
  --  generic map (
  --    --XN            => XN,
  --    --N_ELEMENTS    => N_ELEMENTS,
  --    --PRIME_P_WIDTH => PRIME_P_WIDTH,
  --    --PRIME_P       => PRIME_P,
  --    --PSI           => PSI,
  --    --OMEGA         => OMEGA,
  --    --PSI_INVERSE   => PSI_INVERSE,
  --    --OMEGA_INVERSE => OMEGA_INVERSE
  --    N_ELEMENTS    => 64,
  --    PRIME_P_WIDTH => PRIME_P_WIDTH,
  --    XN            => XN,
  --    PRIME_P       => to_unsigned(17, PRIME_P_WIDTH),
  --    PSI           => to_unsigned(3, PRIME_P_WIDTH),
  --    OMEGA         => to_unsigned(9, PRIME_P_WIDTH),
  --    PSI_INVERSE   => to_unsigned(6, PRIME_P_WIDTH),
  --    OMEGA_INVERSE => to_unsigned(2, PRIME_P_WIDTH)
  --    )
  --  port map (
  --    clk              => clk,
  --    start            => start,
  --    finished         => finished,
  --    a_constant       => a_constant,
  --    a_ready          => a_ready,
  --    a_filled         => a_filled,
  --    b_ready          => b_ready,
  --    b_filled         => b_filled,
  --    din_valid        => din_valid,
  --    din_coefficient  => din_coefficient,
  --    din_finished     => din_finished,
  --    dout_valid       => dout_valid,
  --    dout_coefficient => dout_coefficient
  --    );

end Behavioral;

