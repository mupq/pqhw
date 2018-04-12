--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:15:06 11/16/2012
-- Design Name:   
-- Module Name:   C:/Users/thomas/SHA/Projekte/rewrite_signature/uniform_sampler/uniform_sampler/bench/common/gen_fifo_tb.vhd
-- Project Name:  uniform_sampler
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: gen_fifo
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
use ieee.numeric_std.all;
use ieee.math_real.all;




entity gen_fifo_tb is
end gen_fifo_tb;

architecture behavior of gen_fifo_tb is
  constant WIDTH : integer := 15;
  constant DEPTH : integer := 512;

  --Inputs
  signal clk   : std_logic                          := '0';
  signal srst  : std_logic                          := '0';
  signal din   : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
  signal wr_en : std_logic                          := '0';
  signal rd_en : std_logic                          := '0';

  signal uut_dout         : std_logic_vector(WIDTH-1 downto 0);
  signal uut_full         : std_logic;
  signal uut_almost_full  : std_logic;
  signal uut_empty        : std_logic;
  signal uut_almost_empty : std_logic;
  signal uut_valid        : std_logic;
  signal uut_data_count   : std_logic_vector(integer(ceil(log2(real(DEPTH))))-1 downto 0);

  signal ref_dout         : std_logic_vector(WIDTH-1 downto 0);
  signal ref_full         : std_logic;
  signal ref_almost_full  : std_logic;
  signal ref_empty        : std_logic;
  signal ref_almost_empty : std_logic;
  signal ref_valid        : std_logic;
  signal ref_data_count   : std_logic_vector(integer(ceil(log2(real(DEPTH))))-1 downto 0);

  -- Clock period definitions
  constant clk_period : time := 10 ns;
  
