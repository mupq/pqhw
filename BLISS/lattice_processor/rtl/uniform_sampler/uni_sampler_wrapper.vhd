----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:10:18 12/03/2012 
-- Design Name: 
-- Module Name:    uni_sampler_wrapper - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uni_sampler_wrapper is
  generic (
    --Samples a uniform value between 0 and Sx_MAX
    PRIME_P          : unsigned := to_unsigned(8383489, 23);
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

    -- #### Output of sampled values ####
    --Output of the first sampler (buffered by FIFO)
    s1_dout : out std_logic_vector(PRIME_P'length-1 downto 0);
    s1_addr : in  std_logic_vector(integer(ceil(log2(real(S1_FIFO_ELEMENTS))))-1 downto 0)
    );
end uni_sampler_wrapper;

architecture Behavioral of uni_sampler_wrapper is

  signal uni_sampler_seed       : std_logic_vector(127 downto 0);
  signal uni_sampler_key        : std_logic_vector(127 downto 0);
  signal uni_sampler_init       : std_logic := '0';
  signal uni_sampler_key_update : std_logic := '0';

  type   eg_state is (IDLE, WORKING);
  signal state_reg : eg_state := IDLE;

  signal s1_dout_val      : std_logic_vector(S1_MAX'length-1 downto 0);
  signal s1_dout_val_temp : unsigned(PRIME_P'length-1 downto 0);

  
begin

  uniform_sampler_1 : entity work.uniform_sampler
    generic map (
      S1_MAX           => S1_MAX,
      S1_FIFO_ELEMENTS => S1_FIFO_ELEMENTS
      )
    port map (
      clk        => clk,
      ready      => ready,
      start      => start,
      stop       => stop,
      seed       => uni_sampler_seed,
      key        => uni_sampler_key,
      init       => uni_sampler_init,
      key_update => uni_sampler_key_update,
      s1_dout    => s1_dout_val,
      s1_addr    => s1_addr
      );


  process(clk)
  begin  -- process c
    if rising_edge(clk) then




      if ((signed("0"&s1_dout_val)-to_signed(2**14, 16)) < 0) then
        s1_dout <= std_logic_vector(resize(unsigned(PRIME_P-unsigned(s1_dout_val)-to_unsigned(2**14, 16)), s1_dout'length));
     else
        s1_dout <= std_logic_vector(resize(unsigned(s1_dout_val), s1_dout'length));
      end if;


      --if s1_dout_val(0) = '0' then
      --  s1_dout <= std_logic_vector(resize(unsigned(s1_dout_val), s1_dout'length));
      --else
      --  --s1_dout_val_temp <= resize(unsigned(PRIME_P-unsigned(s1_dout_val)),s1_dout'length)
      --  s1_dout <= std_logic_vector(resize(unsigned(PRIME_P-unsigned(s1_dout_val)), s1_dout'length));
      --end if;


      uni_sampler_init <= '0';
      case state_reg is
        -----------------------------------------------------------------------
        -- IDLE
        -----------------------------------------------------------------------
        when IDLE =>
          uni_sampler_init <= '1';
          uni_sampler_key  <= (others => '1');
          uni_sampler_seed <= (others => '0');
          state_reg        <= WORKING;

        when WORKING =>
          state_reg <= WORKING;
          
      end case;

    end if;
  end process;

end Behavioral;

