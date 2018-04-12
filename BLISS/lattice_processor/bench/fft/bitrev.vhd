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
-- Create Date:    17:18:00 03/19/2012 
-- Design Name: 
-- Module Name:    bitrev - Behavioral 
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


-- Performs the bitrev operation. This means that the coefficients of the
-- polynomial are ordered for the following fft step. When the ring xn=-1 is
-- chosen, this also involes a multiplication with psi.
-- Rises finished when finishedS


entity bitrev is
  generic (
    N_ELEMENTS    : integer := 32;
    PRIME_P_WIDTH : integer := 10;
    XN            : integer := -1
    );
  port (
    clk             : in  std_logic;
    --input from outside
    usr_valid       : in  std_logic                                                          := '0';
    usr_coefficient : in  unsigned(PRIME_P_WIDTH-1 downto 0);
    usr_ready       : out std_logic                                                          := '1';
    usr_finished    : out std_logic                                                          := '0';
    --connection to w table
    w_psi_req       : out std_logic;
    w_inverse_req   : out std_logic;
    w_index         : out unsigned(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) :=(others => '0');
    w_out_val       : in  unsigned(PRIME_P_WIDTH-1 downto 0);
    w_delay         : in  integer                                                          := 5;
    --connection to arithmetic unit
    a_op            : out std_logic_vector(0 downto 0)                                       := (others => '0');
    a_w_in          : out unsigned(PRIME_P_WIDTH-1 downto 0);
    a_a_in          : out unsigned(PRIME_P_WIDTH-1 downto 0);
    a_b_in          : out unsigned(PRIME_P_WIDTH-1 downto 0);
    a_x_out         : in  unsigned(PRIME_P_WIDTH-1 downto 0);
    a_delay         : in  integer                                  := 35;
    --connection to output BRAM
    bram_addra      : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    bram_din        : out std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');
    bram_we         : out std_logic                                                          := '0'
    );

end bitrev;

architecture Behavioral of bitrev is
  constant GEN_BITWIDTH : integer := integer(ceil(log2(real(N_ELEMENTS))));

  signal counter         : unsigned(GEN_BITWIDTH-1 downto 0) := (others => '0');
  signal bit_rev_counter : unsigned(GEN_BITWIDTH-1 downto 0) := (others => '0');

  signal valid    : std_logic := '0';
  signal finished : std_logic := '0';

  signal coefficient           : unsigned(usr_coefficient'length-1 downto 0)         := (others => '0');
  signal coefficient_w_delayed : std_logic_vector(usr_coefficient'length-1 downto 0) := (others => '0');


  signal addra_reg : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0);
  signal din_reg   : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal we_reg    : std_logic                                  := '0';


  signal we_reg_in  : std_logic_vector(0 downto 0) := (others => '0');
  signal we_reg_out : std_logic_vector(0 downto 0) := (others => '0');

  signal finished_reg_in  : std_logic_vector(0 downto 0) := (others => '0');
  signal finished_reg_out : std_logic_vector(0 downto 0) := (others => '0');


  signal brv_counter_reg_in  : unsigned(GEN_BITWIDTH-1 downto 0)         := (others => '0');
  signal brv_counter_reg_out : std_logic_vector(GEN_BITWIDTH-1 downto 0) := (others => '0');

  signal added_delays         : integer := 0;
  signal added_delays_minus_1 : integer := 0;
  signal w_delay_plus1        : integer := 0;

  signal sinnlos : std_logic_vector(10 downto 0) := (others => '0');
begin

  --Performs the bitrev operation on the value of counter (just interconnect on
  --FPGA)
  bitrev : for I in 0 to GEN_BITWIDTH-1 generate
    bit_rev_counter(I) <= counter(GEN_BITWIDTH-1-I);
  end generate bitrev;



  --input register transfer
  process (clk)
  begin
    if rising_edge(clk) then
      valid       <= usr_valid;
      coefficient <= usr_coefficient;

      if xn = 1 then
        usr_finished <= finished;
      end if;

      if xn = -1 then
        usr_finished <= finished_reg_out(0);
      end if;


      bram_we    <= we_reg;
      bram_din   <= din_reg;
      bram_addra <= addra_reg;
      
    end if;
  end process;


  XN_m1 : if xn = -1 generate
    --Connections are only needed in case of XN=-1

    added_delays <= w_delay+a_delay;

    w_delay_plus1 <= w_delay+1;
    coefficient_sh_reg_1 : entity work.dyn_shift_reg
      generic map (
        width => coefficient'length
        )
      port map (
        clk    => clk,
        depth  => w_delay_plus1,
        Input  => std_logic_vector(coefficient),
        Output => coefficient_w_delayed
        );


    added_delays_minus_1 <= added_delays +1;
    coefficient_we_reg_1 : entity work.dyn_shift_reg
      generic map (
        width => 1
        )
      port map (
        clk    => clk,
        depth  => added_delays,
        Input  => we_reg_in,
        Output => we_reg_out
        );

    
    coefficient_reverse_reg_1 : entity work.dyn_shift_reg
      generic map (
        width => brv_counter_reg_in'length
        )
      port map (
        clk    => clk,
        depth  => added_delays ,
        Input  => std_logic_vector(brv_counter_reg_in),
        Output => brv_counter_reg_out
        );

    finished_delay_reg_1 : entity work.dyn_shift_reg
      generic map (
        width => 1
        )
      port map (
        clk    => clk,
        depth  => added_delays_minus_1,
        Input  => finished_reg_in,
        Output => finished_reg_out
        );



    --configuration of the W_table
    w_psi_req     <= '1';
    w_inverse_req <= '0';


    --Configuration of MAR
    a_a_in <= (others => '0');
    a_op   <= (others => '0');

    --Put delayed coefficient and psi from w_table into the mar arithemtic
    a_w_in <= w_out_val;
    a_b_in <= unsigned(coefficient_w_delayed);

     
  end generate XN_m1;

  --Working process
  process (clk)
  begin
    if rising_edge(clk) then
      --XN=-1 Case
      if xn = -1 then
        if finished_reg_out(0) = '1' then
          usr_ready <= '1';
        end if;
        addra_reg <= brv_counter_reg_out;
        we_reg    <= we_reg_out(0);
        din_reg   <= std_logic_vector(a_x_out);
      end if;


      finished           <= '0';
      we_reg_in(0)       <= '0';
      finished_reg_in(0) <= '0';
      

      if valid = '1' then
        --The much more complicated case. XN=-1 and therefore we need the
        --multiplication by psi which involes the w_table and mar arithemtic unit.
        if xn = -1 then
          usr_ready          <= '0';
          w_index            <= counter;
          we_reg_in(0)       <= '1';
          brv_counter_reg_in <= bit_rev_counter;
          counter            <= counter+1;
          if counter = N_ELEMENTS-1 then
            counter            <= (others => '0');
            finished_reg_in(0) <= '1';
          end if;
        end if;
        
        
        
      end if;
    end if;
  end process;

end Behavioral;




































