begin

  -- Instantiate the Unit Under Test (UUT)
  uut : entity work.gen_fifo
    generic map (
      WIDTH => WIDTH,
      DEPTH => DEPTH
      )         
    port map (
      clk          => clk,
      srst         => srst,
      din          => din,
      wr_en        => wr_en,
      rd_en        => rd_en,
      dout         => uut_dout,
      full         => uut_full,
      almost_full  => uut_almost_full,
      empty        => uut_empty,
      almost_empty => uut_almost_empty,
      valid        => uut_valid,
      data_count   => uut_data_count
      );

  --width 15, depth 15 - reference
  ref_fifo : entity work.test_fifo
    port map (
      clk          => clk,
      srst         => srst,
      din          => din,
      wr_en        => wr_en,
      rd_en        => rd_en,
      dout         => ref_dout,
      full         => ref_full,
      almost_full  => ref_almost_full,
      empty        => ref_empty,
      almost_empty => ref_almost_empty,
      valid        => ref_valid,
      data_count   => ref_data_count
      );



  test_process : process
  begin  -- process
    wait for 100 ns;

    while 1 = 1 loop
      if uut_dout /= ref_dout or uut_full /= ref_full or uut_almost_full /= ref_almost_full or uut_empty /= ref_empty or uut_almost_empty /= ref_almost_empty or uut_valid /= ref_valid or uut_data_count /= ref_data_count then
        report "FIFOs do not match" severity error;
      end if;

      wait for clk_period;
    end loop;
    
  end process;


  -- Clock process definitions
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;


  -- Stimulus process
  stim_proc : process
    variable i : integer := 0;
  begin
    -- hold reset state for 100 ns.
    wait for 100 ns;

    wait for clk_period*10;

    --Write into FIFO (full)
    for i in 0 to 511 loop
      din   <= not std_logic_vector(to_unsigned(i+1, din'length));
      wr_en <= '1';
      wait for clk_period;
    end loop;  -- i
    din   <= (others => '0');
    wr_en <= '0';
    wait for clk_period;

    --Read from FIFO (empty)
    while uut_almost_empty = '0' loop
      rd_en <= '1';
      wait for clk_period;
    end loop;
    wr_en <= '0';

    --Write some values into FIFO
    wait for clk_period*10;
    for i in 0 to 20 loop
      din   <= std_logic_vector(to_unsigned(i+1, din'length));
      wr_en <= '1';
      wait for clk_period;
    end loop;  -- i
    din   <= (others => '0');
    wr_en <= '0';
    wait for clk_period;

    --Read Some values into FIFO
    while uut_almost_empty = '0' loop
      rd_en <= '1';
      wait for clk_period;
    end loop;
    wr_en <= '0';


    --Write some values into FIFO
    wait for clk_period*10;
    for i in 0 to 50 loop
      din   <= std_logic_vector(to_unsigned(i+1, din'length));
      wr_en <= '1';
      wait for clk_period;
    end loop;  -- i
    din   <= (others => '0');
    wr_en <= '0';
    --Just wait
    wait for clk_period*50;

    --Write some more values into FIFO
    wait for clk_period*10;
    for i in 0 to 50 loop
      din   <= std_logic_vector(to_unsigned(i+1, din'length));
      wr_en <= '1';
      wait for clk_period;
    end loop;  -- i
    din   <= (others => '0');
    wr_en <= '0';

    --Just wait
    wait for clk_period*50;
    rd_en <= '0';

    --Write some more values into FIFO
    wait for clk_period*10;
    for i in 0 to 50 loop
      din   <= std_logic_vector(to_unsigned(i+1, din'length));
      wr_en <= '1';
      wait for clk_period;
    end loop;  -- i
    din   <= (others => '0');
    wr_en <= '0';

    wait for clk_period*50;

    --Write some more values into FIFO
    wait for clk_period*10;
    for i in 0 to 50 loop
      din   <= std_logic_vector(to_unsigned(i+1, din'length));
      wr_en <= '1';
      wait for clk_period;
    end loop;  -- i
    din   <= (others => '0');
    wr_en <= '0';

    wait for clk_period*50;
    --Write too much into FIFO
    wait for clk_period*10;
    for i in 0 to 555 loop
      din   <= std_logic_vector(to_unsigned(i+1+10, din'length));
      wr_en <= '1';
      wait for clk_period;
    end loop;  -- i
    din   <= (others => '0');
    wr_en <= '0';

    wait for clk_period;


    --Read Some values into FIFO
    while uut_almost_empty = '0' loop
      rd_en <= '1';
      wait for clk_period;
    end loop;
    rd_en <= '0';
    wait for clk_period;


    --Read and Write Too
    rd_en <= '1';
    for i in 0 to 1000 loop
      din   <= not std_logic_vector(to_unsigned(i+1, din'length)) xor std_logic_vector(to_unsigned(i+10, din'length));
      wr_en <= '1';
      wait for clk_period;
    end loop;  -- i
    wr_en <= '0';
    rd_en <= '0';


    --Write some more values into FIFO
    wait for clk_period*10;
    for i in 0 to 50 loop
      din   <= std_logic_vector(to_unsigned(i+1, din'length));
      wr_en <= '1';
      wait for clk_period;
    end loop;  -- i
    din   <= (others => '0');
    wr_en <= '0';
      wait for clk_period;

    --RESET !!!!!!!!!!!!!
    srst <= '1';
      wait for clk_period;
    srst <= '0';
      wait for clk_period;


     --Write into FIFO (full)
    for i in 0 to 511 loop
      din   <= not std_logic_vector(to_unsigned(i+1, din'length));
      wr_en <= '1';
      wait for clk_period;
    end loop;  -- i
    din   <= (others => '0');
    wr_en <= '0';
    wait for clk_period;

    --Read from FIFO (empty)
    while uut_almost_empty = '0' loop
      rd_en <= '1';
      wait for clk_period;
    end loop;
    wr_en <= '0';

    --Write some values into FIFO
    wait for clk_period*10;
    for i in 0 to 20 loop
      din   <= std_logic_vector(to_unsigned(i+1, din'length));
      wr_en <= '1';
      wait for clk_period;
    end loop;  -- i
    din   <= (others => '0');
    wr_en <= '0';
    wait for clk_period;

    --Read Some values into FIFO
    while uut_almost_empty = '0' loop
      rd_en <= '1';
      wait for clk_period;
    end loop;
    wr_en <= '0';


    --Write some values into FIFO
    wait for clk_period*10;
    for i in 0 to 50 loop
      din   <= std_logic_vector(to_unsigned(i+1, din'length));
      wr_en <= '1';
      wait for clk_period;
    end loop;  -- i
    din   <= (others => '0');
    wr_en <= '0';
    --Just wait
    wait for clk_period*50;


    --RESET during operation
       --Write some values into FIFO
    wait for clk_period*10;
    for i in 0 to 50 loop
      din   <= std_logic_vector(to_unsigned(i+1, din'length));
      wr_en <= '1';
      if i=20 then
        srst <= '1';
      else
        srst <= '0';
      end if;
      wait for clk_period;
    end loop;  -- i
    din   <= (others => '0');
    wr_en <= '0';
    --Just wait
    wait for clk_period*50;

      --Write some more values into FIFO
    wait for clk_period*10;
    for i in 0 to 50 loop
      din   <= std_logic_vector(to_unsigned(i+1, din'length));
      wr_en <= '1';
      wait for clk_period;
    end loop;  -- i
    din   <= (others => '0');
    wr_en <= '0';

    wait for clk_period*50;
    --Write too much into FIFO
    wait for clk_period*10;
    for i in 0 to 555 loop
      din   <= std_logic_vector(to_unsigned(i+1+10, din'length));
      wr_en <= '1';
      wait for clk_period;
    end loop;  -- i
    din   <= (others => '0');
    wr_en <= '0';

    wait for clk_period;
    -- insert stimulus here 

    report "OK" severity note;
    
    wait;
  end process;

end;
