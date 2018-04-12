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
-- Create Date:    08:33:08 02/03/2014 
-- Design Name: 
-- Module Name:    gen_lifo - Behavioral 
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

--Implements FWFT
entity gen_lifo is
  generic (
    WIDTH : integer := 1;
    --Has to be power of two
    DEPTH : integer := 32
    );
  port (
    clk          : in  std_logic;
    srst         : in  std_logic                          := '0';
    din          : in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    wr_en        : in  std_logic                          := '0';
    rd_en        : in  std_logic                          := '0';
    dout         : out std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    full         : out std_logic                          := '0';
    almost_full  : out std_logic                          := '0';
    empty        : out std_logic                          := '0';
    almost_empty : out std_logic                          := '0';
    valid        : out std_logic                          := '0';
    data_count   : out std_logic_vector(integer(ceil(log2(real(DEPTH))))-1 downto 0)
    );
end gen_lifo;

architecture Behavioral of gen_lifo is
  constant ADDR_WIDTH : integer := integer(ceil(log2(real(DEPTH))));
  constant COL_WIDTH  : integer := WIDTH;

  signal ram_wea   : std_logic;
  signal ram_addra : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal ram_dia   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal ram_doa   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');

  signal ram_wea_test   : std_logic;
  signal ram_addra_test : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal ram_dia_test   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal ram_doa_test   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');


  signal EVAL_READ  : integer := 0;
  signal EVAL_WRITE : integer := 0;

  --Keeps track of the number of elements in the FIFO
  signal counter : integer range -1 to DEPTH+1 := -1;

  --Write and read pointers
  --signal ptr_w : unsigned(integer(ceil(log2(real(DEPTH))))-1 downto 0) := (others => '0');
  --signal ptr_r : unsigned(integer(ceil(log2(real(DEPTH))))-1 downto 0) := (others => '0');

  --signal dout_intern  : std_logic_vector(COL_WIDTH-1 downto 0) := (others => '0');
  --signal written_last : std_logic_vector(COL_WIDTH-1 downto 0) := (others => '0');

  signal reg_val : std_logic_vector(COL_WIDTH-1 downto 0) := (others => '0');

  signal output : std_logic := '0';

  component sp_ram_33_16
    port (
      a    : in  std_logic_vector(3 downto 0);
      d    : in  std_logic_vector(32 downto 0);
      clk  : in  std_logic;
      we   : in  std_logic;
      qspo : out std_logic_vector(32 downto 0)
      );
  end component;


  component sp_ram_1_32
    port (
      a   : in  std_logic_vector(4 downto 0);
      d   : in  std_logic_vector(0 downto 0);
      clk : in  std_logic;
      we  : in  std_logic;
      spo : out std_logic_vector(0 downto 0)
      );
  end component;


begin

  full         <= '1' when counter = DEPTH-1    else '0';
  almost_full  <= '1' when counter >= DEPTH-1-1 else '0';
  empty        <= '1' when counter = -1         else '0';
  almost_empty <= '1' when counter <= -1+1      else '0';


  data_count <= std_logic_vector(resize(to_unsigned(counter+1, data_count'length), data_count'length)) when counter < DEPTH-1 else std_logic_vector(to_unsigned(DEPTH-1, data_count'length));

  --fifo_ram : entity work.low_delay_dp_bram
  --  generic map (
  --    SIZE       => DEPTH,
  --    ADDR_WIDTH => ADDR_WIDTH,
  --    COL_WIDTH  => COL_WIDTH,
  --    InitFile   => ""
  --    )
  --  port map (
  --    clka  => clk,
  --    clkb  => clk,
  --    ena   => '1',
  --    enb   => '0',
  --    --a=write, b=read
  --    wea   => ram_wea,
  --    web   => '0',
  --    addra => ram_addra,
  --    addrb => open,
  --    dia   => ram_dia,
  --    dib   => open,                    --(others => '0'),
  --    doa   => ram_doa,
  --    dob   => open
  --    );


  --ram_33_16 : if DEPTH = 16 and WIDTH = 33 generate
  --  sp_ram_33_16_inst : sp_ram_33_16
  --    port map (
  --      a    => ram_addra,
  --      d    => ram_dia,
  --      clk  => clk,
  --      we   => ram_wea,
  --      qspo => ram_doa
  --      );

  --end generate ram_33_16;

  --ram_1_32 : if DEPTH = 32 and WIDTH = 1 generate
  --  ram_1_32_inst : sp_ram_1_32
  --    port map (
  --      a    => ram_addra,
  --      d    => ram_dia,
  --      clk  => clk,
  --      we   => ram_wea,
  --      spo => ram_doa
  --      );
  --end generate ram_1_32;

  --XXX TODO The inferred RAM behaves different than the generated RAM.
  --Especially when writing.

  --ram_addra_test <= ram_addra;
  --ram_wea_test <= ram_wea;
  --ram_dia_test <= ram_dia;
  -- ram_1_32 : if DEPTH = 32 and WIDTH = 1 generate
  --  ram_1_32_inst : sp_ram_1_32
  --    port map (
  --      a    => ram_addra_test,
  --      d    => ram_dia_test,
  --      clk  => clk,
  --      we   => ram_wea_test,
  --      spo => ram_doa_test
  --      );
  --end generate ram_1_32;


  --general_ram : if not (DEPTH = 16 and WIDTH = 33) and  not (DEPTH = 32 and WIDTH = 1)  generate
  --general_ram : if (DEPTH /= 32 and WIDTH /= 1)  generate
  fifo_ram : entity work.low_delay_sp_bram
    generic map (
      SIZE       => DEPTH,
      ADDR_WIDTH => ADDR_WIDTH,
      COL_WIDTH  => COL_WIDTH,
      InitFile   => ""
      )
    port map (
      clk   => clk,
      ena   => '1',
      --a=write, b=read
      wea   => ram_wea,
      addra => ram_addra,
      dia   => ram_dia,
      doa   => ram_doa
      );

-- end generate general_ram;

  dout <= reg_val when output = '1' else ram_doa;


  process(clk)
  begin  -- process
    if rising_edge(clk) then
      if wr_en = '1' then
        EVAL_WRITE <= EVAL_WRITE+1;
      end if;

      if rd_en = '1' then
        EVAL_READ <= EVAL_READ+1;
      end if;
    end if;
  end process;

  process (clk)
  begin  -- process
    if rising_edge(clk) then            -- rising clock edge
      --Write
      valid   <= '0';
      ram_wea <= '0';
      output  <= '0';

      if wr_en = '1' and rd_en = '1' then
        valid   <= '1';
        output  <= '1';
        reg_val <= din;
        
      elsif wr_en = '1' and counter < DEPTH-1 then
        ram_addra <= std_logic_vector(to_unsigned(counter+1, ram_addra'length));
        ram_wea   <= '1';
        ram_dia   <= din;
        counter   <= counter+1;
      elsif rd_en = '1' and counter >= 0 then
        if counter > 0 then
          ram_addra <= std_logic_vector(to_unsigned(counter-1, ram_addra'length));
        else
          ram_addra <= std_logic_vector(to_unsigned(counter, ram_addra'length));
        end if;
        counter <= counter-1;
        valid   <= '1';
      end if;

    end if;
  end process;
  

end Behavioral;

