-- TestBench Template 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;



entity fft_top_tb is
  generic (
    N_ELEMENTS    : integer := 128;
    PRIME_P_WIDTH : integer := 6;
    XN            : integer := -1;
    PRIME_P       : unsigned;
    PSI           : unsigned;
    OMEGA         : unsigned;
    PSI_INVERSE   : unsigned;
    OMEGA_INVERSE : unsigned
    );


end fft_top_tb;

architecture behavior of fft_top_tb is



  -- Component Declaration for the Unit Under Test (UUT)




  signal error_happened    : std_logic := '0';
  signal end_of_simulation : std_logic := '0';

  signal clk          : std_logic;
  signal usr_start    : std_logic := '0';
  signal usr_inverse  : std_logic := '0';
  signal usr_finished : std_logic;



  signal w_psi_req     : std_logic;
  signal w_inverse_req : std_logic;
  signal w_index       : unsigned(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0);
  signal w_out_val     : unsigned(PRIME_P_WIDTH-1 downto 0):= (others => '0');
  signal w_delay       : integer                      := 5;
  signal a_op          : std_logic_vector(0 downto 0) := (others => '0');
  signal a_w_in        : unsigned(PRIME_P_WIDTH-1 downto 0):= (others => '0');
  signal a_a_in        : unsigned(PRIME_P_WIDTH-1 downto 0):= (others => '0');
  signal a_b_in        : unsigned(PRIME_P_WIDTH-1 downto 0):= (others => '0');
  signal a_x_out       : unsigned(PRIME_P_WIDTH-1 downto 0):= (others => '0');
  signal a_delay       : integer                      := 35;

  signal bram_addra : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal bram_doa   : std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');
  signal bram_addrb : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal bram_dib   : std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');
  signal bram_web   : std_logic                                                          := '0';
  signal bram_delay : integer                                                            := 2;


  signal tb_addra      : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal tb_dia        : std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');
  signal tb_wea        : std_logic                                                          := '0';
  signal bram_addra_in : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');

  type   ram_type is array (N_ELEMENTS-1 downto 0) of std_logic_vector(PRIME_P_WIDTH-1 downto 0);
  signal shadow_mem : ram_type :=(others => (others => '0') );

  constant clk_period : time := 10ns;

  signal res_mem   : ram_type:=(others => (others => '0') );
  signal input_mem : ram_type:=(others => (others => '0') );

  impure function FFT(N_ELEMENTS, IFFT : integer; input_mem : ram_type) return ram_type is
    variable xa_val      : unsigned(PRIME_P_WIDTH-1 downto 0);
    variable xb_val      : unsigned(PRIME_P_WIDTH-1 downto 0);
    variable m           : integer := 2;
    variable s           : integer := 0;
    variable i           : integer := 0;
    variable a           : integer := 0;
    variable b           : integer := 0;
    variable n           : integer := 0;
    variable temp        : signed(1000 downto 0);
    variable tmp_omega   : unsigned(PRIME_P_WIDTH-1 downto 0);
    variable result_mem  : ram_type :=(others => (others => '0'));
    variable omega_table : ram_type:=(others => (others => '0'));
  begin

