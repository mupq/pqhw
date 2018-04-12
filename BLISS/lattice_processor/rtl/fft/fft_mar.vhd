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
-- Create Date:    18:27:24 02/01/2012 
-- Design Name: 
-- Module Name:    fft_mar - Behavioral 
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
use IEEE.math_real.all;
use IEEE.NUMERIC_STD.all;



-- What is this component doing? --
-- Implementes the Butterly arithemtic of the iterative FFT
--    x[a] = xa_val + W[n % N] * xb_val % self.p
--    x[b] = xa_val - W[n % N] * xb_val % self.p


-- x_add_out = a_in + w_in* b_insum_added
-- x_sub_out = a_in - w_in* b_in


entity fft_mar is
  generic (
    SPEED_LEVEL     : integer  := 2;    --2=very high speed,1=normal
                                        --speed,0=low latency
    W_WIDTH         : integer  := 14;
    A_WIDTH         : integer  := 14;
    B_WIDTH         : integer  := 14;
    RED_PRIME_WIDTH : integer  := 14;
    RED_PRIME       : unsigned :=to_unsigned(12289,14)
    );
  port (
    clk       : in  std_logic;
    --parallel input
    w_in      : in  unsigned(W_WIDTH-1 downto 0)         := (others => '0');
    a_in      : in  unsigned(A_WIDTH-1 downto 0)         := (others => '0');
    b_in      : in  unsigned(B_WIDTH-1 downto 0)         := (others => '0');
    --parallel output
    x_add_out : out unsigned(RED_PRIME_WIDTH-1 downto 0) := (others => '0');
    x_sub_out : out unsigned(RED_PRIME_WIDTH-1 downto 0) := (others => '0');
    delay     : out integer                              := 68
    );
end fft_mar;

architecture Behavioral of fft_mar is


  constant sub_from_cnst_delay : integer := 3;

  constant adder_delay : integer := 3;


  --Delays
  signal gen_mul_delay            : integer := 8;
  signal gen_reducer_delay        : integer := 0;
  signal gen_reducer_delay_final1 : integer := 0;
  signal gen_reducer_delay_final2 : integer := 0;


  constant PRIME_BITS : integer := RED_PRIME_WIDTH;

  signal w_in_reg : unsigned(w_in'length-1 downto 0) := (others => '0');
  signal b_in_reg : unsigned(b_in'length-1 downto 0) := (others => '0');

  signal mul_res     : unsigned(W_WIDTH+B_WIDTH-1 downto 0) := (others => '0');
  signal mul_res_reg : unsigned(mul_res'length-1 downto 0)  := (others => '0');

  signal a_in_delayed  : std_logic_vector(a_in'length-1 downto 0) := (others => '0');
  signal adder_1_delay : integer                                  := 0;



  signal mul_res_substracted : unsigned(PRIME_BITS-1 downto 0)         := (others => '0');
  signal mul_res_reg_delayed : std_logic_vector(PRIME_BITS-1 downto 0) := (others => '0');




  signal reduce_reg    : unsigned(PRIME_BITS-1 downto 0) := (others => '0');
  signal test          : integer;
  signal delay_a_depth : integer                         := 0;

  signal sum_added      : unsigned(1+PRIME_BITS-1 downto 0) := (others => '0');
  signal sum_subtracted : unsigned(1+PRIME_BITS-1 downto 0) := (others => '0');

  signal x_sub_reg : unsigned(RED_PRIME_WIDTH-1 downto 0) := (others => '0');
  signal x_add_reg : unsigned(RED_PRIME_WIDTH-1 downto 0) := (others => '0');

  signal reduce_reg_delayed : std_logic_vector(RED_PRIME_WIDTH-1 downto 0) := (others => '0');

  

  
begin

  --Step 1
  gen_mul_1 : entity work.gen_mul
    generic map (
      VAL1_WIDTH => A_WIDTH,
      VAL2_WIDTH => B_WIDTH
      )
    port map (
      -- delay => delay_mul,
      clk       => clk,
      v1        => b_in_reg,
      v2        => w_in_reg,
      res       => mul_res,
      mul_delay => gen_mul_delay
      );

  --Step 2
  gen_reducer_1 : entity work.gen_reducer
    generic map (
      VAL_WIDTH       => mul_res'length,
      REDUCTION_PRIME => RED_PRIME,
      USE_GENERIC     => '0'
      )
    port map (
      clk   => clk,
      val   => mul_res,
      red   => reduce_reg,
      delay => gen_reducer_delay
      );

  --Step 3,a
  delay_mul_res : entity work.dyn_shift_reg
    generic map (
      width => reduce_reg'length
      --Delay is the delay of the multyply unit - delay of inverter
      )
    port map(
      clk    => clk,
      depth  => 3,
      Input  => std_logic_vector(reduce_reg),
      Output => reduce_reg_delayed
      );

  --Step 3,b
  sub_from_cnst_1 : entity work.sub_from_cnst
    generic map (
      VAL_IN_WIDTH  => RED_PRIME_WIDTH,
      VAl_OUT_WIDTH => RED_PRIME_WIDTH,
      CONST_VAL     => RED_PRIME
      )
    port map (
      clk => clk,
      val => reduce_reg,
      res => mul_res_substracted
      );



  --Step 3a
  adder_1 : entity work.adder
    generic map (
      VAL1_WIDTH => reduce_reg_delayed'length,
      VAL2_WIDTH => a_in_delayed'length
      )
    port map (
      clk   => clk,
      val1  => unsigned(reduce_reg_delayed),
      val2  => unsigned(a_in_delayed),
      delay => adder_1_delay,
      sum   => sum_added
      );


  adder_2 : entity work.adder
    generic map (
      VAL1_WIDTH => mul_res_substracted'length,
      VAL2_WIDTH => a_in_delayed'length
      )
    port map (
      clk  => clk,
      val1 => unsigned(mul_res_substracted),
      val2 => unsigned(a_in_delayed),
      sum  => sum_subtracted
      );

  
  gen_reducer_final_1 : entity work.gen_reducer
    generic map (
      VAL_WIDTH       => sum_subtracted'length,
      REDUCTION_PRIME => RED_PRIME,
      USE_GENERIC     => '1'
      )
    port map (
      clk   => clk,
      val   => sum_subtracted,
      red   => x_sub_reg,
      delay => gen_reducer_delay_final1
      );

  gen_reducer_final_2 : entity work.gen_reducer
    generic map (
      VAL_WIDTH       => sum_added'length,
      REDUCTION_PRIME => RED_PRIME,
      USE_GENERIC     => '1'
      )
    port map (
      clk   => clk,
      val   => sum_added,
      red   => x_add_reg,
      delay => gen_reducer_delay_final2
      );


  
  delay_a_depth <= gen_mul_delay+gen_reducer_delay+3+1;
  delay_a : entity work.dyn_shift_reg
    generic map (
      width => a_in'length
      --Delay is the delay of the multyply unit - delay of inverter
      )
    port map(
      clk    => clk,
      depth  => delay_a_depth,
      Input  => std_logic_vector(a_in),
      Output => a_in_delayed
      );

  delay <= delay_a_depth + adder_1_delay + gen_reducer_delay_final1+1;

  process(clk)
  begin  -- process c
    if rising_edge(clk) then
      --Input registers of module
      w_in_reg <= w_in;
      b_in_reg <= b_in;

      --Register behind multiplier
      mul_res_reg <= mul_res;

      --register behind reducer
      x_sub_out <= x_sub_reg;
      x_add_out <= x_add_reg;

      
    end if;
  end process;

end Behavioral;

