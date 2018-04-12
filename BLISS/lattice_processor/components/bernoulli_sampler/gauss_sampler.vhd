--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/


 --Company: 
 --Engineer: 
 
 --Create Date:    16:03:07 02/03/2014 
 --Design Name: 
 --Module Name:    gauss_sampler - Behavioral 
 --Project Name: 
 --Target Devices: 
 --Tool versions: 
 --Description: 

 --Dependencies: 

 --Revision: 
 --Revision 0.01 - File Created
 --Additional Comments: 


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.ber_sampler_pkg.all;
use work.cdt_sampler_pkg.all;


entity ber_sampler is
  generic (
    INIT_VAL:integer :=0;
   PARAMETER_SET:integer:=1
    );
  port (
    clk              : in  std_logic;
    gauss_fifo_full  : in  std_logic := '0';
    gauss_fifo_wr_en : out std_logic;
    --gauss_fifo_dout  : out std_logic_vector(integer(ceil(log2(real((get_ber_max_sigma(PARAMETER_SET))))))-1+1 downto 0)
    gauss_fifo_dout  : out std_logic_vector(integer(ceil(log2(real(get_max_sigma(PARAMETER_SET)))))+1 -1 downto 0)
    );
end  ber_sampler;

architecture Behavioral of  ber_sampler is
  constant MAX_PREC : integer := get_ber_precision(PARAMETER_SET);
  constant    CONST_K  : integer := get_ber_k(PARAMETER_SET);
  constant    MAX_X    : integer := get_ber_max_x(PARAMETER_SET);

                          
  signal sigma2_plus_rd_en : std_logic;
  signal sigma2_plus_din   : std_logic;
  signal sigma2_plus_empty : std_logic;
  signal sigma2_plus_wr_en : std_logic;
  signal sigma2_plus_dout  : std_logic_vector(integer(ceil(log2(real(MAX_X))))-1 downto 0) := (others => '0');
  signal sigma2_plus_full  : std_logic;

  constant LIFO1_WIDTH     : integer                                                  := sigma2_plus_dout'length;
  constant LIFO1_OUT_PORTS : integer                                                  := 1;
  signal   lifo1_din       : std_logic_vector(LIFO1_WIDTH-1 downto 0);
  signal   lifo1_wr_en     : std_logic;
  signal   lifo1_full      : std_logic                                                := '0';
  signal   lifo1_rd_en     : std_logic_vector(LIFO1_OUT_PORTS-1 downto 0)             := (others => '0');
  signal   lifo1_dout      : std_logic_vector(LIFO1_OUT_PORTS*LIFO1_WIDTH-1 downto 0) := (others => '0');
  signal   lifo1_empty     : std_logic_vector(LIFO1_OUT_PORTS-1 downto 0)             := (others => '0');
  signal   lifo1_valid     : std_logic_vector(LIFO1_OUT_PORTS-1 downto 0)             := (others => '0');



  signal ber_comp_x_rd_en        : std_logic;
  signal ber_comp_x_empty        : std_logic;
  signal ber_comp_x_valid        : std_logic;
  signal ber_comp_x_val          : std_logic_vector(integer(ceil(log2(real(MAX_X-1))))-1 downto 0);
  signal ber_comp_y_rd_en        : std_logic;
  signal ber_comp_y_empty        : std_logic;
  signal ber_comp_y_valid        : std_logic;
  signal ber_comp_y_val          : std_logic_vector(integer(ceil(log2(real(CONST_K-1))))-1 downto 0);
  signal ber_comp_fifo_ber_full  : std_logic;
  signal ber_comp_fifo_ber_wr_en : std_logic;
  signal ber_comp_fifo_ber_out   : std_logic_vector(integer(ceil(log2(real((CONST_K-1)*((CONST_K-1)+2*CONST_K*MAX_X)))))-1 downto 0);
  signal ber_comp_fifo_z_full    : std_logic;
  signal ber_comp_fifo_z_wr_en   : std_logic;
  signal ber_comp_fifo_z_out     : std_logic_vector(integer(ceil(log2(real((CONST_K)*(MAX_X)+CONST_K-1))))-1 downto 0);

  constant LIFO2_WIDTH     : integer                                                  := ber_comp_fifo_ber_out'length + ber_comp_fifo_z_out'length;
  constant LIFO2_OUT_PORTS : integer                                                  := 2;
  signal   lifo2_din       : std_logic_vector(LIFO2_WIDTH-1 downto 0);
  signal   lifo2_wr_en     : std_logic;
  signal   lifo2_full      : std_logic                                                := '0';
  signal   lifo2_rd_en     : std_logic_vector(LIFO2_OUT_PORTS-1 downto 0)             := (others => '0');
  signal   lifo2_dout      : std_logic_vector(LIFO2_OUT_PORTS*LIFO2_WIDTH-1 downto 0) := (others => '0');
  signal   lifo2_empty     : std_logic_vector(LIFO2_OUT_PORTS-1 downto 0)             := (others => '0');
  signal   lifo2_valid     : std_logic_vector(LIFO2_OUT_PORTS-1 downto 0)             := (others => '0');



  signal eval_rand_rd_en     : std_logic;
  signal eval_rand_din       : std_logic;
  signal eval_rand_empty     : std_logic;
  signal eval_rand_valid     : std_logic;
  signal eval_fifo_ber_empty : std_logic;
  signal eval_fifo_ber_rd_en : std_logic;
  signal eval_fifo_ber_valid : std_logic;
  signal eval_fifo_ber_in    : std_logic_vector(integer(ceil(log2(real((CONST_K-1)*((CONST_K-1)+2*CONST_K*MAX_X)))))-1 downto 0);
  signal eval_fifo_z_empty   : std_logic;
  signal eval_fifo_z_rd_en   : std_logic;
  signal eval_fifo_z_valid   : std_logic;
  signal eval_fifo_z_in      : std_logic_vector(integer(ceil(log2(real((CONST_K)*(MAX_X)+CONST_K-1))))-1 downto 0);
  signal eval_z_dout         : std_logic_vector(integer(ceil(log2(real((CONST_K)*(MAX_X)+CONST_K-1))))-1 downto 0);
  signal eval_z_full         : std_logic;
  signal eval_z_wr_en        : std_logic;


  signal eval2_rand_rd_en     : std_logic;
  signal eval2_rand_din       : std_logic;
  signal eval2_rand_empty     : std_logic;
  signal eval2_rand_valid     : std_logic;
  signal eval2_fifo_ber_empty : std_logic;
  signal eval2_fifo_ber_rd_en : std_logic;
  signal eval2_fifo_ber_valid : std_logic;
  signal eval2_fifo_ber_in    : std_logic_vector(integer(ceil(log2(real((CONST_K-1)*((CONST_K-1)+2*CONST_K*MAX_X)))))-1 downto 0);
  signal eval2_fifo_z_empty   : std_logic;
  signal eval2_fifo_z_rd_en   : std_logic;
  signal eval2_fifo_z_valid   : std_logic;
  signal eval2_fifo_z_in      : std_logic_vector(integer(ceil(log2(real((CONST_K)*(MAX_X)+CONST_K-1))))-1 downto 0);
  signal eval2_z_dout         : std_logic_vector(integer(ceil(log2(real((CONST_K)*(MAX_X)+CONST_K-1))))-1 downto 0);
  signal eval2_z_full         : std_logic;
  signal eval2_z_wr_en        : std_logic;




  signal uni_rand_rd_en : std_logic;
  signal uni_rand_din   : std_logic;
  signal uni_rand_empty : std_logic;
  signal uni_rand_valid : std_logic;
  signal uni_dout       : std_logic_vector(integer(ceil(log2(real((CONST_K-1)))))-1 downto 0);
  signal uni_full       : std_logic;
  signal uni_wr_en      : std_logic;

  constant RAND_LIFO_OUT_PORTS : integer                                                          := 2;
  constant RAND_LIFO_WIDTH     : integer                                                          := 1;
  signal   rand_din            : std_logic_vector(RAND_LIFO_WIDTH-1 downto 0);
  signal   rand_wr_en          : std_logic;
  signal   rand_full           : std_logic                                                        := '0';
  signal   rand_rd_en          : std_logic_vector(RAND_LIFO_OUT_PORTS-1 downto 0)                 := (others => '0');
  signal   rand_dout           : std_logic_vector(RAND_LIFO_OUT_PORTS*RAND_LIFO_WIDTH-1 downto 0) := (others => '0');
  signal   rand_empty          : std_logic_vector(RAND_LIFO_OUT_PORTS-1 downto 0)                 := (others => '0');
  signal   rand_valid          : std_logic_vector(RAND_LIFO_OUT_PORTS-1 downto 0)                 := (others => '0');

  constant RAND2_LIFO_OUT_PORTS : integer                                                            := 3;
  constant RAND2_LIFO_WIDTH     : integer                                                            := 1;
  signal   rand2_din            : std_logic_vector(RAND2_LIFO_WIDTH-1 downto 0);
  signal   rand2_wr_en          : std_logic;
  signal   rand2_full           : std_logic                                                          := '0';
  signal   rand2_rd_en          : std_logic_vector(RAND2_LIFO_OUT_PORTS-1 downto 0)                  := (others => '0');
  signal   rand2_dout           : std_logic_vector(RAND2_LIFO_OUT_PORTS*RAND2_LIFO_WIDTH-1 downto 0) := (others => '0');
  signal   rand2_empty          : std_logic_vector(RAND2_LIFO_OUT_PORTS-1 downto 0)                  := (others => '0');
  signal   rand2_valid          : std_logic_vector(RAND2_LIFO_OUT_PORTS-1 downto 0)                  := (others => '0');


  signal final_rand_rd_en  : std_logic;
  signal final_rand_din    : std_logic;
  signal final_rand_empty  : std_logic;
  signal final_rand_valid  : std_logic;
  signal final_gauss_dout  : std_logic_vector(integer(ceil(log2(real((CONST_K)*(MAX_X)+CONST_K-1))))-1+1 downto 0) := (others => '0');
  signal final_gauss_full  : std_logic;
  signal final_gauss_wr_en : std_logic;

  constant RAND_D_SIGMA_PLUS : integer := 0;
  constant RAND_UNIFORM      : integer := 1;

  constant RAND_FINAL : integer := 0;
  constant RAND_EVAL  : integer := 1;
  constant RAND_EVAL2 : integer := 2;

  signal rst   : std_logic                     := '1';

   signal key    : std_logic_vector(79 downto 0) := x"67c6697351ff4aec29cd";
  signal IV     : std_logic_vector(79 downto 0) := x"baabf2fbe3457cc254f8";
  
  --signal key   : std_logic_vector(79 downto 0) := std_logic_vector(to_unsigned(INIT_VAL+5,80));
  --signal IV    : std_logic_vector(79 downto 0) := (others => '0');
  signal o_vld : std_logic                     := '0';
  signal z     : std_logic                     := '0';

  signal rst2   : std_logic                     := '1';
  --signal key2   : std_logic_vector(79 downto 0) := std_logic_vector(to_unsigned(INIT_VAL+500,80));
  --signal IV2    : std_logic_vector(79 downto 0) := (others => '0');

   signal key2    : std_logic_vector(79 downto 0) := x"1be8e78d765a2e63339f";
  signal IV2    : std_logic_vector(79 downto 0) := x"c99a66320db43158a35a";

  
  signal o_vld2 : std_logic                     := '0';
  signal z2     : std_logic                     := '0';

  constant FINAL_WIDTH     : integer := eval_z_dout'length;
  constant FINAL_OUT_PORTS : integer := 2;

  signal lifo3_din          : std_logic_vector(FINAL_OUT_PORTS*FINAL_WIDTH-1 downto 0) := (others => '0');
  signal lifo3_wr_en        : std_logic_vector(FINAL_OUT_PORTS-1 downto 0)             := (others => '0');
  signal lifo3_full         : std_logic_vector(FINAL_OUT_PORTS-1 downto 0)             := (others => '0');
  signal lifo3_almost_full  : std_logic_vector(FINAL_OUT_PORTS-1 downto 0)             := (others => '0');
  signal lifo3_rd_en        : std_logic                                                := '0';
  signal lifo3_dout         : std_logic_vector(FINAL_WIDTH-1 downto 0)                 := (others => '0');
  signal lifo3_empty        : std_logic                                                := '0';
  signal lifo3_almost_empty : std_logic                                                := '0';
  signal lifo3_valid        : std_logic                                                := '0';
  signal trivium1_clk_en    : std_logic                                                := '0';
  signal trivium2_clk_en    : std_logic                                                := '0';

  --Deal with the randomness consumption
  signal EVAL_TRIVIUM1_RAND_COUNTER    : integer := 1;
  signal EVAL_TRIVIUM2_RAND_COUNTER    : integer := 1;
  signal EVAL_UNIFORM_RAND_COUNTER     : integer := 1;
  signal EVAL_SIGMA2_PLUS_RAND_COUNTER : integer := 1;
  signal EVAL_BER1_RAND_COUNTER        : integer := 1;
  signal EVAL_BER2_RAND_COUNTER        : integer := 1;
  signal EVAL_FINAL_RAND_COUNTER       : integer := 1;

  --Deal with how many outputs we get
  signal EVAL_UNIFORM_OUTPUT_COUNTER : integer := 0;
  signal EVAL_SIGMA2_PLUS_OUTPUT_COUNTER : integer := 0;
  signal EVAL_BER1_OUTPUT_COUNTER        : integer := 0;
  signal EVAL_BER2_OUTPUT_COUNTER        : integer := 0;
  signal EVAL_FINAL_OUTPUT_COUNTER       : integer := 1;

  signal sigma2_plus_rnd_valid    : std_logic                                                := '0';

  -- synthesis translate_off
  signal BER_PERCENT : real := 0.0;
  signal UNIFORM_PERCENT : real := 0.0;
 signal S2PLUS_PERCENT : real := 0.0;
  signal RAND_PER_SAMPLE : real := 0.0;
   -- synthesis translate_on                              
