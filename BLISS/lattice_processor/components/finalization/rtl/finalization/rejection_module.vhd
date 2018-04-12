--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:18:11 02/12/2014 
-- Design Name: 
-- Module Name:    rejection_module - Behavioral 
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




entity rejection_module is
  generic (
    PARAMETER_SET          : integer               := 1;
    MAX_PREC               : integer               := 79;
    CONST_K                : integer               := 253;
    MAX_X                  : integer               := 10;
    --------------------------General --------------------------------------
    N_ELEMENTS             : integer               := 512;
    PRIME_P_WIDTH          : integer               := 14;
    PRIME_P                : unsigned              := to_unsigned(12289, 14);
    ZETA                   : unsigned              := to_unsigned(6145, 13);
    D_BLISS                : integer               := 10;
    MODULUS_P_BLISS        : unsigned              := to_unsigned(24, 5);
    MAX_RES_WIDTH_COEFF_SC : integer               := 6;
    -----------------------  Sparse Mul Core --------------------------------
    CORES                  : integer               := 8;
    KAPPA                  : integer               := 23;
    WIDTH_S1               : integer               := 2;
    WIDTH_S2               : integer               := 3;
    --Used to initialize the right s (s1 or s2)
    INIT_TABLE             : integer               := 0;
    c_delay                : integer range 0 to 16 := 2;
    MAX_RES_WIDTH          : integer               := 6
    ---------------------------------------------------------------------------
    );

  port(

    clk : in std_logic;

    reset     : in  std_logic;
    rejection : out std_logic;
    finished  : out std_logic;

    encoder_finished : in std_logic := '1';
    encoder_ok       : in std_logic := '1';

    --Results of the multiplication
    coeff_sc_addr : in std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');

    coeff_sc1       : in std_logic_vector(MAX_RES_WIDTH-1 downto 0) := (others => '0');
    coeff_sc1_valid : in std_logic                                  := '0';

    coeff_sc2       : in std_logic_vector(MAX_RES_WIDTH-1 downto 0) := (others => '0');
    coeff_sc2_valid : in std_logic                                  := '0';

    --The u ports
    delay_temp_ram : in  integer range 0 to 63                                              := 10;
    u_data         : in  std_logic_vector(PRIME_P'length+1-1 downto 0)                      := (others => '0');
    u_addr         : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    --The y1 port
    y1_data        : in  std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
    y1_addr        : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    --T y2 port
    y2_data        : in  std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
    y2_addr        : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');


    --Final ports
    z1_final       : out std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
    z1_final_addr  : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    z1_final_valid : out std_logic                                                          := '0';

    --Final ports
    z2_final       : out std_logic_vector(MODULUS_P_BLISS'length-1 downto 0)                := (others => '0');
    z2_final_addr  : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    z2_final_valid : out std_logic                                                          := '0'


    );
end rejection_module;

architecture Behavioral of rejection_module is

  signal shift_reg_in  : std_logic_vector(2*MAX_RES_WIDTH+2-1 downto 0);
  signal shift_reg_out : std_logic_vector(shift_reg_in'range);


  signal coeff_sc1_delayed       : std_logic_vector(MAX_RES_WIDTH-1 downto 0) := (others => '0');
  signal coeff_sc1_valid_delayed : std_logic                                  := '0';
  signal coeff_sc2_delayed       : std_logic_vector(MAX_RES_WIDTH-1 downto 0) := (others => '0');
  signal coeff_sc2_valid_delayed : std_logic                                  := '0';

  signal delay_sc1 : integer := 2;

  signal output_valid : std_logic := '0';

  signal u_data_delayed    : std_logic_vector(PRIME_P'length+1-1 downto 0) := (others => '0');
  signal z2_u_data_delayed : unsigned(PRIME_P'length+1-1 downto 0)         := (others => '0');
  signal u_valid           : std_logic                                     := '0';
  signal add_sub_z1_data   : std_logic_vector(PRIME_P'length-1 downto 0)   := (others => '0');
  signal add_sub_z2_data   : std_logic_vector(PRIME_P'length-1 downto 0)   := (others => '0');

  signal z2_data  : signed(PRIME_P'length-1 downto 0) := (others => '0');
  signal z2_valid : std_logic                         := '0';

  signal add_sub_input_valid   : std_logic                                           := '0';
  signal add_sub_coeff_sc1     : std_logic_vector(MAX_RES_WIDTH_COEFF_SC-1 downto 0) := (others => '0');
  signal add_sub_coeff_sc2     : std_logic_vector(MAX_RES_WIDTH_COEFF_SC-1 downto 0) := (others => '0');
  signal add_sub_y1_data       : std_logic_vector(PRIME_P'length-1 downto 0)         := (others => '0');
  signal add_sub_y2_data       : std_logic_vector(PRIME_P'length-1 downto 0)         := (others => '0');
  signal add_sub_output_valid  : std_logic;
  signal add_sub_coeff_sc1_out : std_logic_vector(MAX_RES_WIDTH_COEFF_SC-1 downto 0) := (others => '0');
  signal add_sub_coeff_sc2_out : std_logic_vector(MAX_RES_WIDTH_COEFF_SC-1 downto 0) := (others => '0');

  signal z1_data : std_logic_vector(PRIME_P'length-1 downto 0) := (others => '0');

  constant Y_WIDTH      : integer := PRIME_P_WIDTH;
  constant SC_WIDTH     : integer := MAX_RES_WIDTH_COEFF_SC;
  constant OUTPUT_WIDTH : integer := 32;


  signal scalar_reset             : std_logic                                 := '0';
  signal scalar_y1_data           : std_logic_vector(Y_WIDTH-1 downto 0)      := (others => '0');
  signal scalar_y2_data           : std_logic_vector(Y_WIDTH-1 downto 0)      := (others => '0');
  signal scalar_coeff_sc1_out     : std_logic_vector(SC_WIDTH-1 downto 0)     := (others => '0');
  signal scalar_coeff_sc1_valid   : std_logic                                 := '0';
  signal scalar_coeff_sc2_out     : std_logic_vector(SC_WIDTH-1 downto 0)     := (others => '0');
  signal scalar_coeff_sc2_valid   : std_logic                                 := '0';
  signal scalar_scalar_prod       : std_logic_vector(OUTPUT_WIDTH-1 downto 0) := (others => '0');
  signal scalar_scalar_prod_valid : std_logic                                 := '0';


  signal norm_reset           : std_logic                                  := '0';
  signal norm_coeff_sc1_out   : std_logic_vector(MAX_RES_WIDTH-1 downto 0) := (others => '0');
  signal norm_coeff_sc1_valid : std_logic                                  := '0';
  signal norm_coeff_sc2_out   : std_logic_vector(MAX_RES_WIDTH-1 downto 0) := (others => '0');
  signal norm_coeff_sc2_valid : std_logic                                  := '0';
  signal norm_norm            : std_logic_vector(OUTPUT_WIDTH-1 downto 0)  := (others => '0');
  signal norm_norm_valid      : std_logic                                  := '0';

  signal z1_counter : integer := 0;
  signal z2_counter : integer := 0;


  signal temp_z2_final       : std_logic_vector(z2_final'range)                         := (others => '0');
  signal temp_z2_final_addr  : signed(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal temp_z2_final_valid : std_logic                                                := '0';

  signal scalar_was_valid : std_logic := '0';
  signal norm_was_valid   : std_logic := '0';

  signal SCALAR_PROD_WIDTH : integer := OUTPUT_WIDTH;
  signal NORM_WIDTH        : integer := OUTPUT_WIDTH;

  signal rejecter_reset             : std_logic;
  signal rejecter_rejection         : std_logic;
  signal rejecter_finished          : std_logic;
  signal rejecter_scalar_prod       : std_logic_vector(SCALAR_PROD_WIDTH-1 downto 0) := (others => '0');
  signal rejecter_scalar_prod_valid : std_logic                                      := '0';
  signal rejecter_norm              : std_logic_vector(NORM_WIDTH-1 downto 0)        := (others => '0');
  signal rejecter_norm_valid        : std_logic                                      := '0';
begin

  assert ((to_integer(signed(temp_z2_final)) >= -1) or (to_integer(signed(temp_z2_final)) <= 1)) report "ERROR";



  process(clk)
  begin  -- process
    if rising_edge(clk) then
      z1_final_valid <= '0';
      if add_sub_output_valid = '1' then
        z1_final       <= add_sub_z1_data;
        z1_final_addr  <= std_logic_vector(to_unsigned(z1_counter, z1_final_addr'length));
        z1_final_valid <= '1';
        z1_counter     <= (z1_counter+1) mod N_ELEMENTS;
      end if;

      z2_final_valid <= '0';
      if temp_z2_final_valid = '1' then
        z2_final       <= temp_z2_final;
        z2_final_addr  <= std_logic_vector(to_unsigned(z2_counter, z2_final_addr'length));
        z2_final_valid <= '1';
        z2_counter     <= (z2_counter+1) mod N_ELEMENTS;
      end if;
    end if;
  end process;


  u_addr  <= coeff_sc_addr;
  y1_addr <= coeff_sc_addr;
  y2_addr <= coeff_sc_addr;

  --Delay the sc data so that we have time to request the y1,y2 and u values
  shift_reg_in <= coeff_sc1_valid & coeff_sc2 & coeff_sc2_valid & coeff_sc1;
  dyn_shift_reg_1 : entity work.dyn_shift_reg
    generic map (
      width     => shift_reg_in'length,
      max_depth => 32
      )
    port map (
      clk    => clk,
      depth  => delay_sc1,
      Input  => shift_reg_in,
      Output => shift_reg_out
      );
  coeff_sc1_delayed       <= shift_reg_out(coeff_sc1_delayed'length-1 downto 0);
  coeff_sc1_valid_delayed <= shift_reg_out(coeff_sc1_delayed'length);
  coeff_sc2_delayed       <= shift_reg_out(coeff_sc1_delayed'length+1+coeff_sc2_delayed'length-1 downto coeff_sc1_delayed'length+1);
  coeff_sc2_valid_delayed <= shift_reg_out(shift_reg_out'length-1);


  add_sub_coeff_sc1   <= coeff_sc1_delayed;
  add_sub_coeff_sc2   <= coeff_sc2_delayed;
  add_sub_input_valid <= coeff_sc1_valid_delayed;
  add_sub_y1_data     <= y1_data;
  add_sub_y2_data     <= y2_data;
  --Feed the values into the add substract module
  add_sub_sc_y_1 : entity work.add_sub_sc_y
    generic map (
      N_ELEMENTS             => N_ELEMENTS,
      PRIME_P                => PRIME_P,
      MAX_RES_WIDTH_COEFF_SC => MAX_RES_WIDTH_COEFF_SC
      )
    port map (
      clk           => clk,
      bit_b         => '1',
      input_valid   => add_sub_input_valid,
      coeff_sc1     => add_sub_coeff_sc1,
      coeff_sc2     => add_sub_coeff_sc2,
      y1_data       => add_sub_y1_data,
      y2_data       => add_sub_y2_data,
      output_valid  => add_sub_output_valid,
      z1_data       => add_sub_z1_data,
      z2_data       => add_sub_z2_data,
      coeff_sc1_out => add_sub_coeff_sc1_out,
      coeff_sc2_out => add_sub_coeff_sc2_out
      );

  dyn_shift_reg_2 : entity work.dyn_shift_reg
    generic map (
      width     => u_data'length,
      max_depth => 32
      )
    port map (
      clk    => clk,
      depth  => 2,
      Input  => u_data,
      Output => u_data_delayed
      );

  z2_data           <= signed(add_sub_z2_data);
  z2_u_data_delayed <= unsigned(u_data_delayed);
  z2_computation_1 : entity work.z2_computation
    generic map (
      N_ELEMENTS      => N_ELEMENTS,
      D_BLISS         => D_BLISS,
      MODULUS_P_BLISS => MODULUS_P_BLISS,
      Z_LENGTH        => PRIME_P'length,
      PRIME_P         => PRIME_P
      )
    port map (
      clk            => clk,
      u_data         => z2_u_data_delayed,
      u_valid        => add_sub_output_valid,
      z2_data        => z2_data,
      z2_valid       => add_sub_output_valid,
      z2_final       => temp_z2_final,
      z2_final_addr  => temp_z2_final_addr,
      z2_final_valid => temp_z2_final_valid
      );



  --scalar_y1_data         <= "0"&y1_data when unsigned("0"&y1_data)<=PRIME_P/2 else std_logic_vector(unsigned("0"&y1_data)-PRIME_P);
  --scalar_y2_data         <= "0"&y2_data when unsigned("0"&y2_data)<=PRIME_P/2 else std_logic_vector(unsigned("0"&y2_data)-PRIME_P);

  scalar_y1_data         <= add_sub_z1_data;
  scalar_y2_data         <= add_sub_z2_data;
  scalar_reset           <= reset;
  scalar_coeff_sc1_out   <= add_sub_coeff_sc1_out;
  scalar_coeff_sc1_valid <= add_sub_output_valid;
  scalar_coeff_sc2_out   <= add_sub_coeff_sc2_out;
  scalar_coeff_sc2_valid <= add_sub_output_valid;
  scalar_product_1 : entity work.scalar_product
    generic map (
      Y_WIDTH      => Y_WIDTH,
      SC_WIDTH     => SC_WIDTH,
      OUTPUT_WIDTH => OUTPUT_WIDTH,
      DEPTH        => N_ELEMENTS
      )
    port map (
      clk               => clk,
      reset             => scalar_reset,
      y1_data           => scalar_y1_data,
      y2_data           => scalar_y2_data,
      coeff_sc1_out     => scalar_coeff_sc1_out,
      coeff_sc1_valid   => scalar_coeff_sc1_valid,
      coeff_sc2_out     => scalar_coeff_sc2_out,
      coeff_sc2_valid   => scalar_coeff_sc2_valid,
      scalar_prod       => scalar_scalar_prod,
      scalar_prod_valid => scalar_scalar_prod_valid
      );

  norm_reset <= reset;
  norm_1 : entity work.norm
    generic map (
      PRIME_P       => PRIME_P,
      MAX_RES_WIDTH => MAX_RES_WIDTH,
      OUTPUT_WIDTH  => OUTPUT_WIDTH,
      DEPTH         => N_ELEMENTS
      )
    port map (
      clk             => clk,
      reset           => norm_reset,
      coeff_sc1_out   => scalar_coeff_sc1_out,
      coeff_sc1_valid => scalar_coeff_sc1_valid,
      coeff_sc2_out   => scalar_coeff_sc2_out,
      coeff_sc2_valid => scalar_coeff_sc2_valid,
      norm            => norm_norm,
      norm_valid      => norm_norm_valid
      );


  rejecter_scalar_prod       <= scalar_scalar_prod;
  rejecter_scalar_prod_valid <= scalar_scalar_prod_valid;
  rejecter_norm              <= norm_norm;
  rejecter_norm_valid        <= norm_norm_valid;
  rejecter_1 : entity work.rejecter
    generic map (
      PARAMETER_SET     => PARAMETER_SET,
      SCALAR_PROD_WIDTH => OUTPUT_WIDTH,
      NORM_WIDTH        => OUTPUT_WIDTH,
      N_ELEMENTS        => N_ELEMENTS,
      PRIME_P           => PRIME_P
      )
    port map (
      clk               => clk,
      reset             => rejecter_reset,
      rejection         => rejecter_rejection,
      finished          => rejecter_finished,
      scalar_prod       => rejecter_scalar_prod,
      scalar_prod_valid => rejecter_scalar_prod_valid,
           encoder_finished =>        encoder_finished ,
    encoder_ok    =>     encoder_ok  ,
      norm              => rejecter_norm,
      norm_valid        => rejecter_norm_valid
      );



  process(clk)
  begin  -- process
    if rising_edge(clk) then
      finished  <= '0';
      rejection <= '0';


      if norm_norm_valid = '1' then
        norm_was_valid <= '1';
      end if;

      if scalar_scalar_prod_valid = '1' then
        scalar_was_valid <= '1';
      end if;


      --if norm_norm_valid = '1' and scalar_scalar_prod_valid = '1' then
      if rejecter_finished = '1' then
        scalar_was_valid <= '0';
        norm_was_valid   <= '0';

        finished <= '1';
        if rejecter_rejection = '1' then
          rejection <= '1';
        else
          rejection <= '0';
        end if;
      end if;
      

    end if;
  end process;
end Behavioral;

