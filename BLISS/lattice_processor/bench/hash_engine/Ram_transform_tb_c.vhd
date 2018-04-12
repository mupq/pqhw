--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:34:42 09/06/2011
-- Design Name:   
-- Module Name:   /home/thomasp/xilinx/DSPMU/Ram_transform_tb_c.vhd
-- Project Name:  DSP_Mul
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: RAM_transform
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.HASH_ENGINE_DEFS.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use ieee.math_real.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

entity Ram_transform_tb_c is
end Ram_transform_tb_c;

architecture behavior of Ram_transform_tb_c is

  -- Component Declaration for the Unit Under Test (UUT)
  
  component RAM_transform
    port(
      clk                 : in  std_logic;
      start               : in  std_logic;
      finished            : out std_logic;
      ram_addr            : out std_logic_vector(8 downto 0);
      ram_data            : in  std_logic_vector(22 downto 0);
      fifo_din            : out std_logic_vector(31 downto 0);
      fifo_threshold_full : in  std_logic;
      fifo_wr_en          : out std_logic
      );
  end component;

  component hash_input_fifo
    port (
      rst          : in  std_logic;
      clk          : in  std_logic;
      --wr_clk       : in  std_logic;
      --rd_clk       : in  std_logic;
      din          : in  std_logic_vector(31 downto 0);
      wr_en        : in  std_logic;
      rd_en        : in  std_logic;
      dout         : out std_logic_vector(31 downto 0);
      full         : out std_logic;
      almost_full  : out std_logic;
      empty        : out std_logic;
      almost_empty : out std_logic;
      prog_full    : out std_logic);
  end component;


  --End of simulation
  signal end_of_simulation : std_logic := '0';

  --Inputs
  signal clk                 : std_logic                     := '0';
  signal start               : std_logic                     := '0';
  signal ram_data            : std_logic_vector(22 downto 0) := (others => '0');
  signal fifo_din            : std_logic_vector(31 downto 0) := (others => '0');
  signal fifo_threshold_full : std_logic                     := '0';

  --Outputs
  signal finished   : std_logic;
  signal ram_addr   : std_logic_vector(8 downto 0);
  signal fifo_wr_en : std_logic;

  -- Clock period definitions
  constant clk_period : time := 10 ns;

  signal ram_addr_delayed : std_logic_vector(RAM_ADDR_WIDTH-1 downto 0);
  signal ram_data_output  : std_logic_vector(RAM_DATA_WIDTH-1 downto 0);

  signal tb_dout            : std_logic_vector(31 downto 0);
  signal tb_rd_en           : std_logic                                                 := '0';
  signal tb_empty           : std_logic;
  signal reality_bitstream  : std_logic_vector(TRANSFORM_OUT_W*RAM_ELEMENTS-1 downto 0) := (others => '0');
  signal computed_bitstream : std_logic_vector(TRANSFORM_OUT_W*RAM_ELEMENTS-1 downto 0) := (others => '0');

  signal debug_out              : integer;
  signal finished_triggered     : std_logic :='0';
  signal tb_empty_neg           : std_logic;
  signal clear_finish_triggered : std_logic;

  signal tb_empty_delay : std_logic;

  signal error_happened : std_logic := '0';

  type ram_type is array (511 downto 0) of std_logic_vector(RAM_DATA_WIDTH-1 downto 0);
  
