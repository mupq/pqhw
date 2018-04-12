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
-- Create Date:    09:14:13 02/03/2014 
-- Design Name: 
-- Module Name:    compute_input_bernoulli - Behavioral 
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



entity compute_input_bernoulli is
  generic (
    MAX_PREC : integer := 79;
    CONST_K  : integer := 253;
    MAX_X    : integer := 10
    );
  port (
    clk     : in  std_logic;
    x_rd_en : out std_logic;
    x_empty : in  std_logic;
    x_valid : in  std_logic;
    x_val   : in  std_logic_vector(integer(ceil(log2(real(MAX_X-1))))-1 downto 0);

    y_rd_en : out std_logic;
    y_empty : in  std_logic;
    y_valid : in  std_logic;
    y_val   : in  std_logic_vector(integer(ceil(log2(real(CONST_K-1))))-1 downto 0);

    fifo_ber_full  : in  std_logic;
    fifo_ber_wr_en : out std_logic;
    fifo_ber_out   : out std_logic_vector(integer(ceil(log2(real((CONST_K-1)*((CONST_K-1)+2*CONST_K*MAX_X)))))-1 downto 0);
    fifo_z_full    : in  std_logic;
    fifo_z_wr_en   : out std_logic;
    fifo_z_out     : out std_logic_vector(integer(ceil(log2(real((CONST_K)*(MAX_X)+CONST_K-1))))-1 downto 0)
    );
end compute_input_bernoulli;

architecture Behavioral of compute_input_bernoulli is

  constant OUTPUT_SIZE_BER : integer := integer(ceil(log2(real((CONST_K-1)*((CONST_K-1)+2*CONST_K*MAX_X)))));
  constant OUTPUT_SIZE_Z   : integer := integer(ceil(log2(real((CONST_K)*(MAX_X)+CONST_K-1))));

  signal clk_en : std_logic;


  signal x_reg     : std_logic_vector(integer(ceil(log2(real(MAX_X-1))))-1 downto 0)   := (others => '0');
  signal y_reg     : std_logic_vector(integer(ceil(log2(real(CONST_K-1))))-1 downto 0) := (others => '0');
  signal valid_reg : std_logic                                                         := '0';

  signal x_reg_01     : std_logic_vector(integer(ceil(log2(real(MAX_X-1))))-1 downto 0)   := (others => '0');
  signal y_reg_01     : std_logic_vector(integer(ceil(log2(real(CONST_K-1))))-1 downto 0) := (others => '0');
  signal valid_reg_01 : std_logic                                                         := '0';

  signal xk_reg       : std_logic_vector(integer(ceil(log2(real(CONST_K*MAX_X))))-1 downto 0) := (others => '0');
  signal y_reg_02     : std_logic_vector(integer(ceil(log2(real(CONST_K-1))))-1 downto 0)     := (others => '0');
  signal valid_reg_02 : std_logic                                                             := '0';



  signal result_ber : std_logic_vector(OUTPUT_SIZE_BER-1 downto 0) := (others => '0');
  signal result_z   : std_logic_vector(OUTPUT_SIZE_Z-1 downto 0)   := (others => '0');

  signal result_ber_reg2 : std_logic_vector(OUTPUT_SIZE_BER-1 downto 0) := (others => '0');
  signal result_z_reg2   : std_logic_vector(OUTPUT_SIZE_Z-1 downto 0)   := (others => '0');

  signal valid_reg1 : std_logic := '0';
  signal valid_reg2 : std_logic := '0';

  signal read_not_read : std_logic := '0';
    signal wait_cycle : std_logic := '0';

begin


  process (clk)
  begin  -- process
    if rising_edge(clk) then            -- rising clock edge
      valid_reg <= '0';

      if clk_en = '1' then
        --Input to pileline

        --Statge -1
        x_reg_01 <= x_val;
        y_reg_01 <= y_val;

        valid_reg_01 <= '0';
        if x_valid = '1' and y_valid = '1' then
          valid_reg_01 <= '1';
        end if;

        --stage -2
        valid_reg_02 <= valid_reg_01;
        y_reg_02     <= y_reg_01;
        xk_reg       <= std_logic_vector(resize(to_unsigned(CONST_K, result_ber'length)*unsigned(x_reg_01), xk_reg'length));


        --Stage one
        result_ber <= std_logic_vector(resize(unsigned(y_reg_02)*(resize(unsigned(y_reg_02) + 2*unsigned(xk_reg), integer(ceil(log2(real(CONST_K-1+2*MAX_X*CONST_K)))))), result_ber'length));
        result_z   <= std_logic_vector(resize(unsigned(xk_reg)+unsigned(y_reg_02), result_z'length));
        valid_reg1 <= valid_reg_02;

        --Stage two
        result_ber_reg2 <= result_ber;
        result_z_reg2   <= result_z;
        valid_reg2      <= valid_reg1;
        
      end if;
    end if;
  end process;


  process (fifo_ber_full, fifo_z_full)
  begin  -- process
    -- purpose:
    clk_en <= '0';
    if fifo_ber_full = '0' and fifo_z_full = '0' then
      clk_en <= '1';
    end if;
  end process;

  process (clk)
  begin  -- process
    if rising_edge(clk) then            -- rising clock edge
      wait_cycle <= '0';
 
      x_rd_en <= '0';
      y_rd_en <= '0';

      fifo_z_out     <= (others => '0');
      fifo_z_wr_en   <= '0';
      fifo_ber_out   <= (others => '0');
      fifo_ber_wr_en <= '0';

      if fifo_ber_full = '0' and fifo_z_full = '0' and wait_cycle='0' then
        if x_empty = '0' and y_empty = '0' then
          wait_cycle <= '1';
          x_rd_en       <= '1';
          y_rd_en       <= '1';
          read_not_read <= read_not_read xor '1';
        end if;

        fifo_ber_out   <= result_ber_reg2;
        fifo_ber_wr_en <= valid_reg2;

        fifo_z_out   <= result_z_reg2;
        fifo_z_wr_en <= valid_reg2;

      end if;
    end if;
  end process;
  

end Behavioral;

