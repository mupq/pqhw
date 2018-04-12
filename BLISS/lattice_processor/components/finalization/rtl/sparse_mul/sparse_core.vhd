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
-- Create Date:    11:52:52 02/06/2014 
-- Design Name: 
-- Module Name:    sparse_core - Behavioral 
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




entity sparse_core is
  generic (
    PARAMETER_SET:integer:=1;
    --FFT and general configuration   
    N_ELEMENTS    : integer := 512;
    --The the core which number it has for the counter of positions
    CORES         : integer := 2;
    CORE_NUM      : integer := 1;
    KAPPA         : integer := 23;
    --probably either 2 (s1) or 3 (s2)
    WIDTH_S       : integer := 2;
    --Used to initialize the right s (s1 or s2)
    INIT_TABLE    : integer := 0;
    MAX_RES_WIDTH : integer := 6
    );

  port (
    clk : in std_logic;

    start : in  std_logic;
    ready : out std_logic;

    --Output (logic generating the kapps knows when we are finished)
    res       : out std_logic_vector(MAX_RES_WIDTH-1 downto 0) := (others => '0');
    res_valid : out std_logic                                  := '0';

    --All cores the the same s - so no addr
    data_c  : in std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    valid_c : in std_logic                                                          := '0';

    --Access to the key port (to change the secret key). Write only
    s_addr  : in std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    s_in    : in std_logic_vector(WIDTH_S-1 downto 0);
    s_wr_en :    std_logic                                                          := '0'

    );

end sparse_core;

architecture Behavioral of sparse_core is
  
  signal ram_addr  : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal ram_din   : std_logic_vector(WIDTH_S-1 downto 0);
  signal ram_dout  : std_logic_vector(WIDTH_S-1 downto 0);
  signal ram_wr_en : std_logic                                                          := '0';

  type   eg_state is (IDLE, COMPUTE);
  signal state_reg : eg_state := IDLE;

  signal counter_kappa    : integer range 0 to KAPPA        := 0;
  signal counter_position : integer range 0 to 3*N_ELEMENTS := CORE_NUM;

  --Initialize with number of core
  signal position : integer range 0 to 2*N_ELEMENTS := 0;

  signal result           : signed(MAX_RES_WIDTH-1 downto 0) := (others => '0');
  signal s_out_valid      : std_logic                        := '0';
  signal s_out_valid_reg  : std_logic                        := '0';
  signal s_out_valid_reg2 : std_logic                        := '0';

  signal s_out_sign   : std_logic := '0';
  signal s_out_sign_r : std_logic := '0';

  component s1_ram_core
    port (
      a    : in  std_logic_vector(8 downto 0);
      d    : in  std_logic_vector(1 downto 0);
      clk  : in  std_logic;
      we   : in  std_logic;
      qspo : out std_logic_vector(1 downto 0)
      );
  end component;
  
  component p3_s1_ram_core
    port (
      a    : in  std_logic_vector(8 downto 0);
      d    : in  std_logic_vector(2 downto 0);
      clk  : in  std_logic;
      we   : in  std_logic;
      qspo : out std_logic_vector(2 downto 0)
      );
  end component;
  
 component p4_s1_ram_core
    port (
      a    : in  std_logic_vector(8 downto 0);
      d    : in  std_logic_vector(2 downto 0);
      clk  : in  std_logic;
      we   : in  std_logic;
      qspo : out std_logic_vector(2 downto 0)
      );
  end component;
  
  component s2_ram_core
    port (
      a    : in  std_logic_vector(8 downto 0);
      d    : in  std_logic_vector(2 downto 0);
      clk  : in  std_logic;
      we   : in  std_logic;
      qspo : out std_logic_vector(2 downto 0)
      );
  end component;
  
  component p3_s2_ram_core
    port (
      a    : in  std_logic_vector(8 downto 0);
      d    : in  std_logic_vector(3 downto 0);
      clk  : in  std_logic;
      we   : in  std_logic;
      qspo : out std_logic_vector(3 downto 0)
      );
  end component;

   component p4_s2_ram_core
    port (
      a    : in  std_logic_vector(8 downto 0);
      d    : in  std_logic_vector(3 downto 0);
      clk  : in  std_logic;
      we   : in  std_logic;
      qspo : out std_logic_vector(3 downto 0)
      );
  end component;
