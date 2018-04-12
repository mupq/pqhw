--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:32:07 02/13/2014 
-- Design Name: 
-- Module Name:    z2_computation - Behavioral 
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



entity z2_computation is
  generic (
    --------------------------General --------------------------------------
    N_ELEMENTS      : integer  := 512;
    D_BLISS         : integer  := 10;
    MODULUS_P_BLISS : unsigned := to_unsigned(24, 5);
    Z_LENGTH        : integer  := 10;
    PRIME_P         : unsigned := to_unsigned(12289, 14)

    );
  port (
    clk : in std_logic;

    u_data  : in unsigned(PRIME_P'length+1-1 downto 0) := (others => '0');
    u_valid : in std_logic                             := '0';

    z2_data  : in signed(Z_LENGTH-1 downto 0) := (others => '0');
    z2_valid : in std_logic                   := '0';

    z2_final       : out std_logic_vector(MODULUS_P_BLISS'length-1 downto 0)                                       := (others => '0');
    z2_final_addr  : out signed(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    z2_final_valid : out std_logic                                                := '0'
    );

end z2_computation;

architecture Behavioral of z2_computation is
  signal drop_u_delay     : integer range 0 to 7                                  := 3;
  signal drop_u_valid_in  : std_logic := '0';
  signal drop_u_data_in   : std_logic_vector(PRIME_P'length+1-1 downto 0)         := (others => '0');
  signal drop_u_valid_out : std_logic := '0';
  signal drop_u_data_out  : std_logic_vector(PRIME_P'length+1-1-D_BLISS downto 0) := (others => '0');

  signal sub_res_u_z2           : signed(PRIME_P'length+1+1+1-1 downto 0):= (others => '0');
  signal sub_res_u_z2_mod2p     : unsigned(PRIME_P'length+1+1-1 downto 0):= (others => '0');
  --signal sub_res_u_z2_mod2p_reg : unsigned(PRIME_P'length+1-1 downto 0):= (others => '0');
  signal data_out_reg : signed(PRIME_P'length+1-1 downto 0):= (others => '0');

  signal sub_res_u_z2_valid       : std_logic := '0';
  signal sub_res_u_z2_mod2p_valid : std_logic := '0';
  signal dropped_result_valid     : std_logic := '0';

  signal dropped_result     : unsigned(PRIME_P'length+1-D_BLISS-1 downto 0):= (others => '0');
  signal carries            : signed(PRIME_P'length+1+1-D_BLISS-1 downto 0):= (others => '0');
  signal carries_valid      : std_logic := '0';
  signal data_out_reg_valid : std_logic := '0';

begin

  drop_u_data_in  <= std_logic_vector(u_data);
  drop_u_valid_in <= u_valid;
  drop_bits_u : entity work.drop_bits
    generic map (
      N_ELEMENTS      => N_ELEMENTS,
      PRIME_P         => PRIME_P,
      MODULUS_P_BLISS => MODULUS_P_BLISS,
      D_BLISS         => D_BLISS
      )
    port map (
      clk       => clk,
      delay     => drop_u_delay,
      valid_in  => drop_u_valid_in,
      data_in   => drop_u_data_in,
      valid_out => drop_u_valid_out,
      data_out  => drop_u_data_out
      );


  
  --Too lazy to build submodules.
  process(clk)
  begin
    if rising_edge(clk) then
      sub_res_u_z2_valid <= '0';


      --stage 1
      if z2_valid = '1' and u_valid = '1' then
        sub_res_u_z2_valid <= '1';
        if z2_data <= 0 then
          sub_res_u_z2 <= resize(signed("0"&u_data) - signed(z2_data), sub_res_u_z2'length);
        else
          sub_res_u_z2 <= resize(signed("0"&u_data) + (( signed("0"&(2*PRIME_P)) - signed(z2_data))), sub_res_u_z2'length);
        end if;
      end if;

      --stage 2
      sub_res_u_z2_mod2p_valid <= sub_res_u_z2_valid;
      if sub_res_u_z2 >= resize(signed("0"&(2*PRIME_P)),sub_res_u_z2'length) then
        sub_res_u_z2_mod2p <= resize(unsigned(sub_res_u_z2 - signed("0"&(2*PRIME_P))),sub_res_u_z2_mod2p'length);
      elsif sub_res_u_z2 < to_signed(0,sub_res_u_z2'length) then
        sub_res_u_z2_mod2p <= resize(unsigned("0"&sub_res_u_z2),sub_res_u_z2_mod2p'length);
        report "sub_res_u_z2 smaller than zero" severity note;
        --sub_res_u_z2_mod2p <=resize(unsigned(sub_res_u_z2+signed("0"&(2*PRIME_P))),sub_res_u_z2_mod2p'length);
      else
        sub_res_u_z2_mod2p <= resize(unsigned("0"&sub_res_u_z2),sub_res_u_z2_mod2p'length);
      end if;

      --Stage 3
      dropped_result       <= resize(((2*resize(sub_res_u_z2_mod2p, PRIME_P'length+2)+((to_unsigned(1, 2*(PRIME_P'length)) sll D_BLISS))) srl (D_BLISS+1)), dropped_result'length);
      dropped_result_valid <= sub_res_u_z2_mod2p_valid;


      --Stage 4 substract the dropped result of u from the dropped result of u-z2
      carries       <= resize(resize(signed("0"&drop_u_data_out),carries'length) - signed("0"&dropped_result),carries'length);
      carries_valid <= dropped_result_valid;

      --Stage 5 mod BLISS_P
      if carries > signed("0"&(MODULUS_P_BLISS/2)) then
        data_out_reg <= resize(carries- signed("0"&MODULUS_P_BLISS), data_out_reg'length);
      elsif carries <= -signed("0"&(MODULUS_P_BLISS/2)) then
        data_out_reg <= resize(carries+ signed("0"&MODULUS_P_BLISS), data_out_reg'length);
      else
        data_out_reg <= signed(resize(carries, data_out_reg'length));
      end if;
      data_out_reg_valid <= carries_valid;


      --_XXXXXX HACK
     -- if data_out_reg=-8 then
--z2_final <= (others => '0');
      --  else
        z2_final       <=std_logic_vector(resize(data_out_reg, z2_final'length));
     -- end if;
      


      
      z2_final_addr  <= (others => '0');
      z2_final_valid <= data_out_reg_valid;
      
    end if;
  end process;

  --assert sub_res_u_z2_mod2p<2*PRIME_P report "FALSCH";
 --assert signed(z2_final)>=-1 report "Z2 ERROR";

  
end Behavioral;




















--library IEEE;
--use IEEE.STD_LOGIC_1164.all;
--use ieee.numeric_std.all;
--use ieee.math_real.all;



--entity z2_computation is
--  generic (
--    --------------------------General --------------------------------------
--    N_ELEMENTS      : integer  := 512;
--    D_BLISS         : integer  := 10;
--    MODULUS_P_BLISS : unsigned := to_unsigned(24, 5);
--    Z_LENGTH        : integer  := 10;
--    PRIME_P         : unsigned := to_unsigned(12289, 14)

--    );
--  port (
--    clk : in std_logic;

--    u_data  : in unsigned(PRIME_P'length+1-1 downto 0) := (others => '0');
--    u_valid : in std_logic                             := '0';

--    z2_data  : in signed(Z_LENGTH-1 downto 0) := (others => '0');
--    z2_valid : in std_logic                   := '0';

--    z2_final       : out std_logic_vector(1 downto 0)                                       := (others => '0');
--    z2_final_addr  : out signed(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
--    z2_final_valid : out std_logic                                                := '0'
--    );

--end z2_computation;

--architecture Behavioral of z2_computation is
--  signal drop_u_delay     : integer range 0 to 7                                  := 3;
--  signal drop_u_valid_in  : std_logic := '0';
--  signal drop_u_data_in   : std_logic_vector(PRIME_P'length+1-1 downto 0)         := (others => '0');
--  signal drop_u_valid_out : std_logic := '0';
--  signal drop_u_data_out  : std_logic_vector(PRIME_P'length+1-1-D_BLISS downto 0) := (others => '0');

--  signal sub_res_u_z2           : unsigned(PRIME_P'length+1+1-1 downto 0):= (others => '0');
--  signal sub_res_u_z2_mod2p     : unsigned(PRIME_P'length+1-1 downto 0):= (others => '0');
--  signal sub_res_u_z2_mod2p_reg : unsigned(PRIME_P'length+1-1 downto 0):= (others => '0');
--  signal data_out_reg : signed(PRIME_P'length+1-1 downto 0):= (others => '0');

--  signal sub_res_u_z2_valid       : std_logic := '0';
--  signal sub_res_u_z2_mod2p_valid : std_logic := '0';
--  signal dropped_result_valid     : std_logic := '0';

--  signal dropped_result     : unsigned(PRIME_P'length+1-D_BLISS-1 downto 0):= (others => '0');
--  signal carries            : signed(PRIME_P'length+1-D_BLISS-1 downto 0):= (others => '0');
--  signal carries_valid      : std_logic := '0';
--  signal data_out_reg_valid : std_logic := '0';

--begin

--  drop_u_data_in  <= std_logic_vector(u_data);
--  drop_u_valid_in <= u_valid;
--  drop_bits_u : entity work.drop_bits
--    generic map (
--      N_ELEMENTS      => N_ELEMENTS,
--      PRIME_P         => PRIME_P,
--      MODULUS_P_BLISS => MODULUS_P_BLISS,
--      D_BLISS         => D_BLISS
--      )
--    port map (
--      clk       => clk,
--      delay     => drop_u_delay,
--      valid_in  => drop_u_valid_in,
--      data_in   => drop_u_data_in,
--      valid_out => drop_u_valid_out,
--      data_out  => drop_u_data_out
--      );


--  --Too lazy to build submodules.
--  process(clk)
--  begin
--    if rising_edge(clk) then
--      sub_res_u_z2_valid <= '0';


--      --stage 1
--      if z2_valid = '1' and u_valid = '1' then
--        sub_res_u_z2_valid <= '1';
--        if z2_data < 0 then
--          sub_res_u_z2 <= resize(unsigned(signed("0"&u_data) - signed(z2_data)), sub_res_u_z2'length);
--        else
--          sub_res_u_z2 <= resize(unsigned(signed("0"&u_data) + (( signed("0"&(2*PRIME_P))) - signed(z2_data))), sub_res_u_z2'length);
--        end if;
--      end if;

--      --stage 2
--      sub_res_u_z2_mod2p_valid <= sub_res_u_z2_valid;
--      if sub_res_u_z2 >= (2*PRIME_P) then
--        sub_res_u_z2_mod2p <= resize(sub_res_u_z2 - 2*PRIME_P,sub_res_u_z2_mod2p'length);
--      elsif sub_res_u_z2<0 then
--        sub_res_u_z2_mod2p <= resize(sub_res_u_z2+2*PRIME_P,sub_res_u_z2_mod2p'length);
--      else
--        sub_res_u_z2_mod2p <= resize(sub_res_u_z2,sub_res_u_z2_mod2p'length);
--      end if;

--      --Stage 3
--      dropped_result       <= resize(((to_unsigned(2, PRIME_P'length+2)*resize(sub_res_u_z2_mod2p, PRIME_P'length+2)+((to_unsigned(1, 2*(PRIME_P'length)) sll D_BLISS))) srl (D_BLISS+1)), dropped_result'length);
--      dropped_result_valid <= sub_res_u_z2_mod2p_valid;


--      --Stage 4 substract the dropped result of u from the dropped result of u-z2
--      carries       <= resize(signed("0"&drop_u_data_out) - signed("0"&dropped_result),carries'length);
--      carries_valid <= dropped_result_valid;

--      --Stage 5 mod BLISS_P
--      if carries > signed("0"&(MODULUS_P_BLISS/2)) then
--        data_out_reg <= resize(carries- signed("0"&MODULUS_P_BLISS), data_out_reg'length);
--      elsif carries <= -signed("0"&(MODULUS_P_BLISS/2)) then
--        data_out_reg <= resize(carries+ signed("0"&MODULUS_P_BLISS), data_out_reg'length);
--      else
--        data_out_reg <= signed(resize(carries, data_out_reg'length));
--      end if;
--      data_out_reg_valid <= carries_valid;


--      z2_final       <=std_logic_vector(resize(data_out_reg, z2_final'length));
--      z2_final_addr  <= (others => '0');
--      z2_final_valid <= data_out_reg_valid;
      
--    end if;
--  end process;

--  assert sub_res_u_z2_mod2p<2*PRIME_P report "FALSCH";

--  assert signed(z2_final)>=-1 report "Z2 ERROR";

  
--end Behavioral;