--    I in 0 to N_ELEMENTS-1 loop

    --copy input into result mem
    for i in 0 to N_ELEMENTS-1 loop
      result_mem(I) := input_mem(I);
    end loop;  -- i

    --create omega/iomega table (why is unsigend exponentation not supported :(
    tmp_omega := to_unsigned(1, tmp_omega'length);
    for i in 0 to N_ELEMENTS-1 loop
      omega_table(I) := std_logic_vector(tmp_omega);
      if IFFT = 1 then
        tmp_omega := resize((resize(tmp_omega, tmp_omega'length+OMEGA_INVERSE'length+10)*OMEGA_INVERSE) mod PRIME_P, tmp_omega'length);
      else
        tmp_omega := resize((resize(tmp_omega, tmp_omega'length+OMEGA'length+10)*OMEGA) mod PRIME_P, tmp_omega'length);
      end if;
    end loop;  -- i

    m       := 2;
    while m <= N_ELEMENTS loop
      --for s in range(0, N, m) :
      s := 0;
      while s < N_ELEMENTS loop
        for i in 0 to (m/2)-1 loop
          n := i * N_ELEMENTS / m;
          a := s + i;
          b := s + i + m/2;

          xa_val := unsigned(result_mem(a));
          xb_val := unsigned(result_mem(b));

          result_mem(a) := std_logic_vector(to_unsigned((to_integer(xa_val)+to_integer(unsigned(omega_table(n mod N_ELEMENTS)))*to_integer(xb_val)) mod to_integer(PRIME_P), result_mem(0)'length));

          result_mem(b) := std_logic_vector(to_unsigned((to_integer(xa_val)-to_integer(unsigned(omega_table(n mod N_ELEMENTS)))*to_integer(xb_val)) mod to_integer(PRIME_P), result_mem(0)'length));

          ----f*** you VHDL
          --result_mem(a) := std_logic_vector(resize(unsigned(unsigned(resize("000000000000000"&xa_val, xa_val'length*2+10)) + unsigned("00000000000000000000"&unsigned(omega_table(n mod N_ELEMENTS)))* unsigned(resize("00000000000000"&xb_val, xb_val'length))) mod unsigned(PRIME_P) , result_mem(0)'length));


          --temp := signed(resize((signed("0000000000000000"&xa_val) - signed("000000000000000"&unsigned(omega_table(n mod N_ELEMENTS))*"00000000000"&xb_val)) , temp'length));

          --while signed(temp) < 0 loop
          --  temp := temp+signed("00"&PRIME_P);
          --end loop;

          --result_mem(b) := std_logic_vector(resize(unsigned("0"&temp) mod PRIME_P, result_mem(b)'length));

          --report "val a "& integer'image(to_integer(unsigned(result_mem(a)))) &" "&integer'image(a) severity note;
          --report "val b "& integer'image(to_integer(unsigned(result_mem(b))))&" "&integer'image(b) severity note;

          ---- result_mem(b) :=

        end loop;
        s := s+m;
      end loop;
      m := m * 2;
    end loop;


    return result_mem;
    
  end function;

begin

  fft_top_1 : entity work.fft_top
    generic map (
      N_ELEMENTS    => N_ELEMENTS,
      PRIME_P_WIDTH => PRIME_P_WIDTH,
      XN            => XN)
    port map (
      clk           => clk,
      usr_start     => usr_start,
      usr_inverse   => usr_inverse,
      usr_finished  => usr_finished,
      w_psi_req     => w_psi_req,
      w_inverse_req => w_inverse_req,
      w_index       => w_index,
      w_out_val     => w_out_val,
      w_delay       => w_delay,
      a_op          => a_op,
      a_w_in        => a_w_in,
      a_a_in        => a_a_in,
      a_b_in        => a_b_in,
      a_x_out       => a_x_out,
      a_delay       => a_delay,
      bram_addra    => bram_addra_in,
      bram_doa      => bram_doa,
      bram_addrb    => bram_addrb,
      bram_dib      => bram_dib,
      bram_web      => bram_web,
      bram_delay    => bram_delay
      );

  fft_mar_1 : entity work.fft_mar
    generic map (
      W_WIDTH   => PRIME_P_WIDTH,
      A_WIDTH   => PRIME_P_WIDTH,
      B_WIDTH   => PRIME_P_WIDTH,
      RED_PRIME => to_integer(PRIME_P)
      )
    port map (
      clk   => clk,
      op    => a_op,
      w_in  => a_w_in,
      a_in  => a_a_in,
      b_in  => a_b_in,
      x_out => a_x_out,
      delay => a_delay
      );

  w_table_1 : entity work.w_table
    generic map (
      XN            => XN,
      N_ELEMENTS    => N_ELEMENTS,
      PRIME_P_WIDTH => PRIME_P_WIDTH,
      PRIME_P       => PRIME_P,
      PSI           => PSI,
      OMEGA         => OMEGA,
      PSI_INVERSE   => PSI_INVERSE,
      OMEGA_INVERSE => OMEGA_INVERSE
      )
    port map (
      clk         => clk,
      psi_req     => w_psi_req,
      inverse_req => w_inverse_req,
      index       => w_index,
      out_val     => w_out_val,
      delay       => w_delay
      );


  bram_with_delay_1 : entity work.bram_with_delay
    generic map (
      SIZE       => N_ELEMENTS,
      ADDR_WIDTH => integer(ceil(log2(real(N_ELEMENTS)))),
      COL_WIDTH  => PRIME_P_WIDTH,
      add_reg_a  => 0,
      add_reg_b  => 0,
      InitFile   => ""
      )
    port map (
      clka  => clk,
      clkb  => clk,
      ena   => '1',
      enb   => '1',
      wea   => tb_wea,
      web   => bram_web,
      addra => bram_addra,
      addrb => bram_addrb,
      dia   => tb_dia,
      dib   => bram_dib,
      doa   => bram_doa,
      dob   => open
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


  bram_addra <= bram_addra_in when tb_wea = '0' else tb_addra;

  process (clk)
  begin
    if rising_edge(clk) then
      if bram_web = '1' then
        shadow_mem(to_integer(unsigned(bram_addrb))) <= bram_dib;
      end if;
      

    end if;
  end process;


  -- Stimulus process
  stim_proc : process
  begin
    -- hold reset state for 100 ns.
    wait for 100 ns;

    wait for clk_period*10;

    -- insert stimulus here
    wait until falling_edge(clk);
    wait for 1ns;
    --Fill the BRAM with values (0..N_ELEMENTS-1)
    for I in 0 to N_ELEMENTS-1 loop
      tb_wea                                    <= '1';
      tb_dia                                    <= std_logic_vector(resize(to_unsigned(i, 500) mod PRIME_P, tb_dia'length));
      tb_addra                                  <= std_logic_vector(to_unsigned(I, tb_addra'length));
      wait for 1ns;
      input_mem(to_integer(unsigned(tb_addra))) <= std_logic_vector(tb_dia);
      wait until falling_edge(clk);
      wait for 1ns;
    end loop;  -- I
    tb_wea  <= '0';
    wait until falling_edge(clk);
    wait for 1ns;
    res_mem <= FFT(N_ELEMENTS, 0, input_mem);


    wait for clk_period*100;
    usr_start <= '1';
    wait until falling_edge(clk);
    wait for 1ns;
    usr_start <= '0';
    wait until falling_edge(clk);
    wait for 1ns;

    wait until usr_finished = '1';
    wait until falling_edge(clk);
    wait for 1ns;


    --Compare now the shadow memory with the result
    for I in 0 to N_ELEMENTS-1 loop
      if res_mem(I) /= shadow_mem(I) then
        error_happened <= '1';
      end if;
    end loop;

    wait until falling_edge(clk);
    wait for 1ns;

    wait for 10000*clk_period;
    
    if error_happened = '1' then
      report "ERROR";
    else
      report "OK";
    end if;


    wait for 10000*clk_period;
    end_of_simulation <= '1';
    wait;

    
  end process;

end;
