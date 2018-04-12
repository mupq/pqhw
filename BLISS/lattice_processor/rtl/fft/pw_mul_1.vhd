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
-- Create Date:    18:12:22 03/28/2012 
-- Design Name: 
-- Module Name:    pw_mul - Behavioral 
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



entity pw_mul is
  generic (
    N_ELEMENTS    : integer := 512;
    PRIME_P_WIDTH : integer := 10
    );

  port (
    clk      : in  std_logic;
    start    : in  std_logic;
    finished : out std_logic;

    --connection to arithmetic unit
    a_op    : out std_logic_vector(0 downto 0)       := (others => '0');
    a_w_in  : out unsigned(PRIME_P_WIDTH-1 downto 0) := (others => '0');
    a_a_in  : out unsigned(PRIME_P_WIDTH-1 downto 0) := (others => '0');
    a_b_in  : out unsigned(PRIME_P_WIDTH-1 downto 0) := (others => '0');
    a_x_out : in  unsigned(PRIME_P_WIDTH-1 downto 0) := (others => '0');
    a_delay : in  integer                            := 35;

    --connection to block RAMs coefficient wise bit reversing c=a*b
    bram_delay : in  integer                                                            := 10;
    bram_addra : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    bram_doa   : in  std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');

    bram_addrb : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    bram_dob   : in  std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');

    bram_addrc : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    bram_dic   : out std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');
    bram_wec   : out std_logic                                                          := '0'
    );

end pw_mul;

architecture Behavioral of pw_mul is

  constant GEN_ADDR_WIDTH : integer := integer(ceil(log2(real(N_ELEMENTS))));


  type   eg_state is (DO_POINTMUL, I_SMALLER);
  signal state_reg : eg_state := DO_POINTMUL;


  signal en_addr_gen : std_logic := '0';

  signal counter     : unsigned(GEN_ADDR_WIDTH-1 downto 0) := (others => '0');
  signal rev_counter : unsigned(GEN_ADDR_WIDTH-1 downto 0) := (others => '0');

  signal bram_addrc_rin : std_logic_vector(GEN_ADDR_WIDTH-1 downto 0) := (others => '0');
  signal bram_wec_rin   : std_logic_vector(0 downto 0)                := (others => '0');
  signal bram_wec_rout  : std_logic_vector(0 downto 0)                := (others => '0');

  signal fin_reg_rout : std_logic_vector(0 downto 0) := (others => '0');
  signal fin_reg_rin  : std_logic_vector(0 downto 0) := (others => '0');

  signal bram_addrc_reg_depth : integer := 0;
  signal bram_wec_reg_depth   : integer := 0;
  signal fin_reg_depth        : integer := 0;

  

begin

  --Counter and its bitreverse value
  bitrev : for I in 0 to GEN_ADDR_WIDTH-1 generate
    rev_counter(I) <= counter(GEN_ADDR_WIDTH-1-I);
  end generate bitrev;

  --Connect output of block RAM with the arithemtic
  a_w_in   <= unsigned(bram_doa);
  a_b_in   <= unsigned(bram_dob);
  bram_dic <= std_logic_vector(a_x_out);

  bram_addrc_reg_depth <= bram_delay + a_delay;
  bramc_addrc_reg_1 : entity work.dyn_shift_reg
    generic map (
      width => bram_addrc'length
      )
    port map (
      clk    => clk,
      depth  => bram_addrc_reg_depth,
      Input  => bram_addrc_rin,
      Output => bram_addrc
      );


  bram_wec_reg_depth <= bram_delay + a_delay;
  bram_wec           <= bram_wec_rout(0);
  bramc_wec_reg_1 : entity work.dyn_shift_reg
    generic map (
      width => 1
      )
    port map (
      clk    => clk,
      depth  => bram_wec_reg_depth,
      Input  => bram_wec_rin,
      Output => bram_wec_rout
      );

  
  fin_reg_depth <= bram_delay + a_delay;
  finished      <= fin_reg_rout(0);
  fin_reg_1 : entity work.dyn_shift_reg
    generic map (
      width => 1
      )
    port map (
      clk    => clk,
      depth  => fin_reg_depth,
      Input  => fin_reg_rin,
      Output => fin_reg_rout
      );

  
  
  process (clk)
  begin
    if rising_edge(clk) then
      bram_wec_rin(0) <= '0';
      fin_reg_rin(0)  <= '0';


      if en_addr_gen = '1' or start = '1' then
        --Continue working once started
        en_addr_gen <= '1';

        if state_reg = DO_POINTMUL then
          bram_addra      <= std_logic_vector(counter);
          bram_addrb      <= std_logic_vector(counter);
          bram_addrc_rin  <= std_logic_vector(rev_counter);
          bram_wec_rin(0) <= '1';


          if counter < rev_counter then
            state_reg <= I_SMALLER;
            
          else
            counter <= counter+1;
            if counter > rev_counter then
              bram_wec_rin(0) <= '0';
            end if;
          end if;
        end if;


        if state_reg = I_SMALLER then
          bram_addra      <= std_logic_vector(rev_counter);
          bram_addrb      <= std_logic_vector(rev_counter);
          bram_addrc_rin  <= std_logic_vector(counter);
          bram_wec_rin(0) <= '1';
          state_reg       <= DO_POINTMUL;
          counter         <= counter+1;
        end if;
        
      end if;

      if counter = N_ELEMENTS-1 then
        en_addr_gen    <= '0';
        fin_reg_rin(0) <= '1';
        counter        <= (others => '0');
      end if;
      
    end if;
  end process;


end Behavioral;

