--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/


--Copyright (c) 2012, 2013 All Right Reserved
--Author: Thomas Pöppelmann (thomas.poeppelmann@rub.de), Secure Hardware
--Group, Ruhr-University Bochum
--Licence: Please look at licence.txt
--Usage information: Please look at readme.txt
--If licence.txt or readme.txt are missing please contact Thomas Pöppelmann
--(thomas.poeppelmann@rub.de) and Tim Güneysu (tim.gueneysu@rub.de)

--Note that this is academic proof-of-concept code in order to evaluate ideas
--and not ment for any usage in products or real-world systems
--It is a research-oriented implementation and thus contains hacks, fixed
--values and is written in some cases for a large number of parameters but can
--be very specific for others (depending on the authors choice)

-- THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY 
-- KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
-- PARTICULAR PURPOSE.

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;



-- This components stores the constants needed for the FFT computation. it
-- holds that psi*psi=omega which reduces the amount elements that need to be
-- stored to 3N (XN=-1) or 2N (XN=1). It uses one big block RAM for this purpose.

entity w_table_improved is
  generic (
    XN            : integer := -1;      --ring (-1 or 1)
   N_ELEMENTS    : integer  := 512;
   PSI           : unsigned := to_unsigned(49,  14);
   OMEGA         : unsigned := to_unsigned(2401, 14 );
   PSI_INVERSE   : unsigned := to_unsigned(1254, 14 );
   OMEGA_INVERSE : unsigned := to_unsigned(11813, 14 );
   N_INVERSE     : unsigned := to_unsigned(12265, 14 );
   PRIME_P       : unsigned := to_unsigned(12289, 14);
   PRIME_P_WIDTH : integer  := 14
    );
  port (
    clk         : in  std_logic;
    psi_req     : in  std_logic;        --request a psi or a omega
    inverse_req : in  std_logic;        --request normal (0) or inverse (1)
    index       : in  unsigned(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0);  --index of value
    out_val     : out unsigned(PRIME_P_WIDTH-1 downto 0);  --output
    delay       : out integer := 6      --delay of component
    );
end w_table_improved;

