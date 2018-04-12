--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;



entity ber_eval_tb is
  generic (
    MAX_PREC : integer := 80;
    CONST_K  : integer := 254;
    MAX_X    : integer := 10
    );
  port (
    error_happened_out    : out std_logic := '0';
    end_of_simulation_out : out std_logic := '0'
    );

end ber_eval_tb;

architecture behavior of ber_eval_tb is
  signal end_of_simulation : std_logic := '0';
  signal error_happened    : std_logic := '0';


  -- Component Declaration for the Unit Under Test (UUT)
  constant OUTPUT_SIZE_BER : integer := integer(ceil(log2(real((CONST_K-1)*((CONST_K-1)+2*CONST_K*MAX_X)))));
  constant OUTPUT_SIZE_Z   : integer := integer(ceil(log2(real((CONST_K)*(MAX_X)+CONST_K-1))));

  constant SAMPLES : integer := 40;
  type     speicher is array (0 to SAMPLES-1) of unsigned(32-1 downto 0);

  signal fifo_z_ram : speicher := (to_unsigned( 342 ,32), to_unsigned( 15 ,32), to_unsigned( 10 ,32), to_unsigned( 179 ,32), to_unsigned( 51 ,32), to_unsigned( 231 ,32), to_unsigned( 214 ,32), to_unsigned( 247 ,32), to_unsigned( 201 ,32), to_unsigned( 216 ,32), to_unsigned( 135 ,32), to_unsigned( 152 ,32), to_unsigned( 170 ,32), to_unsigned( 120 ,32), to_unsigned( 230 ,32), to_unsigned( 99 ,32), to_unsigned( 292 ,32), to_unsigned( 370 ,32), to_unsigned( 85 ,32), to_unsigned( 139 ,32), to_unsigned( 61 ,32), to_unsigned( 343 ,32), to_unsigned( 172 ,32), to_unsigned( 436 ,32), to_unsigned( 191 ,32), to_unsigned( 163 ,32), to_unsigned( 181 ,32), to_unsigned( 223 ,32), to_unsigned( 450 ,32), to_unsigned( 295 ,32), to_unsigned( 66 ,32), to_unsigned( 114 ,32), to_unsigned( 485 ,32), to_unsigned( 83 ,32), to_unsigned( 265 ,32), to_unsigned( 140 ,32), to_unsigned( 505 ,32), to_unsigned( 243 ,32), to_unsigned( 80 ,32), to_unsigned( 3 ,32));

  signal fifo_ber_ram : speicher := (to_unsigned( 52955 ,32), to_unsigned( 225 ,32), to_unsigned( 100 ,32), to_unsigned( 32041 ,32), to_unsigned( 2601 ,32), to_unsigned( 53361 ,32), to_unsigned( 45796 ,32), to_unsigned( 61009 ,32), to_unsigned( 40401 ,32), to_unsigned( 46656 ,32), to_unsigned( 18225 ,32), to_unsigned( 23104 ,32), to_unsigned( 28900 ,32), to_unsigned( 14400 ,32), to_unsigned( 52900 ,32), to_unsigned( 9801 ,32), to_unsigned( 21255 ,32), to_unsigned( 72891 ,32), to_unsigned( 7225 ,32), to_unsigned( 19321 ,32), to_unsigned( 3721 ,32), to_unsigned( 53640 ,32), to_unsigned( 29584 ,32), to_unsigned( 126087 ,32), to_unsigned( 36481 ,32), to_unsigned( 26569 ,32), to_unsigned( 32761 ,32), to_unsigned( 49729 ,32), to_unsigned( 138491 ,32), to_unsigned( 23016 ,32), to_unsigned( 4356 ,32), to_unsigned( 12996 ,32), to_unsigned( 171216 ,32), to_unsigned( 6889 ,32), to_unsigned( 6216 ,32), to_unsigned( 19600 ,32), to_unsigned( 191016 ,32), to_unsigned( 59049 ,32), to_unsigned( 6400 ,32), to_unsigned( 9 ,32));

  constant rand_ram : std_logic_vector := "11011111000110100110001101000101101001111100100100001010101111011111101110100110001000000010100110000011000110000101000111000100000110001111000010000011101011011110010010000001100101111000001101100000011110110110000001011101000000110011100101101101110101011101110001111010010101101010111001011100000001100101011010101110101111111010110011101101110110111011010011000010110100100011000110010000011110110110001000";

  signal result : speicher := (others => (others => '0'));

 signal MODEL_RESULTS: speicher := (to_unsigned( 15 ,32), to_unsigned( 10 ,32), to_unsigned( 179 ,32), to_unsigned( 51 ,32), to_unsigned( 231 ,32), to_unsigned( 216 ,32), to_unsigned( 135 ,32), to_unsigned( 152 ,32), to_unsigned( 170 ,32), to_unsigned( 120 ,32), to_unsigned( 230 ,32), to_unsigned( 99 ,32), to_unsigned( 292 ,32), to_unsigned( 370 ,32), to_unsigned( 85 ,32), to_unsigned( 139 ,32), to_unsigned( 61 ,32), to_unsigned( 343 ,32), to_unsigned( 172 ,32), to_unsigned( 436 ,32), to_unsigned( 191 ,32), to_unsigned( 163 ,32), to_unsigned( 181 ,32), to_unsigned( 66 ,32), to_unsigned( 114 ,32), to_unsigned( 83 ,32), to_unsigned( 265 ,32), to_unsigned( 140 ,32), to_unsigned( 243 ,32), to_unsigned( 80 ,32), to_unsigned( 3 ,32), to_unsigned( 0 ,32), to_unsigned( 0 ,32), to_unsigned( 0 ,32), to_unsigned( 0 ,32), to_unsigned( 0 ,32), to_unsigned( 0 ,32), to_unsigned( 0 ,32), to_unsigned( 0 ,32), to_unsigned( 0 ,32));

  --Accepts:
  --" 1 1 1 0 1 0 0 1 1 1 1 1 1 1 0 1 0 0 0 0 "
