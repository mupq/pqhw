----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:25:15 03/15/2012 
-- Design Name: 
-- Module Name:    fft_addr_gen - Behavioral 
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
use ieee.math_real.all;
use ieee.numeric_std.all;



-- Generates the address lines for the FFT
--while m <= N: 
--            for s in range(0, N, m): 
--                for i in range(m/2): 
--                    n = i * N / m 
--                    a = s + i 
--                    b = s + i + m/2
--            m = m * 2


entity fft_addr_gen is
  generic (
    N_ELEMENTS : integer := 512
    );
  port (

    clk      : in  std_logic;
    --control signals
    start    : in  std_logic;
    finished : out std_logic;

    --Generated address values
    valid : out std_logic;
    a     : out unsigned(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0);
    b     : out unsigned(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0);
    n     : out unsigned(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0);
    op    : out std_logic
    );

end fft_addr_gen;

architecture Behavioral of fft_addr_gen is

  constant GEN_SIZE : integer := integer(ceil(log2(real(N_ELEMENTS))));

  signal rc_overflow    : std_logic := '0';
  signal ra_overflow_d1 : std_logic := '0';
  signal ra_overflow    : std_logic := '0';
  signal en             : std_logic := '0';
  signal en_tmp         : std_logic := '0';
  signal step           : std_logic := '0';

  signal m_reg1 : integer range 0 to N_ELEMENTS := 2;
  signal m_reg2 : integer range 0 to N_ELEMENTS := 2;

  signal madd_reg1 : integer range 0 to GEN_SIZE := 1;
  signal madd_reg2 : integer range 0 to GEN_SIZE := 1;

  signal i_reg1 : integer range 0 to N_ELEMENTS := 0;
  signal i_reg2 : integer range 0 to N_ELEMENTS := 0;
  signal s_reg1 : integer range 0 to N_ELEMENTS := 0;
  signal s_reg2 : integer range 0 to N_ELEMENTS := 0;

  signal a_reg1 : unsigned(GEN_SIZE-1 downto 0);
  signal a_reg2 : unsigned(GEN_SIZE-1 downto 0);

  signal b_reg1 : unsigned(GEN_SIZE-1 downto 0);
  signal b_reg2 : unsigned(GEN_SIZE-1 downto 0);

  signal n_reg1 : unsigned(GEN_SIZE-1 downto 0);
  signal n_reg2 : unsigned(GEN_SIZE-1 downto 0);

  signal valid_reg1 : std_logic := '0';
  signal valid_reg2 : std_logic := '0';
  signal valid_reg3 : std_logic := '0';
  signal valid_reg4 : std_logic := '0';

  signal finished_s1 : std_logic := '0';
  signal finished_s2 : std_logic := '0';
  signal finished_s3 : std_logic := '0';


begin
  
  --Kind of state machine
  ctl : process (clk)
    variable i    : integer range 0 to N_ELEMENTS   := 0;
    variable m    : integer range 0 to N_ELEMENTS*2 := 2;
    variable s    : integer range 0 to N_ELEMENTS   := 0;
    variable madd : integer range 0 to GEN_SIZE+1   := 1;
    -- variable s_r   : integer := 0;
    --  variable m_r : integer := 0;

  begin  -- process

    if rising_edge(clk) then            -- rising clock edge

      finished_s1 <= '0';
      --register Transfers
      finished_s2 <= finished_s1;
      finished_s3 <= finished_s2;
      finished    <= finished_s3;


      if start = '1' then
        i    := 0;
        en   <= '1';
        step <= '0';
        --valid_reg1 <= '1';
      end if;


      if en = '1' then
        valid_reg1 <= '1';
      end if;

      if en = '1' then
        if i < (m/2)-1 then
          i := i+1;
        else
          i := 0;
          if to_unsigned(s, GEN_SIZE) srl 1 < to_unsigned(N_ELEMENTS-m, GEN_SIZE)srl 1 then
            s := s+m;

          else
            m    := m*2;
            madd := madd+1;

            s := 0;
          end if;
        end if;

        if m > N_ELEMENTS then
          en          <= '0';
          valid_reg1  <= '0';
          i           := 0;
          m           := 2;
          madd        := 1;
          s           := 0;
          finished_s1 <= '1';
        end if;
      end if;

      --Register Transfer
      valid_reg2 <= valid_reg1;
      valid_reg3 <= valid_reg2;
      valid      <= valid_reg3 or valid_reg4;
      valid_reg4 <= valid_reg3;


      i_reg1 <= i;
      i_reg2 <= i_reg1;

      m_reg1 <= m;
      m_reg2 <= m_reg1;

      madd_reg1 <= madd;
      madd_reg2 <= madd_reg1;

      s_reg1 <= s;
      s_reg2 <= s_reg1;

      a_reg1 <= a_reg2;
      a      <= a_reg1;

      b_reg1 <= b_reg2;
      b      <= b_reg1;

      n_reg1 <= n_reg2;
      n      <= n_reg1;

      n_reg2 <= resize(unsigned(to_unsigned(i_reg2*N_ELEMENTS, 2*GEN_SIZE) srl madd_reg2), n_reg2'length);
      a_reg2 <= to_unsigned(s_reg2+i_reg2, a'length);
      b_reg2 <= to_unsigned(s_reg2+i_reg2+m_reg2/2, b'length);
    end if;
  end process ctl;

end Behavioral;