architecture Behavioral of w_table_improved is
  --constant ROM_SIZE   : integer := 2*N_ELEMENTS -1*(XN-1)*N_ELEMENTS/2;
  constant ROM_SIZE   : integer := 2*N_ELEMENTS+N_ELEMENTS/2;
  
  constant ADDR_WIDTH : integer := integer(ceil(log2(real(ROM_SIZE))));
  constant COL_WIDTH  : integer := PRIME_P_WIDTH;

  signal ena   : std_logic                               := '1';
  signal enb   : std_logic                               := '1';
  signal addra : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal addrb : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal doa   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal dob   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');

  --input register
  signal psi_req_s1     : std_logic;
  signal inverse_req_s1 : std_logic;
  signal index_s1       : unsigned(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0);


  --type vector_type is;
  impure function MODULUS(VALUE : unsigned) return unsigned is
    variable result : unsigned(value'length-1 downto 0) := (others => '0');
    
  begin
    result := value;


    for i in PRIME_P_WIDTH downto 0 loop
      if result > (resize(PRIME_P, result'length) sll i) then
        result := result - (resize(PRIME_P, result'length) sll i);
      end if;
    end loop;  -- i


    return resize(result, PRIME_P_WIDTH);
  end function;



  function InitTable(XN, N_ELEMENTS, PRIME_P_WIDTH : integer) return std_logic_vector is
    variable table : std_logic_vector(ROM_SIZE*COL_WIDTH-1 downto 0);
    variable tmp   : unsigned(3*PRIME_P_WIDTH downto 0);
    
  begin
    
    if XN = -1 then
      tmp := to_unsigned(1, tmp'length);
      --psi^0(w0),psi^1,psi^2(w1),psi^3,psi^4(w2),
      for i in 0 to N_ELEMENTS-1 loop
        table(i*PRIME_P_WIDTH+PRIME_P_WIDTH-1 downto i*PRIME_P_WIDTH) := std_logic_vector(resize(tmp(PRIME_P_WIDTH-1 downto 0), PRIME_P_WIDTH));
        --tmp                                                           := resize(tmp*psi mod PRIME_P, tmp'length);
        tmp                                                           := resize(MODULUS(tmp*psi), tmp'length);
      end loop;  -- i in range

      --only missing w...
      for i in N_ELEMENTS to N_ELEMENTS-1+N_ELEMENTS/2 loop
        table(i*PRIME_P_WIDTH+PRIME_P_WIDTH-1 downto i*PRIME_P_WIDTH) := std_logic_vector(resize(tmp, PRIME_P_WIDTH));
        --tmp                                                           := resize(tmp*psi*psi mod PRIME_P, tmp'length);
        tmp                                                           := resize(MODULUS(tmp*psi*psi), tmp'length);
      end loop;  -- i in range
      --No the same for the inverse
      tmp := to_unsigned(1, tmp'length);
      for i in N_ELEMENTS+N_ELEMENTS/2 to N_ELEMENTS+N_ELEMENTS+N_ELEMENTS/2-1 loop
        table(i*PRIME_P_WIDTH+PRIME_P_WIDTH-1 downto i*PRIME_P_WIDTH) := std_logic_vector(resize(tmp, PRIME_P_WIDTH));
        --  tmp                                                           := resize(tmp*PSI_INVERSE mod PRIME_P, tmp'length);
        tmp                                                           := resize(MODULUS(tmp*PSI_INVERSE), tmp'length);
      end loop;  -- i in range
      --only missing w...
      for i in N_ELEMENTS+N_ELEMENTS+N_ELEMENTS/2 to ROM_SIZE-1 loop
        table(i*PRIME_P_WIDTH+PRIME_P_WIDTH-1 downto i*PRIME_P_WIDTH) := std_logic_vector(resize(tmp, PRIME_P_WIDTH));
        --  tmp                                                           := resize(tmp*PSI_INVERSE*PSI_INVERSE mod PRIME_P, tmp'length);
        tmp                                                           := resize(MODULUS(tmp*PSI_INVERSE*PSI_INVERSE), tmp'length);
        
      end loop;  -- i in range
    end if;

    return table;
  end function;

begin


  --input register transfer
  process (clk)
  begin
    if rising_edge(clk) then

      --assert (to_integer(  (PSI*unsigned(PSI)) mod PRIME_P) = to_integer((OMEGA mod PRIME_P))) or XN=1  report "PSI*PSI != OMEGA, FAILURE" severity FAILURE;

      
      psi_req_s1     <= psi_req;
      inverse_req_s1 <= inverse_req;
      index_s1       <= index;
    end if;
  end process;


  XN_m1 : if XN = -1 generate
    --XN-1 case
    process (clk)
    begin
      if rising_edge(clk) then

        if psi_req_s1 = '0' and inverse_req_s1 = '0' then
          --w is requested
          if index_s1 < N_ELEMENTS/2 then
            addra <= std_logic_vector(to_unsigned(to_integer(index_s1)*2, addra'length));
          else
            addra <= std_logic_vector(to_unsigned(N_ELEMENTS + to_integer(index_s1) - N_ELEMENTS/2 , addra'length));
          end if;
        end if;

        if psi_req_s1 = '1' and inverse_req_s1 = '0' then
          addra <= std_logic_vector(to_unsigned(to_integer(index_s1), addra'length));
        end if;

        if psi_req_s1 = '0' and inverse_req_s1 = '1' then
          if index_s1 < N_ELEMENTS/2 then
            addra <= std_logic_vector(to_unsigned(to_integer(index_s1)*2+N_ELEMENTS+N_ELEMENTS/2, addra'length));
          else
            addra <= std_logic_vector(to_unsigned(N_ELEMENTS + N_ELEMENTS + to_integer(index_s1) , addra'length));
          end if;
        end if;

        if psi_req_s1 = '1' and inverse_req_s1 = '1' then
          addra <= std_logic_vector(to_unsigned(to_integer(index_s1)+N_ELEMENTS+N_ELEMENTS/2, addra'length));
        end if;
        
      end if;
    end process;
    
  end generate XN_m1;

assert to_integer(unsigned(addra))<1280 report "LARGER" severity error;
  
  delay_rom_1 : entity work.delay_rom
    generic map (
      SIZE        => ROM_SIZE,
      ADDR_WIDTH  => ADDR_WIDTH,
      COL_WIDTH   => PRIME_P_WIDTH,
      PRIME_P => PRIME_P,
       N_ELEMENTS =>  N_ELEMENTS,
      add_reg_a   => 1,
      add_reg_b   => 1,
      init_vector => InitTable(XN, N_ELEMENTS, PRIME_P_WIDTH)
      )
    port map (
      clk   => clk,
      ena   => '1',
      enb   => '1',
      addra => addra,
      addrb => addrb,
      doa   => doa,
      dob   => dob
      );

  out_val <= unsigned(doa(PRIME_P_WIDTH-1 downto 0));

end Behavioral;