begin

  -- Instantiate the Unit Under Test (UUT)
  uut : RAM_transform port map (
    clk                 => clk,
    start               => start,
    finished            => finished,
    ram_addr            => ram_addr,
    ram_data            => ram_data,
    fifo_din            => fifo_din,
    fifo_threshold_full => fifo_threshold_full,
    fifo_wr_en          => fifo_wr_en
    );

  -- Clock process definitions
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  -----------------------------------------------------------------------------
  -- Chicken Food to make it work
  -----------------------------------------------------------------------------

  bram_ayy : entity work.dp_bram
    generic map (
      SIZE       => RAM_ELEMENTS,
      ADDR_WIDTH => RAM_ADDR_WIDTH,
      COL_WIDTH  => RAM_DATA_WIDTH ,
      InitFile   => "../bench/hash_engine/Ram_transform_tb_c/result"
      )
    port map (
      clka  => clk,
      clkb  => clk,
      ena   => '1',
      enb   => '0',
      wea   => '0',
      web   => '0',
      addra => ram_addr_delayed,
      addrb => (others => '0'),
      dia   => (others => '0'),
      dib   => (others => '0'),
      doa   => ram_data_output,
      dob   => open
      );


  
  your_instance_name : hash_input_fifo
    port map (
      rst          => '0',
      clk          => clk,
      -- wr_clk       => clk,
      -- rd_clk       => clk,
      din          => fifo_din,
      wr_en        => fifo_wr_en,
      rd_en        => tb_rd_en,
      dout         => tb_dout,
      full         => open,
      almost_full  => open,
      empty        => tb_empty,
      almost_empty => open,
      prog_full    => fifo_threshold_full
      );

  addr_register : entity work.shift_reg
    generic map(
      width => RAM_ADDR_WIDTH,
      depth => 1
      )
    port map(
      output => ram_addr_delayed,
      input  => ram_addr,
      clk    => clk
      );

  data_register : entity work.shift_reg
    generic map(
      width => RAM_DATA_WIDTH,
      depth => 1
      )
    port map(
      output => ram_data,
      input  => ram_data_output,
      clk    => clk
      );

  hash_finish : entity work.rising_edge_detector
    port map (
      clk           => clk,
      input         => finished,
      reset_rs_edge => '0',
      rs_edge       => finished_triggered
      );

  delay_counter_1 : entity work.delay_counter
    generic map (
      cycles => 10                      --just to be sure
      )
    port map (
      clk   => clk,
      input => tb_empty_neg,
      q     => tb_empty_delay
      );


  tb_empty_neg <= not tb_empty;

  -- Stimulus process
  stim_proc : process
    variable y1          : std_logic_vector(TRANSFORM_OUT_W-1 downto 0);
    variable y           : std_logic_vector(TRANSFORM_IN_W-1 downto 0);
    file RamFile         : text is in "../bench/hash_engine/Ram_transform_tb_c/result";
    variable RamFileLine : line;
    variable temp        : integer;
    variable ptr         : integer := 0;
    variable RAM         : ram_type;
    variable counter     : integer := 0;
    variable y_tb        : integer;

    variable N                               :       integer;  -- range 0 to 2**this_size-1;
    variable seed1                           :       integer := 12363;
    variable seed2                           :       integer := 54783;
    procedure rand_int(variable seed1, seed2 : inout positive; min, max : in integer; result : out integer) is
      variable rand : real;
    begin
      uniform(seed1, seed2, rand);
      result := integer(real(min) + (rand * (real(max)-real(min))));
    end procedure;

    variable delay : integer := 0;
    
  begin
    -- hold reset state for 100 ns.
    wait for 100 ns;

    --Compute the reality bitstream
    for I in 511 downto 0 loop
      readline (RamFile, RamFileLine);
      read (RamFileLine, RAM(I));
    end loop;

    for I in 0 to 511 loop
      y_tb := to_integer(unsigned(RAM(I)));
      --Get signed number
      if y_tb > ((8383489-1)/2) then
        y_tb := y_tb-8383489;
      end if;
      --calculate y0
      temp := (y_tb mod 32705);
      if temp > ((32705-1)/2) then
        temp := temp - 32705;
      end if;
      --calculate y1
      temp                                                                            := (y_tb -temp)/32705;
      debug_out                                                                       <= temp;
      wait for 10ps;
      reality_bitstream(I*TRANSFORM_OUT_W+TRANSFORM_OUT_W-1 downto I*TRANSFORM_OUT_W) <= std_logic_vector(to_signed(temp, TRANSFORM_OUT_W));
    end loop;


    --wait until rising_edge(clk);
    wait for clk_period*10;

    --Start computation

    for z in 0 to 10 loop
      clear_finish_triggered <= '1';
      counter                := 0;
      start                  <= '1';
      wait for clk_period*10;
      clear_finish_triggered <= '0';
      start                  <= '0';

      wait for clk_period*10;
      tb_rd_en <= '0';

      wait until rising_edge(clk);

      --Gather the outputs of the buffer
      while finished_triggered = '0' or tb_empty = '0' or tb_empty_delay = '0' loop
        debug_out <= counter;
        tb_rd_en  <= '0';
        --Randomized delay fpr the fifo
        rand_int(seed1, seed2, 0, 50, delay);
        wait for clk_period*delay;
        wait for clk_period*1;
        wait until rising_edge(clk);
        if tb_empty = '0' then
          tb_rd_en                                                                                     <= '1';
          wait until rising_edge(clk);
          wait for 1ns;
          tb_rd_en                                                                                     <= '0';
          --Copy in the result buffer
          computed_bitstream(counter*FIFO_DATA_WIDTH+FIFO_DATA_WIDTH-1 downto counter*FIFO_DATA_WIDTH) <= tb_dout;
-- report  to_string_std_logic_vector(tb_dout);
          counter                                                                                      := counter+1;
        end if;
      end loop;

      wait for clk_period*1000;
      --Check that both buffers contain simililar data
      if computed_bitstream /= reality_bitstream then
        error_happened <= '1';
        report "No match between large vectors";
      end if;
      
    end loop;  -- z in 0 to 2

    wait for clk_period*10;

    --Finish simulation
    if error_happened = '1' then
      report "ERORR";
    else
      report "OK";
    end if;
    end_of_simulation <= '1';


    wait;
  end process;

end;
