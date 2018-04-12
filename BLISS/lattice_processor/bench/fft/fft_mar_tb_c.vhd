--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:36:04 02/03/2012
-- Design Name:   
-- Module Name:   /home/thomasp/diploma/code/hw_implementation/lattice_signature/bench/fft/fft_mar_tb_c.vhd
-- Project Name:  lattice_signature
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: fft_mar
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


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

entity fft_mar_tb_c is
  generic(
    set           : integer := 0;
    tb_data_width : integer := 23;
    tb_prime      : integer := 8383489
    );
end fft_mar_tb_c;

architecture behavior of fft_mar_tb_c is

  -- Component Declaration for the Unit Under Test (UUT)


  --Inputs
  signal clk  : std_logic                          := '0';
  signal w_in : unsigned(tb_data_width-1 downto 0) := (others => '0');
  signal a_in : unsigned(tb_data_width-1 downto 0) := (others => '0');
  signal b_in : unsigned(tb_data_width-1 downto 0) := (others => '0');

  --Outputs
  signal x_add_out : unsigned(tb_data_width-1 downto 0);
    signal x_sub_out : unsigned(tb_data_width-1 downto 0);

  -- Clock period definitions
  constant clk_period : time := 10 ns;

  signal result_add         : std_logic_vector(tb_data_width-1 downto 0) := (others => '0');
  signal result_sub         : std_logic_vector(tb_data_width-1 downto 0) := (others => '0');
  signal result_add_delayed : std_logic_vector(tb_data_width-1 downto 0) := (others => '0');
  signal result_sub_delayed : std_logic_vector(tb_data_width-1 downto 0) := (others => '0');



  signal valid         : std_logic_vector(0 downto 0) := (others => '0');
  signal valid_delayed : std_logic_vector(0 downto 0);

  signal error_happened    : std_logic := '0';
  signal end_of_simulation : std_logic := '0';
  signal fft_mar_delay     : integer   := 0;
begin


  uut : entity work.fft_mar
    generic map(
      W_WIDTH   => tb_data_width,
      A_WIDTH   => tb_data_width,
      B_WIDTH   => tb_data_width,
               RED_PRIME_WIDTH   => tb_data_width,
      RED_PRIME => to_unsigned(tb_prime, tb_data_width)
  
      )
    port map (
      clk       => clk,
      w_in      => w_in,
      a_in      => a_in,
      b_in      => b_in,
      x_add_out => x_add_out,
      x_sub_out => x_sub_out,
      delay     => fft_mar_delay
      );


  delay_res_add : entity work.dyn_shift_reg
    generic map (
      width => tb_data_width

      )
    port map(
      depth  => fft_mar_delay,
      clk    => clk,
      Input  => result_add,
      Output => result_add_delayed
      );

  delay_res_sub : entity work.dyn_shift_reg
    generic map (
      width => tb_data_width
      )
    port map(
      depth  => fft_mar_delay,
      clk    => clk,
      Input  => result_sub,
      Output => result_sub_delayed
      );



  valid_reg : entity work.dyn_shift_reg
    generic map (
      width => 1

      )
    port map(
      clk    => clk,
      depth  => fft_mar_delay,
      Input  => valid,
      Output => valid_delayed
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


  -- Stimulus process
  stim_proc : process
    variable a : unsigned(a_in'length-1 downto 0) := (others => '0');
    variable b : unsigned(b_in'length-1 downto 0) := (others => '0');
    variable w : unsigned(w_in'length-1 downto 0) := (others => '0');

    variable selector : unsigned(9 downto 0) := to_unsigned(324, 10);
  begin
    --fft_mar_delay
    w_in <= (others => 'X');
    a_in <= (others => 'X');
    b_in <= (others => 'X');
    -- hold reset state for 100 ns.
    wait for 100 ns;
    wait until falling_edge(clk);

    w_in <= to_unsigned(2 mod tb_prime, w_in'length);
    a_in <= to_unsigned(3 mod tb_prime, a_in'length);
    b_in <= to_unsigned(4 mod tb_prime, b_in'length);
    wait for 1 ns;

    wait until falling_edge(clk);
    w_in <= (others => 'X');
    a_in <= (others => 'X');
    b_in <= (others => 'X');
    wait for clk_period*1000;

    wait until falling_edge(clk);


    for i in 0 to 2500 loop
      w_in <= w;
      a_in <= a;
      b_in <= b;

      result_add(tb_data_width-1 downto 0) <= std_logic_vector(resize((a + w *b) mod to_unsigned(tb_prime, tb_data_width), result_add'length));

      result_sub(tb_data_width-1 downto 0) <= std_logic_vector(resize(unsigned(signed("0"&a) +to_signed(tb_prime, tb_data_width+1)*to_signed(tb_prime, tb_data_width+1) - signed("0"&unsigned(w *b))) mod to_unsigned(tb_prime, tb_data_width), result_sub'length));


      valid(0) <= '1';

      if valid_delayed(0) = '1' and unsigned(result_add_delayed(tb_data_width-1 downto 0)) /= x_add_out then
        if valid_delayed(0) = '1' and unsigned(result_sub_delayed(tb_data_width-1 downto 0)) /= x_sub_out then
          error_happened <= '1';
          report "ERROR";
        end if;
      end if;

      w := resize((w+2) mod tb_prime, w'length);
      a := resize((a+1) mod tb_prime, a'length);
      b := resize((b+1) mod tb_prime, b'length);


      wait for 1ns;
      wait until falling_edge(clk);
      
    end loop;  -- i


    wait until falling_edge(clk);


    if error_happened = '1' then
      report "ERROR";
    else
      report "OK";
    end if;

    end_of_simulation <= '1';
    wait;
  end process;

end;
