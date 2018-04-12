--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use work.lattice_processor.all;
use ieee.math_real.all;


entity super_mux is
  generic (
    ADDR_WIDTH  : integer := 9;
    COL_WIDTH   : integer := 14;
    CONNECTIONS : integer := 5
    );
  port (
    clk   : in  std_logic;
    delay : out integer := 6;
    reset : in  std_logic;

    --connected to ALU
    rd_p1_addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
    rd_p1_do   : out std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
    rd_p2_addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
    rd_p2_do   : out std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
    wr_p1_addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
    wr_p1_di   : in  std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
    wr_p1_we   : in  std_logic;

    --select signal
    rd_p1_ctl              : in  unsigned(3 downto 0) := (others => '0');
    rd_p2_ctl              : in  unsigned(3 downto 0) := (others => '0');
    wr_p1_ctl              : in  unsigned(3 downto 0) := (others => '0');
    stable                 : out std_logic            := '0';  --muxer stable after change
    smem_enable_copy_to_io : in  std_logic            := '0';

    --Connected to Port1 of the RAMs
    mux_a_addr : out std_logic_vector(ADDR_WIDTH*CONNECTIONS-1 downto 0) := (others => '0');
    mux_a_do   : in  std_logic_vector(COL_WIDTH*CONNECTIONS-1 downto 0)  := (others => '0');

    --Connected to Port2 of the RAMs
    mux_b_addr : out std_logic_vector(ADDR_WIDTH*CONNECTIONS-1 downto 0) := (others => '0');
    mux_b_we   : out std_logic_vector(CONNECTIONS-1 downto 0)            := (others => '0');
    mux_b_di   : out std_logic_vector(COL_WIDTH*CONNECTIONS-1 downto 0)  := (others => '0')

    );
end super_mux;

architecture Behavioral of super_mux is
  constant MAX_C : integer := integer(ceil(log2(real(CONNECTIONS))));

  --Register layer
  signal rd_p1_addr_r1  : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal rd_p1_do_r1    : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal rd_p1_do_r1_c0 : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal rd_p1_do_r1_c1 : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');

  signal rd_p2_addr_r1  : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal rd_p2_do_r1    : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal rd_p2_do_r1_c0 : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal rd_p2_do_r1_c1 : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');

  signal wr_p1_addr_r1 : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal wr_p1_di_r1   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal wr_p1_we_r1   : std_logic;

  signal mux_a_addr_r1 : std_logic_vector(ADDR_WIDTH*CONNECTIONS-1 downto 0) := (others => '0');
  signal mux_a_do_r1   : std_logic_vector(COL_WIDTH*CONNECTIONS-1 downto 0)  := (others => '0');
  signal mux_b_addr_r1 : std_logic_vector(ADDR_WIDTH*CONNECTIONS-1 downto 0) := (others => '0');
  signal mux_b_we_r1   : std_logic_vector(CONNECTIONS-1 downto 0)            := (others => '0');
  signal mux_b_di_r1   : std_logic_vector(COL_WIDTH*CONNECTIONS-1 downto 0)  := (others => '0');

  signal mux_a_do_r1_1 : std_logic_vector(COL_WIDTH*4-1 downto 0)               := (others => '0');
  signal mux_a_do_r1_2 : std_logic_vector(COL_WIDTH*(CONNECTIONS-4)-1 downto 0) := (others => '0');

  signal rd_p1_ctl_r1 : unsigned(3 downto 0) := (others => '0');
  signal rd_p2_ctl_r1 : unsigned(3 downto 0) := (others => '0');
  signal wr_p1_ctl_r1 : unsigned(3 downto 0) := (others => '0');

  signal rd_p1_ctl_r2 : unsigned(3 downto 0) := (others => '0');
  signal rd_p2_ctl_r2 : unsigned(3 downto 0) := (others => '0');
  signal wr_p1_ctl_r2 : unsigned(3 downto 0) := (others => '0');

  signal counter : unsigned(3 downto 0) := (others => '0');

  signal rd_p1_shift_1 : integer range 0 to CONNECTIONS*COL_WIDTH            := 0;
  signal rd_p1_shift_2 : integer range -4*COL_WIDTH to CONNECTIONS*COL_WIDTH := 0;
  signal rd_p2_shift_1 : integer range 0 to CONNECTIONS*COL_WIDTH            := 0;
  signal rd_p2_shift_2 : integer range -4*COL_WIDTH to CONNECTIONS*COL_WIDTH := 0;

  type   mux_array_t is array (0 to CONNECTIONS) of std_logic_vector(COL_WIDTH-1 downto 0);
  signal mux_array : mux_array_t;
  
