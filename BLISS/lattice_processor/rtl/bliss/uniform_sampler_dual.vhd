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
-- Create Date:    12:25:59 02/24/2014 
-- Design Name: 
-- Module Name:    uniform_sampler_dual - Behavioral 
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



entity uniform_sampler_dual is
  generic (
    UNIFORM_BITS :integer := 8
    );
  port (
    clk        : in  std_logic;
    clk_en     : in  std_logic := '0';
    --Fifo interface to get randomness
    rand_rd_en : out std_logic;
    rand_empty : in  std_logic;
    rand_valid : in  std_logic;

    rand_din1 : in std_logic;
    rand_din2 : in std_logic;
    rand_din3 : in std_logic;

    --uniform bit for sign
    fifo_bit_rd_en        : in  std_logic;
    fifo_bit_empty        : out std_logic;
    fifo_bit_almost_empty : out std_logic;
    fifo_bit_dout         : out std_logic_vector(0 downto 0);


    --Uniform output
    dout : out std_logic_vector(UNIFORM_BITS-1 downto 0);
    full : in  std_logic;

    wr_en : out std_logic
    );


end uniform_sampler_dual;

architecture Behavioral of uniform_sampler_dual is
  signal value       : unsigned(dout'length-1 downto 0) := (others => '0');
  signal counter_sig : integer;

  signal uni_bit1_intern : std_logic := '0';
  signal uni_bit2_intern : std_logic := '0';


  component uni_bit_fifo
    port (
      clk          : in  std_logic;
      din          : in  std_logic_vector(0 downto 0);
      wr_en        : in  std_logic;
      rd_en        : in  std_logic;
      dout         : out std_logic_vector(0 downto 0);
      full         : out std_logic;
      almost_full  : out std_logic;
      empty        : out std_logic;
      almost_empty : out std_logic;
      underflow    : out std_logic
      );
  end component;

  signal fifo_din         : std_logic_vector(0 downto 0);
  signal fifo_wr_en       : std_logic;
  signal fifo_full        : std_logic;
  signal fifo_almost_full : std_logic;
  signal fifo_underflow   : std_logic;

begin



  

  your_instance_name : uni_bit_fifo
    port map (
      clk          => clk,
      din          => fifo_din,
      wr_en        => fifo_wr_en,
      rd_en        => fifo_bit_rd_en,
      dout         => fifo_bit_dout,
      full         => fifo_full,
      almost_full  => fifo_almost_full,
      empty        => fifo_bit_empty,
      almost_empty => fifo_bit_almost_empty,
      underflow    => fifo_underflow
      );


  process(clk)
    variable counter : integer range 0 to value'length+4 := 0;
  begin  -- process c
    
      
    if rising_edge(clk) then
             wr_en           <= '0';
     fifo_wr_en <= '0';
             
      if clk_en = '1' then
  
   
        rand_rd_en      <= '0';
        uni_bit1_intern <= '0';
        uni_bit2_intern <= '0';
        counter         := counter;

        --uni_bit1 <= uni_bit1_intern;
        --uni_bit2 <= uni_bit2_intern;
--uni_bit1 <= '0';
        --uni_bit2 <= '0';

        --counter_sig <= Counter;
        if counter >= 8 then
          wr_en   <= '1';
          dout    <= std_logic_vector(value(dout'length-1 downto 0));
          value   <= (others => '0');
          counter := 0;
        end if;

        --counter_sig <= Counter;
        if counter < value'length then
          if rand_empty = '0' then
            rand_rd_en <= '1';
          end if;
          if rand_valid = '1' then
            value(counter)     <= rand_din1;
            value((counter+1)) <= rand_din2;
            if (counter+2)     <= 7 then
              value(counter+2) <= rand_din3;
            else
              if fifo_almost_full = '0' then
                fifo_wr_en  <= '1';
                fifo_din(0) <= rand_din3;
              end if;
            end if;
            counter := counter+3;
          end if;
        end if;
        
      end if;
    end if;
    
  end process;

end Behavioral;

