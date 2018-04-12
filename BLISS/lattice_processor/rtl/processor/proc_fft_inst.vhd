----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:34:11 11/30/2012 
-- Design Name: 
-- Module Name:    proc_fft_inst - Behavioral 
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
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.lattice_processor.all;
use ieee.math_real.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity proc_fft_inst is
  generic(
    XN            : integer := -1;      --ring (-1 or 1)
    PRIME_P_WIDTH : integer := 17;
    N_ELEMENTS    : integer := 128
    );
  port (
    clk : in std_logic;

    ntt_ready : out std_logic                                  := '0';
    ntt_start : in  std_logic                                  := '0';
    ntt_op    : in  std_logic_vector(NTT_INST_SIZE-1 downto 0) := (others => '0');

    --Allows access to the internal RAM structure
    -- Port 1 for the FFT
    fft_ram0_rd_addr : in std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    fft_ram0_rd_do   : out  std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');

    fft_ram0_wr_addr : in std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0);
    fft_ram0_wr_di   : in std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
    fft_ram0_wr_we   : in std_logic;

    -- Port 2 for the FFT
    fft_ram1_rd_addr : in std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    fft_ram1_rd_do   : out  std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');

    fft_ram1_wr_addr : in std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    fft_ram1_wr_di   : in std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');
    fft_ram1_wr_we   : in std_logic;

    --Exports the PE/MAR when in export mode so that it can be used by the
    --processors ALU
    mar_w_in      : in  unsigned(PRIME_P_WIDTH-1 downto 0) := (others => '0');
    mar_a_in      : in  unsigned(PRIME_P_WIDTH-1 downto 0) := (others => '0');
    mar_b_in      : in  unsigned(PRIME_P_WIDTH-1 downto 0) := (others => '0');
    mar_x_add_out : out unsigned(PRIME_P_WIDTH-1 downto 0) := (others => '0');
    mar_x_sub_out : out unsigned(PRIME_P_WIDTH-1 downto 0) := (others => '0');
    mar_delay     : out integer                            := 68;


    --Cycles counter: optional debugging port for cycle measurement
    cycles : out unsigned(31 downto 0) := (others => '0')

    );
end proc_fft_inst;

architecture Behavioral of proc_fft_inst is
 --Block RAMs/PE is only accessible when the general pupose command
  --INST_NTT_GP_MODE has been triggered. Afterwards the INST_NTT_NTT_MODE
  --command is need to allow FFT operations again
  --
  --
   constant PRIME_P       : unsigned(PRIME_P_WIDTH-1 downto 0) := to_unsigned(65537, PRIME_P_WIDTH);
  constant PSI           : unsigned(PRIME_P_WIDTH-1 downto 0) := to_unsigned(141, PRIME_P_WIDTH);
  constant OMEGA         : unsigned(PRIME_P_WIDTH-1 downto 0) := to_unsigned(19881, PRIME_P_WIDTH);
  constant PSI_INVERSE   : unsigned(PRIME_P_WIDTH-1 downto 0) := to_unsigned(63213, PRIME_P_WIDTH);
  constant OMEGA_INVERSE : unsigned(PRIME_P_WIDTH-1 downto 0) := to_unsigned(26942, PRIME_P_WIDTH);
  constant N_INVERSE     : unsigned(PRIME_P_WIDTH-1 downto 0) := to_unsigned(65025, PRIME_P_WIDTH);
  
begin

  

  proc_fft_1: entity work.proc_fft
    generic map (
      XN            => XN,
      N_ELEMENTS    => N_ELEMENTS,
      PRIME_P_WIDTH => PRIME_P_WIDTH,
      PRIME_P       => PRIME_P,
      PSI           => PSI,
      OMEGA         => OMEGA,
      PSI_INVERSE   => PSI_INVERSE,
      OMEGA_INVERSE => OMEGA_INVERSE,
      N_INVERSE     => N_INVERSE
      )
    port map (
      clk              => clk,
      ntt_ready        => ntt_ready,
      ntt_start        => ntt_start,
      ntt_op           => ntt_op,
      fft_ram0_rd_addr => fft_ram0_rd_addr,
      fft_ram0_rd_do   => fft_ram0_rd_do,
      fft_ram0_wr_addr => fft_ram0_wr_addr,
      fft_ram0_wr_di   => fft_ram0_wr_di,
      fft_ram0_wr_we   => fft_ram0_wr_we,
      fft_ram1_rd_addr => fft_ram1_rd_addr,
      fft_ram1_rd_do   => fft_ram1_rd_do,
      fft_ram1_wr_addr => fft_ram1_wr_addr,
      fft_ram1_wr_di   => fft_ram1_wr_di,
      fft_ram1_wr_we   => fft_ram1_wr_we,
      mar_w_in         => mar_w_in,
      mar_a_in         => mar_a_in,
      mar_b_in         => mar_b_in,
      mar_x_add_out    => mar_x_add_out,
      mar_x_sub_out    => mar_x_sub_out,
      mar_delay        => mar_delay,
      cycles           => open
      );


end Behavioral;

