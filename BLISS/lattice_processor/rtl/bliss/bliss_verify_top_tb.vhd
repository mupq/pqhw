--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/

--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:02:03 03/01/2014
-- Design Name:   
-- Module Name:   C:/Users/thomas/SHA/Projekte/BLISS/code/bliss_arithmetic/lattice_processor/bliss_verify_top_tb.vhd
-- Project Name:  lattice_processor
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: bliss_verify_top
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
use ieee.math_real.all;
use work.lattice_processor.all;
use work.lyu512_pkg.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

entity bliss_verify_top_tb is
  generic (
    NUMBER_OF_SAMPLERS : integer := 2;
    KECCAK_SLICES      : integer := 16;
    CORES              : integer := 8;

    -- DO NOT TOUCH ----------------------------------------------------------
    --------------------------General -----------------------------------------
    RAM_DEPTH        : integer               := 64;
    NUMBER_OF_BLOCKS : integer               := 16;
    N_ELEMENTS       : integer               := 512;
    PRIME_P_WIDTH    : integer               := 14;
    PRIME_P          : unsigned              := to_unsigned(12289, 14);
    -----------------------  Sparse Mul Core ----------------------------------
    KAPPA            : integer               := 23;
    HASH_BLOCKS      : integer               := 4;
    HASH_WIDTH       : integer               := 64;
    --------------------------General --------------------------------------
    GAUSS_S_MAX      : unsigned              := to_unsigned(24, 5);
    ZETA             : unsigned              := to_unsigned(6145, 13);
    D_BLISS          : integer               := 10;
    MODULUS_P_BLISS  : unsigned              := to_unsigned(24, 5);
    -----------------------  Sparse Mul Core ------------------------------------------
    WIDTH_S1         : integer               := 2;
    WIDTH_S2         : integer               := 3;
    --Used to initialize the right s (s1 or s2)   
    INIT_TABLE       : integer               := 0;
    USE_MOCKUP       : integer               := 0;
    c_delay          : integer range 0 to 16 := 2;
    ---------------------------------------------------------------------------
    MAX_RES_WIDTH    : integer               := 6
    );
end bliss_verify_top_tb;

