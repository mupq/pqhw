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
-- Create Date:    08:51:14 02/07/2014 
-- Design Name: 
-- Module Name:    drop_bits_mod_p - Behavioral 
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


entity drop_bits_mod_p is
  generic (
    N_ELEMENTS      : integer  := 512;
    PRIME_P         : unsigned := to_unsigned(12289, 14);
    MODULUS_P_BLISS : unsigned := to_unsigned(24, 5);
    ZETA            : unsigned := to_unsigned(6145, 13);
    D_BLISS         : integer  := 10
    );
  port (
    clk : in std_logic;

    --Input to the pipeline
    valid_in : in std_logic;
    addr_in  : in std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    ay_in    : in std_logic_vector(PRIME_P'length+1-1 downto 0)                      := (others => '0');
    y2_in    : in std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');


    --Output of the pipeline
    add_result_out       : out std_logic_vector(PRIME_P'length+1-1 downto 0)                      := (others => '0');
    add_result_addr_out  : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    add_result_valid_out : out std_logic;

    valid_out : out std_logic;
    data_out  : out std_logic_vector(MODULUS_P_BLISS'length-1 downto 0)                := (others => '0');
    addr_out  : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0')
    );

end drop_bits_mod_p;


architecture Behavioral of drop_bits_mod_p is
  signal shift_reg_in   : std_logic_vector(addr_in'length+1-1 downto 0);
  signal shift_reg_out  : std_logic_vector(addr_in'length+1-1 downto 0);
  signal delay          : integer range 0 to 63 := 30;
  signal delay_mod      : integer range 0 to 63 := 10;
  signal ay_in_reg      : std_logic_vector(ay_in'range);
  signal y2_in_reg      : std_logic_vector(y2_in'range);
  signal data_out_reg   : signed(data_out'range);
  signal add_result     : signed(ay_in'length+1+1-1 downto 0);
  signal mod_result     : unsigned(PRIME_P'length+1-1 downto 0);
  signal dropped_result : unsigned(ay_in'length-D_BLISS-1 downto 0);
  signal addr_r1        : std_logic_vector(addr_in'length-1 downto 0);
  signal addr_r2        : std_logic_vector(addr_in'length-1 downto 0);
  signal addr_valid_r1  : std_logic             := '0';
  signal addr_valid_r2  : std_logic             := '0';


begin
  
  delay        <= 6;
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


  process(clk)
  begin
    if rising_edge(clk) then
      --Stage 1
      ay_in_reg     <= ay_in;
      y2_in_reg     <= y2_in;
      addr_r1       <= addr_in;
      addr_valid_r1 <= valid_in;

      --Stage 2
      addr_r2       <= addr_r1;
      addr_valid_r2 <= addr_valid_r1;
      if unsigned(y2_in_reg) > PRIME_P/2 then
        add_result <= resize(signed("0"&ay_in_reg)+signed("0"&y2_in_reg)-signed("0"&PRIME_P), add_result'length);
      else
        add_result <= resize(signed(unsigned("0"&ay_in_reg)+unsigned("0"&y2_in_reg)), add_result'length);
      end if;

      --if unsigned(y2_in_reg) > PRIME_P/2 then
      --  add_result <= resize(unsigned(signed("0"&ay_in_reg)+signed("0"&y2_in_reg)-signed("0"&PRIME_P)), add_result'length);
      -- else
      -- add_result <= unsigned("0"&ay_in_reg)+unsigned(y2_in_reg);
      --  end if;


      --Stage 3
      --add_result_out <= std_logic_vector(resize(add_result, add_result_out'length));


      add_result_addr_out  <= addr_r2;
      add_result_valid_out <= addr_valid_r2;
      if add_result >= resize(signed("0"&(2*PRIME_P)), add_result'length) then
        mod_result <= resize(unsigned(add_result - signed("0"&2*PRIME_P)), mod_result'length);
        add_result_out<= std_logic_vector(resize(unsigned(add_result - signed("0"&2*PRIME_P)), add_result_out'length));
      elsif add_result < 0 then
        mod_result <= resize(unsigned(add_result + signed("0"&(2*PRIME_P))), mod_result'length);
         add_result_out<=std_logic_vector( resize(unsigned(add_result + signed("0"&(2*PRIME_P))), add_result_out'length));
      else
        mod_result <= resize(unsigned(add_result), mod_result'length);
         add_result_out<=  std_logic_vector(resize(unsigned(add_result), add_result_out'length));
      end if;



      --Stage 4
      dropped_result <= resize(((to_unsigned(2, PRIME_P'length+10)*resize(mod_result, PRIME_P'length+3)+((to_unsigned(1, 2*(PRIME_P'length)) sll D_BLISS))) srl (D_BLISS+1)), dropped_result'length);

      --stage 5
      if dropped_result > MODULUS_P_BLISS/2 then
        data_out_reg <= resize(signed("0"&dropped_result)- signed("0"&MODULUS_P_BLISS), data_out_reg'length);
      else
        data_out_reg <= signed(resize(dropped_result, data_out_reg'length));
      end if;

      --Stage ?
      data_out <= std_logic_vector(data_out_reg);
      
    end if;
  end process;

  assert mod_result < 2*PRIME_P report "BAAAD";
  assert data_out_reg <= signed("0"&(MODULUS_P_BLISS/2)) report "ADSADA";

  
end Behavioral;

