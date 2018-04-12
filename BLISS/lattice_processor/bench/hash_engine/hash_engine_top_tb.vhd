--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:36:18 09/07/2011
-- Design Name:   
-- Module Name:   /home/thomasp/xilinx/DSPMU/dsadadsada.vhd
-- Project Name:  DSP_Mul
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: hash_engine_top
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
use std.textio.all;
use ieee.numeric_std.all;


-------------------------------------------------------------------------------
-- Data obtained from hash_engine_model.exe in this folder hierachy
-------------------------------------------------------------------------------



entity hash_engine_top_tb_c is
end hash_engine_top_tb_c;

architecture behavior of hash_engine_top_tb_c is

  -- Component Declaration for the Unit Under Test (UUT)
  
  component hash_engine_top
    port(
      clk          : in  std_logic;
      clear_state  : in  std_logic;
      hash_msg     : in  std_logic;
      msg_end      : in  std_logic;
      hash_arith   : in  std_logic;
      arith_hashed : out std_logic;
      reset_arith  : in  std_logic;
      arith_wait   : out std_logic;
      msg_wait     : out std_logic;

      fifo_din         : in  std_logic_vector(31 downto 0);
      fifo_almost_full : out std_logic;
      fifo_wr_en       : in  std_logic;
      ram_addr         : out std_logic_vector(8 downto 0);
      ram_data         : in  std_logic_vector(22 downto 0);
      c                : out std_logic_vector(159 downto 0)
      );
  end component;

  --End of simulation
  signal end_of_simulation : std_logic := '0';
  signal cycle_counter     : integer   := 0;

  --Inputs
  signal clk         : std_logic                     := '0';
  signal clear_state : std_logic                     := '0';
  signal hash_msg    : std_logic                     := '0';
  signal msg_end     : std_logic                     := '0';
  signal hash_arith  : std_logic                     := '0';
  signal reset_arith : std_logic                     := '0';
  signal fifo_din    : std_logic_vector(31 downto 0) := (others => '0');
  signal fifo_wr_en  : std_logic                     := '0';
  signal ram_data    : std_logic_vector(22 downto 0) := (others => '0');

  --Outputs
  signal msg_hashed       : std_logic;
  signal arith_hashed     : std_logic;
  signal fifo_almost_full : std_logic;
  signal ram_addr         : std_logic_vector(8 downto 0);
  signal c                : std_logic_vector(159 downto 0);
  signal arith_wait       : std_logic;
  signal msg_wait         : std_logic;

  -- Clock period definitions
  constant clk_period : time := 10 ns;


  signal ram_addr_delayed : std_logic_vector(RAM_ADDR_WIDTH-1 downto 0);
  signal ram_data_output  : std_logic_vector(RAM_DATA_WIDTH-1 downto 0);

  type   message_type is array (5 downto 0) of std_logic_vector(FIFO_DATA_WIDTH-1 downto 0);
  signal message : message_type := ("11111111111111111111111111111111", "11111111111111111111111111111111", "11111111111111111111111111111111", "11111111111111111111111111111111", "11111111111111111111111111111111", "11111111111111111111111111111111");

  --signal message1 : message_type := ("11111111111111111111111111111111", "11111111111111111111111111111111", "11111111111111111111111111111111", "11111111111111111111111111111111", "11111111111111111111111111111111", "11111111111111111111111111111111");

  signal message2 : message_type := ("11111111111111111111111111111111", "11111111111111111111111111111111", "11111111111111111111111111111111", "11111111111111111111111111111111", "11111111111111111111111111111111", "00000000111111111111111111111111");

  signal error_happened : std_logic := '0';
  
  
