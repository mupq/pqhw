----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:43:16 11/16/2012 
-- Design Name: 
-- Module Name:    uniform_sampler - Behavioral 
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



entity uniform_sampler is
  generic (
    --Samples a uniform value between 0 and Sx_MAX
    S1_MAX           : unsigned := to_unsigned(37011, 12);
    --Address generator to fill RAM
    S1_FIFO_ELEMENTS : integer  := 512
    );
  port (
    clk : in std_logic;

    -- #### Control logic ####
    --Sampling can be enabled if ready is high
    ready : out std_logic;
    start : in  std_logic := '0';
    stop  : in  std_logic := '0';

    output_delay : in integer := 6;

    -- #### Seed management ####
    --The key can be updated at any time but it is not guaranteed when this
    --will have an effect
    seed       : in std_logic_vector(127 downto 0) := (others => '0');
    key        : in std_logic_vector(127 downto 0) := (others => '0');
    init       : in std_logic                      := '0';  --needs to be asserted to set module
                                        --with appropriate key
    key_update : in std_logic                      := '0';  --assert if key has been updated

    -- #### Output of sampled values ####
    --Output of the first sampler (buffered by FIFO)
    s1_dout : out std_logic_vector(S1_MAX'length-1 downto 0);
    s1_addr : in  std_logic_vector(integer(ceil(log2(real(S1_FIFO_ELEMENTS))))-1 downto 0)
    );

end uniform_sampler;

architecture Behavioral of uniform_sampler is

  signal s1_dout_delay : std_logic_vector(S1_MAX'length-1 downto 0);

  --S1
  signal s1_clk_en        : std_logic := '0';
  signal s1_rst           : std_logic := '0';
  signal s1_buf_empty     : std_logic := '0';
  signal s1_din_refresh   : std_logic := '0';
  signal s1_valid_out     : std_logic := '0';
  signal s1_valid_sampler : std_logic := '0';


  --AES_CBC
  signal aes_rst    : std_logic                       := '1';
  signal aes_enable : std_logic;
  signal aes_dout   : std_logic_vector (127 downto 0) := (others => '0');
  signal aes_done   : std_logic;

  --FIFO
  constant WIDTH : integer := S1_MAX'length;
  constant DEPTH : integer := S1_FIFO_ELEMENTS;

  signal fifo_srst         : std_logic;
  signal fifo_din          : std_logic_vector(WIDTH-1 downto 0);
  signal fifo_rd_en        : std_logic;
  signal fifo_dout         : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
  signal fifo_full         : std_logic                          := '0';
  signal fifo_almost_full  : std_logic                          := '0';
  signal fifo_empty        : std_logic                          := '0';
  signal fifo_almost_empty : std_logic                          := '0';
  signal fifo_valid        : std_logic                          := '0';
  signal fifo_data_count   : std_logic_vector(integer(ceil(log2(real(DEPTH))))-1 downto 0);

  --FSM
  type   eg_state_output is (FIRST_RESET, IDLE);
  signal state_reg_output : eg_state_output := FIRST_RESET;

  type   eg_state_aes is (AES_WAIT, AES_START, AES_RUN, SAMPLE, SAMPLE_DONE);
  signal state_reg_aes : eg_state_aes := AES_WAIT;


  signal key_intern : std_logic_vector(127 downto 0);

  signal processing_fifo : std_logic                                                                := '0';
  signal init_flag       : std_logic                                                                := '0';
  signal ready_r1        : std_logic                                                                := '0';
  signal s1_addr_r1      : std_logic_vector(integer(ceil(log2(real(S1_FIFO_ELEMENTS))))-1 downto 0) := (others => '0');
  signal s1_addr_d1      : std_logic_vector(integer(ceil(log2(real(S1_FIFO_ELEMENTS))))-1 downto 0) := (others => '0');
  signal s1_delay_value  : integer                                                                  := 60;

  impure function maximum(x, y : integer) return integer;

  impure function maximum(x, y : integer) return integer is
    variable ret : integer;
  begin
    if (x > y) then
      ret := x;
    else
      ret := y;
    end if;
    return ret;
  end;

begin

  -- AES-CBC based PRNG. Output directly connected to samplers.
  aes_cbc_1 : entity work.aes_cbc
    port map (
      clk    => clk,
      rst    => aes_rst,
      enable => aes_enable,
      seed   => seed,
      key    => key_intern,
      dout   => aes_dout,
      done   => aes_done
      );

  -- Sampler 1 behind FIFO
  S1 : entity work.sampler
    generic map (
      S_MAX => S1_MAX
      )
    port map (
      clk         => clk,
      clk_en      => s1_clk_en,
      rst         => s1_rst,
      buf_empty   => s1_buf_empty,
      din_refresh => s1_din_refresh,
      din         => aes_dout,
      dout        => fifo_din,
      valid       => s1_valid_sampler
      );

  --The output of the FIFO is directly wired to the output of the component
  gen_fifo_1 : entity work.gen_fifo
    generic map (
      WIDTH => WIDTH,
      DEPTH => DEPTH
      )
    port map (
      clk          => clk,
      srst         => fifo_srst,
      din          => fifo_din,
      wr_en        => s1_valid_sampler,
      rd_en        => fifo_rd_en,
      dout         => s1_dout_delay,
      full         => fifo_full,
      almost_full  => fifo_almost_full,
      empty        => fifo_empty,
      almost_empty => fifo_almost_empty,
      valid        => s1_valid_out,
      data_count   => open
      );

  s1_delay_value <= output_delay -2 -1;  --We need a register in the wrapper
  s1_dout_delay_reg : entity work.dyn_shift_reg
    generic map (
      max_depth => 255,
      width     => s1_dout_delay'length
      )
    port map (
      clk    => clk,
      depth  => s1_delay_value,
      Input  => s1_dout_delay,
      Output => s1_dout
      );


  
  fsm : process (clk)
  begin  -- process
    if rising_edge(clk) then            -- rising clock edge

      --Key update: Xor internal key state with external input
      if key_update = '1' then
        key_intern <= key_intern xor key;
      end if;

      -------------------------------------------------------------------------

      --Default values
      aes_rst        <= '0';
      fifo_srst      <= '0';
      s1_rst         <= '0';
      s1_din_refresh <= '0';
      fifo_rd_en     <= '0';
      ready_r1       <= '0';

      s1_addr_d1 <= s1_addr;
      ready      <= ready_r1;

      -------------------------------------------------------------------------
      -- State machine for output handling
      -------------------------------------------------------------------------
      case state_reg_output is

        when FIRST_RESET =>
          --Reset has to be asserted once in order to set the seed and the key
          aes_rst        <= '1';
          fifo_srst      <= '1';
          s1_rst         <= '1';
          s1_din_refresh <= '0';

          if init = '1' then
            key_intern       <= key;
            init_flag        <= '1';
            state_reg_output <= IDLE;
          end if;
          
        when IDLE =>
          --Wait until the FIFO is full
          if fifo_full = '1' or fifo_almost_full = '1' then
            ready_r1 <= '1';
          end if;

          fifo_rd_en <= '0';
          if s1_addr_d1 /= s1_addr then
            fifo_rd_en <= '1';
          end if;
          
      end case;


      -------------------------------------------------------------------------
      -- State machine for FIFO input handling
      -------------------------------------------------------------------------
      aes_enable <= '0';

      case state_reg_aes is
        when AES_WAIT =>
          if init_flag = '1' then
            state_reg_aes <= AES_START;
          end if;

        when AES_START =>
          if fifo_almost_full = '0' then
            aes_enable    <= '1';
            state_reg_aes <= AES_RUN;
          end if;

        when AES_RUN =>
          if aes_done = '1' then
            state_reg_aes <= SAMPLE;
            s1_clk_en     <= '1';
          end if;

        when SAMPLE =>
         
          s1_clk_en      <= '1';
          s1_din_refresh <= '1';
          state_reg_aes  <= SAMPLE_DONE;

        when SAMPLE_DONE =>
          s1_clk_en <= '1';
          if s1_buf_empty = '1' then
            state_reg_aes <= AES_START;
          end if;
          
      end case;



    end if;
    
  end process fsm;
end Behavioral;