begin

  --Core is used to compute for s1
  s1 : if N_ELEMENTS = 512 and WIDTH_S = 2 and PARAMETER_SET=1 generate
    s1_inst : s1_ram_core
      port map (
        clk  => clk,
        a    => ram_addr,
        d    => ram_din,
        we   => ram_wr_en,
        qspo => ram_dout
        );
  end generate s1;

  p3_s1 : if N_ELEMENTS = 512 and WIDTH_S = 3 and PARAMETER_SET=3 generate
    s1_inst : p3_s1_ram_core
      port map (
        clk  => clk,
        a    => ram_addr,
        d    => ram_din,
        we   => ram_wr_en,
        qspo => ram_dout
        );
  end generate  p3_s1;

   p4_s1 : if N_ELEMENTS = 512 and WIDTH_S = 3 and PARAMETER_SET=4 generate
    s1_inst : p4_s1_ram_core
      port map (
        clk  => clk,
        a    => ram_addr,
        d    => ram_din,
        we   => ram_wr_en,
        qspo => ram_dout
        );
  end generate  p4_s1;

  
  --Core is used to compute for s2
  s2 : if N_ELEMENTS = 512 and WIDTH_S = 3 and PARAMETER_SET=1 generate
    s2_inst : s2_ram_core
      port map (
        clk  => clk,
        a    => ram_addr,
        d    => ram_din,
        we   => ram_wr_en,
        qspo => ram_dout
        );
  end generate s2;

   p3_s2 : if N_ELEMENTS = 512 and WIDTH_S =4 and PARAMETER_SET=3 generate
    s2_inst : p3_s2_ram_core
      port map (
        clk  => clk,
        a    => ram_addr,
        d    => ram_din,
        we   => ram_wr_en,
        qspo => ram_dout
        );
  end generate p3_s2;

 p4_s2 : if N_ELEMENTS = 512 and WIDTH_S =4 and PARAMETER_SET=4 generate
    s2_inst : p4_s2_ram_core
      port map (
        clk  => clk,
        a    => ram_addr,
        d    => ram_din,
        we   => ram_wr_en,
        qspo => ram_dout
        );
  end generate p4_s2;


  
  position <= N_ELEMENTS - to_integer(unsigned(data_c)) + counter_position;


  process(clk)
  begin
    if rising_edge(clk) then
      
      ram_wr_en       <= '0';
      ram_din         <= (others => '0');
      ready           <= '0';
      s_out_valid     <= '0';
      s_out_valid_reg <= s_out_valid;
      --s_out_valid_reg  <= s_out_valid_reg2;
      --s_out_valid_reg2 <= s_out_valid;
      res_valid       <= '0';
      s_out_sign_r    <= s_out_sign;

      case state_reg is
        --Just wait. 
        when IDLE =>
          --Allow writing the S RAM
          ram_addr         <= s_addr;
          ram_wr_en        <= s_wr_en;
          ram_din          <= s_in;
          ready            <= '1';
          counter_position <= CORE_NUM;
          counter_kappa    <= 0;

          --Go
          if start = '1' then
            state_reg <= COMPUTE;
            ready     <= '0';
          end if;
          
        when COMPUTE =>
          --accumulate output s ram (if valid)
          if s_out_valid_reg = '1' then
            if s_out_sign_r = '1' then
              result <= result - resize(signed(ram_dout), result'length);
            else
              result <= result + resize(signed(ram_dout), result'length);
            end if;

          end if;

          --We got a valid c position. Compute the s address
          if valid_c = '1' then
            counter_kappa <= counter_kappa+1;
            ram_addr      <= std_logic_vector(to_unsigned(position mod N_ELEMENTS, s_addr'length));
            if position < N_ELEMENTS then
              s_out_sign <= '1';
            else
              s_out_sign <= '0';
            end if;
            s_out_valid <= '1';
          end if;

          if counter_kappa = KAPPA and s_out_valid_reg = '0' then
            counter_position <= counter_position+CORES;
            counter_kappa    <= 0;
            if (counter_position+CORES) >= N_ELEMENTS then
              state_reg        <= IDLE;
              counter_position <= 0;
            end if;
            res       <= std_logic_vector(result);
            res_valid <= '1';
            result    <= (others => '0');
          end if;

          
      end case;
    end if;
    
  end process;


end Behavioral;