architecture behavior of bliss_verify_top_tb is

  type ram_type is array (0 to 512-1) of integer;
  type ram_type_c is array (0 to 23-1) of integer;

  signal z1 : ram_type := (-79, 123, -365, -424, -24, -170, -208, 73, -159, -86, 2, 208, 530, 62, 210, -164, -408, 96, 9, -245, 103, 2, 222, -7, 479, -84, -207, -88, -358, 25, -207, 285, -298, -273, -158, 139, 75, -199, -325, 13, -122, 105, 517, 10, 34, -286, -161, 140, -439, 332, -254, 97, -61, 200, 305, 445, 162, 43, -152, -199, -107, 279, -116, -302, -64, 13, -206, -116, 74, -527, 83, -15, -149, -73, 599, -204, -53, 261, 215, -186, 27, -387, -51, -208, 369, -81, 83, 24, -247, 0, -160, 338, -39, 99, 60, -165, -206, -498, -485, 192, 79, 288, -14, 40, 435, -351, -88, -136, -157, 148, -325, -252, -64, -533, -13, 48, 124, -93, 201, -241, 532, -274, -448, -590, -46, 73, 107, 69, 255, -307, -69, 334, 356, 139, -257, 159, 89, 202, -385, -10, -262, -46, -171, -214, 355, -83, -127, 279, -251, 6, -57, -190, 444, -184, 168, 440, -411, 291, 74, 172, 117, 373, -140, -69, -39, -169, -518, 40, 63, -167, -44, 70, 90, 226, 654, 319, -146, 65, 151, 76, 109, 258, -94, 177, 32, 233, 167, 183, 119, 199, -349, -141, -4, -211, 222, -195, -128, 202, -267, 227, 141, 121, -172, 262, -44, 109, -54, 51, -255, -45, -18, -413, -128, 167, 86, -18, -317, -161, -97, -339, 270, 52, -64, 55, 137, -144, 173, -143, -215, 57, -599, -321, 131, -113, 344, -161, 240, -4, 58, -52, 217, -34, 142, -49, -262, -56, 155, 162, -117, 104, -375, -79, -245, -163, 100, 114, -106, 266, 128, 286, 152, 140, 302, -332, 43, -96, 93, -250, -321, 199, 410, 229, 21, 184, 29, 150, 391, -79, -651, 228, -100, 107, -169, -233, -824, -123, -170, -256, -244, -182, 191, 433, -46, -91, 147, 293, -56, -69, 147, 23, 438, 154, -307, -11, 39, -341, 65, -39, 16, 37, -66, -358, -81, -36, -243, -161, -227, 311, 453, 319, 38, -206, -141, -33, -167, 287, 18, -82, -17, -173, 400, -272, -53, -136, 34, 98, 96, 38, 462, -154, 262, -206, 4, -252, -239, -227, 168, 68, -133, -13, 486, -221, -117, 11, -122, -224, 42, -359, 268, -21, -111, -142, -303, -155, 261, 166, -377, 133, -77, -161, 349, -40, 175, -545, 6, -206, 115, -171, -192, 203, -434, 28, 70, -232, 158, 154, -35, 81, -147, -29, -59, -115, 19, -149, -156, 59, 21, -186, -370, -162, -168, -168, -216, -107, 226, 198, -121, 133, -345, -158, -48, -199, -31, 123, -5, -155, -35, -86, 354, 47, -132, 141, 238, -577, 134, -317, 39, 30, -170, -72, -2, -21, -101, 60, -127, 70, -143, -65, -217, -56, 316, -383, 118, -165, -130, 67, -89, 35, -6, -381, -66, -362, -284, -399, 230, -78, -161, 275, -149, -48, -360, 46, 106, -86, 5, 114, -133, 80, -120, 307, 504, -588, 1, -36, -81, 390, 652, 35, 49, -184, 72, -323, 96, 88, 289, 135, 52, -315, -157, -186, -186, -6, 421, -209, 97, 211, 146, -371, 288, -74, -76, 131, 338, 96, 200, 310, 285, -72, -252, 88, -185, -153);

  signal z2 : ram_type := (0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, -1, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, -1, 0, 0, 0, 0, 1, 0, 0, 0, -1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, -1, 0, 0, 0, 0, 1, 0, 0, 0, -1, 0, 0, -1, 0, 0, 0, -1, 0, -1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, -1, 0, 0, 0, 0, 0, -1, 0, -1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1, 1, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, -1, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1, 0, 0, 1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, -1, 0, 0, 0, 1, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, -1, 0, 0, 0, 1, 0, 0, 0, 0, -1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, -1, 1, -1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, -1, 0, 0, 0, 0, 0, 0, 1, -1, 0, 1, 0);

  signal c : ram_type_c := (100,230,39,151,107,57,8,330,96,231,455,263,122,502,467,459,238,453,195,110,103,353,89);


  signal clk                : std_logic;
  signal ready              : std_logic;
  signal verify             : std_logic;
  signal load_public_key    : std_logic;
  signal signature_verified : std_logic                                                          := '0';
  signal signature_valid    : std_logic                                                          := '0';
  signal signature_invalid  : std_logic                                                          := '0';
  signal ready_message      : std_logic                                                          := '0';
  signal message_finished   : std_logic                                                          := '0';
  signal message_din        : std_logic_vector(HASH_WIDTH-1 downto 0)                            := (others => '0');
  signal message_valid      : std_logic                                                          := '0';
  signal public_key_addr    : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal public_key_data    : std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
  signal sig_delay          : integer                                                            := 1;
  signal c_sig_addr         : std_logic_vector(integer(ceil(log2(real(KAPPA))))-1 downto 0)      := (others => '0');
  signal c_sig_data         : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal z1_sig_data        : std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
  signal z1_sig_addr        : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal z2_sig_data        : std_logic_vector(4 downto 0)                                       := (others => '0');
  signal z2_sig_addr        : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  -- Component Declaration for the Unit Under Test (UUT)



  -- Clock period definitions
  constant clk_period : time := 10 ns;

  constant ADDR_WIDTH : integer := 9;
  constant COL_WIDTH  : integer := PRIME_P_WIDTH;

  signal ram_z1_wea   : std_logic                               := '0';
  signal ram_z1_web   : std_logic                               := '0';
  signal ram_z1_addra : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal ram_z1_addrb : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal ram_z1_dia   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal ram_z1_dib   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal ram_z1_doa   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal ram_z1_dob   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');

  signal ram_z2_wea   : std_logic                               := '0';
  signal ram_z2_web   : std_logic                               := '0';
  signal ram_z2_addra : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal ram_z2_addrb : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal ram_z2_dia   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal ram_z2_dib   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal ram_z2_doa   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal ram_z2_dob   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');

  signal ram_c_wea   : std_logic                               := '0';
  signal ram_c_web   : std_logic                               := '0';
  signal ram_c_addra : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal ram_c_addrb : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal ram_c_dia   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal ram_c_dib   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal ram_c_doa   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal ram_c_dob   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');

  
  
