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
-- Create Date:    14:31:09 02/04/2014 
-- Design Name: 
-- Module Name:    lifo_n_to_1 - Behavioral 
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


entity lifo_n_to_1 is
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
    din         : in  std_logic_vector(OUT_PORTS*WIDTH-1 downto 0) := (others => '0');
    wr_en       : in  std_logic_vector(OUT_PORTS-1 downto 0)       := (others => '0');
    full        : out std_logic_vector(OUT_PORTS-1 downto 0)       := (others => '0');
    almost_full : out std_logic_vector(OUT_PORTS-1 downto 0)       := (others => '0');

    -- N output ports
    out_lifo_full        : out std_logic                          := '0';
    out_lifo_almost_full : out std_logic                          := '0';
    rd_en                : in  std_logic                          := '0';
    dout                 : out std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    empty                : out std_logic                          := '0';
    almost_empty         : out std_logic                          := '0';
    valid                : out std_logic                          := '0';
        data_count   : out std_logic_vector(integer(ceil(log2(real(DEPTH))))-1 downto 0)
    );
end lifo_n_to_1;

architecture Behavioral of lifo_n_to_1 is
  type   eg_state is (WAIT_INPUT, WAIT_CYCLE, WAIT_CYCLE2);
  signal state_reg : eg_state := WAIT_INPUT;

  signal lifo_din         : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
  signal lifo_wr_en       : std_logic                          := '0';
  signal lifo_full        : std_logic                          := '0';
  signal lifo_almost_full : std_logic                          := '0';

  signal port_ptr : integer range 0 to OUT_PORTS-1 := 0;
  
begin


  process (din, wr_en)
  begin  -- process
    lifo_din   <= (others => '0');
    lifo_wr_en <= '0';

    for i in 0 to OUT_PORTS-1 loop
      if wr_en(i) = '1' then
        lifo_din   <= din(i*WIDTH+WIDTH-1 downto i*WIDTH);
        lifo_wr_en <= wr_en(i);
      end if;
    end loop;
  end process;


  --Ideal: Be always full. Just open a short windows in which the input part is
  --allowed to submit data
  process(clk)
  begin  -- process
    if rising_edge(clk) then
      almost_full <= (others => '1');
      full        <= (others => '1');

      case state_reg is
        when WAIT_INPUT =>
          if lifo_almost_full = '0' then
            --There is space in the LIFO. Tell this to one input module
            almost_full(port_ptr) <= '0';
            full(port_ptr)        <= '0';
            state_reg             <= WAIT_CYCLE;
          end if;

        when WAIT_CYCLE =>
          state_reg <= WAIT_CYCLE2;

        when WAIT_CYCLE2 =>
          if port_ptr = OUT_PORTS-1 then
            port_ptr <= 0;
          else
            port_ptr <= port_ptr+1;
          end if;
          state_reg <= WAIT_INPUT;
      end case;

    end if;
  end process;

  out_lifo_full        <= lifo_full;
  out_lifo_almost_full <= lifo_almost_full;

  gen_lifo_1 : entity work.gen_lifo
    generic map (
      WIDTH => WIDTH,
      DEPTH => DEPTH)
    port map (
      clk          => clk,
      srst         => '0',
      --
      din          => lifo_din,
      wr_en        => lifo_wr_en,
      full         => lifo_full,
      almost_full  => lifo_almost_full,
      --Direct to output
      dout         => dout,
      rd_en        => rd_en,
      empty        => empty,
      almost_empty => almost_empty,
      valid        => valid,
      data_count   => data_count
      );

end Behavioral;

