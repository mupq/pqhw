----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:47:53 11/16/2012 
-- Design Name: 
-- Module Name:    gen_fifo - Behavioral 
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


entity gen_fifo is
  generic (
    WIDTH : integer := 15;
    --Has to be power of two
    DEPTH : integer := 512
    );
  port (
    clk          : in  std_logic;
    srst         : in  std_logic;
    din          : in  std_logic_vector(WIDTH-1 downto 0);
    wr_en        : in  std_logic;
    rd_en        : in  std_logic;
    dout         : out std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    full         : out std_logic                          := '0';
    almost_full  : out std_logic                          := '0';
    empty        : out std_logic                          := '0';
    almost_empty : out std_logic                          := '0';
    valid        : out std_logic                          := '0';
    data_count   : out std_logic_vector(integer(ceil(log2(real(DEPTH))))-1 downto 0)
    );
end gen_fifo;

architecture Behavioral of gen_fifo is

  constant ADDR_WIDTH : integer := integer(ceil(log2(real(DEPTH))));
  constant COL_WIDTH  : integer := WIDTH;

  signal ram_wea   : std_logic;
  signal ram_web   : std_logic;
  signal ram_addra : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal ram_addrb : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal ram_dia   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal ram_doa   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal ram_dob   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');

  --Keeps track of the number of elements in the FIFO
  signal counter : integer range 0 to DEPTH := 0;

  --Write and read pointers
  signal ptr_w : unsigned(integer(ceil(log2(real(DEPTH))))-1 downto 0) := (others => '0');
  signal ptr_r : unsigned(integer(ceil(log2(real(DEPTH))))-1 downto 0) := (others => '0');

  signal dout_intern  : std_logic_vector(COL_WIDTH-1 downto 0) := (others => '0');
  signal written_last : std_logic_vector(COL_WIDTH-1 downto 0) := (others => '0');

  
begin

  fifo_ram : entity work.low_delay_dp_bram
    generic map (
      SIZE       => DEPTH,
      ADDR_WIDTH => ADDR_WIDTH,
      COL_WIDTH  => COL_WIDTH,
      InitFile   => ""
      )
    port map (
      clka  => clk,
      clkb  => clk,
      ena   => '1',
      enb   => '1',
      --a=write, b=read
      wea   => ram_wea,
      web   => '0',
      addra => ram_addra,
      addrb => ram_addrb,
      dia   => ram_dia,
      dib   => open, --(others => '0'),
      doa   => ram_doa,
      dob   => ram_dob
      );


  full         <= '1' when counter = DEPTH                      else '0';
  almost_full  <= '1' when counter = DEPTH-1 or counter = DEPTH else '0';
  empty        <= '1' when counter = 0                          else '0';
  almost_empty <= '1' when counter = 1 or counter = 0           else '0';
  data_count   <= std_logic_vector(resize(to_unsigned(counter, data_count'length+1),data_count'length));

  ram_addrb <= std_logic_vector(ptr_r) when rd_en = '0' or counter = 0 else
               std_logic_vector(ptr_r+1);

  process (clk)
    variable counter_intern : integer range 0 to DEPTH := 0;
  begin  -- process
    if rising_edge(clk) then            -- rising clock edge

      
      valid          <= '0';
      ram_wea        <= '0';
      counter_intern := counter;

      --Reset mode
      if srst = '1' then
        ptr_r          <= (others => '0');
        ptr_w          <= (others => '0');
        counter        <= 0;
        counter_intern := 0;
      else
        --Working mode

        if wr_en = '1' and counter_intern < DEPTH then
          ram_addra      <= std_logic_vector(ptr_w);
          ram_dia        <= din;
          written_last   <= din;
          ram_wea        <= '1';
          counter_intern := counter +1;
          if ptr_w = (DEPTH-1) then
            ptr_w <= (others => '0');
          else
            ptr_w <= ptr_w + 1;         --wraps around automatically 
          end if;
        end if;

        if rd_en = '1' and counter > 0 then
          if(ptr_r+1) = ptr_w then
            dout <= written_last;
          else
            dout <= ram_dob;
          end if;

          if ptr_r = (DEPTH-1) then
            ptr_r <= (others => '0');
          else
            ptr_r <= ptr_r + 1;         --wraps around automatically 
          end if;

          counter_intern := counter_intern - 1;
          valid          <= '1';
        end if;
      end if;

      counter <= counter_intern;

    end if;
  end process;


end Behavioral;

