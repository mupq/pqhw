--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.lattice_processor.all;


entity super_ram is
  generic (
    ADDR_WIDTH    : integer    := 9;
    ELEMENTS      : integer    := 512;
    RAMS          : integer    := 2;
    MAX_RAM_WIDTH : integer    := 14;
    INIT_ARRAY    : init_array_t:=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    RAM_WIDTHs    : my_array_t := (14, 14, 0, 0, 0, 0, 0, 0, 0, 0)
    );
  port (
    clk : in std_logic;

    delay : out integer := 6;

    rams_a_addr : in  std_logic_vector(ADDR_WIDTH*RAMS-1 downto 0);
    rams_a_do   : out std_logic_vector(MAX_RAM_WIDTH*RAMS-1 downto 0);
    rams_b_addr : in  std_logic_vector(ADDR_WIDTH*RAMS-1 downto 0);
    rams_b_di   : in  std_logic_vector(MAX_RAM_WIDTH*RAMS-1 downto 0) := (others => '0');
    rams_b_we   : in  std_logic_vector(RAMS-1 downto 0)               := (others => '0')

    );
end super_ram;

architecture Behavioral of super_ram is

begin
  --Generate the memories. Get init_vector returns a path to the init vector.
  gen_rams : for i in 0 to RAMS-1 generate
    bram_with_delay_1 : entity work.bram_with_delay
      generic map (
        SIZE       => ELEMENTS,
        ADDR_WIDTH => ADDR_WIDTH,
        COL_WIDTH  => RAM_WIDTHs(i),
        add_reg_a  => 2,
        add_reg_b  => 2,
        InitFile   => get_init_vector(INIT_ARRAY(i))
        )
      port map (
        clka  => clk,
        clkb  => clk,
        ena   => '1',
        enb   => '1',
        wea   => open,
        web   => rams_b_we(i),
        addra => rams_a_addr(i*ADDR_WIDTH+ADDR_WIDTH-1 downto i*ADDR_WIDTH),
        addrb => rams_b_addr(i*ADDR_WIDTH+ADDR_WIDTH-1 downto i*ADDR_WIDTH),
        dia   => open,
        dib   => rams_b_di(i*MAX_RAM_WIDTH + RAM_WIDTHs(i)-1 downto i* MAX_RAM_WIDTH),
        doa   => rams_a_do(i*MAX_RAM_WIDTH + RAM_WIDTHs(i)-1 downto i* MAX_RAM_WIDTH),
        dob   => open
        );
  end generate gen_rams;

end Behavioral;

