-- TestBench Template 

--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:41:19 02/14/2014
-- Design Name:   
-- Module Name:   C:/Users/thomas/SHA/Projekte/BLISS/code/bliss_arithmetic/lattice_processor/components/finalization/bench/finalization/bliss_sign_top_tb.vhd
-- Project Name:  lattice_processor
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: bliss_sign_top
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



entity bliss_sign_mockup_tb is
  generic (
    RAM_DEPTH        : integer               := 64;
    NUMBER_OF_BLOCKS : integer               := 16;
    --------------------------General -----------------------------------------
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
    CORES            : integer               := 8;
    WIDTH_S1         : integer               := 2;
    WIDTH_S2         : integer               := 3;
    --Used to initialize the right s (s1 or s2)
    INIT_TABLE       : integer               := 0;
    c_delay          : integer range 0 to 16 := 2;
    USE_MOCKUP       : integer               := 1;
    ---------------------------------------------------------------------------
    MAX_RES_WIDTH    : integer               := 6
    );
  port (
    error_happened_out    : out std_logic := '0';
    end_of_simulation_out : out std_logic := '0'
    );

end bliss_sign_mockup_tb;

architecture behavior of bliss_sign_mockup_tb is

  -- Component Declaration for the Unit Under Test (UUT)
  
  signal clk : std_logic;

  signal end_of_simulation : std_logic := '0';
  signal error_happened    : std_logic := '0';


  signal message_din       : std_logic_vector(HASH_WIDTH-1 downto 0)                            := (others => '0');
  signal message_valid     : std_logic                                                          := '0';
  signal ready             : std_logic;
  signal sign              : std_logic                                                          := '0';
  signal ready_message     : std_logic                                                          := '0';
  signal message_finished  : std_logic                                                          := '0';
  signal stop_engine       : std_logic                                                          := '0';
  signal engine_stoped     : std_logic                                                          := '0';
  signal load_public_key   : std_logic                                                          := '0';
  signal signature_ready   : std_logic                                                          := '0';
  signal signature_valid   : std_logic                                                          := '0';
  signal signature_invalid : std_logic                                                          := '0';
  signal s1_addr           : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal s1_in             : std_logic_vector(WIDTH_S1-1 downto 0)                              := (others => '0');
  signal s1_wr_en          : std_logic                                                          := '0';
  signal s2_addr           : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal s2_in             : std_logic_vector(WIDTH_S2-1 downto 0)                              := (others => '0');
  signal s2_wr_en          : std_logic                                                          := '0';
  signal public_key_addr   : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal public_key_data   : std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
  signal z1_final          : std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
  signal z1_final_addr     : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal z1_final_valid    : std_logic                                                          := '0';
  signal z2_final          : std_logic_vector(MODULUS_P_BLISS'length-1 downto 0)                                       := (others => '0');
  signal z2_final_addr     : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal z2_final_valid    : std_logic                                                          := '0';
  signal final_c_pos       : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal final_c_pos_valid : std_logic                                                          := '0';

  -- Clock period definitions
  constant clk_period : time := 10 ns;

 type ram_type is array (0 to N_ELEMENTS-1) of integer;

  --signal z1_gold : ram_type :=(113, -44, -190, 205, 10, -5, -155, 101, 138, -75, 114, -176, -285, 253, 207, 234, -240, -31, -141, 259, 47, 12, -19, 255, 284, -115, -167, 31, -224, -358, -97, 177, 213, -127, -63, 50, -53, -369, 164, -381, 307, -507, -10, -228, 69, -107, -4, -272, 270, -262, 220, 363, -56, -86, 174, -146, 203, 22, 664, -337, 72, 72, 187, -73, -196, -90, 40, -203, -21, 86, 116, -55, -29, -407, 301, -166, 76, -310, -276, 64, 213, 281, 339, 1, -138, -334, -110, 30, -236, 34, -81, 60, -306, -46, -73, 110, -506, 100, -66, 228, 309, 13, 170, -252, 64, -265, -41, -54, -302, 20, -115, -54, 283, 228, -70, 55, -105, -153, 148, -8, -363, -92, 244, 109, 159, -487, -346, -137, -148, -401, 96, 75, -313, 6, -42, -131, -158, -209, -141, 102, 7, -236, 48, 25, 141, 46, 124, 298, -63, 196, -176, 60, 249, 111, 170, -128, -53, -97, -210, -229, -47, -333, -310, 146, -24, -93, -135, 110, -346, 79, 491, -322, 41, 270, 49, 97, -262, -279, 224, 238, 350, 103, 57, -227, 274, 79, -30, 257, 395, -597, 414, -383, -152, 133, -525, -249, -2, -141, 1, 500, -96, -117, 289, -154, -39, -105, -52, 25, -109, -32, -283, -29, 191, -62, -30, -166, 289, 4, 172, 109, 87, -214, -7, -378, 10, -124, 183, -417, 55, 42, -183, -175, 34, 400, 25, 112, 259, -297, 0, 228, 233, 299, -55, 373, -97, -28, -124, 7, 475, 63, 136, -181, 12, -153, 40, 193, -131, 327, -58, 160, -59, 212, -15, -61, -214, 69, -117, -246, 280, 188, -68, -119, 441, 275, -54, -244, 308, -118, 431, -151, 16, 41, 168, -13, -460, -6, -19, -2, -76, -430, 147, -60, -122, 18, 188, -1, -23, -387, 34, 38, -283, -131, -204, -164, 431, -213, -118, 362, 134, -43, 181, 120, 387, -148, 131, -40, -53, 208, 123, -9, -539, 189, 223, -311, -123, 47, -102, 364, 16, -30, -326, -27, 96, -309, 241, -246, -284, 414, -71, -13, 303, -9, -240, 104, -323, 192, 85, 221, 242, -280, -42, 68, 304, -227, 44, 82, 169, 182, -71, -389, 250, -7, -129, -376, -242, 422, -120, -243, 153, -109, -65, -105, 178, -196, -40, -176, -128, 138, 421, 127, -563, 149, 22, -208, -272, 268, 408, 106, 305, 509, -129, -136, 307, 167, 60, 47, -93, 201, -250, -107, -222, 99, -240, -294, 163, -514, 333, 496, -235, 285, 174, 34, -242, 42, -155, 26, 208, -27, -170, -349, 226, -254, -481, 294, -231, -139, 150, 33, -204, -53, -226, 293, -42, -387, -378, 54, -502, -32, 325, 15, -461, 207, 23, -291, 191, 250, 114, 231, 132, 291, -106, 17, 339, -183, 362, 88, 130, 35, -178, 195, -109, -15, 616, 300, -54, 2, -414, 126, -522, -65, -187, 312, 6, -22, -136, -146, -314, -36, 120, 93, -471, -31, 339, 160, -79, 59, 242, 266, -38, 26, -339, -26, -69, -167, 254, -81, 123, -101, 156, -165, 55, -45, -531, 438, 317, -125, 276, -217, -227, -23, 162, 34);


  signal z1_gold : ram_type :=(-79,123,-365,-424,-24,-170,-208,73,-159,-86,2,208,530,62,210,-164,-408,96,9,-245,103,2,222,-7,479,-84,-207,-88,-358,25,-207,285,-298,-273,-158,139,75,-199,-325,13,-122,105,517,10,34,-286,-161,140,-439,332,-254,97,-61,200,305,445,162,43,-152,-199,-107,279,-116,-302,-64,13,-206,-116,74,-527,83,-15,-149,-73,599,-204,-53,261,215,-186,27,-387,-51,-208,369,-81,83,24,-247,0,-160,338,-39,99,60,-165,-206,-498,-485,192,79,288,-14,40,435,-351,-88,-136,-157,148,-325,-252,-64,-533,-13,48,124,-93,201,-241,532,-274,-448,-590,-46,73,107,69,255,-307,-69,334,356,139,-257,159,89,202,-385,-10,-262,-46,-171,-214,355,-83,-127,279,-251,6,-57,-190,444,-184,168,440,-411,291,74,172,117,373,-140,-69,-39,-169,-518,40,63,-167,-44,70,90,226,654,319,-146,65,151,76,109,258,-94,177,32,233,167,183,119,199,-349,-141,-4,-211,222,-195,-128,202,-267,227,141,121,-172,262,-44,109,-54,51,-255,-45,-18,-413,-128,167,86,-18,-317,-161,-97,-339,270,52,-64,55,137,-144,173,-143,-215,57,-599,-321,131,-113,344,-161,240,-4,58,-52,217,-34,142,-49,-262,-56,155,162,-117,104,-375,-79,-245,-163,100,114,-106,266,128,286,152,140,302,-332,43,-96,93,-250,-321,199,410,229,21,184,29,150,391,-79,-651,228,-100,107,-169,-233,-824,-123,-170,-256,-244,-182,191,433,-46,-91,147,293,-56,-69,147,23,438,154,-307,-11,39,-341,65,-39,16,37,-66,-358,-81,-36,-243,-161,-227,311,453,319,38,-206,-141,-33,-167,287,18,-82,-17,-173,400,-272,-53,-136,34,98,96,38,462,-154,262,-206,4,-252,-239,-227,168,68,-133,-13,486,-221,-117,11,-122,-224,42,-359,268,-21,-111,-142,-303,-155,261,166,-377,133,-77,-161,349,-40,175,-545,6,-206,115,-171,-192,203,-434,28,70,-232,158,154,-35,81,-147,-29,-59,-115,19,-149,-156,59,21,-186,-370,-162,-168,-168,-216,-107,226,198,-121,133,-345,-158,-48,-199,-31,123,-5,-155,-35,-86,354,47,-132,141,238,-577,134,-317,39,30,-170,-72,-2,-21,-101,60,-127,70,-143,-65,-217,-56,316,-383,118,-165,-130,67,-89,35,-6,-381,-66,-362,-284,-399,230,-78,-161,275,-149,-48,-360,46,106,-86,5,114,-133,80,-120,307,504,-588,1,-36,-81,390,652,35,49,-184,72,-323,96,88,289,135,52,-315,-157,-186,-186,-6,421,-209,97,211,146,-371,288,-74,-76,131,338,96,200,310,285,-72,-252,88,-185,-153);

  --signal z2_gold : ram_type :=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1, 0, 0, 1, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, -1, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, -1, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 1, 0, 0, -1, 0, 1, 0, -1, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 1, 0, -1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, -1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, -1, 0, 0, 1, 0, 0, 0, 0, -1, 1, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, -1, -1, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, -1, -1, 0, 0, 0, 0, 0, 0, 0, -1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, -1, 0, 0, 1, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, -1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 1, 0, -1, 0, 0, -1, 0, 0, 0, 0, 0, 0, -1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0);


  signal z2_gold : ram_type :=(0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,-1,0,0,0,-1,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,1,1,0,1,0,0,1,0,0,0,-1,0,0,0,0,0,0,0,0,-1,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,1,0,0,0,0,0,0,0,-1,0,0,-1,0,0,0,0,1,0,0,0,-1,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,-1,1,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,-1,0,0,0,0,1,0,0,0,-1,0,0,-1,0,0,0,-1,0,-1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,-1,0,0,0,0,0,-1,0,-1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,1,0,0,0,0,0,0,-1,0,0,0,0,1,1,0,0,0,0,0,0,1,0,0,-1,0,0,0,0,0,0,0,0,0,0,1,-1,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,1,0,0,1,-1,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,1,0,0,0,0,0,-1,0,0,0,1,0,-1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,-1,0,0,0,1,0,0,0,0,-1,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,-1,0,0,0,0,-1,1,-1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,-1,0,0,0,0,0,0,1,-1,0,1,0);
  