begin

  
  -- synthesis translate_off
    BER_PERCENT <= real(EVAL_BER1_RAND_COUNTER+EVAL_BER2_RAND_COUNTER)/real(EVAL_TRIVIUM1_RAND_COUNTER+EVAL_TRIVIUM2_RAND_COUNTER);
  UNIFORM_PERCENT <= real( EVAL_UNIFORM_RAND_COUNTER)/real(EVAL_TRIVIUM1_RAND_COUNTER+EVAL_TRIVIUM2_RAND_COUNTER);
  S2PLUS_PERCENT<= real(EVAL_SIGMA2_PLUS_RAND_COUNTER)/real(EVAL_TRIVIUM1_RAND_COUNTER+EVAL_TRIVIUM2_RAND_COUNTER);
  RAND_PER_SAMPLE<= real(EVAL_TRIVIUM1_RAND_COUNTER+EVAL_TRIVIUM2_RAND_COUNTER)/real( EVAL_FINAL_OUTPUT_COUNTER);

    
  process(clk)
  begin
    --This process does not influence any output variables
    --It is just for evaluation of the Bernoulli sampler
    if rising_edge(clk) then
      if uni_rand_rd_en = '1' then
        EVAL_UNIFORM_RAND_COUNTER <= EVAL_UNIFORM_RAND_COUNTER+1;
      end if;

      if sigma2_plus_rd_en = '1' then
        EVAL_SIGMA2_PLUS_RAND_COUNTER <= EVAL_SIGMA2_PLUS_RAND_COUNTER +1;
      end if;

      if eval_rand_rd_en = '1' then
        EVAL_BER1_RAND_COUNTER <= EVAL_BER1_RAND_COUNTER+1;
      end if;

      if eval2_rand_rd_en = '1' then
        EVAL_BER2_RAND_COUNTER <= EVAL_BER2_RAND_COUNTER+1;
      end if;

      if final_rand_rd_en = '1' then
        EVAL_FINAL_RAND_COUNTER <= EVAL_FINAL_RAND_COUNTER+1;
      end if;

      -------------------------------------------------------------------------------
      -------------------------------------------------------------------------------

      if uni_wr_en='1' then
        EVAL_UNIFORM_OUTPUT_COUNTER <= EVAL_UNIFORM_OUTPUT_COUNTER+1;
      end if;

      if sigma2_plus_wr_en ='1' then
        EVAL_SIGMA2_PLUS_OUTPUT_COUNTER <= EVAL_SIGMA2_PLUS_OUTPUT_COUNTER+1;
      end if;

        if  eval_z_wr_en= '1' then
        EVAL_BER1_OUTPUT_COUNTER <= EVAL_BER1_OUTPUT_COUNTER+1;
      end if;

      if eval2_z_wr_en= '1' then
        EVAL_BER2_OUTPUT_COUNTER <= EVAL_BER2_OUTPUT_COUNTER+1;
      end if;

      if final_gauss_wr_en= '1' then
        EVAL_FINAL_OUTPUT_COUNTER <= EVAL_FINAL_OUTPUT_COUNTER+1;
      end if;
    end if;
  end process;
