----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:24:57 08/12/2014 
-- Design Name: 
-- Module Name:    PAPER_HUFF_DECODE_I - Behavioral 
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
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PAPER_HUFF_DECODE_I is
  port (
    ap_clk : IN STD_LOGIC;
    ap_rst : IN STD_LOGIC;
    ap_start : IN STD_LOGIC;
    ap_done : OUT STD_LOGIC;
    ap_idle : OUT STD_LOGIC;
    ap_ready : OUT STD_LOGIC;
    code_V_V_dout : IN STD_LOGIC_VECTOR (31 downto 0);
    code_V_V_empty_n : IN STD_LOGIC;
    code_V_V_read : OUT STD_LOGIC;
    z1_V_V_din : OUT STD_LOGIC_VECTOR (13 downto 0);
    z1_V_V_full_n : IN STD_LOGIC;
    z1_V_V_write : OUT STD_LOGIC;
    z2_V_V_din : OUT STD_LOGIC_VECTOR (2 downto 0);
    z2_V_V_full_n : IN STD_LOGIC;
    z2_V_V_write : OUT STD_LOGIC;
    ap_return : OUT STD_LOGIC_VECTOR (0 downto 0) );

end PAPER_HUFF_DECODE_I;

architecture Behavioral of PAPER_HUFF_DECODE_I is

begin

  huffman_decoder_1:entity work.huffman_decoder
    port map (
      ap_clk           => ap_clk,
      ap_rst           => ap_rst,
      ap_start         => ap_start,
      ap_done          => ap_done,
      ap_idle          => ap_idle,
      ap_ready         => ap_ready,
      code_V_V_dout    => code_V_V_dout,
      code_V_V_empty_n => code_V_V_empty_n,
      code_V_V_read    => code_V_V_read,
      z1_V_V_din       => z1_V_V_din,
      z1_V_V_full_n    => z1_V_V_full_n,
      z1_V_V_write     => z1_V_V_write,
      z2_V_V_din       => z2_V_V_din,
      z2_V_V_full_n    => z2_V_V_full_n,
      z2_V_V_write     => z2_V_V_write,
      ap_return        => ap_return);
end Behavioral;

