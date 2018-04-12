-- TestBench Template 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity poly_mul_top_gen_tb is
  generic (
    XN : integer := -1;                 --ring (-1 or 1)
    --N_ELEMENTS    : integer  := 128;
    --PRIME_P_WIDTH : integer  := 9;
    --PRIME_P       : unsigned := to_unsigned(257, 9);
    --PSI           : unsigned := to_unsigned(3, 9);
    --OMEGA         : unsigned := to_unsigned(9, 9);
    --PSI_INVERSE   : unsigned := to_unsigned(86, 9);
    --OMEGA_INVERSE : unsigned := to_unsigned(200, 9);
    --N_INVERSE     : unsigned := to_unsigned(255, 9)


    TARGET        : string   := "NTT";
    N_ELEMENTS    : integer  := 512;
    PRIME_P_WIDTH : integer  := 23;
    PRIME_P       : unsigned := to_unsigned(8383489, 23);
    PSI           : unsigned := to_unsigned(42205, 23);
    OMEGA         : unsigned := to_unsigned(3962357, 23);
    PSI_INVERSE   : unsigned := to_unsigned(3933218, 23);
    OMEGA_INVERSE : unsigned := to_unsigned(681022, 23);
    N_INVERSE     : unsigned := to_unsigned(8367115, 23)


    -- PRIME_P       : unsigned;           --(natural range <>);
    -- PSI           : unsigned;           --(natural range <>);
    -- OMEGA         : unsigned;           --(natural range <>);
    -- PSI_INVERSE   : unsigned;           --(natural range <>);
    -- OMEGA_INVERSE : unsigned            --(natural range <>)
    );
  port (
    a_constant_in       : in  std_logic             := '0';
    cycles              : out unsigned(31 downto 0) := (others => '0');
    use_rand_input      : in  std_logic             := '0';  --trigger. 0=linear
                                                             --rising input
                                                             --coefficients. 1=
                                        --randomly chosen coefficients
    simulation_runs     : in  integer               := 1;
    error_happened      : out std_logic             := '0';
    simulation_finished : out std_logic             := '0'
    );


end poly_mul_top_gen_tb;

