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
-- Create Date:    17:50:44 02/06/2014 
-- Design Name: 
-- Module Name:    mul_zeta - Behavioral 
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


--Multiply by zeta. And delay the address of addr_out appropriately

entity mul_zeta is
  generic (
    N_ELEMENTS : integer  := 512;
    PRIME_P    : unsigned := to_unsigned(12289, 14);
    ZETA       : unsigned := to_unsigned(6145, 13)
    );
  port (
    clk : in std_logic;

    --Input to the pipeline
    valid_in : in std_logic                                                          := '0';
    data_in  : in std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
    addr_in  : in std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');

    --Output of the pipeline
    valid_out : out std_logic;
    data_out  : out std_logic_vector(PRIME_P'length+1-1 downto 0)                      := (others => '0');
    addr_out  : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0')
    );

end mul_zeta;

architecture Behavioral of mul_zeta is
  constant MUL_RES_LENGTH : integer := integer(ceil(log2(real(to_integer(PRIME_P*2*ZETA)))))+1;

  signal mul_res : unsigned(MUL_RES_LENGTH-1 downto 0) := (others => '0');


  signal data_in_reg  : std_logic_vector(data_in'range) := (others => '0');
  signal data_out_reg : unsigned(data_out'range)        := (others => '0');

  signal shift_reg_in  : std_logic_vector(addr_in'length+1-1 downto 0) := (others => '0');
  signal shift_reg_out : std_logic_vector(addr_in'length+1-1 downto 0) := (others => '0');

  signal delay     : integer := 10;
  signal delay_mod : integer := 10;
begin

  delay        <= 3 + delay_mod;
  shift_reg_in <= valid_in & addr_in;
  addr_reg_1 : entity work.dyn_shift_reg
    generic map (
      width     => shift_reg_in'length,
      max_depth => 32
      )
    port map (
      clk    => clk,
      depth  => delay,
      Input  => shift_reg_in,
      Output => shift_reg_out
      );
  addr_out  <= shift_reg_out(addr_in'length-1 downto 0);
  valid_out <= shift_reg_out(shift_reg_out'length-1);


 prime_12289: if PRIME_P=12289 generate
   delay_mod <= 1;
   mul_zeta_12289_6145_1:entity work.mul_zeta_12289_6145
     port map (
       ap_clk    => clk,
       ap_rst    => '0',
       data_in_V => data_in,
       ap_return => data_out
       );
 end generate prime_12289;
  
  not_12289 : if PRIME_P /= 12289 generate
    red_subtract_sparse_1 : entity work.red_subtract_sparse
      generic map (
        PRIME_P_WIDTH => PRIME_P'length+1,
        PRIME_P       => 2*PRIME_P,
        VAL_IN_WIDTH  => MUL_RES_LENGTH
        )
      port map (
        clk   => clk,
        val   => mul_res,
        red   => data_out_reg,
        delay => delay_mod
        );

    process(clk)
    begin
      if rising_edge(clk) then
        --Stage 1
        data_in_reg <= data_in;

        --Stage 2
        mul_res <= resize(resize(unsigned(data_in_reg), mul_res'length) * ZETA * to_unsigned(2, mul_res'length), mul_res'length);

        --Stage 3
        data_out <= std_logic_vector(data_out_reg);
      end if;
    end process;
  end generate not_12289;
  

  
end Behavioral;

