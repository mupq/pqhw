--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity lifo_1_to_n_tb is
  generic (
    --Determines the number of output ports
    OUT_PORTS : integer := 1;
    WIDTH     : integer := 8;
    --Has to be power of two
    DEPTH     : integer := 8
    );
end lifo_1_to_n_tb;

architecture behavior of lifo_1_to_n_tb is
  -- Clock period definitions
  constant clk_period : time := 10 ns;


  signal clk          : std_logic;
  signal srst         : std_logic                          := '0';
  signal din          : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
  signal wr_en        : std_logic                          := '0';
  signal rd_en        : std_logic                          := '0';
  signal dout         : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
  signal full         : std_logic                          := '0';
  signal almost_full  : std_logic                          := '0';
  signal empty        : std_logic                          := '0';
  signal almost_empty : std_logic                          := '0';
  signal valid        : std_logic                          := '0';
  signal data_count   : std_logic_vector(integer(ceil(log2(real(DEPTH))))-1 downto 0);


  type   vector_type is array (0 to 19) of integer;
  signal input  : vector_type := (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19);
  signal output : vector_type := (others => 0);

  signal counter1 : integer := 0;

    signal counter_wait : integer := 0;
begin
  gen_lifo_1 : entity work.gen_lifo
    generic map (
      WIDTH => WIDTH,
      DEPTH => DEPTH)
    port map (
      clk          => clk,
      srst         => srst,
      din          => din,
      wr_en        => wr_en,
      rd_en        => rd_en,
      dout         => dout,
      full         => full,
      almost_full  => almost_full,
      empty        => empty,
      almost_empty => almost_empty,
      valid        => valid,
      data_count   => data_count
      );


  process(clk)
  begin  -- process
    if rising_edge(clk) then
      wr_en <= '0';
      if almost_full = '0' and counter1<20 then
        counter1 <= counter1+1;
        din   <= std_logic_vector(to_unsigned(input(counter1), din'length));
        wr_en <= '1';
      end if;
      
    end if;
  end process;


  process(clk)
  begin  -- process
    if rising_edge(clk) then
      rd_en <= '0';

      counter_wait <= counter_wait+1;
      
      if valid = '1' then
        output(to_integer(unsigned(dout))) <= output(to_integer(unsigned(dout)))+1;
      end if;

      if almost_empty = '0' and counter_wait>10 then
        rd_en <= '1';
      end if;
      
    end if;
  end process;



  -- Clock process definitions
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;


  -- Stimulus process
  stim_proc : process
  begin
    -- hold reset state for 100 ns.
    wait for 100 ns;
    wait for clk_period;






    wait;
  end process;


end;