begin

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
  end_of_simulation_out <= end_of_simulation;




  bliss_sign_top_1 : entity work.bliss_sign_top
    generic map (
      RAM_DEPTH        => RAM_DEPTH,
      NUMBER_OF_BLOCKS => NUMBER_OF_BLOCKS,
      N_ELEMENTS       => N_ELEMENTS,
      PRIME_P_WIDTH    => PRIME_P_WIDTH,
      PRIME_P          => PRIME_P,
      KAPPA            => KAPPA,
      HASH_BLOCKS      => HASH_BLOCKS,
      HASH_WIDTH       => HASH_WIDTH,
      GAUSS_S_MAX      => GAUSS_S_MAX,
      ZETA             => ZETA,
      D_BLISS          => D_BLISS,
      MODULUS_P_BLISS  => MODULUS_P_BLISS,
      CORES            => CORES,
      WIDTH_S1         => WIDTH_S1,
      WIDTH_S2         => WIDTH_S2,
      INIT_TABLE       => INIT_TABLE,
      USE_MOCKUP       => USE_MOCKUP,
      c_delay          => c_delay,
      MAX_RES_WIDTH    => MAX_RES_WIDTH)
    port map (
      clk               => clk,
      ready             => ready,
      sign              => sign,
      final_c_pos       => final_c_pos,
      final_c_pos_valid => final_c_pos_valid,
      ready_message     => ready_message,
      message_finished  => message_finished,
      message_din       => message_din ,
      message_valid     => message_valid,
      stop_engine       => stop_engine,
      engine_stoped     => engine_stoped,
      load_public_key   => load_public_key,
      signature_ready   => signature_ready,
      signature_valid   => signature_valid,
      signature_invalid => signature_invalid,
      s1_addr           => s1_addr,
      s1_in             => s1_in,
      s1_wr_en          => s1_wr_en,
      s2_addr           => s2_addr,
      s2_in             => s2_in,
      s2_wr_en          => s2_wr_en,
      public_key_addr   => public_key_addr,
      public_key_data   => public_key_data,
      z1_final          => z1_final,
      z1_final_addr     => z1_final_addr,
      z1_final_valid    => z1_final_valid,
      z2_final          => z2_final,
      z2_final_addr     => z2_final_addr,
      z2_final_valid    => z2_final_valid);




  process(clk)
  begin  -- process
    if rising_edge(clk) then
      if z1_final_valid='1' then
        if z1_gold(to_integer(unsigned(z1_final_addr))) /= to_integer(signed(z1_final)) then
          error_happened <= '1';
        end if;
      end if;

      if z2_final_valid='1' then
        if z2_gold(to_integer(unsigned(z2_final_addr))) /= to_integer(signed(z2_final)) then
          error_happened <= '1';
        end if;
      end if;
      
    end if;
  end process;

  -- Stimulus process
  stim_proc : process
  begin
    -- hold reset state for 100 ns.
    wait for 100 ns;

    wait for clk_period*100;

    wait for clk_period*25000;




    while ready_message = '0' loop
      wait for clk_period;
    end loop;

    wait for clk_period;

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

    wait for clk_period*10;
    sign <= '1';
    wait for clk_period;
    sign <= '0';
    wait for clk_period*10;

    while signature_ready = '0' loop
      wait for clk_period;
    end loop;



    wait for clk_period*500000;


    if error_happened = '1' then
      report "ERROR";
    else
      report "OK";
    end if;

    end_of_simulation <= '1';
    wait;

  end process;

  
end;
