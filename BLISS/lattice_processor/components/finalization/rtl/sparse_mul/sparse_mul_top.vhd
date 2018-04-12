----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:41:50 02/06/2014 
-- Design Name: 
-- Module Name:    sparse_mul_top - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;



entity sparse_mul_top is
  generic (
    PARAMETER_SET :integer:=1;
    --FFT and general configuration
    CORES         : integer               := 8;
    N_ELEMENTS    : integer               := 512;
    KAPPA         : integer               := 23;
    WIDTH_S1      : integer               := 2;
    WIDTH_S2      : integer               := 3;
    --Used to initialize the right s (s1 or s2)
    INIT_TABLE    : integer               := 0;
    c_delay       : integer range 0 to 16 := 2;
    MAX_RES_WIDTH : integer               := 6
    );
  port (
    clk : in std_logic;

    start    : in  std_logic := '0';
    ready    : out std_logic := '0';
    finished : out std_logic := '0';

    --Access to the key port (to change the secret key). Write only
    s1_addr  : in std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    s1_in    : in std_logic_vector(WIDTH_S1-1 downto 0)                              := (others => '0');
    s1_wr_en :    std_logic                                                          := '0';

    --Access to the key port (to change the secret key). Write only
    s2_addr  : in std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    s2_in    : in std_logic_vector(WIDTH_S2-1 downto 0)                              := (others => '0');
    s2_wr_en :    std_logic                                                          := '0';

    --Access to the positions of c
    addr_c : out std_logic_vector(integer(ceil(log2(real(KAPPA))))-1 downto 0)      := (others => '0');
    data_c : in  std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');

    --valid_c : in  std_logic                                                          := '0';

    --Results of the multiplication
    coeff_sc1_out   : out std_logic_vector(MAX_RES_WIDTH-1 downto 0)                         := (others => '0');
    coeff_sc1_addr  : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    coeff_sc1_valid : out std_logic                                                          := '0';

    coeff_sc2_out   : out std_logic_vector(MAX_RES_WIDTH-1 downto 0)                         := (others => '0');
    coeff_sc2_addr  : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    coeff_sc2_valid : out std_logic                                                          := '0'
    );
end sparse_mul_top;

