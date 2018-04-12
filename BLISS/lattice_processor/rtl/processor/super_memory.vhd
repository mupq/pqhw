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


-- The super memory implements additional storage space for polynomials. The
-- number and size of registers is configurable. The can be initialized by the
-- init_array variable which uses the lattice_processor package to determine the location of the
-- init files.
entity super_memory is
  generic (
     MODE             : string     := "BOTH";
    ADDR_WIDTH    : integer      := 9;
    ELEMENTS      : integer      := 512;
    RAMS          : integer      := 2;
    MAX_RAM_WIDTH : integer      := 14;
    INIT_ARRAY    : init_array_t := (0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    RAM_WIDTHs    : my_array_t   := (14, 14, 0, 0, 0, 0, 0, 0, 0, 0)
    );

  port (
    clk : in std_logic;

    delay      : out integer                                    := 10;
    ---------------------------------------------------------------------------
    -- Connected to ALU: Hindes all memory accesses
    rd_p1_addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
    rd_p1_do   : out std_logic_vector(MAX_RAM_WIDTH-1 downto 0) := (others => '0');

    rd_p2_addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
    rd_p2_do   : out std_logic_vector(MAX_RAM_WIDTH-1 downto 0) := (others => '0');

    wr_p1_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    wr_p1_di   : in std_logic_vector(MAX_RAM_WIDTH-1 downto 0) := (others => '0');
    wr_p1_we   : in std_logic;

    --select signal
    rd_p1_ctl              : in  unsigned(3 downto 0) := (others => '0');
    rd_p2_ctl              : in  unsigned(3 downto 0) := (others => '0');
    wr_p1_ctl              : in  unsigned(3 downto 0) := (others => '0');
    stable                 : out std_logic            := '0';  --muxer stable after change
    smem_enable_copy_to_io : in  std_logic            := '0';

    -- Additional ports beside the ram in super_ram
    -- Port 1 for the FFT
    fft_ram0_rd_addr : out std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
    fft_ram0_rd_do   : in  std_logic_vector(MAX_RAM_WIDTH-1 downto 0) := (others => '0');

    fft_ram0_wr_addr : out std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
    fft_ram0_wr_di   : out std_logic_vector(MAX_RAM_WIDTH-1 downto 0) := (others => '0');
    fft_ram0_wr_we   : out std_logic;

    -- Port 2 for the FFT
    fft_ram1_rd_addr : out std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
    fft_ram1_rd_do   : in  std_logic_vector(MAX_RAM_WIDTH-1 downto 0) := (others => '0');

    fft_ram1_wr_addr : out std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
    fft_ram1_wr_di   : out std_logic_vector(MAX_RAM_WIDTH-1 downto 0) := (others => '0');
    fft_ram1_wr_we   : out std_logic;

    -- Port for the Sampler (read only)
    sampler_rd_addr : out std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
    sampler_rd_do   : in  std_logic_vector(MAX_RAM_WIDTH-1 downto 0) := (others => '0');

    -- Port for the I/O RAM
    io_rd_addr : out std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
    io_rd_do   : in  std_logic_vector(MAX_RAM_WIDTH-1 downto 0) := (others => '0');

    io_wr_addr : out std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
    io_wr_di   : out std_logic_vector(MAX_RAM_WIDTH-1 downto 0) := (others => '0');
    io_wr_we   : out std_logic

    );

end super_memory;

architecture Behavioral of super_memory is
  constant ADDITIONAL_PORTS : integer := 4;  --Special ports for FFT0,FFT1,IO,Sampler

  constant FFT0_PORT       : integer := 0;
  constant FFT1_PORT       : integer := 1;
  constant FULL_ADDR_WIDTH : integer := ADDR_WIDTH*RAMS + ADDR_WIDTH*ADDITIONAL_PORTS;
  constant FULL_DATA_WIDTH : integer := MAX_RAM_WIDTH*RAMS + MAX_RAM_WIDTH*ADDITIONAL_PORTS;

  signal mux_a_addr : std_logic_vector(FULL_ADDR_WIDTH-1 downto 0)        := (others => '0');
  signal mux_b_addr : std_logic_vector(FULL_ADDR_WIDTH-1 downto 0)        := (others => '0');
  signal mux_a_do   : std_logic_vector(FULL_DATA_WIDTH-1 downto 0)        := (others => '0');
  signal mux_b_di   : std_logic_vector(FULL_DATA_WIDTH-1 downto 0)        := (others => '0');
  signal mux_b_we   : std_logic_vector(RAMS+ADDITIONAL_PORTS -1 downto 0) := (others => '0');

  signal sram_delay : integer;
  signal smux_delay : integer;
  signal smux_reset : std_logic := '1';
begin

  process(clk)
  begin  -- process
    if rising_edge(clk) then
      smux_reset <= '0';
    end if;
  end process;

  delay <= sram_delay + smux_delay;

  --Connection to FFT0
  fft_ram0_rd_addr <= mux_a_addr(FFT0_PORT*ADDR_WIDTH+ADDR_WIDTH-1 downto FFT0_PORT*ADDR_WIDTH);
  fft_ram0_wr_addr <= mux_b_addr(FFT0_PORT*ADDR_WIDTH+ADDR_WIDTH-1 downto FFT0_PORT*ADDR_WIDTH);
  fft_ram0_wr_di   <= mux_b_di(FFT0_PORT*MAX_RAM_WIDTH+MAX_RAM_WIDTH-1 downto FFT0_PORT*MAX_RAM_WIDTH);
  fft_ram0_wr_we   <= mux_b_we(FFT0_PORT);

  mux_a_do(FFT0_PORT*MAX_RAM_WIDTH+MAX_RAM_WIDTH-1 downto FFT0_PORT*MAX_RAM_WIDTH) <= fft_ram0_rd_do;

  --Connection to FFT1
  fft_ram1_rd_addr <= mux_a_addr(FFT1_PORT*ADDR_WIDTH+ADDR_WIDTH-1 downto FFT1_PORT*ADDR_WIDTH);
  fft_ram1_wr_addr <= mux_b_addr(FFT1_PORT*ADDR_WIDTH+ADDR_WIDTH-1 downto FFT1_PORT*ADDR_WIDTH);
  fft_ram1_wr_di   <= mux_b_di(FFT1_PORT*MAX_RAM_WIDTH+MAX_RAM_WIDTH-1 downto FFT1_PORT*MAX_RAM_WIDTH);
  fft_ram1_wr_we   <= mux_b_we(FFT1_PORT);

  mux_a_do(FFT1_PORT*MAX_RAM_WIDTH+MAX_RAM_WIDTH-1 downto FFT1_PORT*MAX_RAM_WIDTH) <= fft_ram1_rd_do;

  --Connection to Sampler
      sampler_rd_addr <= mux_a_addr(SAMPLER_PORT*ADDR_WIDTH+ADDR_WIDTH-1 downto SAMPLER_PORT*ADDR_WIDTH);
      mux_a_do(SAMPLER_PORT*MAX_RAM_WIDTH+MAX_RAM_WIDTH-1 downto SAMPLER_PORT*MAX_RAM_WIDTH) <= sampler_rd_do;

  --connection to IO
  io_rd_addr <= mux_a_addr(IO_PORT*ADDR_WIDTH+ADDR_WIDTH-1 downto IO_PORT*ADDR_WIDTH);
  io_wr_addr <= mux_b_addr(IO_PORT*ADDR_WIDTH+ADDR_WIDTH-1 downto IO_PORT*ADDR_WIDTH);
  io_wr_di   <= mux_b_di(IO_PORT*MAX_RAM_WIDTH+MAX_RAM_WIDTH-1 downto IO_PORT*MAX_RAM_WIDTH);
  io_wr_we   <= mux_b_we(IO_PORT);

  mux_a_do(IO_PORT*MAX_RAM_WIDTH+MAX_RAM_WIDTH-1 downto IO_PORT*MAX_RAM_WIDTH) <= io_rd_do;

  --Multiplexer in order to allow access to specific registers
  super_mux_1 : entity work.super_mux
    generic map (
      ADDR_WIDTH  => ADDR_WIDTH,
      COL_WIDTH   => MAX_RAM_WIDTH,
      CONNECTIONS => RAMS+ADDITIONAL_PORTS  --Rams + FFT1,FFT2,sampler,IO
      )
    port map (
      clk                    => clk,
      delay                  => smux_delay,
      reset                  => smux_reset,
      --Route through
      rd_p1_addr             => rd_p1_addr,
      rd_p1_do               => rd_p1_do,
      rd_p2_addr             => rd_p2_addr,
      rd_p2_do               => rd_p2_do,
      wr_p1_addr             => wr_p1_addr,
      wr_p1_di               => wr_p1_di,
      wr_p1_we               => wr_p1_we,
      rd_p1_ctl              => rd_p1_ctl,
      rd_p2_ctl              => rd_p2_ctl,
      wr_p1_ctl              => wr_p1_ctl,
      stable                 => stable,
      smem_enable_copy_to_io => smem_enable_copy_to_io,
      mux_a_addr             => mux_a_addr,
      mux_a_do               => mux_a_do,
      mux_b_addr             => mux_b_addr,
      mux_b_we               => mux_b_we,
      mux_b_di               => mux_b_di
      );

  --Ram array to store polynomials
  super_ram_1 : entity work.super_ram
    generic map (
      ADDR_WIDTH    => ADDR_WIDTH,
      ELEMENTS      => ELEMENTS,
      RAMS          => RAMS,
      MAX_RAM_WIDTH => MAX_RAM_WIDTH,
      INIT_ARRAY    => INIT_ARRAY,
      RAM_WIDTHs    => RAM_WIDTHs
      )
    port map (
      clk         => clk,
      delay       => sram_delay,
      rams_a_addr => mux_a_addr(FULL_ADDR_WIDTH-1 downto ADDR_WIDTH*ADDITIONAL_PORTS),
      rams_a_do   => mux_a_do(FULL_DATA_WIDTH-1 downto MAX_RAM_WIDTH*ADDITIONAL_PORTS),
      rams_b_addr => mux_b_addr(FULL_ADDR_WIDTH-1 downto ADDR_WIDTH*ADDITIONAL_PORTS) ,
      rams_b_di   => mux_b_di(FULL_DATA_WIDTH-1 downto MAX_RAM_WIDTH*ADDITIONAL_PORTS) ,
      rams_b_we   => mux_b_we(RAMS+ADDITIONAL_PORTS -1 downto ADDITIONAL_PORTS)
      );

end Behavioral;

