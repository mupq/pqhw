----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:14:25 02/28/2014 
-- Design Name: 
-- Module Name:    PAPER_POLY_MUL - Behavioral 
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

entity PAPER_POLY_MUL is
   generic (
    MODE : string := "BOTH"
    );
  port (
    clk : in std_logic;

    data_avail  : out std_logic := '0';
    copy_data   : in  std_logic := '0';
    data_copied : out std_logic := '0';

    data_out : out std_logic_vector(13 downto 0);
    addr_out : out std_logic_vector(8 downto 0);

    we_ayy : out std_logic;
    we_y1  : out std_logic;
    we_y2  : out std_logic;

    ver_rd_fin : out std_logic := '0';

    command  : in  std_logic_vector(LYU_ARITH_COMMAND_SIZE-1 downto 0) := LYU_ARITH_SIGN_MODE;
    finished : out std_logic;

    data_in : in  std_logic_vector(13 downto 0) := (others => '0');  --For verify
    addr_in : out std_logic_vector(8 downto 0)  --For verify
    );
end PAPER_POLY_MUL;

architecture Behavioral of PAPER_POLY_MUL is

begin

  bliss_processor_1:entity work.bliss_processor
    generic map (
      MODE               => MODE
      )
    port map (
      clk         => clk,
      data_avail  => data_avail,
      copy_data   => copy_data,
      data_copied => data_copied,
      data_out    => data_out,
      addr_out    => addr_out,
      we_ayy      => we_ayy,
      we_y1       => we_y1,
      we_y2       => we_y2,
      ver_rd_fin  => ver_rd_fin,
      command     => command,
      finished    => finished,
      data_in     => data_in,
      addr_in     => addr_in);
end Behavioral;