architecture Behavioral of sparse_mul_top is

  signal data_c_intern : std_logic_vector(data_c'range) := (others => '0');
  signal start_cores   : std_logic                      := '0';

  signal s1_res        : std_logic_vector(CORES*MAX_RES_WIDTH-1 downto 0);
  signal s1_res_valid  : std_logic_vector(CORES-1 downto 0);
  signal s1_ready      : std_logic_vector(CORES-1 downto 0);
  signal s1_ready_ones : std_logic_vector(CORES-1 downto 0) := (others => '1');

  signal s2_res        : std_logic_vector(CORES*MAX_RES_WIDTH-1 downto 0);
  signal s2_res_valid  : std_logic_vector(CORES-1 downto 0);
  signal s2_ready      : std_logic_vector(CORES-1 downto 0);
  signal s2_ready_ones : std_logic_vector(CORES-1 downto 0) := (others => '1');

  type   eg_state1 is (IDLE, COMPUTE, WAIT_CYCLE, FINISH, OUTPUT);
  signal state_reg : eg_state1 := IDLE;

  signal addr_c_intern : unsigned(addr_c'range)   := (others => '0');
  signal out_counter   : integer range 0 to CORES := 0;
  signal addr_counter  : integer range 0 to 512   := 0;
  signal started       : std_logic                := '0';

  signal c_valid_delay_in  : std_logic_vector(0 downto 0) := (others => '0');
  signal c_valid_delay_out : std_logic_vector(0 downto 0);

  signal coeff_sc1_out_val : std_logic_vector(MAX_RES_WIDTH-1 downto 0) := (others => '0');
  signal coeff_sc2_out_val : std_logic_vector(MAX_RES_WIDTH-1 downto 0) := (others => '0');
begin

  --Delay the valid signal for the C RAM
  Shift_reg_new_1 : entity work.Shift_reg_new
    generic map (
      depth => c_delay,
      width => 1
      )
    port map (
      clk    => clk,
      Output => c_valid_delay_out,
      Input  => c_valid_delay_in
      );


  --coeff_sc1_out_val <= s1_res(MAX_RES_WIDTH*out_counter+MAX_RES_WIDTH-1 downto MAX_RES_WIDTH*out_counter);
  --coeff_sc2_out_val <= s2_res(MAX_RES_WIDTH*out_counter+MAX_RES_WIDTH-1 downto MAX_RES_WIDTH*out_counter);
  
 coeff_sc1_out_val <= std_logic_vector(resize(unsigned(s1_res) srl MAX_RES_WIDTH*out_counter,coeff_sc1_out_val'length));
   coeff_sc2_out_val <= std_logic_vector(resize(unsigned(s2_res) srl MAX_RES_WIDTH*out_counter,coeff_sc2_out_val'length));
                     



  
  process(clk)
  begin
    if rising_edge(clk) then
      data_c_intern       <= data_c;
      c_valid_delay_in(0) <= '0';       --XXX
      ready               <= '0';
      addr_c              <= std_logic_vector(addr_c_intern);
      start_cores         <= '0';
      coeff_sc1_valid     <= '0';
      coeff_sc2_valid     <= '0';
      started             <= '0';
      finished            <= '0';

      case state_reg is
        --Just wait. 
        when IDLE =>
          ready         <= '1';
          addr_c_intern <= (others => '0');
          out_counter   <= 0;
          addr_counter  <= 0;
          started       <= '0';


          --Go go go
          if start = '1' then
            start_cores         <= '1';
            state_reg           <= COMPUTE;
            c_valid_delay_in(0) <= '1';
            started             <= '1';
            ready               <= '0';
            addr_counter        <= 0;
          end if;

        when COMPUTE =>
          out_counter         <= 0;
          c_valid_delay_in(0) <= '1';
          --Iterate over c until all cores are ready
          if addr_c_intern < KAPPA-1 then
            addr_c_intern <= addr_c_intern+1;
          else
            c_valid_delay_in(0) <= '0';
            addr_c_intern       <= (others => '0');
            state_reg           <= WAIT_CYCLE;
          end if;

          if s1_ready = s1_ready_ones and started = '0' then
            state_reg <= FINISH;
          end if;

          --The cores need one cycle to reset
        when WAIT_CYCLE =>
          if s1_res_valid(0) = '1' then
            state_reg <= OUTPUT;
          end if;

          

          
        when OUTPUT =>
          if out_counter < CORES then
            coeff_sc1_out   <= coeff_sc1_out_val;
            coeff_sc1_addr  <= std_logic_vector(to_unsigned(addr_counter, coeff_sc1_addr'length));
            coeff_sc1_valid <= '1';

            coeff_sc2_out   <= coeff_sc2_out_val;
            coeff_sc2_addr  <= std_logic_vector(to_unsigned(addr_counter, coeff_sc2_addr'length));
            coeff_sc2_valid <= '1';
            addr_counter    <= addr_counter+1;
            out_counter     <= out_counter+1;
          else
            state_reg           <= COMPUTE;
            c_valid_delay_in(0) <= '1';
          end if;
          

        when FINISH =>
          state_reg <= IDLE;
          finished  <= '1';
      end case;
    end if;
  end process;






  cores_s1 : for i in 0 to CORES-1 generate
    sparse_core_1 : entity work.sparse_core
      generic map (
        PARAMETER_SET => PARAMETER_SET,
        N_ELEMENTS    => N_ELEMENTS,
        CORES         => CORES,
        CORE_NUM      => i,
        KAPPA         => KAPPA,
        WIDTH_S       => WIDTH_S1,
        INIT_TABLE    => INIT_TABLE,
        MAX_RES_WIDTH => MAX_RES_WIDTH
        )
      port map (
        clk       => clk,
        start     => start_cores,
        ready     => s1_ready(i),
        res       => s1_res(MAX_RES_WIDTH*i+MAX_RES_WIDTH-1 downto MAX_RES_WIDTH*i),
        res_valid => s1_res_valid(i),
        data_c    => data_c,
        valid_c   => c_valid_delay_out(0),
        --just wire to toplevel
        s_addr    => s1_addr,
        s_in      => s1_in,
        s_wr_en   => s1_wr_en
        );
  end generate cores_s1;



  cores_s2 : for i in 0 to CORES-1 generate
    sparse_core_2 : entity work.sparse_core
      generic map (
                PARAMETER_SET => PARAMETER_SET,
        N_ELEMENTS    => N_ELEMENTS,
        CORES         => CORES,
        CORE_NUM      => i,
        KAPPA         => KAPPA,
        WIDTH_S       => WIDTH_S2,
        INIT_TABLE    => INIT_TABLE,
        MAX_RES_WIDTH => MAX_RES_WIDTH
        )
      port map (
        clk       => clk,
        start     => start_cores,
        ready     => s2_ready(i),
        res       => s2_res(MAX_RES_WIDTH*i+MAX_RES_WIDTH-1 downto MAX_RES_WIDTH*i),
        res_valid => s2_res_valid(i),
        data_c    => data_c,
        valid_c   => c_valid_delay_out(0),
        --just wire to toplevel
        s_addr    => s2_addr,
        s_in      => s2_in,
        s_wr_en   => s2_wr_en
        );
  end generate cores_s2;

end Behavioral;