-- synthesis translate_on

  

  process (clk)
  begin
    if rising_edge(clk) then
      rst         <= '0';
      rst2        <= '0';
      rand_wr_en  <= '0';
      rand2_wr_en <= '0';

      if RAND_full = '0' then
        rand_wr_en                 <= '1';
        trivium1_clk_en            <= '1';
        rand_din(0)                <= z;
        EVAL_TRIVIUM1_RAND_COUNTER <= EVAL_TRIVIUM1_RAND_COUNTER+1;
      else
        trivium1_clk_en <= '0';
      end if;

      if RAND2_full = '0' then
        rand2_wr_en                <= '1';
        rand2_din(0)               <= z2;
        trivium2_clk_en            <= '1';
        EVAL_TRIVIUM2_RAND_COUNTER <= EVAL_TRIVIUM2_RAND_COUNTER+1;
      else
        trivium2_clk_en <= '0';
      end if;

    end if;
  end process;

  trivium_1 : entity work.trivium
    port map (
      clk    => clk,
      clk_en => trivium1_clk_en,
      rst    => rst,
      key    => key,
      IV     => IV,
      o_vld  => o_vld,
      z      => z
      );


  trivium_2 : entity work.trivium
    port map (
      clk    => clk,
      clk_en => trivium2_clk_en,
      rst    => rst2,
      key    => key2,
      IV     => IV2,
      o_vld  => o_vld2,
      z      => z2
      );


  rand_lifo_1 : entity work.lifo_1_to_n
    generic map (
      OUT_PORTS => RAND_LIFO_OUT_PORTS,
      WIDTH     => RAND_LIFO_WIDTH,
      DEPTH     => 16
      )
    port map (
      clk          => clk,
      din          => rand_din,
      wr_en        => rand_wr_en,
      almost_full  => rand_full,
      rd_en        => rand_rd_en,
      dout         => rand_dout,
      almost_empty => rand_empty,
      valid        => rand_valid
      );


  rand_lifo_2 : entity work.lifo_1_to_n
    generic map (
      OUT_PORTS => RAND2_LIFO_OUT_PORTS,
      WIDTH     => RAND2_LIFO_WIDTH,
      DEPTH     => 16
      )
    port map (
      clk          => clk,
      din          => rand2_din,
      wr_en        => rand2_wr_en,
      almost_full  => rand2_full,
      rd_en        => rand2_rd_en,
      dout         => rand2_dout,
      almost_empty => rand2_empty,
      valid        => rand2_valid
      );



  rand_rd_en(RAND_D_SIGMA_PLUS) <= sigma2_plus_rd_en;
  sigma2_plus_din               <= rand_dout(RAND_D_SIGMA_PLUS);
  sigma2_plus_empty             <= rand_empty(RAND_D_SIGMA_PLUS);
  sigma2_plus_rnd_valid <= rand_valid(RAND_D_SIGMA_PLUS);

  rand_rd_en(RAND_UNIFORM) <= uni_rand_rd_en;
  uni_rand_din             <= rand_dout(RAND_UNIFORM);
  uni_rand_empty           <= rand_empty(RAND_UNIFORM);
  uni_rand_valid           <= rand_valid(RAND_UNIFORM);



  rand2_rd_en(RAND_EVAL) <= eval_rand_rd_en;
  eval_rand_din          <= rand2_dout(RAND_EVAL);
  eval_rand_empty        <= rand2_empty(RAND_EVAL);
  eval_rand_valid        <= rand2_valid(RAND_EVAL);


  rand2_rd_en(RAND_EVAL2) <= eval2_rand_rd_en;
  eval2_rand_din          <= rand2_dout(RAND_EVAL2);
  eval2_rand_empty        <= rand2_empty(RAND_EVAL2);
  eval2_rand_valid        <= rand2_valid(RAND_EVAL2);


  rand2_rd_en(RAND_FINAL) <= final_rand_rd_en;
  final_rand_din          <= rand2_dout(RAND_FINAL);
  final_rand_empty        <= rand2_empty(RAND_FINAL);
  final_rand_valid        <= rand2_valid(RAND_FINAL);





  d_sigma2_plus_1 : entity work.d_sigma2_plus
    generic map (
      MAX_X => MAX_X
      )
    port map (
      clk   => clk,
      --Randomness
      valid => sigma2_plus_rnd_valid,
      rd_en => sigma2_plus_rd_en,
      din   => sigma2_plus_din,
      empty => sigma2_plus_empty,
      --Output
      wr_en => sigma2_plus_wr_en,
      dout  => sigma2_plus_dout,
      full  => sigma2_plus_full
      );

  --Connect the output of the sigma2_plus sampler to the input of the LIFO1
  lifo1_wr_en      <= sigma2_plus_wr_en;
  sigma2_plus_full <= lifo1_full;
  lifo1_din        <= sigma2_plus_dout;

  --XXX TODO: make this a normal LIFO (not 1 to n). Has just one output port.
  lifo_1_to_n_1 : entity work.lifo_1_to_n
    generic map (
      OUT_PORTS => LIFO1_OUT_PORTS,
      WIDTH     => LIFO1_WIDTH,
      DEPTH     => 8
      )
    port map (
      clk          => clk,
      --Input
      din          => lifo1_din,
      wr_en        => lifo1_wr_en,
      almost_full  => lifo1_full,
      --Output
      rd_en        => lifo1_rd_en,
      dout         => lifo1_dout,
      almost_empty => lifo1_empty,
      valid        => lifo1_valid
      );

  uniform_sampler_1 : entity work.uniform_sampler
    generic map (
      MAX_PREC => MAX_PREC,
      CONST_K  => CONST_K,
      MAX_X    => MAX_X
      )
    port map (
      clk        => clk,
      rand_rd_en => uni_rand_rd_en,
      rand_din   => uni_rand_din,
      rand_empty => uni_rand_empty,
      rand_valid => uni_rand_valid,
      dout       => uni_dout,
      full       => uni_full,
      wr_en      => uni_wr_en
      );

  gen_lifo_1 : entity work.gen_lifo
    generic map (
      WIDTH => uni_dout'length,
      DEPTH => 8
      )
    port map (
      clk          => clk,
      srst         => '0',
      din          => uni_dout,
      wr_en        => uni_wr_en,
      almost_full  => uni_full,
      rd_en        => ber_comp_y_rd_en,
      dout         => ber_comp_y_val,
      almost_empty => ber_comp_y_empty,
      valid        => ber_comp_y_valid,
      data_count   => open
      );


  lifo1_rd_en(0)   <= ber_comp_x_rd_en;
  ber_comp_x_empty <= lifo1_empty(0);
  ber_comp_x_valid <= lifo1_valid(0);
  ber_comp_x_val   <= lifo1_dout(ber_comp_x_val'length-1 downto 0);
  compute_input_bernoulli_1 : entity work.compute_input_bernoulli
    generic map (
      MAX_PREC => MAX_PREC,
      CONST_K  => CONST_K,
      MAX_X    => MAX_X
      )
    port map (
      clk            => clk,
      x_rd_en        => ber_comp_x_rd_en,
      x_empty        => ber_comp_x_empty ,
      x_valid        => ber_comp_x_valid ,
      x_val          => ber_comp_x_val ,
      y_rd_en        => ber_comp_y_rd_en,
      y_empty        => ber_comp_y_empty,
      y_valid        => ber_comp_y_valid,
      y_val          => ber_comp_y_val,
      fifo_ber_full  => ber_comp_fifo_ber_full,
      fifo_ber_wr_en => ber_comp_fifo_ber_wr_en,
      fifo_ber_out   => ber_comp_fifo_ber_out,
      fifo_z_full    => ber_comp_fifo_z_full,
      fifo_z_wr_en   => ber_comp_fifo_z_wr_en,
      fifo_z_out     => ber_comp_fifo_z_out
      );


  lifo2_din              <= ber_comp_fifo_ber_out & ber_comp_fifo_z_out;
  lifo2_wr_en            <= ber_comp_fifo_ber_wr_en or ber_comp_fifo_z_wr_en;
  ber_comp_fifo_z_full   <= lifo2_full;
  ber_comp_fifo_ber_full <= lifo2_full;
  lifo_1_to_n_2 : entity work.lifo_1_to_n
    generic map (
      OUT_PORTS => LIFO2_OUT_PORTS,
      WIDTH     => lifo2_din'length,
      DEPTH     => 8 
      )
    port map (
      clk         => clk,
      din         => lifo2_din,
      wr_en       => lifo2_wr_en,
      almost_full => lifo2_full,

      rd_en        => lifo2_rd_en,
      dout         => lifo2_dout,
      almost_empty => lifo2_empty,
      valid        => lifo2_valid
      );


  eval_fifo_z_in      <= lifo2_dout(ber_comp_fifo_z_out'length-1 downto 0);
  eval_fifo_ber_in    <= lifo2_dout(ber_comp_fifo_z_out'length+ ber_comp_fifo_ber_out'length-1 downto ber_comp_fifo_z_out'length);
  lifo2_rd_en(0)      <= eval_fifo_ber_rd_en and eval_fifo_z_rd_en;
  eval_fifo_ber_valid <= lifo2_valid(0);
  eval_fifo_z_valid   <= lifo2_valid(0);
  eval_fifo_ber_empty <= lifo2_empty(0);
  eval_fifo_z_empty   <= lifo2_empty(0);

  ber_eval_1 : entity work.ber_eval
    generic map (
     PARAM_SET => PARAMETER_SET,
      MAX_PREC => MAX_PREC,
      CONST_K  => CONST_K,
      MAX_X    => MAX_X
      )
    port map (
      clk            => clk,
      rand_rd_en     => eval_rand_rd_en,
      rand_din       => eval_rand_din,
      rand_empty     => eval_rand_empty,
      rand_valid     => eval_rand_valid,
      fifo_ber_empty => eval_fifo_ber_empty,
      fifo_ber_rd_en => eval_fifo_ber_rd_en,
      fifo_ber_valid => eval_fifo_ber_valid,
      fifo_ber_in    => eval_fifo_ber_in,
      fifo_z_empty   => eval_fifo_z_empty,
      fifo_z_rd_en   => eval_fifo_z_rd_en,
      fifo_z_valid   => eval_fifo_z_valid,
      fifo_z_in      => eval_fifo_z_in,
      z_dout         => eval_z_dout,
      z_full         => eval_z_full,
      z_wr_en        => eval_z_wr_en
      );


  eval2_fifo_z_in      <= lifo2_dout(lifo2_dout'length/2+ber_comp_fifo_z_out'length-1 downto lifo2_dout'length/2);
  eval2_fifo_ber_in    <= lifo2_dout(lifo2_dout'length/2+ber_comp_fifo_z_out'length+ ber_comp_fifo_ber_out'length-1 downto ber_comp_fifo_z_out'length+lifo2_dout'length/2);
  lifo2_rd_en(1)       <= eval2_fifo_ber_rd_en and eval2_fifo_z_rd_en;
  eval2_fifo_ber_valid <= lifo2_valid(1);
  eval2_fifo_z_valid   <= lifo2_valid(1);
  eval2_fifo_ber_empty <= lifo2_empty(1);
  eval2_fifo_z_empty   <= lifo2_empty(1);
  ber_eval_2 : entity work.ber_eval
    generic map (
           PARAM_SET => PARAMETER_SET,
      MAX_PREC => MAX_PREC,
      CONST_K  => CONST_K,
      MAX_X    => MAX_X)
    port map (
      clk            => clk,
      rand_rd_en     => eval2_rand_rd_en,
      rand_din       => eval2_rand_din,
      rand_empty     => eval2_rand_empty,
      rand_valid     => eval2_rand_valid,
      fifo_ber_empty => eval2_fifo_ber_empty,
      fifo_ber_rd_en => eval2_fifo_ber_rd_en,
      fifo_ber_valid => eval2_fifo_ber_valid,
      fifo_ber_in    => eval2_fifo_ber_in,
      fifo_z_empty   => eval2_fifo_z_empty,
      fifo_z_rd_en   => eval2_fifo_z_rd_en,
      fifo_z_valid   => eval2_fifo_z_valid,
      fifo_z_in      => eval2_fifo_z_in,
      z_dout         => eval2_z_dout,
      z_full         => eval2_z_full,
      z_wr_en        => eval2_z_wr_en
      );



  lifo3_din    <= eval2_z_dout & eval_z_dout;
  lifo3_wr_en  <= eval2_z_wr_en & eval_z_wr_en;
  eval_z_full  <= lifo3_almost_full(0);
  eval2_z_full <= lifo3_almost_full(1);

  lifo_n_to_1_1 : entity work.lifo_n_to_1
    generic map (
      OUT_PORTS => 2,
      WIDTH     => eval_z_dout'length,
      DEPTH     => 8
      )
    port map (
      clk          => clk,
      din          => lifo3_din,
      wr_en        => lifo3_wr_en,
      full         => lifo3_full,
      almost_full  => lifo3_almost_full,
      rd_en        => lifo3_rd_en,
      dout         => lifo3_dout,
      empty        => lifo3_empty,
      almost_empty => lifo3_almost_empty,
      valid        => lifo3_valid
      );

  z_sampler_1 : entity work.z_sampler
    generic map (
      MAX_PREC => MAX_PREC,
      CONST_K  => CONST_K,
      MAX_X    => MAX_X
      )
    port map (
      clk        => clk,
      rand_rd_en => final_rand_rd_en,
      rand_din   => final_rand_din,
      rand_empty => final_rand_empty,
      rand_valid => final_rand_valid,

      fifo_z_empty => lifo3_empty,
      fifo_z_rd_en => lifo3_rd_en,
      fifo_z_valid => lifo3_valid,
      fifo_z_in    => lifo3_dout,

      gauss_dout  => final_gauss_dout,
      gauss_full  => final_gauss_full,
      gauss_wr_en => final_gauss_wr_en
      );

  --assert to_integer(unsigned(final_gauss_dout))/=-109 and final_gauss_wr_en='1' report "109";
  
  gauss_fifo_wr_en <= final_gauss_wr_en;
  gauss_fifo_dout  <= std_logic_vector(resize(signed(final_gauss_dout),gauss_fifo_dout'length));
  final_gauss_full <= gauss_fifo_full;

end Behavioral;