architecture behavior of poly_mul_top_gen_tb is

  
  signal   end_of_simulation : std_logic := '0';
  constant clk_period        : time      := 10ns;

  signal clk : std_logic;

  signal start            : std_logic                          := '0';
  signal finished         : std_logic                          := '0';
  signal a_constant       : std_logic                          := '0';
  signal din_valid        : std_logic                          := '0';
  signal din_coefficient  : unsigned(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal din_ready        : std_logic                          := '1';
  signal din_finished     : std_logic                          := '0';
  signal dout_valid       : std_logic                          := '0';
  signal dout_coefficient : unsigned(PRIME_P_WIDTH-1 downto 0) := (others => '0');
  signal a_ready          : std_logic                          := '0';
  signal a_filled         : std_logic                          := '0';
  signal b_ready          : std_logic                          := '0';
  signal b_filled         : std_logic                          := '0';


  type   ram_type is array (N_ELEMENTS-1 downto 0) of std_logic_vector(PRIME_P_WIDTH-1 downto 0);
  signal shadow_mem : ram_type := (others => (others => '0'));


  --a*b=c
  signal poly_a : ram_type := (others => (others => '0'));
  signal poly_b : ram_type := (others => (others => '0'));
  signal poly_c : ram_type := (others => (others => '0'));

  signal debug : unsigned(PRIME_P_WIDTH-1 downto 0) := (others => '0');

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


 NTT: if TARGET = "NTT" generate
    poly_mul_top_1 : entity work.poly_mul_top
      generic map (
        N_ELEMENTS    => N_ELEMENTS,
        PRIME_P_WIDTH => PRIME_P_WIDTH,
        XN            => -1 ,
        PRIME_P       => PRIME_P,
        PSI           => PSI,
        OMEGA         => OMEGA,
        PSI_INVERSE   => PSI_INVERSE,
        OMEGA_INVERSE => OMEGA_INVERSE,
        N_INVERSE     => N_INVERSE
        )
      port map (
        clk      => clk,
        start    => start,
        finished => finished,
        a_ready  => a_ready ,
        a_filled => a_filled,
        b_ready  => b_ready ,
        b_filled => b_filled ,

        a_constant       => a_constant,
        din_valid        => din_valid,
        din_coefficient  => din_coefficient,
        din_finished     => din_finished,
        dout_valid       => dout_valid,
        dout_coefficient => dout_coefficient,
        cycles           => cycles
        );  
  end generate NTT;

  SCHOOLBOOK:  if TARGET = "SCHOOLBOOK" generate
    poly_mul_school_top_1 :entity work.poly_mul_school_top
      generic map (
        XN            => XN,
        N_ELEMENTS    => N_ELEMENTS,
        PRIME_P_WIDTH => PRIME_P_WIDTH,
        PRIME_P       => PRIME_P,
        COEFF_A_WIDTH => PRIME_P_WIDTH,
        COEFF_B_WIDTH => PRIME_P_WIDTH
        )
      port map (
        clk              => clk,
        start            => start,
        finished         => finished,
        a_ready          => a_ready,
        a_filled         => a_filled,
        b_ready          => b_ready,
        b_filled         => b_filled,
        a_constant       => a_constant,
        cycles           => cycles,
        din_valid        => din_valid,
        din_coefficient  => din_coefficient,
        din_finished     => din_finished,
        dout_valid       => dout_valid,
        dout_coefficient => dout_coefficient
        );
  end generate SCHOOLBOOK;

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






  -- Stimulus process
  stim_proc : process
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


    while run_cnt < simulation_runs loop
      -- hold reset state for 100 ns.
      wait for 100 ns;

      wait for clk_period*10;
      wait until falling_edge(clk);
      wait for 1ns;
      if use_rand_input = '0' then
        --Just rising values
        for i in 0 to N_ELEMENTS-1 loop
          poly_a(i) <= std_logic_vector(resize(to_unsigned(i, integer(ceil(log2(real(N_ELEMENTS))))) mod PRIME_P , poly_a(0)'length));
          poly_b(i) <= std_logic_vector(resize(to_unsigned(i, integer(ceil(log2(real(N_ELEMENTS))))) mod PRIME_P , poly_a(0)'length));
          wait for 1ns;
        end loop;  -- i

        wait for clk_period*10;

      else
        --Randomly selected coefficients

        for i in 0 to N_ELEMENTS-1 loop
          rand_int(seed1, seed2, 1, to_integer(PRIME_P), N_A);
          rand_int(seed1, seed2, 1, to_integer(PRIME_P), N_B);
          if a_constant_in = '0' or (a_constant_in = '1' and run_cnt = 0) then
            poly_a(i) <= std_logic_vector(resize(to_unsigned(N_A, integer(ceil(log2(real(N_ELEMENTS))))) mod PRIME_P , poly_a(0)'length));
          end if;
          poly_b(i) <= std_logic_vector(resize(to_unsigned(N_B, integer(ceil(log2(real(N_ELEMENTS))))) mod PRIME_P , poly_a(0)'length));
          wait for 1ns;
        end loop;  -- i

        wait for clk_period*10;
      end if;
      --fill both RAMs with testvector

      --Calculate the result
      poly_c <= poly_mul(poly_a, poly_b);

      wait for clk_period*11;



      -- insert stimulus here
      wait until falling_edge(clk);
      wait for 1ns;
      start <= '1';
      if a_constant_in = '1' and run_cnt > 0 then
        a_constant <= '1';
      else
        a_constant <= '0';
      end if;
      wait until falling_edge(clk);
      wait for 1ns;
      start <= '0';
      --Input A
      if a_constant_in = '0' or (a_constant_in = '1' and run_cnt = 0) then
        if a_ready = '0' then
          wait until a_ready = '1';
        end if;
        wait until falling_edge(clk);
        wait for 1ns;
        --Fill with 
        for i in 0 to N_ELEMENTS-1 loop
          din_valid       <= '1';
          din_coefficient <= unsigned(poly_a(i));
          wait until falling_edge(clk);
          wait for 1ns;
        end loop;  -- i
        din_valid <= '0';
      end if;

      --input B
      if b_ready = '0' then
        wait until b_ready = '1';
      end if;
      wait until falling_edge(clk);
      wait for 1ns;
      for i in 0 to N_ELEMENTS-1 loop
        din_valid       <= '1';
        din_coefficient <= unsigned(poly_b(i));
        wait until falling_edge(clk);
        wait for 1ns;
      end loop;  -- i
      din_valid <= '0';


      wait until finished = '1';
      --Test for correctness
      for counter in 0 to N_ELEMENTS-1 loop
        if shadow_mem(counter) /= poly_c(counter) then
          error_happened <= '1';
          report "Error" severity error;
        end if;
      end loop;  -- counter


      --increment run counter
      run_cnt := run_cnt+1;
    end loop;

    simulation_finished <= '1';
    end_of_simulation   <= '1';

    wait;

    
  end process;


  --Just collect the results
  process(clk)
    variable counter : integer := 0;
  begin
    if rising_edge(clk) then

      if finished = '1' then
        counter := 0;
      end if;


      if dout_valid = '1' then
        shadow_mem(counter) <= std_logic_vector(dout_coefficient);
        counter             := counter + 1;
      end if;
      
    end if;
  end process;


end;
