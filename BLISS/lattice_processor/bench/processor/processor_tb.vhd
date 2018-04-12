-- TestBench Template 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lattice_processor.all;
use ieee.math_real.all;

entity processor_tb is
  generic(
    --FFT and general configuration
    XN            : integer  := -1;     --ring (-1 or 1)
    N_ELEMENTS    : integer  := 512;
    PRIME_P_WIDTH : integer  := 13;
    PRIME_P       : unsigned;
    PSI           : unsigned;
    OMEGA         : unsigned;
    PSI_INVERSE   : unsigned;
    OMEGA_INVERSE : unsigned;
    N_INVERSE     : unsigned;
    --Sampler configuration
    S1_MAX        : unsigned := to_unsigned(37011, 12)
    --RAM configuration
    );
  port(
    cycles              : out unsigned(31 downto 0) := (others => '0');
    use_rand_input      : in  std_logic             := '1';  --trigger. 0=linear
                                                             --rising input
                                                             --coefficients. 1=
                                        --randomly chosen coefficients
    simulation_runs     : in  integer               := 1;
    error_happened      : buffer std_logic             := '0';
    simulation_finished : out std_logic             := '0'
    );
end processor_tb;

architecture behavior of processor_tb is
  
  constant RAMS           : integer    := 2;
  constant RAM_WIDTHs     : my_array_t := (PRIME_P_WIDTH, PRIME_P_WIDTH, 0, 0, 0, 0, 0, 0, 0, 0);
    constant INIT_ARRAY : init_array_t := (0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

  constant MAX_AS_INTEGER : integer    := 20;


  signal clk        : std_logic;
  signal proc_ready : std_logic                                                          := '0';
  signal proc_start : std_logic                                                          := '0';
  signal proc_op    : std_logic_vector(PROC_INST_SIZE-1 downto 0)                        := (others => '0');
  signal proc_arg0  : std_logic_vector(PROC_ARG1_SIZE-1 downto 0)                        := (others => '0');
  signal proc_arg1  : std_logic_vector(PROC_ARG2_SIZE-1 downto 0)                        := (others => '0');
  signal io_rd_addr : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal io_rd_do   : std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');
  signal io_wr_addr : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal io_wr_di   : std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');
  signal io_wr_we   : std_logic;

  signal io_rd_do_r1 : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal io_rd_do_r2 : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal io_rd_do_r3 : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal io_rd_do_r4 : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal io_rd_do_r5 : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');

  signal   end_of_simulation : std_logic := '0';
  constant clk_period        : time      := 10ns;



  type   ram_type is array (N_ELEMENTS-1 downto 0) of std_logic_vector(PRIME_P_WIDTH-1 downto 0);
  signal shadow_mem : ram_type := (others => (others => '0'));

  --a*b=c
  signal poly_a       : ram_type := (others => (others => '0'));
  signal poly_b       : ram_type := (others => (others => '0'));
  signal poly_c       : ram_type := (others => (others => '0'));
  signal poly_res     : ram_type := (others => (others => '0'));
  signal poly_res_add : ram_type := (others => (others => '0'));
  signal poly_res_sub : ram_type := (others => (others => '0'));


  signal select_ram : integer := 0;


  impure function poly_mul(a, b : ram_type) return ram_type is
    variable temp      : ram_type                                   := (others => (others => '0'));
    variable fac       : integer                                    := 0;
    variable temp_prod : unsigned(PRIME_P_WIDTH-1 downto 0)         := (others => '0');
    variable temp_sum  : signed(2+2*PRIME_P_WIDTH-1 downto 0)       := (others => '0');
    variable temp_std  : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  begin
    for i in 0 to N_ELEMENTS-1 loop
      for j in 0 to N_ELEMENTS-1 loop
        if i+j >= N_ELEMENTS then
          fac := -1;
        else
          fac := 1;
        end if;
        temp_prod := unsigned(a(i))*unsigned(b(j)) mod PRIME_P;

        temp_std := std_logic_vector(temp((i+j) mod N_ELEMENTS));

        temp_sum := signed("0"&unsigned(temp_std)) + signed("0"&temp_prod) * fac;

        while signed(temp_sum) < signed("0"&PRIME_P) loop
          temp_sum := signed(temp_sum)+signed("0"&PRIME_P);
        end loop;

        temp((i+j) mod N_ELEMENTS) := std_logic_vector(unsigned(temp_sum) mod PRIME_P);
        --debug <= temp((i+j) mod N_ELEMENTS);
        --wait for 1ns;
        
      end loop;  -- j
    end loop;  -- i

    return temp;
  end function;

  impure function poly_add(a, b : ram_type) return ram_type is
    variable temp      : ram_type                                   := (others => (others => '0'));
    variable fac       : integer                                    := 0;
    variable temp_prod : unsigned(PRIME_P_WIDTH-1 downto 0)         := (others => '0');
    variable temp_sum  : unsigned(PRIME_P_WIDTH-1 downto 0)         := (others => '0');
    variable temp_std  : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  begin
    for i in 0 to N_ELEMENTS-1 loop
      
      temp_sum := (resize(unsigned(a(i)), temp_sum'length+1) + unsigned(b(i))) mod PRIME_P;

      temp(i) := std_logic_vector(temp_sum);
      --debug <= temp((i+j) mod N_ELEMENTS);
      --wait for 1ns;
      
    end loop;  -- i

    return temp;
  end function;


  impure function poly_sub(a, b : ram_type) return ram_type is
    variable temp      : ram_type                                   := (others => (others => '0'));
    variable fac       : integer                                    := 0;
    variable temp_prod : unsigned(PRIME_P_WIDTH-1 downto 0)         := (others => '0');
    variable temp_sum  : unsigned(PRIME_P_WIDTH-1 downto 0)         := (others => '0');
        variable temp_neg_b  : unsigned(PRIME_P_WIDTH-1 downto 0)         := (others => '0');

    variable temp_std  : std_logic_vector(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  begin
    for i in 0 to N_ELEMENTS-1 loop
      
      temp_neg_b := PRIME_P - unsigned(b(i));
 
      temp_sum := (resize(unsigned(a(i)), temp_sum'length+1) + temp_neg_b ) mod PRIME_P;

      temp(i) := std_logic_vector(temp_sum);
      --debug <= temp((i+j) mod N_ELEMENTS);
      --wait for 1ns;
      
    end loop;  -- i

    return temp;
  end function;


  -- Gauss Sampler configuration
  constant GAUSS_FIFO_ELEMENTS : integer  := 1024;  --3*256;
  constant GAUSS_RND_WIDTH     : integer  := 25;
  constant GAUSS_S_VAL         : real     := 11.32;
  constant GAUSS_S_MAX         : unsigned := to_unsigned(24, 5);
begin


  processor_1 : entity work.processor
    generic map (
      XN            => XN,
            SAMPLER             => "gaussian",
      N_ELEMENTS    => N_ELEMENTS,
      PRIME_P_WIDTH => PRIME_P_WIDTH,
      PRIME_P       => PRIME_P,
      PSI           => PSI,
      OMEGA         => OMEGA,
      PSI_INVERSE   => PSI_INVERSE,
      OMEGA_INVERSE => OMEGA_INVERSE,
      N_INVERSE     => N_INVERSE,
      RAMS          => RAMS,
      -- Gauss Sampler configuration
      INIT_ARRAY => INIT_ARRAY,

      RAM_WIDTHs    => RAM_WIDTHs
      )
    port map (
      clk        => clk,
      proc_ready => proc_ready,
      proc_start => proc_start,
      proc_op    => proc_op,
      proc_arg0  => proc_arg0,
      proc_arg1  => proc_arg1,
      io_rd_addr => io_rd_addr,
      io_rd_do   => io_rd_do,
      io_wr_addr => io_wr_addr,
      io_wr_di   => io_wr_di,
      io_wr_we   => io_wr_we
      );


-- Clock process definitions
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
    if end_of_simulation = '1' then
      wait;
    end if;
  end process;

--Simulates the RAM interface
  process (clk)
  begin  -- process
    if rising_edge(clk) then

      
      
      
      if select_ram = 0 then
        io_rd_do_r1 <= poly_a(to_integer(unsigned(io_rd_addr)));
      end if;

      if select_ram = 1 then
        io_rd_do_r1 <= poly_b(to_integer(unsigned(io_rd_addr)));
      end if;

      if select_ram = 2 then
        io_rd_do_r1 <= poly_c(to_integer(unsigned(io_rd_addr)));
        if io_wr_we = '1' then
          poly_c(to_integer(unsigned(io_wr_addr))) <= io_wr_di;
        end if;
      end if;



      io_rd_do_r2 <= io_rd_do_r1;
      io_rd_do_r3 <= io_rd_do_r2;
      io_rd_do_r4 <= io_rd_do_r3;
      io_rd_do_r5 <= io_rd_do_r4;
      io_rd_do    <= io_rd_do_r5;
    end if;
  end process;

  --  Test Bench Statements
  tb : process
    variable counter : integer := 0;
    variable run_cnt : integer := 0;

    variable N_a                             :       integer;  -- range 0 to 2**this_size-1;
    variable N_b                             :       integer;  -- range 0 to 2**this_size-1;
    variable seed1                           :       integer := 12362;
    variable seed2                           :       integer := 54783;
    variable sign                            :       integer := 0;
    variable sign_vect                       :       std_logic_vector(10 downto 0);
    variable val                             :       std_logic_vector(47 downto 0);
    variable sign_myA                        :       integer := 0;
    procedure rand_int(variable seed1, seed2 : inout positive; min, max : in integer; result : out integer) is
      variable rand : real;
      
    begin
      uniform(seed1, seed2, rand);
      result := integer(real(min) + (rand * (real(max)-real(min))));
    end procedure;
  begin

    wait for 100 ns;  -- wait until global set/reset completes

    for runs in 1 to simulation_runs loop
      
   
    select_ram <= -1;
    wait for clk_period;

    if use_rand_input = '0' then
      -------------------------------------------------------------------------
      -- Random Input
      -------------------------------------------------------------------------
      for i in 0 to N_ELEMENTS-1 loop
        poly_a(i) <= std_logic_vector(resize(to_unsigned(i, integer(ceil(log2(real(N_ELEMENTS))))) mod PRIME_P , poly_a(0)'length));
        poly_b(i) <= std_logic_vector(resize(to_unsigned(i, integer(ceil(log2(real(N_ELEMENTS))))) mod PRIME_P , poly_a(0)'length));
        wait for clk_period;
      end loop;  -- i

    else
      -------------------------------------------------------------------------
      -- No random Input
      -------------------------------------------------------------------------
      for i in 0 to N_ELEMENTS-1 loop
        rand_int(seed1, seed2, 1, to_integer(PRIME_P), N_A);
        rand_int(seed1, seed2, 1, to_integer(PRIME_P), N_B);
        poly_a(i) <= std_logic_vector(resize(to_unsigned(N_A, integer(ceil(log2(real(N_ELEMENTS))))) mod PRIME_P , poly_a(0)'length));
        poly_b(i) <= std_logic_vector(resize(to_unsigned(N_B, integer(ceil(log2(real(N_ELEMENTS))))) mod PRIME_P , poly_a(0)'length));
        wait for clk_period;
      end loop;  -- i
    end if;


    wait until rising_edge(clk);
    wait for clk_period/2;

    poly_res     <= poly_mul(poly_a, poly_b);
    poly_res_add <= poly_add(poly_a, poly_b);
    poly_res_sub <= poly_sub(poly_a, poly_b);

    wait until rising_edge(clk);
    wait for clk_period/2;

    ---------------------------------------------------------------------------
    -- Load first coefficient
    ---------------------------------------------------------------------------
    select_ram <= 0;
    proc_start <= '1';
    proc_op    <= INST_PROC_IN;
    proc_arg0  <= std_logic_vector(to_unsigned(4, proc_arg0'length));
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;
    wait for clk_period*10;

    ---------------------------------------------------------------------------
    -- Load second coefficient
    ---------------------------------------------------------------------------
    select_ram <= 1;
    proc_start <= '1';
    proc_op    <= INST_PROC_IN;
    proc_arg0  <= std_logic_vector(to_unsigned(5, proc_arg0'length));
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;
    wait for clk_period*10;

    ---------------------------------------------------------------------------
    -- bitrev first coefficient
    ---------------------------------------------------------------------------
    proc_start <= '1';
    proc_op    <= INST_PROC_NTT_BITREV_A;
    proc_arg0  <= std_logic_vector(to_unsigned(4, proc_arg0'length));
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;
    wait for clk_period*10;

    ---------------------------------------------------------------------------
    -- bitrev second coefficient
    ---------------------------------------------------------------------------
    proc_start <= '1';
    proc_op    <= INST_PROC_NTT_BITREV_B;
    proc_arg0  <= std_logic_vector(to_unsigned(5, proc_arg0'length));
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;

    wait for clk_period*10;
    ---------------------------------------------------------------------------
    -- NTT first coefficient
    ---------------------------------------------------------------------------
    proc_start <= '1';
    proc_op    <= INST_PROC_NTT_NTT_A;
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;
    wait for clk_period*10;

    ---------------------------------------------------------------------------
    -- NTT second coefficient
    ---------------------------------------------------------------------------
    proc_start <= '1';
    proc_op    <= INST_PROC_NTT_NTT_B;
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;
    wait for clk_period*10;


    ---------------------------------------------------------------------------
    -- Pointwise mul
    ---------------------------------------------------------------------------
    proc_start <= '1';
    proc_op    <= INST_PROC_NTT_POINTWISE_MUL;
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;
    wait for clk_period*10;

    ---------------------------------------------------------------------------
    -- General purpose mode - just for confusion
    ---------------------------------------------------------------------------
    proc_start <= '1';
    proc_op    <= INST_PROC_NTT_GP_MODE;
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;
    wait for clk_period*10;


    ---------------------------------------------------------------------------
    -- INTT
    ---------------------------------------------------------------------------
    proc_start <= '1';
    proc_op    <= INST_PROC_NTT_INTT;
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;
    wait for clk_period*10;

    ---------------------------------------------------------------------------
    -- IPSI
    ---------------------------------------------------------------------------
    proc_start <= '1';
    proc_op    <= INST_PROC_NTT_INV_PSI;
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;

    wait for clk_period*10;
    ---------------------------------------------------------------------------
    -- INVN
    ---------------------------------------------------------------------------
    proc_start <= '1';
    proc_op    <= INST_PROC_NTT_INV_N;
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;
    wait for clk_period*10;

    ---------------------------------------------------------------------------
    -- General purpose mode
    ---------------------------------------------------------------------------
    proc_start <= '1';
    proc_op    <= INST_PROC_NTT_GP_MODE;
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;
    wait for clk_period*10;

    ---------------------------------------------------------------------------
    -- Output input on IO
    ---------------------------------------------------------------------------
    select_ram <= 2;
    proc_start <= '1';
    proc_arg0  <= std_logic_vector(to_unsigned(FFT_R1_PORT, proc_arg0'length));
    proc_op    <= INST_PROC_OUT;
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;
    wait for clk_period*10;


    ---------------------------------------------------------------------------
    -- ###### Now check the result if multiplication was successful
    ---------------------------------------------------------------------------
    for counter in 0 to N_ELEMENTS-1 loop
      if poly_c(counter) /= poly_res(counter) then
        error_happened <= '1';
        report "Error" severity error;
      end if;
    end loop;  -- counter



    ---------------------------------------------------------------------------
    -- No we do the FFT again with the a already transformed in RAM0
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- Load second coefficient
    ---------------------------------------------------------------------------
    select_ram <= 1;
    proc_start <= '1';
    proc_op    <= INST_PROC_IN;
    proc_arg0  <= std_logic_vector(to_unsigned(5, proc_arg0'length));
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;
    wait for clk_period*10;

    ---------------------------------------------------------------------------
    -- bitrev first coefficient
    ---------------------------------------------------------------------------
    --Not needed

    ---------------------------------------------------------------------------
    -- bitrev second coefficient
    ---------------------------------------------------------------------------
    proc_start <= '1';
    proc_op    <= INST_PROC_NTT_BITREV_B;
    proc_arg0  <= std_logic_vector(to_unsigned(5, proc_arg0'length));
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;

    wait for clk_period*10;

    ---------------------------------------------------------------------------
    -- NTT first coefficient
    ---------------------------------------------------------------------------
    -- Not needed

    ---------------------------------------------------------------------------
    -- NTT second coefficient
    ---------------------------------------------------------------------------
    proc_start <= '1';
    proc_op    <= INST_PROC_NTT_NTT_B;
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;
    wait for clk_period*10;


    ---------------------------------------------------------------------------
    -- Pointwise mul
    ---------------------------------------------------------------------------
    proc_start <= '1';
    proc_op    <= INST_PROC_NTT_POINTWISE_MUL;
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;
    wait for clk_period*10;

    ---------------------------------------------------------------------------
    -- INTT
    ---------------------------------------------------------------------------
    proc_start <= '1';
    proc_op    <= INST_PROC_NTT_INTT;
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;
    wait for clk_period*10;

    ---------------------------------------------------------------------------
    -- IPSI
    ---------------------------------------------------------------------------
    proc_start <= '1';
    proc_op    <= INST_PROC_NTT_INV_PSI;
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;

    wait for clk_period*10;
    ---------------------------------------------------------------------------
    -- INVN
    ---------------------------------------------------------------------------
    proc_start <= '1';
    proc_op    <= INST_PROC_NTT_INV_N;
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;
    wait for clk_period*10;

    ---------------------------------------------------------------------------
    -- General purpose mode
    ---------------------------------------------------------------------------
    proc_start <= '1';
    proc_op    <= INST_PROC_NTT_GP_MODE;
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;
    wait for clk_period*10;

    ---------------------------------------------------------------------------
    -- Output input on IO
    ---------------------------------------------------------------------------
    select_ram <= 2;
    proc_start <= '1';
    proc_arg0  <= std_logic_vector(to_unsigned(FFT_R1_PORT, proc_arg0'length));
    proc_op    <= INST_PROC_OUT;
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;
    wait for clk_period*10;


    ---------------------------------------------------------------------------
    -- ###### Now check the result if multiplication was successful
    ---------------------------------------------------------------------------
    for counter in 0 to N_ELEMENTS-1 loop
      if poly_c(counter) /= poly_res(counter) then
        error_happened <= '1';
        report "Error" severity error;
      end if;
    end loop;  -- counter



    ---------------------------------------------------------------------------
    -- Add two inputs
    ---------------------------------------------------------------------------
    proc_start <= '1';
    proc_arg0  <= std_logic_vector(to_unsigned(4, proc_arg0'length));
    proc_arg1  <= std_logic_vector(to_unsigned(5, proc_arg0'length));
    proc_op    <= INST_PROC_ADD;
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;
    wait for clk_period*10;

    ---------------------------------------------------------------------------
    -- Output result of addition on IO
    ---------------------------------------------------------------------------
    select_ram <= 2;
    proc_start <= '1';
    proc_arg0  <= std_logic_vector(to_unsigned(4, proc_arg0'length));
    proc_op    <= INST_PROC_OUT;
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;
    wait for clk_period*10;

    ---------------------------------------------------------------------------
    -- ###### Now check the result if multiplication was successful
    ---------------------------------------------------------------------------
    for counter in 0 to N_ELEMENTS-1 loop
      if poly_c(counter) /= poly_res_add(counter) then
        error_happened <= '1';
        report "Error" severity error;
      end if;
    end loop;  -- counter



    ---------------------------------------------------------------------------
    -- ##### Check copy to IO and SUB #####
    ---------------------------------------------------------------------------


    ---------------------------------------------------------------------------
    -- Load first coefficient
    ---------------------------------------------------------------------------
    select_ram <= 0;
    proc_start <= '1';
    proc_op    <= INST_PROC_IN;
    proc_arg0  <= std_logic_vector(to_unsigned(4, proc_arg0'length));
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;
    wait for clk_period*10;

    ---------------------------------------------------------------------------
    -- Load second coefficient
    ---------------------------------------------------------------------------
    select_ram <= 1;
    proc_start <= '1';
    proc_op    <= INST_PROC_IN;
    proc_arg0  <= std_logic_vector(to_unsigned(5, proc_arg0'length));
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;
    wait for clk_period*10;

    ---------------------------------------------------------------------------
    -- Enable shadow copy to the IO port
    ---------------------------------------------------------------------------
   select_ram <= 2;
    proc_start <= '1';
    proc_op    <= INST_PROC_ENABLE_COPY_TO_IO;
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;
    wait for clk_period*10;


    ---------------------------------------------------------------------------
    -- Subb two inputs
    ---------------------------------------------------------------------------
    proc_start <= '1';
    proc_arg0  <= std_logic_vector(to_unsigned(4, proc_arg0'length));
    proc_arg1  <= std_logic_vector(to_unsigned(5, proc_arg0'length));
    proc_op    <= INST_PROC_SUB;
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;
    wait for clk_period*10;


    ---------------------------------------------------------------------------
    -- ###### Now check the result if the subtraction was successful and copied
    -- silently to IO port
    ---------------------------------------------------------------------------
    for counter in 0 to N_ELEMENTS-1 loop
      if poly_c(counter) /= poly_res_sub(counter) then
        error_happened <= '1';
        report "Error" severity error;
      end if;
    end loop;  -- counter


    ---------------------------------------------------------------------------
    -- Output result of addition on IO
    ---------------------------------------------------------------------------
    proc_start <= '1';
    proc_arg0  <= std_logic_vector(to_unsigned(4, proc_arg0'length));
    proc_op    <= INST_PROC_OUT;
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;
    wait for clk_period*10;

    ---------------------------------------------------------------------------
    -- Sample a value
    ---------------------------------------------------------------------------
    proc_start <= '1';
    --proc_arg0  <= std_logic_vector(to_unsigned(4, proc_arg0'length));
    proc_op    <= INST_PROC_WAIT_UNI_SAMPLER_READY;
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;
    wait for clk_period*10;

    ---------------------------------------------------------------------------
    -- Transfer data from the sampler into the RAM
    ---------------------------------------------------------------------------
    proc_start <= '1';
    proc_arg1  <= std_logic_vector(to_unsigned(SAMPLER_PORT, proc_arg0'length));
    proc_arg0  <= std_logic_vector(to_unsigned(4, proc_arg0'length));
    proc_op    <= INST_PROC_MOV;
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;
    wait for clk_period*10;



    ---------------------------------------------------------------------------
    -- Output result of sampling on IO
    ---------------------------------------------------------------------------
    proc_start <= '1';
    proc_arg0  <= std_logic_vector(to_unsigned(4, proc_arg0'length));
    proc_op    <= INST_PROC_OUT;
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;
    wait for clk_period*10;

    
    ---------------------------------------------------------------------------
    -- Enable shadow copy to the IO port
    ---------------------------------------------------------------------------
    proc_start <= '1';
    proc_arg0  <= std_logic_vector(to_unsigned(4, proc_arg0'length));
    proc_op    <= INST_PROC_ENABLE_COPY_TO_IO;
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;
    wait for clk_period*10;


    ---------------------------------------------------------------------------
    -- Wait till sampler is ready again
    ---------------------------------------------------------------------------
    proc_start <= '1';
    --proc_arg0  <= std_logic_vector(to_unsigned(4, proc_arg0'length));
    proc_op    <= INST_PROC_WAIT_UNI_SAMPLER_READY;
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;
    wait for clk_period*10;

    ---------------------------------------------------------------------------
    -- Trasfer data from the sampler into the RAM -- should also appear on
    -- output port
    ---------------------------------------------------------------------------
    proc_start <= '1';
    proc_arg1  <= std_logic_vector(to_unsigned(SAMPLER_PORT, proc_arg0'length));
    proc_arg0  <= std_logic_vector(to_unsigned(4, proc_arg0'length));
    proc_op    <= INST_PROC_MOV;
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;
    wait for clk_period*10;



    ---------------------------------------------------------------------------
    -- Disable shadow copy to the IO port
    ---------------------------------------------------------------------------
    proc_start <= '1';
    proc_arg0  <= std_logic_vector(to_unsigned(4, proc_arg0'length));
    proc_op    <= INST_PROC_DISABLE_COPY_TO_IO;
    wait for clk_period;
    proc_start <= '0';

    if proc_ready /= '1' then
      wait until proc_ready = '1';
      wait for clk_period/2;
    end if;
    wait for clk_period*10;

 end loop;  -- runs

    ---------------------------------------------------------------------------
    -- THE END
    ---------------------------------------------------------------------------
     if error_happened = '1' then
      report "ERROR";
    else
      report "OK";
    end if;

          wait for clk_period*10;

     
    simulation_finished <= '1';

    wait for clk_period*1000;

    end_of_simulation <= '1';
    wait;                               -- will wait forever
  end process tb;
  --  End Test Bench 

end;
