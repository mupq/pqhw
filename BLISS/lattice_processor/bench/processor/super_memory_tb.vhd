-- TestBench Template 



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lattice_processor.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

entity super_memory_tb is
end super_memory_tb;

architecture behavior of super_memory_tb is

  -- Component Declaration for the Unit Under Test (UUT)
  

  signal clk            : std_logic;
  signal error_happened : std_logic := '0';

  -- Clock period definitions
  constant clk_period : time := 10 ns;

  constant ADDR_WIDTH    : integer := 9;
  constant ELEMENTS      : integer := 512;
  constant RAMS          : integer := 6;
  constant MAX_RAM_WIDTH : integer := 23;
  constant RAM_WIDTHs    : my_array_t := (10, 10, 10, 10, 23, 10, 10, 10, 10, 10);

  signal delay            : integer                                    := 1;
  signal rd_p1_addr       : std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
  signal rd_p1_do         : std_logic_vector(MAX_RAM_WIDTH-1 downto 0) := (others => '0');
  signal rd_p2_addr       : std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
  signal rd_p2_do         : std_logic_vector(MAX_RAM_WIDTH-1 downto 0) := (others => '0');
  signal wr_p1_addr       : std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
  signal wr_p1_di         : std_logic_vector(MAX_RAM_WIDTH-1 downto 0) := (others => '0');
  signal wr_p1_we         : std_logic                                  := '0';
  signal rd_p1_ctl        : unsigned(3 downto 0)                       := (others => '0');
  signal rd_p2_ctl        : unsigned(3 downto 0)                       := (others => '0');
  signal wr_p1_ctl        : unsigned(3 downto 0)                       := (others => '0');
  signal stable           : std_logic                                  := '0';
  signal fft_ram0_rd_addr : std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
  signal fft_ram0_rd_do   : std_logic_vector(MAX_RAM_WIDTH-1 downto 0) := (others => '0');
  signal fft_ram0_wr_addr : std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
  signal fft_ram0_wr_di   : std_logic_vector(MAX_RAM_WIDTH-1 downto 0) := (others => '0');
  signal fft_ram0_wr_we   : std_logic                                  := '0';
  signal fft_ram1_rd_addr : std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
  signal fft_ram1_rd_do   : std_logic_vector(MAX_RAM_WIDTH-1 downto 0) := (others => '0');
  signal fft_ram1_wr_addr : std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
  signal fft_ram1_wr_di   : std_logic_vector(MAX_RAM_WIDTH-1 downto 0) := (others => '0');
  signal fft_ram1_wr_we   : std_logic                                  := '0';
  signal sampler_rd_addr  : std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
  signal sampler_rd_do    : std_logic_vector(MAX_RAM_WIDTH-1 downto 0) := (others => '0');
  signal io_rd_addr       : std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
  signal io_rd_do         : std_logic_vector(MAX_RAM_WIDTH-1 downto 0) := (others => '0');
  signal io_wr_addr       : std_logic_vector(ADDR_WIDTH-1 downto 0)    := (others => '0');
  signal io_wr_di         : std_logic_vector(MAX_RAM_WIDTH-1 downto 0) := (others => '0');
  signal io_wr_we         : std_logic                                  := '0';

  
