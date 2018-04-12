-- TestBench Template 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lattice_processor.all;
use ieee.math_real.all;

entity proc_fft_tb is
  port(
    cycles              : out    unsigned(31 downto 0) := (others => '0');
    use_rand_input      : in     std_logic             := '0';  --trigger. 0=linear
                                                                --rising input
                                        --coefficients. 1=
                                        --randomly chosen coefficients
    simulation_runs     : in     integer               := 1;
    error_happened      : buffer std_logic             := '0';
    simulation_finished : out    std_logic             := '0'
    );
end proc_fft_tb;


architecture behavior of proc_fft_tb is

  constant XN            : integer                            := -1;  --ring (-1 or 1)
  constant PRIME_P_WIDTH : integer                            := 17;
  constant N_ELEMENTS    : integer                            := 128;
  constant PRIME_P       : unsigned(PRIME_P_WIDTH-1 downto 0) := to_unsigned(65537, PRIME_P_WIDTH);
  constant PSI           : unsigned(PRIME_P_WIDTH-1 downto 0) := to_unsigned(141, PRIME_P_WIDTH);
  constant OMEGA         : unsigned(PRIME_P_WIDTH-1 downto 0) := to_unsigned(19881, PRIME_P_WIDTH);
  constant PSI_INVERSE   : unsigned(PRIME_P_WIDTH-1 downto 0) := to_unsigned(63213, PRIME_P_WIDTH);
  constant OMEGA_INVERSE : unsigned(PRIME_P_WIDTH-1 downto 0) := to_unsigned(26942, PRIME_P_WIDTH);
  constant N_INVERSE     : unsigned(PRIME_P_WIDTH-1 downto 0) := to_unsigned(65025, PRIME_P_WIDTH);

  signal end_of_simulation : std_logic := '0';


  constant clk_period : time := 10ns;


  type   ram_type is array (N_ELEMENTS-1 downto 0) of std_logic_vector(PRIME_P_WIDTH-1 downto 0);
  signal shadow_mem : ram_type := (others => (others => '0'));


  --a*b=c
  signal poly_a   : ram_type := (others => (others => '0'));
  signal poly_b   : ram_type := (others => (others => '0'));
  signal poly_c   : ram_type := (others => (others => '0'));
  signal poly_res : ram_type := (others => (others => '0'));



  signal clk              : std_logic;
  signal ntt_ready        : std_logic                                                          := '0';
  signal ntt_start        : std_logic                                                          := '0';
  signal ntt_op           : std_logic_vector(NTT_INST_SIZE-1 downto 0)                         := (others => '0');
  signal fft_ram0_rd_addr : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal fft_ram0_rd_do   : std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');
  signal fft_ram0_wr_addr : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal fft_ram0_wr_di   : std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');
  signal fft_ram0_wr_we   : std_logic                                                          := '0';
  signal fft_ram1_rd_addr : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal fft_ram1_rd_do   : std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');
  signal fft_ram1_wr_addr : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal fft_ram1_wr_di   : std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');
  signal fft_ram1_wr_we   : std_logic                                                          := '0';
  signal mar_w_in         : unsigned(PRIME_P_WIDTH-1 downto 0)                                 := (others => '0');
  signal mar_a_in         : unsigned(PRIME_P_WIDTH-1 downto 0)                                 := (others => '0');
  signal mar_b_in         : unsigned(PRIME_P_WIDTH-1 downto 0)                                 := (others => '0');
  signal mar_x_add_out    : unsigned(PRIME_P_WIDTH-1 downto 0)                                 := (others => '0');
  signal mar_x_sub_out    : unsigned(PRIME_P_WIDTH-1 downto 0)                                 := (others => '0');
  signal mar_delay        : integer                                                            := 68;
  signal fft_ram_delay    : integer                                                            := 68;

  signal fft_ram1_rd_addr_delay : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');


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

  
begin

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


  proc_fft_1 : entity work.proc_fft
    generic map (
      XN            => XN,
      N_ELEMENTS    => N_ELEMENTS,
      PRIME_P_WIDTH => PRIME_P_WIDTH,
      PRIME_P       => PRIME_P,
      PSI           => PSI,
      OMEGA         => OMEGA,
      PSI_INVERSE   => PSI_INVERSE,
      OMEGA_INVERSE => OMEGA_INVERSE,
      N_INVERSE     => N_INVERSE)
    port map (
      clk              => clk,
      ntt_ready        => ntt_ready,
      ntt_start        => ntt_start,
      ntt_op           => ntt_op,
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
      fft_ram_delay    => fft_ram_delay,
      mar_w_in         => mar_w_in,
      mar_a_in         => mar_a_in,
      mar_b_in         => mar_b_in,
      mar_x_add_out    => mar_x_add_out,
      mar_x_sub_out    => mar_x_sub_out,
      mar_delay        => mar_delay,
      cycles           => cycles
      );


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

    while run_cnt < simulation_runs loop
      -- hold reset state for 100 ns.
      wait for 100 ns;

      -------------------------------------------------------------------------
      -- Prepare the input

      wait for clk_period;
      if use_rand_input = '0' then
        --Just rising values
        for i in 0 to N_ELEMENTS-1 loop
          poly_a(i) <= std_logic_vector(resize(to_unsigned(i, integer(ceil(log2(real(N_ELEMENTS))))) mod PRIME_P , poly_a(0)'length));
          poly_b(i) <= std_logic_vector(resize(to_unsigned(i, integer(ceil(log2(real(N_ELEMENTS))))) mod PRIME_P , poly_a(0)'length));
          wait for clk_period;
        end loop;  -- i

        wait for clk_period*10;

      else

        ----Randomly selected coefficients
        --for i in 0 to N_ELEMENTS-1 loop
        --  rand_int(seed1, seed2, 1, to_integer(PRIME_P), N_A);
        --  rand_int(seed1, seed2, 1, to_integer(PRIME_P), N_B);
        --  if a_constant_in = '0' or (a_constant_in = '1' and run_cnt = 0) then
        --    poly_a(i) <= std_logic_vector(resize(to_unsigned(N_A, integer(ceil(log2(real(N_ELEMENTS))))) mod PRIME_P , poly_a(0)'length));
        --  end if;
        --  poly_b(i) <= std_logic_vector(resize(to_unsigned(N_B, integer(ceil(log2(real(N_ELEMENTS))))) mod PRIME_P , poly_a(0)'length));
        --  wait for 1ns;
        --end loop;  -- i

        wait for clk_period*10;
      end if;
      --fill both RAMs with testvector

      --Calculate the result
      poly_c <= poly_mul(poly_a, poly_b);

      wait for clk_period*11;


-------------------------------------------------------------------------------
-- ACTION
-------------------------------------------------------------------------------
      -- insert stimulus here
      wait until falling_edge(clk);
      wait for clk_period/2;

      -------------------------------------------------------------------------
      ntt_op    <= INST_NTT_BITREV_A;
      ntt_start <= '1';
      wait for clk_period;
      ntt_start <= '0';
      wait for clk_period;
      for i in 0 to N_ELEMENTS-1 loop
        fft_ram0_wr_we <= '1';
        fft_ram0_wr_di <= poly_a(i);
        wait for clk_period;
      end loop;  -- i
      fft_ram0_wr_we <= '0';

      wait for clk_period;


      -------------------------------------------------------------------------
      if ntt_ready /= '1' then
        wait until ntt_ready = '1';
        wait for clk_period/2;
      end if;

      ntt_op    <= INST_NTT_BITREV_B;
      ntt_start <= '1';
      wait for clk_period;
      ntt_start <= '0';
      wait for clk_period;
      for i in 0 to N_ELEMENTS-1 loop
        fft_ram1_wr_we <= '1';
        fft_ram1_wr_di <= poly_b(i);
        wait for clk_period;
      end loop;  -- i
      fft_ram1_wr_we <= '0';


      -------------------------------------------------------------------------
      if ntt_ready /= '1' then
        wait until ntt_ready = '1';
        wait for clk_period/2;
      end if;

      ntt_op    <= INST_NTT_NTT_A;
      ntt_start <= '1';
      wait for clk_period;
      ntt_start <= '0';
      wait for clk_period*3;

      -------------------------------------------------------------------------
      if ntt_ready /= '1' then
        wait until ntt_ready = '1';
        wait for clk_period/2;
      end if;

      ntt_op    <= INST_NTT_NTT_B;
      ntt_start <= '1';
      wait for clk_period;
      ntt_start <= '0';
      wait for clk_period*3;

      -------------------------------------------------------------------------
      if ntt_ready /= '1' then
        wait until ntt_ready = '1';
        wait for clk_period/2;
      end if;

      ntt_op    <= INST_NTT_POINTWISE_MUL;
      ntt_start <= '1';
      wait for clk_period;
      ntt_start <= '0';
      wait for clk_period*3;


      -------------------------------------------------------------------------
      if ntt_ready /= '1' then
        wait until ntt_ready = '1';
        wait for clk_period/2;
      end if;

      ntt_op    <= INST_NTT_INTT;
      ntt_start <= '1';
      wait for clk_period;
      ntt_start <= '0';
      wait for clk_period*3;

      -------------------------------------------------------------------------
      if ntt_ready /= '1' then
        wait until ntt_ready = '1';
        wait for clk_period/2;
      end if;

      ntt_op    <= INST_NTT_INV_N;
      ntt_start <= '1';
      wait for clk_period;
      ntt_start <= '0';
      wait for clk_period*3;

      -------------------------------------------------------------------------
      if ntt_ready /= '1' then
        wait until ntt_ready = '1';
        wait for clk_period/2;
      end if;

      ntt_op    <= INST_NTT_INV_PSI;
      ntt_start <= '1';
      wait for clk_period;
      ntt_start <= '0';
      wait for clk_period*3;

      -------------------------------------------------------------------------
      if ntt_ready /= '1' then
        wait until ntt_ready = '1';
        wait for clk_period/2;
      end if;

      ntt_op    <= INST_NTT_GP_MODE;
      ntt_start <= '1';
      wait for clk_period;
      ntt_start <= '0';
      wait for clk_period*3;



      --Test for correctness - we are in GP mod
      for i in 0 to N_ELEMENTS-1 loop
        fft_ram1_rd_addr                                       <= std_logic_vector(to_unsigned(i, fft_ram1_rd_addr'length));
        poly_res(to_integer(unsigned(fft_ram1_rd_addr_delay))) <= fft_ram1_rd_do;
        wait for clk_period;
      end loop;  -- i


      for i in 0 to fft_ram_delay loop
        poly_res(to_integer(unsigned(fft_ram1_rd_addr_delay))) <= fft_ram1_rd_do;
        wait for clk_period;
      end loop;  -- i


      --Compare both
      for i in 0 to N_ELEMENTS-1 loop
        if poly_res(i) /= poly_c(i) then
          error_happened <= '1';
          report "WRONG RESULT" severity error;
        end if;
        wait for clk_period;
      end loop;  -- i

      --increment run counter
      run_cnt := run_cnt+1;
    end loop;


    ---------------------------------------------------------------------------
    --Test external MAR/PE
    mar_w_in <= to_unsigned(5, mar_w_in'length);
    mar_a_in <= to_unsigned(1, mar_a_in'length);
    mar_b_in <= to_unsigned(10, mar_b_in'length);
    wait for mar_delay*clk_period;
    if mar_x_add_out /= 51 then
      error_happened <= '1';
      report "WRONG RESULT" severity error;
    end if;




    ---------------------------------------------------------------------------
    -- ------------------------ Do Some stuff to fool the thing
    ---------------------------------------------------------------------------
    -------------------------------------------------------------------------
    if ntt_ready /= '1' then
      wait until ntt_ready = '1';
      wait for clk_period/2;
    end if;

    ntt_op    <= INST_NTT_INV_N;
    ntt_start <= '1';
    wait for clk_period;
    ntt_start <= '0';
    wait for clk_period*3;

    -------------------------------------------------------------------------
    ntt_op    <= INST_NTT_BITREV_A;
    ntt_start <= '1';
    wait for clk_period;
    ntt_start <= '0';
    wait for clk_period;
    for i in 0 to N_ELEMENTS-1 loop
      fft_ram0_wr_we <= '1';
      fft_ram0_wr_di <= poly_a(i);
      wait for clk_period;
    end loop;  -- i
    fft_ram0_wr_we <= '0';

    wait for clk_period;
    ---------------------------------------------------------------------------
    -- ------------------------ DO IT AGAIN
    ---------------------------------------------------------------------------



-------------------------------------------------------------------------------
-- ACTION
-------------------------------------------------------------------------------
    -- insert stimulus here
    if ntt_ready /= '1' then
      wait until ntt_ready = '1';
      wait for clk_period/2;
    end if;

    wait until falling_edge(clk);
    wait for clk_period/2;

    -------------------------------------------------------------------------
    ntt_op    <= INST_NTT_BITREV_A;
    ntt_start <= '1';
    wait for clk_period;
    ntt_start <= '0';
    wait for clk_period;
    for i in 0 to N_ELEMENTS-1 loop
      fft_ram0_wr_we <= '1';
      fft_ram0_wr_di <= poly_a(i);
      wait for clk_period;
    end loop;  -- i
    fft_ram0_wr_we <= '0';

    wait for clk_period;


    -------------------------------------------------------------------------
    if ntt_ready /= '1' then
      wait until ntt_ready = '1';
      wait for clk_period/2;
    end if;

    ntt_op    <= INST_NTT_BITREV_B;
    ntt_start <= '1';
    wait for clk_period;
    ntt_start <= '0';
    wait for clk_period;
    for i in 0 to N_ELEMENTS-1 loop
      fft_ram1_wr_we <= '1';
      fft_ram1_wr_di <= poly_b(i);
      wait for clk_period;
    end loop;  -- i
    fft_ram1_wr_we <= '0';


    -------------------------------------------------------------------------
    if ntt_ready /= '1' then
      wait until ntt_ready = '1';
      wait for clk_period/2;
    end if;

    ntt_op    <= INST_NTT_NTT_A;
    ntt_start <= '1';
    wait for clk_period;
    ntt_start <= '0';
    wait for clk_period*3;

    -------------------------------------------------------------------------
    if ntt_ready /= '1' then
      wait until ntt_ready = '1';
      wait for clk_period/2;
    end if;

    ntt_op    <= INST_NTT_NTT_B;
    ntt_start <= '1';
    wait for clk_period;
    ntt_start <= '0';
    wait for clk_period*3;

    -------------------------------------------------------------------------
    if ntt_ready /= '1' then
      wait until ntt_ready = '1';
      wait for clk_period/2;
    end if;

    ntt_op    <= INST_NTT_POINTWISE_MUL;
    ntt_start <= '1';
    wait for clk_period;
    ntt_start <= '0';
    wait for clk_period*3;


    -------------------------------------------------------------------------


    ---------------------------------------------------------------------------
    --unnecessary step but should not change reult
    -------------------------------------------------------------------------
    if ntt_ready /= '1' then
      wait until ntt_ready = '1';
      wait for clk_period/2;
    end if;

    ntt_op    <= INST_NTT_BITREV_A;
    ntt_start <= '1';
    wait for clk_period;
    ntt_start <= '0';
    wait for clk_period;
    for i in 0 to N_ELEMENTS-1 loop
      fft_ram0_wr_we <= '1';
      fft_ram0_wr_di <= poly_a(i);
      wait for clk_period;
    end loop;  -- i
    fft_ram0_wr_we <= '0';

    wait for clk_period;


    if ntt_ready /= '1' then
      wait until ntt_ready = '1';
      wait for clk_period/2;
    end if;

    ntt_op    <= INST_NTT_INTT;
    ntt_start <= '1';
    wait for clk_period;
    ntt_start <= '0';
    wait for clk_period*3;

    -------------------------------------------------------------------------
    if ntt_ready /= '1' then
      wait until ntt_ready = '1';
      wait for clk_period/2;
    end if;

    ntt_op    <= INST_NTT_INV_N;
    ntt_start <= '1';
    wait for clk_period;
    ntt_start <= '0';
    wait for clk_period*3;

    -------------------------------------------------------------------------
    if ntt_ready /= '1' then
      wait until ntt_ready = '1';
      wait for clk_period/2;
    end if;

    ntt_op    <= INST_NTT_INV_PSI;
    ntt_start <= '1';
    wait for clk_period;
    ntt_start <= '0';
    wait for clk_period*3;

    -------------------------------------------------------------------------
    if ntt_ready /= '1' then
      wait until ntt_ready = '1';
      wait for clk_period/2;
    end if;

    ntt_op    <= INST_NTT_GP_MODE;
    ntt_start <= '1';
    wait for clk_period;
    ntt_start <= '0';
    wait for clk_period*3;



    --Test for correctness - we are in GP mod
    for i in 0 to N_ELEMENTS-1 loop
      fft_ram1_rd_addr                                       <= std_logic_vector(to_unsigned(i, fft_ram1_rd_addr'length));
      poly_res(to_integer(unsigned(fft_ram1_rd_addr_delay))) <= fft_ram1_rd_do;
      wait for clk_period;
    end loop;  -- i


    for i in 0 to fft_ram_delay loop
      poly_res(to_integer(unsigned(fft_ram1_rd_addr_delay))) <= fft_ram1_rd_do;
      wait for clk_period;
    end loop;  -- i


    --Compare both
    for i in 0 to N_ELEMENTS-1 loop
      if poly_res(i) /= poly_c(i) then
        error_happened <= '1';
        report "WRONG RESULT" severity error;
      end if;
      wait for clk_period;
    end loop;  -- i

    --increment run counter
    run_cnt := run_cnt+1;


    ---------------------------------------------------------------------------
    --Test external MAR/PE
    mar_w_in <= to_unsigned(5, mar_w_in'length);
    mar_a_in <= to_unsigned(1, mar_a_in'length);
    mar_b_in <= to_unsigned(10, mar_b_in'length);
    wait for mar_delay*clk_period;
    if mar_x_add_out /= 51 then
      error_happened <= '1';
      report "WRONG RESULT" severity error;
    end if;


    ---------------------------------------------------------------------------
    -- ------------------------ DO IT AGAIN
    ---------------------------------------------------------------------------


    if error_happened = '0' then
      report "OK" severity note;
    else
      report "ERROR" severity note;
    end if;


    simulation_finished <= '1';
    end_of_simulation   <= '1';


    wait;




    -- Add user defined stimulus here

    wait;                               -- will wait forever
  end process tb;
--  End Test Bench 

  result_reg_1 : entity work.dyn_shift_reg
    generic map (
      width => fft_ram1_rd_addr'length
      )
    port map (
      clk    => clk,
      depth  => fft_ram_delay,
      Input  => fft_ram1_rd_addr,
      Output => fft_ram1_rd_addr_delay
      );

end;
