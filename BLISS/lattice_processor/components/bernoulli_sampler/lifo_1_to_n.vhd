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
-- Create Date:    08:30:38 02/03/2014 
-- Design Name: 
-- Module Name:    lifo_1_to_n - Behavioral 
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




entity lifo_1_to_n is
  generic (
    --Determines the number of output ports
    OUT_PORTS : integer := 5;
    WIDTH     : integer := 1;
    --Has to be power of two
    DEPTH     : integer := 32
    );
  port (
    clk : in std_logic;

    -- One input port
    din         : in  std_logic_vector(WIDTH-1 downto 0);
    wr_en       : in  std_logic;
    full        : out std_logic := '0';
    almost_full : out std_logic := '0';

    -- N output ports
    rd_en        : in  std_logic_vector(OUT_PORTS-1 downto 0)       := (others => '0');
    dout         : out std_logic_vector(OUT_PORTS*WIDTH-1 downto 0) := (others => '0');
    empty        : out std_logic_vector(OUT_PORTS-1 downto 0)       := (others => '0');
    almost_empty : out std_logic_vector(OUT_PORTS-1 downto 0)       := (others => '0');
    valid        : out std_logic_vector(OUT_PORTS-1 downto 0)       := (others => '0')
    );
end lifo_1_to_n;


architecture Behavioral of lifo_1_to_n is
  signal multi_din         : std_logic_vector(OUT_PORTS*WIDTH-1 downto 0) := (others => '0');
  signal multi_wr_en       : std_logic_vector(OUT_PORTS-1 downto 0)       := (others => '0');
  signal multi_full        : std_logic_vector(OUT_PORTS-1 downto 0)       := (others => '0');
  signal multi_almost_full : std_logic_vector(OUT_PORTS-1 downto 0)       := (others => '0');

  signal full_intern : std_logic;

begin

  --Check for full an almost full
  process (multi_almost_full, multi_full)
    variable temp_f   : std_logic := '1';
    variable temp_af : std_logic := '1';
  begin
    for i in 0 to OUT_PORTS-1 loop
      temp_f  := temp_f and multi_full(i);
      temp_af := temp_af and multi_almost_full(i);
    end loop;  -- i
    full        <= temp_f;
    full_intern <= temp_f;
    almost_full    <= temp_af;
    --Reset variable
    temp_f      := '1';
    temp_af     := '1';
  end process;



  process (din, multi_full, wr_en)
    variable written : std_logic := '0';
  begin  -- process
    --First all to zero
    multi_din   <= (others => '0');
    multi_wr_en <= (others => '0');

    if wr_en = '1' then
      --Now find a FIFO which can hold the input
      for i in 0 to OUT_PORTS-1 loop
        --Do nothing if no FIFO is free
        if multi_full(i) = '0' and written = '0' then
        --if multi_almost_full(i) = '0' and written = '0' then
          multi_wr_en(i)                            <= '1';
          multi_din(i*WIDTH+WIDTH-1 downto WIDTH*i) <= din;
          written                                   := '1';
        end if;
      end loop;  -- i

      --Debug check
      if written = '0' then
        report "Written to full FIFO" severity warning;
      end if;
    end if;
    written := '0';
  end process;



  LIFO_INST : for i in 0 to OUT_PORTS-1 generate
    --n_fifo_1 : entity work.gen_fifo
    n_lifo_1 : entity work.gen_lifo
      generic map (
        WIDTH => WIDTH,
        DEPTH => DEPTH
        )
      port map (
        clk         => clk,
        din         => multi_din(WIDTH*i+WIDTH-1 downto WIDTH*i),
        wr_en       => multi_wr_en(i),
        full        => multi_full(i),
        almost_full => multi_almost_full(i),

        rd_en => rd_en(i),
        dout  => dout(WIDTH*i+WIDTH-1 downto WIDTH*i),
        empty => empty(i),
        almost_empty => almost_empty(i),
        valid => valid(i)
        );
  end generate LIFO_INST;


end Behavioral;

