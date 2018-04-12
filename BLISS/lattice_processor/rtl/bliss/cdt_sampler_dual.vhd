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
-- Create Date:    19:16:18 02/23/2014 
-- Design Name: 
-- Module Name:    cdt_sampler_dual - Behavioral 
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
use work.cdt_sampler_pkg.all;




entity cdt_sampler_dual is
  generic (
    PARAM_SET : integer := 1
    );
  port (
    clk               : in     std_logic;
    gauss_fifo_full1  : in     std_logic;
    gauss_fifo_wr_en1 : out    std_logic;
    gauss_fifo_dout1  : out std_logic_vector(integer(ceil(log2(real(get_cdt_max_index(PARAM_SET)))))-1+1 downto 0);
    rand1_position    : out    std_logic_vector(5 downto 0);

    gauss_fifo_full2  : in  std_logic                                                                              := '0';
    gauss_fifo_wr_en2 : out std_logic                                                                              := '0';
    gauss_fifo_dout2  : out std_logic_vector(integer(ceil(log2(real(get_cdt_max_index(PARAM_SET)))))-1+1 downto 0) := (others => '0');
    rand2_position    : out std_logic_vector(5 downto 0)                                                           := (others => '0');

    rand1_addr_in : in std_logic_vector(5 downto 0);
    rand1_we      : in std_logic;
    rand1_din     : in std_logic_vector(7 downto 0);

    rand2_addr_in : in std_logic_vector(5 downto 0) := (others => '0');
    rand2_we      : in std_logic                    := '0';
    rand2_din     : in std_logic_vector(7 downto 0) := (others => '0')
    );
end cdt_sampler_dual;

architecture Behavioral of cdt_sampler_dual is
  constant MAX_INDEX      : integer := get_cdt_max_index(PARAM_SET);
  constant MAX_BYTE_TABLE : integer := get_cdt_max_byte_table(PARAM_SET);
  constant MAX_BYTE       : integer := get_cdt_max_byte(PARAM_SET);

  --Load the reverse table
  constant reverseTab : reverse_table_type := get_reverse_table(PARAM_SET);

  attribute RAM_STYLE : string;