begin

  c_sig_data  <= ram_c_dob(c_sig_data'range);
  ram_c_addrb <= std_logic_vector(resize(unsigned(c_sig_addr),ram_c_addrb'length));

  z1_sig_data  <= std_logic_vector(resize(Signed(ram_z1_dob),z1_sig_data'length));
  ram_z1_addrb <= z1_sig_addr;


  z2_sig_data  <=std_logic_vector(resize(Signed(ram_z2_dob),z2_sig_data'length));
  ram_z2_addrb <= z2_sig_addr;



  bliss_verify_top_1 : entity work.bliss_verify_top
    generic map (
      NUMBER_OF_SAMPLERS => NUMBER_OF_SAMPLERS,
      KECCAK_SLICES      => KECCAK_SLICES,
      CORES              => CORES,
      RAM_DEPTH          => RAM_DEPTH,
      NUMBER_OF_BLOCKS   => NUMBER_OF_BLOCKS,
      N_ELEMENTS         => N_ELEMENTS,
      PRIME_P_WIDTH      => PRIME_P_WIDTH,
      PRIME_P            => PRIME_P,
      KAPPA              => KAPPA,
      HASH_BLOCKS        => HASH_BLOCKS,
      HASH_WIDTH         => HASH_WIDTH,
      GAUSS_S_MAX        => GAUSS_S_MAX,
      ZETA               => ZETA,
      D_BLISS            => D_BLISS,
      MODULUS_P_BLISS    => MODULUS_P_BLISS,
      WIDTH_S1           => WIDTH_S1,
      WIDTH_S2           => WIDTH_S2,
      INIT_TABLE         => INIT_TABLE,
      USE_MOCKUP         => USE_MOCKUP,
      c_delay            => c_delay,
      MAX_RES_WIDTH      => MAX_RES_WIDTH)
    port map (
      clk                => clk,
      ready              => ready,
      verify             => verify,
      load_public_key    => load_public_key,
      signature_verified => signature_verified,
      signature_valid    => signature_valid,
      signature_invalid  => signature_invalid,
      ready_message      => ready_message,
      message_finished   => message_finished,
      message_din        => message_din,
      message_valid      => message_valid,
      public_key_addr    => public_key_addr,
      public_key_data    => public_key_data,
      sig_delay          => sig_delay,
      c_sig_addr         => c_sig_addr,
      c_sig_data         => c_sig_data,
      z1_sig_data        => z1_sig_data,
      z1_sig_addr        => z1_sig_addr,
      z2_sig_data        => z2_sig_data,
      z2_sig_addr        => z2_sig_addr);


  bram_z1 : entity work.bram_with_delay
    generic map (
      SIZE       => N_ELEMENTS,
      ADDR_WIDTH => ADDR_WIDTH,
      COL_WIDTH  => COL_WIDTH,
      add_reg_a  => 0,
      add_reg_b  => 0,
      InitFile   => ""
      )
    port map (
      clka  => clk,
      clkb  => clk,
      ena   => '1',
      enb   => '1',
      wea   => ram_z1_wea,
      web   => ram_z1_web,
      addra => ram_z1_addra,
      addrb => ram_z1_addrb,
      dia   => ram_z1_dia,
      dib   => ram_z1_dib,
      doa   => ram_z1_doa,
      dob   => ram_z1_dob
      );


  
  bram_z2 : entity work.bram_with_delay
    generic map (
      SIZE       => N_ELEMENTS,
      ADDR_WIDTH => ADDR_WIDTH,
      COL_WIDTH  => COL_WIDTH,
      add_reg_a  => 0,
      add_reg_b  => 0,
      InitFile   => ""
      )
    port map (
      clka  => clk,
      clkb  => clk,
      ena   => '1',
      enb   => '1',
      wea   => ram_z2_wea,
      web   => ram_z2_web,
      addra => ram_z2_addra,
      addrb => ram_z2_addrb,
      dia   => ram_z2_dia,
      dib   => ram_z2_dib,
      doa   => ram_z2_doa,
      dob   => ram_z2_dob
      );


  bram_c : entity work.bram_with_delay
    generic map (
      SIZE       => N_ELEMENTS,
      ADDR_WIDTH => ADDR_WIDTH,
      COL_WIDTH  => COL_WIDTH,
      add_reg_a  => 0,
      add_reg_b  => 0,
      InitFile   => ""
      )
    port map (
      clka  => clk,
      clkb  => clk,
      ena   => '1',
      enb   => '1',
      wea   => ram_c_wea,
      web   => ram_c_web,
      addra => ram_c_addra,
      addrb => ram_c_addrb,
      dia   => ram_c_dia,
      dib   => ram_c_dib,
      doa   => ram_c_doa,
      dob   => ram_c_dob
      );

  -- Clock process definitions
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;


  -- Stimulus process
  stim_proc : process
  begin
    -- hold reset state for 100 ns.
    wait for 100 ns;

    --Fill the RAM first with the data
    for i in 0 to 511 loop
      ram_z1_wea <= '1';
      ram_z2_wea <= '1';

      ram_z1_addra <= std_logic_vector(to_unsigned(i, ram_z1_addra'length));
      ram_z2_addra <= std_logic_vector(to_unsigned(i, ram_z1_addra'length));

      ram_z1_dia <= std_logic_vector(to_signed(z1(i), ram_z1_dia'length));
      ram_z2_dia <= std_logic_vector(to_signed(z2(i), ram_z2_dia'length));
      wait for clk_period;
    end loop;  -- i
    ram_z1_wea <= '0';
    ram_z2_wea <= '0';

    --module extracts bits
    for i in 0 to 22 loop
      ram_c_wea   <= '1';
      ram_c_addra <= std_logic_vector(to_unsigned(i, ram_c_addra'length));
      ram_c_dia   <= std_logic_vector(to_unsigned(c(i), ram_c_dia'length));
      wait for clk_period;
    end loop;  -- i
    ram_c_wea <= '0';


    wait for clk_period*1000;

       wait for clk_period;



      wait for clk_period;

    verify <= '1';
        wait for clk_period;
    verify <= '0';
          --Write the message
      for i in 0 to 15 loop
        message_din   <= (others => '1');
        message_valid <= '1';
        wait for clk_period;
      end loop;  -- i
      message_valid <= '0';

      --State that the message is finished
      message_finished <= '1';
      wait for clk_period;
      message_finished <= '0';

    -- insert stimulus here 

    wait;
  end process;

end;