begin


  super_memory_1 : entity work.super_memory
    generic map (
      ADDR_WIDTH    => ADDR_WIDTH,
      ELEMENTS      => ELEMENTS,
      RAMS          => RAMS,
      MAX_RAM_WIDTH => MAX_RAM_WIDTH,
      RAM_WIDTHs    => RAM_WIDTHs
      )
    port map (
      clk              => clk,
      delay            => delay,
      rd_p1_addr       => rd_p1_addr,
      rd_p1_do         => rd_p1_do,
      rd_p2_addr       => rd_p2_addr,
      rd_p2_do         => rd_p2_do,
      wr_p1_addr       => wr_p1_addr,
      wr_p1_di         => wr_p1_di,
      wr_p1_we         => wr_p1_we,
      rd_p1_ctl        => rd_p1_ctl,
      rd_p2_ctl        => rd_p2_ctl,
      wr_p1_ctl        => wr_p1_ctl,
      stable           => stable,
      fft_ram0_rd_addr => fft_ram0_rd_addr,
      fft_ram0_rd_do   => fft_ram0_rd_do,
      fft_ram0_wr_addr => fft_ram0_wr_addr,
      fft_ram0_wr_di   => fft_ram0_wr_di,
      fft_ram0_wr_we   => fft_ram0_wr_we,
      fft_ram1_rd_addr => fft_ram1_rd_addr,
      fft_ram1_rd_do   => fft_ram1_rd_do,
      fft_ram1_wr_addr => fft_ram1_wr_addr,
      fft_ram1_wr_di   => fft_ram1_wr_di,
      fft_ram1_wr_we   => fft_ram1_wr_we,
      sampler_rd_addr  => sampler_rd_addr,
      sampler_rd_do    => sampler_rd_do,
      io_rd_addr       => io_rd_addr,
      io_rd_do         => io_rd_do,
      io_wr_addr       => io_wr_addr,
      io_wr_di         => io_wr_di,
      io_wr_we         => io_wr_we
      );

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
  begin
    -- hold reset state for 100 ns.
    wait for 100 ns;

    ---------------------------------------------------------------------------
    --Write into all 6 temporary RAMs and read out the value from there
    for i in 0 to 5 loop
      wr_p1_ctl <= to_unsigned(i+4, wr_p1_ctl'length);
      wait for clk_period*5;
      for j in 0 to ELEMENTS-1 loop
        wr_p1_addr <= std_logic_vector(to_unsigned(j, wr_p1_addr'length));
        wr_p1_di   <= std_logic_vector(to_unsigned(j+i, wr_p1_di'length));
        wr_p1_we   <= '1';
        wait for clk_period;
      end loop;  -- j      
    end loop;  -- i

    wr_p1_we  <= '0';
    wr_p1_ctl <= to_unsigned(0, wr_p1_ctl'length);


    wait for clk_period*1000;

    ----------------------------------------------------------------------------
    --Now read back the data written into the RAM
    for i in 0 to 5 loop
      rd_p1_ctl <= to_unsigned(i+4, rd_p1_ctl'length);
      wait for clk_period*5;
      for j in 0 to ELEMENTS-1 loop
        rd_p1_addr <= std_logic_vector(to_unsigned(j, wr_p1_addr'length));
        wait for clk_period;
      end loop;  -- j      
    end loop;  -- i


    rd_p1_ctl <= to_unsigned(0, rd_p1_ctl'length);

    wait for clk_period*1000;


    ----------------------------------------------------------------------------
    --Now read back the data written into the RAM
    for i in 0 to 5 loop
      rd_p2_ctl <= to_unsigned(i+4, rd_p2_ctl'length);
      wait for clk_period*5;
      for j in 0 to ELEMENTS-1 loop
        rd_p2_addr <= std_logic_vector(to_unsigned(j, rd_p2_addr'length));
        wait for clk_period;
      end loop;  -- j      
    end loop;  -- i


    wait for clk_period*1000;


    ----------------------------------------------------------------------------
    --Now write data to the (unconnected) special ports
    for i in 0 to 3 loop
      wr_p1_ctl <= to_unsigned(i, wr_p1_ctl'length);
      wait for clk_period*5;
      for j in 0 to ELEMENTS-1 loop
        wr_p1_addr <= std_logic_vector(to_unsigned(j, wr_p1_addr'length));
        wr_p1_di   <= std_logic_vector(to_unsigned(j+i, wr_p1_di'length));
        wr_p1_we   <= '1';
        wait for clk_period;
      end loop;  -- j      
    end loop;  -- i

    wr_p1_we  <= '0';
    wr_p1_ctl <= to_unsigned(0, wr_p1_ctl'length);


    wait for clk_period*1000;



    if error_happened = '0' then
      report "OK";
    else
      report "ERROR";
    end if;

    wait for clk_period*10;

    -- insert stimulus here 

    wait;
  end process;

end;