attribute RAM_STYLE of reverseTab: constant is "DISTRIBUTED";

  component cdt_rand_ram_core
    port (
      a    : in  std_logic_vector(5 downto 0);
      d    : in  std_logic_vector(7 downto 0);
      dpra : in  std_logic_vector(5 downto 0);
      clk  : in  std_logic;
      we   : in  std_logic;
      dpo  : out std_logic_vector(7 downto 0)
      );
  end component;


  type   eg_state is (IDLE1 , SAMPLE1, WAIT_CYCLE1);
  signal state_reg1 : eg_state := IDLE1;

  signal index_sel1 : std_logic_vector(integer(ceil(log2(real(MAX_INDEX))))-1 downto 0) := (others => '0');
  signal index_sel2 : std_logic_vector(integer(ceil(log2(real(MAX_INDEX))))-1 downto 0) := (others => '0');

  signal entry_read_sel1       : std_logic                                                         := '0';
  signal entry_byte_sel1       : std_logic_vector(integer(ceil(log2(real(MAX_BYTE))))-1 downto 0)  := (others => '0');
  signal entry_index_sel1      : std_logic_vector(integer(ceil(log2(real(MAX_INDEX))))-1 downto 0) := (others => '0');
  signal entry_value_out1      : std_logic_vector(7 downto 0);
  signal entry_value_out1_wait : std_logic_vector(7 downto 0);
  signal entry_valid1          : std_logic                                                         := '0';

  signal gauss_fifo_wr_en_intern1 : std_logic                                       := '0';
  signal end_next_cycle1          : std_logic                                       := '0';
  signal first_cycle1             : std_logic                                       := '1';
  signal min1                     : integer range 0 to get_cdt_max_index(PARAM_SET) := 0;
  signal max1                     : integer range 0 to get_cdt_max_index(PARAM_SET) := 0;
  signal cur1                     : integer range 0 to get_cdt_max_index(PARAM_SET) := 0;

  constant MAX_RAM_SIZE        : integer                                                          := get_max_ram(PARAM_SET);
  signal   min_reg1            : integer range 0 to MAX_RAM_SIZE                                  := 0;
  signal   max_reg1            : integer range 0 to MAX_RAM_SIZE                                  := 0;
  signal   entry_byte_sel_reg1 : std_logic_vector(integer(ceil(log2(real(MAX_BYTE))))-1 downto 0) := (others => '0');

  signal comp_fin_reg1 : std_logic := '0';
  signal comp_fin1     : std_logic := '0';

  signal reverse_entry1 : reverse_entry_type;

  signal rand1_addr_out1 : std_logic_vector(5 downto 0);
  signal rand1_dout1     : std_logic_vector(7 downto 0);
  signal rand1_dout_reg1 : std_logic_vector(7 downto 0);

  signal rand1_start_ptr     : std_logic_vector(rand1_addr_out1'range)         := (others => '0');
  signal output_data         : std_logic                                       := '0';
  signal max_entry_byte_sel1 : integer range 0 to get_cdt_max_index(PARAM_SET) := 0;
  signal cur1_greater        : integer range 0 to get_cdt_max_index(PARAM_SET) := 0;
  signal cur1_smaller        : integer range 0 to get_cdt_max_index(PARAM_SET) := 0;
  signal output              : integer range 0 to get_cdt_max_index(PARAM_SET) := 0;
  signal max_min_greater     : integer range 0 to get_cdt_max_index(PARAM_SET) := 0;
  signal max_min_smaller     : integer range 0 to get_cdt_max_index(PARAM_SET) := 0;


begin


  --Is filled by toplevel and is used to access random bits
  cdt_ram_inst1 : cdt_rand_ram_core
    port map (
      clk  => clk,
      --Used by toplevel
      a    => rand1_addr_in,
      d    => rand1_din,
      we   => rand1_we,
      --Used by module
      dpra => rand1_addr_out1,
      dpo  => rand1_dout1
      );


  --Get entries from the table. Completely hides floating point representation
  get_entry_dual_1 : entity work.get_entry_dual
    generic map (
      PARAM_SET => PARAM_SET
      )
    port map (
      clk        => clk,
      byte_sel1  => entry_byte_sel1,
      index_sel1 => entry_index_sel1,
      value_out1 => entry_value_out1
      );

  
  entry_index_sel1 <= std_logic_vector(to_unsigned(cur1, entry_index_sel1'length));

  --use reverse table to narrow down search interval
  reverse_entry1 <= reverseTab(to_integer(unsigned(rand1_dout1)));
  --reverse_entry1   <= (0,262); -- for testing

  --select which part of the ram we are accessing
  rand1_addr_out1 <= std_logic_vector(resize(unsigned(rand1_start_ptr) + unsigned(entry_byte_sel1), rand1_addr_out1'length));


  rand1_position    <= rand1_start_ptr;
  gauss_fifo_wr_en1 <= gauss_fifo_wr_en_intern1;

  process(clk)
    variable wait_finish1 : std_logic := '0';
    variable min_max      : integer   := 0;

    variable greater : std_logic := '0';
    variable smaller : std_logic := '0';

  begin  -- process
    
    if rising_edge(clk) then            -- rising clock edge
      gauss_fifo_dout1         <= (others => '0');
      gauss_fifo_wr_en_intern1 <= '0';
      rand1_dout_reg1          <= rand1_dout1;

      case state_reg1 is
        when IDLE1 =>
          max_entry_byte_sel1 <= 0;
          max_min_greater     <= 0;
          max_min_smaller     <= 0;

          if output_data = '1' then
            --switch to other rand RAM
            gauss_fifo_wr_en_intern1 <= '1';
            gauss_fifo_dout1         <= std_logic_vector(to_unsigned(min1, gauss_fifo_dout1'length));
            output_data              <= '0';
          end if;

          if gauss_fifo_full1 = '0' then
            state_reg1      <= WAIT_CYCLE1;
            min1            <= reverse_entry1(0);
            max1            <= reverse_entry1(1);
            cur1            <= (reverse_entry1(0)+(reverse_entry1(1)))/2;
            entry_byte_sel1 <= (others => '0');
          end if;


        when WAIT_CYCLE1 =>
          state_reg1 <= SAMPLE1;

          if to_integer(unsigned(entry_byte_sel1)) > max_entry_byte_sel1 then
            max_entry_byte_sel1 <= to_integer(unsigned(entry_byte_sel1));
          end if;

          --Compute possible values
          max_min_greater <= cur1-min1;
          max_min_smaller <= max1-cur1;

          cur1_greater <= (min1 + cur1)/2;
          cur1_smaller <= (cur1 +max1)/2;

          
        when SAMPLE1 =>
          greater := '0';
          smaller := '0';

          state_reg1 <= WAIT_CYCLE1;
          if (unsigned(rand1_dout_reg1) > unsigned(entry_value_out1)) then
            entry_byte_sel1 <= (others => '0');
            max1            <= cur1;
            greater         := '1';
            cur1            <= cur1_greater;

          elsif unsigned(rand1_dout_reg1) < unsigned(entry_value_out1) then
            entry_byte_sel1 <= (others => '0');
            min1            <= cur1;
            smaller         := '1';
            cur1            <= cur1_smaller;

          elsif unsigned(rand1_dout_reg1) = unsigned(entry_value_out1) then
            entry_byte_sel1 <= std_logic_vector(to_unsigned(to_integer(unsigned(entry_byte_sel1)+1), entry_byte_sel1'length));
          else
            report "ERROR" severity error;
          end if;


          if ((max_min_greater < 2) and greater = '1') or ((max_min_smaller < 2) and smaller = '1') then
            output_data <= '1';
            state_reg1  <= IDLE1;

            rand1_start_ptr <= std_logic_vector(resize(resize(unsigned(rand1_start_ptr) + to_unsigned(max_entry_byte_sel1+1, rand1_start_ptr'length+2), rand1_addr_out1'length), rand1_addr_out1'length));
            entry_byte_sel1 <= (others => '0');
          end if;
          
      end case;
    end if;
  end process;


end Behavioral;












































------------------------------------------------------------------------------------
---- Company: 
---- Engineer: 
---- 
---- Create Date:    19:16:18 02/23/2014 
---- Design Name: 
---- Module Name:    cdt_sampler_dual - Behavioral 
---- Project Name: 
---- Target Devices: 
---- Tool versions: 
---- Description: 
----
---- Dependencies: 
----
---- Revision: 
---- Revision 0.01 - File Created
---- Additional Comments: 
----
------------------------------------------------------------------------------------
--library IEEE;
--use IEEE.STD_LOGIC_1164.all;
--use ieee.numeric_std.all;
--use ieee.math_real.all;
--use work.cdt_sampler_pkg.all;




--entity cdt_sampler_dual is
--  generic (
--    PARAM_SET : integer := 1
--    );
--  port (
--    clk               : in     std_logic;
--    gauss_fifo_full1  : in     std_logic;
--    gauss_fifo_wr_en1 : out    std_logic;
--    gauss_fifo_dout1  : buffer std_logic_vector(integer(ceil(log2(real(get_cdt_max_index(PARAM_SET)))))-1+1 downto 0);
--    rand1_position    : out    std_logic_vector(6 downto 0);

--    gauss_fifo_full2  : in  std_logic                                                                              := '0';
--    gauss_fifo_wr_en2 : out std_logic                                                                              := '0';
--    gauss_fifo_dout2  : out std_logic_vector(integer(ceil(log2(real(get_cdt_max_index(PARAM_SET)))))-1+1 downto 0) := (others => '0');
--    rand2_position    : out std_logic_vector(6 downto 0)                                                           := (others => '0');

--    rand1_addr_in : in std_logic_vector(6 downto 0);
--    rand1_we      : in std_logic;
--    rand1_din     : in std_logic_vector(7 downto 0);

--    rand2_addr_in : in std_logic_vector(6 downto 0) := (others => '0');
--    rand2_we      : in std_logic                    := '0';
--    rand2_din     : in std_logic_vector(7 downto 0) := (others => '0')
--    );
--end cdt_sampler_dual;

--architecture Behavioral of cdt_sampler_dual is
--  constant MAX_INDEX      : integer := get_cdt_max_index(PARAM_SET);
--  constant MAX_BYTE_TABLE : integer := get_cdt_max_byte_table(PARAM_SET);
--  constant MAX_BYTE       : integer := get_cdt_max_byte(PARAM_SET);

--  --Load the reverse table
--  constant reverseTab : reverse_table_type := get_reverse_table(PARAM_SET);


--  component cdt_rand_ram_core
--    port (
--      a    : in  std_logic_vector(6 downto 0);
--      d    : in  std_logic_vector(7 downto 0);
--      dpra : in  std_logic_vector(6 downto 0);
--      clk  : in  std_logic;
--      we   : in  std_logic;
--      dpo  : out std_logic_vector(7 downto 0)
--      );
--  end component;


--  type   eg_state is (IDLE1 , SAMPLE1, WAIT_CYCLE1);
--  signal state_reg1 : eg_state := IDLE1;

--  signal index_sel1 : std_logic_vector(integer(ceil(log2(real(MAX_INDEX))))-1 downto 0) := (others => '0');
--  signal index_sel2 : std_logic_vector(integer(ceil(log2(real(MAX_INDEX))))-1 downto 0) := (others => '0');

--  signal entry_read_sel1  : std_logic                                                         := '0';
--  signal entry_byte_sel1  : std_logic_vector(integer(ceil(log2(real(MAX_BYTE))))-1 downto 0)  := (others => '0');
--  signal entry_index_sel1 : std_logic_vector(integer(ceil(log2(real(MAX_INDEX))))-1 downto 0) := (others => '0');
--  signal entry_value_out1 : std_logic_vector(7 downto 0);
--  signal entry_value_out1_wait : std_logic_vector(7 downto 0);
--  signal entry_valid1     : std_logic                                                         := '0';

--  signal entry_read_sel2  : std_logic                                                         := '0';
--  signal entry_byte_sel2  : std_logic_vector(integer(ceil(log2(real(MAX_BYTE))))-1 downto 0)  := (others => '0');
--  signal entry_index_sel2 : std_logic_vector(integer(ceil(log2(real(MAX_INDEX))))-1 downto 0) := (others => '0');
--  signal entry_value_out2 : std_logic_vector(7 downto 0);
--  signal entry_valid2     : std_logic                                                         := '0';

--  signal gauss_fifo_wr_en_intern1 : std_logic               := '0';
--  signal end_next_cycle1          : std_logic               := '0';
--  signal first_cycle1             : std_logic               := '1';
--  signal min1                     : integer range 0 to 2580 := 0;
--  signal max1                     : integer range 0 to 2580 := 0;
--  signal cur1                     : integer range 0 to 2580 := 0;

--  constant MAX_RAM_SIZE        : integer                                                          := get_max_ram(PARAM_SET);
--  signal   min_reg1            : integer range 0 to MAX_RAM_SIZE                                  := 0;
--  signal   max_reg1            : integer range 0 to MAX_RAM_SIZE                                  := 0;
--  signal   entry_byte_sel_reg1 : std_logic_vector(integer(ceil(log2(real(MAX_BYTE))))-1 downto 0) := (others => '0');

--  signal comp_fin_reg1 : std_logic := '0';
--  signal comp_fin1     : std_logic := '0';

--  signal reverse_entry1 : reverse_entry_type;

--  signal rand1_addr_out1 : std_logic_vector(6 downto 0);
--  signal rand1_dout1     : std_logic_vector(7 downto 0);
--  signal rand1_dout_reg1 : std_logic_vector(7 downto 0);

--  signal rand2_addr_out2 : std_logic_vector(6 downto 0);
--  signal rand2_dout2     : std_logic_vector(7 downto 0);
--  signal rand2_dout_reg2 : std_logic_vector(7 downto 0);

--  signal rand1_start_ptr     : std_logic_vector(rand1_addr_out1'range) := (others => '0');
--  signal output_data         : std_logic                               := '0';
--  signal max_entry_byte_sel1 : integer range 0 to 2580                 := 0;
--  signal cur1_greater        : integer range 0 to 2580                 := 0;
--  signal cur1_smaller        : integer range 0 to 2580                 := 0;
--  signal output              : integer range 0 to 2580                 := 0;
--  signal max_min_greater     : integer range 0 to 2580                 := 0;
--  signal max_min_smaller     : integer range 0 to 2580                 := 0;


--begin

--  cdt_ram_inst1 : cdt_rand_ram_core
--    port map (
--      clk  => clk,
--      a    => rand1_addr_in,
--      d    => rand1_din,
--      we   => rand1_we,
--      dpra => rand1_addr_out1,
--      dpo  => rand1_dout1
--      );


--  get_entry_dual_1 : entity work.get_entry_dual
--    generic map (
--      PARAM_SET => PARAM_SET
--      )
--    port map (
--      clk        => clk,
--      byte_sel1  => entry_byte_sel1,
--      index_sel1 => entry_index_sel1,
--      value_out1 => entry_value_out1
--      );


--  entry_index_sel1 <= std_logic_vector(to_unsigned(cur1, entry_index_sel1'length));

--  --TODO CHANGE BACK
--  reverse_entry1   <= reverseTab(to_integer(unsigned(rand1_dout1)));
--  --reverse_entry1   <= (0,262);


--  --select which part of the ram we are accessing
--  rand1_addr_out1 <= std_logic_vector(resize(unsigned(rand1_start_ptr) + unsigned(entry_byte_sel1), rand1_addr_out1'length));


--  rand1_position    <= rand1_start_ptr;
--  gauss_fifo_wr_en1 <= gauss_fifo_wr_en_intern1;

--  process(clk)
--    variable wait_finish1 : std_logic := '0';
--    variable min_max      : integer   := 0;

--    variable greater : std_logic := '0';
--    variable smaller : std_logic := '0';


--    --variable value : integer := 0;
--  begin  -- process

--    if rising_edge(clk) then            -- rising clock edge
--      --comp_fin_reg1            <= comp_fin1;
--      --cur_reg            <= cur;
--      --entry_byte_sel_reg <= entry_byte_sel;      gauss_fifo_wr_en_intern1 <= '0';
--      gauss_fifo_dout1         <= (others => '0');
--      gauss_fifo_wr_en_intern1 <= '0';

--      --entry_value_out1 <= entry_value_out1_wait;

--      case state_reg1 is
--        when IDLE1 =>
--          max_entry_byte_sel1 <= 0;
--          max_min_greater     <= 5;
--          max_min_smaller     <= 5;

--          if output_data = '1' then
--            --switch to other rand RAM
--            gauss_fifo_wr_en_intern1 <= '1';
--            gauss_fifo_dout1         <= std_logic_vector(to_unsigned(min1, gauss_fifo_dout1'length));
--            output_data              <= '0';
--          end if;

--          if gauss_fifo_full1 = '0' then
--            state_reg1      <= WAIT_CYCLE1;
--            --first_cycle1    <= '0';
--            --min_max         := 3;
--            min1            <= reverse_entry1(0);
--            max1            <= reverse_entry1(1);
--            cur1            <= (reverse_entry1(0)+(reverse_entry1(1)))/2;
--            entry_byte_sel1 <= (others => '0');
--          end if;


--        when WAIT_CYCLE1 =>
--          --state_reg <=  WAIT_CYCLE2;
--          state_reg1 <= SAMPLE1;

--          if to_integer(unsigned(entry_byte_sel1)) > max_entry_byte_sel1 then
--            max_entry_byte_sel1 <= to_integer(unsigned(entry_byte_sel1));
--          end if;
--          max_min_greater <= cur1-min1;
--          max_min_smaller <= max1-cur1;

--          cur1_greater <= (min1 + cur1)/2;
--          cur1_smaller <= (cur1 +max1)/2;


--        when SAMPLE1 =>
--          greater := '0';
--          smaller := '0';
--          -- max_min_greater := 5;
--          -- max_min_smaller := 5;

--          state_reg1 <= WAIT_CYCLE1;
--         if (unsigned(rand1_dout1) > unsigned(entry_value_out1)) then

--            entry_byte_sel1 <= (others => '0');
--            max1            <= cur1;
--            greater         := '1';
--            --cur1            <= (min1 + cur1)/2;
--            cur1            <= cur1_greater;

--            --entry_byte_sel1 <= (others => '0');
--            --max1            <= cur1;
--            --min1            <= min1;
--            --max_min_greater := cur1-min1;
--            --output          <= min1;
--            -- output          <= min1;

--            -- greater         := '1';
--            --value :=min1;
--            --cur1            <= (min1 +cur1)/2;  --(min+max)/2
--            --entry_byte_sel1 <= (others => '0');
--           elsif unsigned(rand1_dout1) < unsigned(entry_value_out1) then
--            entry_byte_sel1 <= (others => '0');
--            min1            <= cur1;
--            smaller         := '1';
--            cur1            <= cur1_smaller;

--            --entry_byte_sel1 <= (others => '0');
--            --max1            <= max1;
--            --min1            <= cur1;
--            --max_min_smaller := max1-cur1;
--            --smaller         := '1';
--            --output          <= cur1;
--            -- output          <= (cur1 +max1)/2;
--            --value :=cur1;
--            --cur1            <= (cur1 +max1)/2;
--          elsif unsigned(rand1_dout1) = unsigned(entry_value_out1) then
--            entry_byte_sel1 <= std_logic_vector(to_unsigned(to_integer(unsigned(entry_byte_sel1)+1), entry_byte_sel1'length));
--          else
--            report "ERROR" severity error;
--          end if;


--          if ((max_min_greater < 2) and greater = '1') or ((max_min_smaller < 2) and smaller = '1') then
--            output_data <= '1';
--            state_reg1  <= IDLE1;

--            rand1_start_ptr <= std_logic_vector(resize(resize(unsigned(rand1_start_ptr) + to_unsigned(max_entry_byte_sel1+1, rand1_start_ptr'length+2), rand1_addr_out1'length), rand1_addr_out1'length));
--            entry_byte_sel1 <= (others => '0');
--          end if;

--      end case;
--    end if;
--  end process;

-- --assert to_integer(unsigned(gauss_fifo_dout1)) /= 31 report "31" severity note;

--end Behavioral;