--Accepts:
--"
-- "

  signal clk        : std_logic;
  signal rand_rd_en : std_logic;
  signal rand_din   : std_logic := '0';
  signal rand_empty : std_logic;
  signal rand_valid : std_logic;

  signal fifo_ber_empty : std_logic;
  signal fifo_ber_rd_en : std_logic;
  signal fifo_ber_valid : std_logic;
  signal fifo_ber_in    : std_logic_vector(integer(ceil(log2(real((CONST_K-1)*((CONST_K-1)+2*CONST_K*MAX_X)))))-1 downto 0);
  signal fifo_z_empty   : std_logic;
  signal fifo_z_rd_en   : std_logic;
  signal fifo_z_valid   : std_logic;
  signal fifo_z_in      : std_logic_vector(integer(ceil(log2(real((CONST_K)*(MAX_X)+CONST_K-1))))-1 downto 0);
  signal z_dout         : std_logic_vector(integer(ceil(log2(real((CONST_K)*(MAX_X)+CONST_K-1))))-1 downto 0);
  signal z_full         : std_logic := '0';
  signal z_wr_en        : std_logic;


  signal rd_counter_ber : integer := 0;
  signal rd_counter_z   : integer := 0;
  signal rd_counter_rnd : integer := 0;
  signal wr_counter_res : integer := 0;


  constant SAMPLE_COUNT : integer := 31;

  -- Clock period definitions
  constant clk_period : time := 10 ns;
  
begin

  -- Instantiate the Unit Under Test (UUT)
  ber_eval_1 : entity work.ber_eval
    generic map (
      MAX_PREC => MAX_PREC,
      CONST_K  => CONST_K,
      MAX_X    => MAX_X
      )
    port map (
      clk            => clk,
      rand_rd_en     => rand_rd_en,
      rand_din       => rand_din,
      rand_empty     => rand_empty,
      rand_valid     => rand_valid,
      fifo_ber_empty => fifo_ber_empty,
      fifo_ber_rd_en => fifo_ber_rd_en,
      fifo_ber_valid => fifo_ber_valid,
      fifo_ber_in    => fifo_ber_in,
      fifo_z_empty   => fifo_z_empty,
      fifo_z_rd_en   => fifo_z_rd_en,
      fifo_z_valid   => fifo_z_valid,
      fifo_z_in      => fifo_z_in,
      z_dout         => z_dout,
      z_full         => z_full,
      z_wr_en        => z_wr_en
      );

  -- Clock process definitions
  clk_process : process
  begin
    if end_of_simulation = '0' then
      clk <= '0';
      wait for clk_period/2;
      clk <= '1';
      wait for clk_period/2;
    end if;
  end process;
  end_of_simulation_out <=  end_of_simulation;


  process(clk)
  begin  -- process
    if rising_edge(clk) then
      fifo_ber_valid <= '0';
      fifo_z_valid   <= '0';
      fifo_z_empty   <= '0';
      fifo_ber_empty <= '0';
      rand_empty     <= '0';
      rand_valid     <= '0';

      if fifo_ber_rd_en = '1' then
        fifo_ber_valid <= '1';
        fifo_ber_in    <= std_logic_vector(resize(fifo_ber_ram(rd_counter_ber), fifo_ber_in'length));
        rd_counter_ber <= (rd_counter_ber+1) mod (SAMPLES);
      end if;

      if fifo_z_rd_en = '1' then
        fifo_z_valid <= '1';
        fifo_z_in    <= std_logic_vector(resize(fifo_z_ram(rd_counter_z), fifo_z_in'length));
        rd_counter_z <= (rd_counter_z+1) mod (SAMPLES);
      end if;

      if rand_rd_en = '1' then
        rand_valid     <= '1';
        rand_din       <= rand_ram(rd_counter_rnd);
        rd_counter_rnd <= (rd_counter_rnd+1) mod (rand_ram'length);
      end if;

      if z_wr_en = '1' then
        result(wr_counter_res) <= resize(unsigned(z_dout), result(0)'length);
        wr_counter_res         <= (wr_counter_res +1) mod (SAMPLES);
      end if;
      
      
    end if;
  end process;


  -- Stimulus process
  stim_proc : process
  begin
    -- hold reset state for 100 ns.
    wait for 100 ns;


    while wr_counter_res < SAMPLE_COUNT loop
      wait for clk_period;
    end loop;


    for i in 0 to SAMPLE_COUNT-1 loop
      if result(i) /= MODEL_RESULTS(i) then
        error_happened <= '1';
      end if;
    end loop;  -- i
    -- insert stimulus here 

    wait for clk_period*10;   

    if error_happened = '1' then
      report "ERROR";
      error_happened_out <= '1';
    else
      report "OK";
    end if;

    end_of_simulation <= '1';
    wait;

  end process;

end;
