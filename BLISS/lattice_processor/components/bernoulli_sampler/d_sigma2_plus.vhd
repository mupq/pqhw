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
-- Create Date:    10:57:44 01/14/2014 
-- Design Name: 
-- Module Name:    d_sigma2_plus - Behavioral 
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


entity d_sigma2_plus is
  generic (
    MAX_X : integer := 10
    );
  port (
    clk   : in  std_logic;
    --Fifo interface to get randomness
    valid : in  std_logic;
    rd_en : out std_logic;
    din   : in  std_logic;
    empty : in  std_logic;
    --Fifo interface to output x
    wr_en : out std_logic;
    dout  : out std_logic_vector(integer(ceil(log2(real(MAX_X))))-1 downto 0) := (others => '0');
    full  : in  std_logic
    );
end d_sigma2_plus;



architecture Behavioral of d_sigma2_plus is
  --type   STATE_TYPE is (WORKING, OUTPUT);
  --signal state_reg : STATE_TYPE;

  function expansion_generator(MAX_X_VAL : integer) return unsigned is
    variable expansion : unsigned(MAX_X_VAL*MAX_X_VAL+1-1 downto 0);  -- variable mit default Zuweisung

    variable k_old : integer;
    variable k_new : integer;
    variable k     : integer;
  begin
    expansion    := (others => '0');
    expansion(0) := '1';
    k_old        := 1;
    for i in 1 to MAX_X_VAL loop
      expansion(i*i+1-1) := '1';
    end loop;  -- i
    return expansion;
  end expansion_generator;

  signal expansion : unsigned(MAX_X*MAX_X+1-1 downto 0) := expansion_generator(MAX_X);

  constant MAX_I : integer                          := MAX_X;
  signal   i     : integer range 0 to MAX_I;
  signal   ptr   : integer range 0 to MAX_X*MAX_X+1 := 0;

  type   eg_state is (IDLE, SAMPLE,WAIT_CYCLE);
  signal state_reg : eg_state := IDLE;

  
begin

  --k <=  2*i-1;
  
  process(clk)
  begin  -- process
    if rising_edge(clk) then

      wr_en <= '0';
      rd_en <= '0';

      case STATE_reg is
        when IDLE =>
          if full = '0' and empty = '0' then
            state_reg <= WAIT_CYCLE;
            rd_en     <= '1';
          end if;

        when WAIT_CYCLE =>
          state_reg <= SAMPLE;
          
        when SAMPLE =>
          state_reg <= WAIT_CYCLE;
          
          if empty = '0' then
            rd_en <= '1';
          end if;

          if valid = '1' then
            ptr <= ptr+1;
            if expansion(ptr) = '1' then
              i <= i+1;
            end if;

            if din = '0' and expansion(ptr) = '1' then
              i         <= 0;
              ptr       <= 0;
              wr_en     <= '1';
              dout      <= std_logic_vector(to_unsigned(i, dout'length));
              rd_en     <= '0';
              state_reg <= IDLE;
            end if;

            if din = '1' and expansion(ptr) = '0' then
              --reject
              ptr <= 0;
              i   <= 0;
            end if;

          end if;



      end case;


    end if;

  end process;



end Behavioral;




























--library IEEE;
--use IEEE.STD_LOGIC_1164.all;
--use ieee.numeric_std.all;
--use ieee.math_real.all;


--entity d_sigma2_plus is
--  generic (
--    MAX_X : integer := 10
--    );
--  port (
--    clk   : in  std_logic;
--    --Fifo interface to get randomness
--    valid : in  std_logic;
--    rd_en : out std_logic;
--    din   : in  std_logic;
--    empty : in  std_logic;
--    --Fifo interface to output x
--    wr_en : out std_logic;
--    dout  : out std_logic_vector(integer(ceil(log2(real(MAX_X))))-1 downto 0) := (others => '0');
--    full  : in  std_logic
--    );
--end d_sigma2_plus;



--architecture Behavioral of d_sigma2_plus is
--  --type   STATE_TYPE is (WORKING, OUTPUT);
--  --signal state_reg : STATE_TYPE;

--  function expansion_generator(MAX_X_VAL : integer) return unsigned is
--    variable expansion : unsigned(MAX_X_VAL*MAX_X_VAL+1-1 downto 0);  -- variable mit default Zuweisung

--    variable k_old : integer;
--    variable k_new : integer;
--    variable k     : integer;
--  begin
--    expansion    := (others => '0');
--    expansion(0) := '1';
--    k_old        := 1;
--    for i in 1 to MAX_X_VAL loop
--      expansion(i*i+1-1) := '1';
--    end loop;  -- i
--    return expansion;
--  end expansion_generator;

--  signal expansion : unsigned(MAX_X*MAX_X+1-1 downto 0) := expansion_generator(MAX_X);

--  constant MAX_I : integer                          := MAX_X;
--  signal   i     : integer range 0 to MAX_I;
--  signal   ptr   : integer range 0 to MAX_X*MAX_X+1 := 0;

--begin

--  --k <=  2*i-1;

--  process(clk)
--  begin  -- process
--    if rising_edge(clk) then
--      wr_en <= '0';
--      rd_en <= '0';

--      --Randomness should be available and there should be free place in the
--      --input fifo
--      if empty = '0' and full = '0' then
--        rd_en <= '1';
--      end if;


--      if valid = '1' and full = '0' then
--        ptr <= ptr+1;
--        if expansion(ptr) = '1' then
--          i <= i+1;
--        end if;

--        --rnd < expansion
--        if  din = '0' and expansion(ptr) = '1' then
--          i     <= 0;
--          ptr   <= 0;
--          wr_en <= '1';
--          dout  <= std_logic_vector(to_unsigned(i, dout'length));
--        end if;

--        --rnd = expansion
--        --Do nothing

--        --rnd > expansion => reject
--        if din = '1' and expansion(ptr) = '0' then
--          --reject
--          ptr <= 0;
--          i   <= 0;
--        end if;
--    end if;
--  end if;

--end process;



--end Behavioral;