begin

  -- Instantiate the Unit Under Test (UUT)
  uut : hash_engine_top port map (
    clk         => clk,
    clear_state => clear_state,
    hash_msg    => hash_msg,
    msg_end     => msg_end,
    arith_wait  => arith_wait,
    msg_wait    => msg_wait,

    hash_arith       => hash_arith,
    arith_hashed     => arith_hashed,
    reset_arith      => reset_arith,
    fifo_din         => fifo_din,
    fifo_almost_full => fifo_almost_full,
    fifo_wr_en       => fifo_wr_en,
    ram_addr         => ram_addr,
    ram_data         => ram_data,
    c                => c
    );

  -- Clock process definitions
  clk_process : process
  begin
    clk           <= '0';
    wait for clk_period/2;
    clk           <= '1';
    wait for clk_period/2;
    cycle_counter <= cycle_counter+1;
  end process;

  bram_ayy : entity work.dp_bram
    generic map (
      SIZE       => RAM_ELEMENTS,
      ADDR_WIDTH => RAM_ADDR_WIDTH,
      COL_WIDTH  => RAM_DATA_WIDTH ,
      InitFile   => "C:\Users\thomas\SHA\Projekte\rewrite_signature\lattice_processor\lattice_processor\bench\hash_engine\hash_engine_top_tb_c\result"
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


  -- Stimulus process
  stim_proc : process
  begin
    -- hold reset state for 100 ns.
    wait for 100 ns;

    wait until rising_edge(clk);
    wait for clk_period*10;

    --Activate the message hashing.
    wait for clk_period*1;
    hash_msg <= '1';
    wait for clk_period*1;
    hash_msg <= '0';

    --Put in a message from above
    wait for clk_period*1;
    for i in 0 to 5 loop
      if fifo_almost_full = '1' then
        wait until fifo_almost_full = '0';
      end if;
      fifo_wr_en <= '1';
      fifo_din   <= message(i);
      wait for clk_period*1;
      fifo_wr_en <= '0';
    end loop;  -- i

    --We are finished with the message
    wait for clk_period*1;
    msg_end <= '1';
    wait for clk_period*1;
    msg_end <= '0';

    --Wait for the signal that the message has been processed
    wait until arith_wait = '1';
    wait for clk_period*1;

    --Now start to hash the arithemtic part
    hash_arith <= '1';
    wait for clk_period*1;
    hash_arith <= '0';

    --Wait for the arithmetic to finish
    wait until arith_hashed = '1';

    --report "Value of hash_output at "& time'image(now) &" "& to_string_std_logic_vector(c);

    wait for clk_period*100;

    reset_arith <= '1';
    wait for clk_period*1;
    reset_arith <= '0';

    wait until arith_wait = '1';
    wait for clk_period*10;
    hash_arith <= '1';
    wait for clk_period*1;
    hash_arith <= '0';

    wait until arith_hashed = '1';
    --report "Value of hash_output at "& time'image(now) &" "& to_string_std_logic_vector(c);
    if c /= x"D9A76D65B93C432F1C44E13851007D4E3126998E" then
      error_happened <= '1';
      report "Wrong c "& time'image(now); --&" "& to_string_std_logic_vector(c);
    end if;

    wait for clk_period*100;

    reset_arith <= '1';
    wait for clk_period*1;
    reset_arith <= '0';

    wait until arith_wait = '1';
    wait for clk_period*10;
    hash_arith <= '1';
    wait for clk_period*1;
    hash_arith <= '0';

    wait until arith_hashed = '1';
    --report "Value of hash_output at "& time'image(now) &" "& to_string_std_logic_vector(c);
    if c /= x"D9A76D65B93C432F1C44E13851007D4E3126998E" then
      error_happened <= '1';
      report "Wrong c "& time'image(now);-- &" "& to_string_std_logic_vector(c);
    end if;

    wait until rising_edge(clk);
    wait until rising_edge(clk);


    ---------------------------------------------------------------------------
    -- New message.  MSB of output is slightly changed.
    ---------------------------------------------------------------------------
    clear_state <= '1';
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    clear_state <= '0';
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait for clk_period*10;

    --Activate the message hashing.
    wait for clk_period*1;
    hash_msg <= '1';
    wait for clk_period*1;
    hash_msg <= '0';

    --Put in a message from above
    wait for clk_period*1;
    for i in 0 to 5 loop
      if fifo_almost_full = '1' then
        wait until fifo_almost_full = '0';
      end if;
      fifo_wr_en <= '1';
      fifo_din   <= message2(i);
      wait for clk_period*1;
      fifo_wr_en <= '0';
    end loop;  -- i

    --We are finished with the message
    wait for clk_period*1;
    msg_end <= '1';
    wait for clk_period*1;
    msg_end <= '0';

    --Wait for the signal that the message has been processed
    wait until arith_wait = '1';
    wait for clk_period*1;

    --Now start to hash the arithemtic part
    hash_arith <= '1';
    wait for clk_period*1;
    hash_arith <= '0';

    --Wait for the arithmetic to finish
    wait until arith_hashed = '1';

    --report "Value of hash_output at "& time'image(now) &" "& to_string_std_logic_vector(c);

    wait for clk_period*100;

    reset_arith <= '1';
    wait for clk_period*1;
    reset_arith <= '0';

    wait until arith_wait = '1';
    wait for clk_period*10;
    hash_arith <= '1';
    wait for clk_period*1;
    hash_arith <= '0';

    wait until arith_hashed = '1';
    --report "Value of hash_output at "& time'image(now) &" "& to_string_std_logic_vector(c);

    if c /=   x"18F2B367D4F9D9EA2D18600D512D39ACA4644FBB" then
      error_happened <= '1';
      report "Wrong c "& time'image(now);-- &" "& to_string_std_logic_vector(c);
    end if;

    wait for clk_period*100;

    reset_arith <= '1';
    wait for clk_period*1;
    reset_arith <= '0';

    wait until arith_wait = '1';
    wait for clk_period*10;
    hash_arith <= '1';
    wait for clk_period*1;
    hash_arith <= '0';

    wait until arith_hashed = '1';
    --report "Value of hash_output at "& time'image(now) &" "& to_string_std_logic_vector(c);
    if c /=x"18F2B367D4F9D9EA2D18600D512D39ACA4644FBB" then
      error_happened <= '1';
      report "Wrong c "& time'image(now);-- &" "& to_string_std_logic_vector(c);
    end if;

    wait for clk_period*100;



    if error_happened = '1' then
      report "ERROR";
    else
      report "OK";
    end if;

    end_of_simulation <= '1';

    --assert signal='1' report "Error" severity error;

    -- insert stimulus here 

    wait;
  end process;

end;
