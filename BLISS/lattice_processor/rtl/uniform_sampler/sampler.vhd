----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:29:22 11/16/2012 
-- Design Name: 
-- Module Name:    sampler - Behavioral 
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



entity sampler is
  generic(
    S_MAX : unsigned := to_unsigned(37011, 16)
    );
  port(
    clk    : in std_logic;
    clk_en : in std_logic := '0';

    rst       : in  std_logic := '0';
    buf_empty : out std_logic := '0';

    din_refresh : in std_logic;
    din         : in std_logic_vector(127 downto 0);

    --Outputs valid numbers
    dout  : out std_logic_vector(S_MAX'length-1 downto 0);
    valid : out std_logic := '0'

    );

end sampler;

architecture Behavioral of sampler is
  constant SAMPLE_WIDTH      : integer := S_MAX'length;
  constant SAMPLES_PER_BLOCK : integer := integer(floor(real(din'length) / real(SAMPLE_WIDTH)));

  signal dout_r1        : std_logic_vector(S_MAX'length-1 downto 0);
  signal valid_r1       : std_logic := '0';

  signal dout_r2        : std_logic_vector(S_MAX'length-1 downto 0);
  signal valid_r2       : std_logic := '0';
  
  signal din_refresh_r1 : std_logic;
  signal din_r1         : std_logic_vector(127 downto 0);

  signal counter : integer range 0 to SAMPLES_PER_BLOCK := SAMPLES_PER_BLOCK;

  signal  sample : unsigned(SAMPLE_WIDTH-1 downto 0);
  signal sample_assigned : std_logic:='0';

begin


  process(clk)
    --variable sample : unsigned(SAMPLE_WIDTH-1 downto 0);
  begin  -- process c
    if rising_edge(clk) then
      if rst = '1' then
        --is set to samples per block in order to prevent it from running on an
        --empty buffer
        counter   <= SAMPLES_PER_BLOCK;
        valid     <= '0';
        valid_r1  <= '0';
        buf_empty <= '0';
      else

        valid_r1 <= '0';
        sample_assigned <= '0';
        
        valid    <= valid_r1;


        if clk_en = '1' then
          --registers

          dout_r2  <= dout_r1;
          valid_r2 <= valid_r1;
                 
          dout  <= dout_r2;
          valid <= valid_r2;

          din_refresh_r1 <= din_refresh;

          --default
          valid_r1 <= '0';

          if counter < SAMPLES_PER_BLOCK then
            --Sample := unsigned(din_r1(counter*SAMPLE_WIDTH+SAMPLE_WIDTH-1 downto counter*SAMPLE_WIDTH));            
            sample  <= resize(unsigned(din_r1) srl (counter*SAMPLE_WIDTH), sample'length);
            sample_assigned <= '1';
            counter <= counter+1;           
          else
            buf_empty <= '1';
          end if;

          if sample_assigned ='1' then
           if sample <= S_MAX then
              valid_r1 <= '1';
            end if;            
          end if;

          dout_r1 <= std_logic_vector(sample);

          if din_refresh_r1 = '1' then
            din_r1         <= din;
            --reset counter
            counter <= 0;
          end if;

          
        end if;
      end if;
      
    end if;
  end process;


end Behavioral;