begin


  process (mux_a_do_r1)
  begin  -- process
    for i in 0 to CONNECTIONS-1 loop
      mux_array(i) <= mux_a_do_r1(COL_WIDTH*i+COL_WIDTH-1 downto COL_WIDTH*i);
    end loop;  -- i
  end process;


  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        rd_p1_addr_r1 <= (others => '0');
        rd_p2_addr_r1 <= (others => '0');
        wr_p1_addr_r1 <= (others => '0');
        wr_p1_di_r1   <= (others => '0');
        wr_p1_we_r1   <= '0';
        mux_a_do_r1_1 <= (others => '0');
        mux_a_do_r1_2 <= (others => '0');

        mux_a_addr <= (others => '0');
        mux_b_addr <= (others => '0');
        mux_b_we   <= (others => '0');
        mux_b_di   <= (others => '0');
      end if;
      rd_p1_addr_r1 <= rd_p1_addr;
      rd_p2_addr_r1 <= rd_p2_addr;
      wr_p1_addr_r1 <= wr_p1_addr;
      wr_p1_di_r1   <= wr_p1_di;
      wr_p1_we_r1   <= wr_p1_we;

      mux_a_do_r1   <= mux_a_do;
      mux_a_do_r1_1 <= mux_a_do(COL_WIDTH*4-1 downto 0);
      mux_a_do_r1_2 <= mux_a_do(COL_WIDTH*CONNECTIONS-1 downto COL_WIDTH*4);
      mux_a_addr    <= mux_a_addr_r1;

      mux_b_addr <= mux_b_addr_r1;
      mux_b_we   <= mux_b_we_r1;
      mux_b_di   <= mux_b_di_r1;


      --connected to ALU
      stable <= '1';

      rd_p1_shift_1 <= ((to_integer(rd_p1_ctl))*COL_WIDTH);
      rd_p1_shift_2 <= ((to_integer(rd_p1_ctl)-4)*COL_WIDTH);

      rd_p2_shift_1 <= ((to_integer(rd_p2_ctl))*COL_WIDTH);
      rd_p2_shift_2 <= ((to_integer(rd_p2_ctl)-4)*COL_WIDTH);

      rd_p1_ctl_r1 <= rd_p1_ctl;
      rd_p2_ctl_r1 <= rd_p2_ctl;
      wr_p1_ctl_r1 <= wr_p1_ctl;

      rd_p1_ctl_r2 <= rd_p1_ctl_r1;
      rd_p2_ctl_r2 <= rd_p2_ctl_r1;
      wr_p1_ctl_r2 <= wr_p1_ctl_r1;

      if counter /= 0 or rd_p1_ctl_r1 /= rd_p1_ctl or rd_p2_ctl_r1 /= rd_p2_ctl or wr_p1_ctl_r1 /= wr_p1_ctl then
        stable  <= '0';
        counter <= counter+1;
        if counter = 5 then
          counter <= (others => '0');
        end if;
      end if;

      -- ### Port a ###
      --Generate shared address line
      mux_a_addr_r1 <= (others => '0');

      if rd_p1_ctl_r1 /= rd_p2_ctl_r1 then
        mux_a_addr_r1 <= std_logic_vector((resize(unsigned(rd_p1_addr_r1), mux_a_addr_r1'length) sll (to_integer(rd_p1_ctl_r1)*ADDR_WIDTH)) or (resize(unsigned(rd_p2_addr_r1), mux_a_addr_r1'length) sll (to_integer(rd_p2_ctl_r1)*ADDR_WIDTH)));
      else
        mux_a_addr_r1 <= std_logic_vector((resize(unsigned(rd_p1_addr_r1), mux_a_addr_r1'length) sll (to_integer(rd_p1_ctl_r1)*ADDR_WIDTH)));
      end if;

      rd_p1_do_r1_c0 <= mux_array(to_integer(rd_p1_ctl_r1));
      rd_p2_do_r1_c0 <= mux_array(to_integer(rd_p2_ctl_r1));
      rd_p1_do       <= rd_p1_do_r1_c0;
      rd_p2_do       <= rd_p2_do_r1_c0;

      -- ### Port b ###
      --Write Port 1
      if smem_enable_copy_to_io = '0' then
        mux_b_addr_r1                         <= (others => '0');
        mux_b_addr_r1                         <= std_logic_vector(resize(unsigned(wr_p1_addr_r1), mux_b_addr_r1'length) sll (to_integer(wr_p1_ctl_r1)*ADDR_WIDTH));
        mux_b_we_r1                           <= (others => '0');
        mux_b_we_r1(to_integer(wr_p1_ctl_r1)) <= wr_p1_we_r1;
        mux_b_di_r1                           <= std_logic_vector(resize(unsigned(wr_p1_di_r1), mux_b_di_r1'length) sll (to_integer(wr_p1_ctl_r1)*COL_WIDTH));

        --Copy the write output to the IO port if shadow IO copy is activated
        --(for efficiency)
      else
        mux_b_addr_r1                         <= (others => '0');
        mux_b_addr_r1                         <= std_logic_vector(resize(unsigned(wr_p1_addr_r1), mux_b_addr_r1'length) sll (to_integer(wr_p1_ctl_r1)*ADDR_WIDTH)) or std_logic_vector(resize(unsigned(wr_p1_addr_r1), mux_b_addr_r1'length) sll (IO_PORT*ADDR_WIDTH));
        mux_b_we_r1                           <= (others => '0');
        mux_b_we_r1(to_integer(wr_p1_ctl_r1)) <= wr_p1_we_r1;
        mux_b_we_r1(IO_PORT)                  <= wr_p1_we_r1;
        mux_b_di_r1                           <= std_logic_vector(resize(unsigned(wr_p1_di_r1), mux_b_di_r1'length) sll (to_integer(wr_p1_ctl_r1)*COL_WIDTH)) or std_logic_vector(resize(unsigned(wr_p1_di_r1), mux_b_di_r1'length) sll (IO_PORT*COL_WIDTH));
      end if;
      
    end if;
  end process;

end Behavioral;



















































--library IEEE;
--use IEEE.STD_LOGIC_1164.all;
--use ieee.numeric_std.all;
--use work.lattice_processor.all;
--use ieee.math_real.all;


--entity super_mux is
--  generic (
--    ADDR_WIDTH  : integer := 9;
--    COL_WIDTH   : integer := 14;
--    CONNECTIONS : integer := 5
--    );
--  port (
--    clk   : in  std_logic;
--    delay : out integer := 6;
--    --reset : in  std_logic;

--    --connected to ALU
--    rd_p1_addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
--    rd_p1_do   : out std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
--    rd_p2_addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
--    rd_p2_do   : out std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
--    wr_p1_addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
--    wr_p1_di   : in  std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
--    wr_p1_we   : in  std_logic;

--    --select signal
--    rd_p1_ctl              : in  unsigned(3 downto 0) := (others => '0');
--    rd_p2_ctl              : in  unsigned(3 downto 0) := (others => '0');
--    wr_p1_ctl              : in  unsigned(3 downto 0) := (others => '0');
--    stable                 : out std_logic            := '0';  --muxer stable after change
--    smem_enable_copy_to_io : in  std_logic            := '0';

--    --Connected to Port1 of the RAMs
--    mux_a_addr : out std_logic_vector(ADDR_WIDTH*CONNECTIONS-1 downto 0) := (others => '0');
--    mux_a_do   : in  std_logic_vector(COL_WIDTH*CONNECTIONS-1 downto 0)  := (others => '0');

--    --Connected to Port2 of the RAMs
--    mux_b_addr : out std_logic_vector(ADDR_WIDTH*CONNECTIONS-1 downto 0) := (others => '0');
--    mux_b_we   : out std_logic_vector(CONNECTIONS-1 downto 0)            := (others => '0');
--    mux_b_di   : out std_logic_vector(COL_WIDTH*CONNECTIONS-1 downto 0)  := (others => '0')

--    );
--end super_mux;

--architecture Behavioral of super_mux is
--  constant MAX_C : integer := integer(ceil(log2(real(CONNECTIONS))));

--  --Register layer
--  signal rd_p1_addr_r1  : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
--  signal rd_p1_do_r1    : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
--  signal rd_p1_do_r1_c0 : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
--  signal rd_p1_do_r1_c1 : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');

--  signal rd_p2_addr_r1  : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
--  signal rd_p2_do_r1    : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
--  signal rd_p2_do_r1_c0 : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
--  signal rd_p2_do_r1_c1 : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');

--  signal wr_p1_addr_r1 : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
--  signal wr_p1_di_r1   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
--  signal wr_p1_we_r1   : std_logic;

--  signal mux_a_addr_r1 : std_logic_vector(ADDR_WIDTH*CONNECTIONS-1 downto 0) := (others => '0');
--  signal mux_a_do_r1   : std_logic_vector(COL_WIDTH*CONNECTIONS-1 downto 0)  := (others => '0');
--  signal mux_b_addr_r1 : std_logic_vector(ADDR_WIDTH*CONNECTIONS-1 downto 0) := (others => '0');
--  signal mux_b_we_r1   : std_logic_vector(CONNECTIONS-1 downto 0)            := (others => '0');
--  signal mux_b_di_r1   : std_logic_vector(COL_WIDTH*CONNECTIONS-1 downto 0)  := (others => '0');

--  signal mux_a_do_r1_1 : std_logic_vector(COL_WIDTH*4-1 downto 0)               := (others => '0');
--  signal mux_a_do_r1_2 : std_logic_vector(COL_WIDTH*(CONNECTIONS-4)-1 downto 0) := (others => '0');

--  signal rd_p1_ctl_r1 : unsigned(3 downto 0) := (others => '0');
--  signal rd_p2_ctl_r1 : unsigned(3 downto 0) := (others => '0');
--  signal wr_p1_ctl_r1 : unsigned(3 downto 0) := (others => '0');

--  signal rd_p1_ctl_r2 : unsigned(3 downto 0) := (others => '0');
--  signal rd_p2_ctl_r2 : unsigned(3 downto 0) := (others => '0');
--  signal wr_p1_ctl_r2 : unsigned(3 downto 0) := (others => '0');

--  signal counter : unsigned(3 downto 0) := (others => '0');

--  signal rd_p1_shift_1 : integer range 0 to CONNECTIONS*COL_WIDTH            := 0;
--  signal rd_p1_shift_2 : integer range -4*COL_WIDTH to CONNECTIONS*COL_WIDTH := 0;
--  signal rd_p2_shift_1 : integer range 0 to CONNECTIONS*COL_WIDTH            := 0;
--  signal rd_p2_shift_2 : integer range -4*COL_WIDTH to CONNECTIONS*COL_WIDTH := 0;

--  type   mux_array_t is array (0 to CONNECTIONS) of std_logic_vector(COL_WIDTH-1 downto 0);
--  signal mux_array : mux_array_t;
  
--begin


--  process (mux_a_do_r1)
--  begin  -- process
--    for i in 0 to CONNECTIONS-1 loop
--      mux_array(i) <= mux_a_do_r1(COL_WIDTH*i+COL_WIDTH-1 downto COL_WIDTH*i);
--    end loop;  -- i
--  end process;


--  process(clk)
--  begin
--    if rising_edge(clk) then
--      --if reset = '1' then
--      --  rd_p1_addr_r1 <= (others => '0');
--      --  rd_p2_addr_r1 <= (others => '0');
--      --  wr_p1_addr_r1 <= (others => '0');
--      --  wr_p1_di_r1   <= (others => '0');
--      --  wr_p1_we_r1   <= '0';
--      --  mux_a_do_r1_1 <= (others => '0');
--      --  mux_a_do_r1_2 <= (others => '0');

--      --  mux_a_addr <= (others => '0');
--      --  mux_b_addr <= (others => '0');
--      --  mux_b_we   <= (others => '0');
--      --  mux_b_di   <= (others => '0');
--      --end if;
--      rd_p1_addr_r1 <= rd_p1_addr;
--      rd_p2_addr_r1 <= rd_p2_addr;
--      wr_p1_addr_r1 <= wr_p1_addr;
--      wr_p1_di_r1   <= wr_p1_di;
--      wr_p1_we_r1   <= wr_p1_we;

--      mux_a_do_r1   <= mux_a_do;
--      mux_a_do_r1_1 <= mux_a_do(COL_WIDTH*4-1 downto 0);
--      mux_a_do_r1_2 <= mux_a_do(COL_WIDTH*CONNECTIONS-1 downto COL_WIDTH*4);
--      mux_a_addr    <= mux_a_addr_r1;

--      mux_b_addr <= mux_b_addr_r1;
--      mux_b_we   <= mux_b_we_r1;
--      mux_b_di   <= mux_b_di_r1;


--      --connected to ALU
--      stable <= '1';

--      rd_p1_shift_1 <= ((to_integer(rd_p1_ctl))*COL_WIDTH);
--      rd_p1_shift_2 <= ((to_integer(rd_p1_ctl)-4)*COL_WIDTH);

--      rd_p2_shift_1 <= ((to_integer(rd_p2_ctl))*COL_WIDTH);
--      rd_p2_shift_2 <= ((to_integer(rd_p2_ctl)-4)*COL_WIDTH);

--      rd_p1_ctl_r1 <= rd_p1_ctl;
--      rd_p2_ctl_r1 <= rd_p2_ctl;
--      wr_p1_ctl_r1 <= wr_p1_ctl;

--      rd_p1_ctl_r2 <= rd_p1_ctl_r1;
--      rd_p2_ctl_r2 <= rd_p2_ctl_r1;
--      wr_p1_ctl_r2 <= wr_p1_ctl_r1;

--      if counter /= 0 or rd_p1_ctl_r1 /= rd_p1_ctl or rd_p2_ctl_r1 /= rd_p2_ctl or wr_p1_ctl_r1 /= wr_p1_ctl then
--        stable  <= '0';
--        counter <= counter+1;
--        if counter = 5 then
--          counter <= (others => '0');
--        end if;
--      end if;

--      -- ### Port a ###
--      --Generate shared address line
--      mux_a_addr_r1 <= (others => '0');

--      if rd_p1_ctl_r1 /= rd_p2_ctl_r1 then
--        mux_a_addr_r1 <= std_logic_vector((resize(unsigned(rd_p1_addr_r1), mux_a_addr_r1'length) sll (to_integer(rd_p1_ctl_r1)*ADDR_WIDTH)) or (resize(unsigned(rd_p2_addr_r1), mux_a_addr_r1'length) sll (to_integer(rd_p2_ctl_r1)*ADDR_WIDTH)));
--      else
--        mux_a_addr_r1 <= std_logic_vector((resize(unsigned(rd_p1_addr_r1), mux_a_addr_r1'length) sll (to_integer(rd_p1_ctl_r1)*ADDR_WIDTH)));
--      end if;

--      rd_p1_do_r1_c0 <= mux_array(to_integer(rd_p1_ctl_r1));
--      rd_p2_do_r1_c0 <= mux_array(to_integer(rd_p2_ctl_r1));
--      rd_p1_do       <= rd_p1_do_r1_c0;
--      rd_p2_do       <= rd_p2_do_r1_c0;

--      -- ### Port b ###
--      --Write Port 1
--      if smem_enable_copy_to_io = '0' then
--        mux_b_addr_r1                         <= (others => '0');
--        mux_b_addr_r1                         <= std_logic_vector(resize(unsigned(wr_p1_addr_r1), mux_b_addr_r1'length) sll (to_integer(wr_p1_ctl_r1)*ADDR_WIDTH));
--        mux_b_we_r1                           <= (others => '0');
--        mux_b_we_r1(to_integer(wr_p1_ctl_r1)) <= wr_p1_we_r1;
--        mux_b_di_r1                           <= std_logic_vector(resize(unsigned(wr_p1_di_r1), mux_b_di_r1'length) sll (to_integer(wr_p1_ctl_r1)*COL_WIDTH));

--        --Copy the write output to the IO port if shadow IO copy is activated
--        --(for efficiency)
--      else
--        mux_b_addr_r1                         <= (others => '0');
--        mux_b_addr_r1                         <= std_logic_vector(resize(unsigned(wr_p1_addr_r1), mux_b_addr_r1'length) sll (to_integer(wr_p1_ctl_r1)*ADDR_WIDTH)) or std_logic_vector(resize(unsigned(wr_p1_addr_r1), mux_b_addr_r1'length) sll (IO_PORT*ADDR_WIDTH));
--        mux_b_we_r1                           <= (others => '0');
--        mux_b_we_r1(to_integer(wr_p1_ctl_r1)) <= wr_p1_we_r1;
--        mux_b_we_r1(IO_PORT)                  <= wr_p1_we_r1;
--        mux_b_di_r1                           <= std_logic_vector(resize(unsigned(wr_p1_di_r1), mux_b_di_r1'length) sll (to_integer(wr_p1_ctl_r1)*COL_WIDTH)) or std_logic_vector(resize(unsigned(wr_p1_di_r1), mux_b_di_r1'length) sll (IO_PORT*COL_WIDTH));
--      end if;
      
--    end if;
--  end process;

--end Behavioral;

