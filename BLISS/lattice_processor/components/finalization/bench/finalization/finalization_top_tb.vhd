--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/

-- TestBench Template 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity finalization_top_tb is
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
    ---------------------------------------------------------------------------
    MAX_RES_WIDTH    : integer               := 6
    );
  port (
    error_happened_out    : out std_logic := '0';
    end_of_simulation_out : out std_logic := '0'
    );
end finalization_top_tb;

architecture behavior of finalization_top_tb is
  signal end_of_simulation : std_logic := '0';
  signal error_happened    : std_logic := '0';

  signal clk              : std_logic;
  signal start            : std_logic                                                          := '0';
  signal ready            : std_logic                                                          := '0';
  signal ready_message    : std_logic                                                          := '0';
  signal message_finished : std_logic                                                          := '0';
  signal message_din      : std_logic_vector(HASH_WIDTH-1 downto 0)                            := (others => '0');
  signal message_valid    : std_logic                                                          := '0';
  signal s1_addr          : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal s1_in            : std_logic_vector(WIDTH_S1-1 downto 0)                              := (others => '0');
  signal s1_wr_en         : std_logic                                                          := '0';
  signal s2_addr          : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal s2_in            : std_logic_vector(WIDTH_S2-1 downto 0)                              := (others => '0');
  signal s2_wr_en         : std_logic                                                          := '0';
  signal coeff_sc1_out    : std_logic_vector(MAX_RES_WIDTH-1 downto 0)                         := (others => '0');
  signal coeff_sc1_addr   : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal coeff_sc1_valid  : std_logic                                                          := '0';
  signal coeff_sc2_out    : std_logic_vector(MAX_RES_WIDTH-1 downto 0)                         := (others => '0');
  signal coeff_sc2_addr   : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal coeff_sc2_valid  : std_logic                                                          := '0';
  signal addr_in          : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal data_in          : std_logic_vector(PRIME_P'length-1 downto 0)                        := (others => '0');
  signal ay1_wr_en        : std_logic                                                          := '0';
  signal y1_wr_en         : std_logic                                                          := '0';
  signal y2_wr_en         : std_logic                                                          := '0';

  constant clk_period    : time    := 10 ns;
  signal   cycle_counter : integer := 0;
  type     ram_type is array (0 to N_ELEMENTS-1) of unsigned(32-1 downto 0);

  signal ay : ram_type := (to_unsigned(807, 32), to_unsigned(2226, 32), to_unsigned(4754, 32), to_unsigned(5272, 32), to_unsigned(10692, 32), to_unsigned(695, 32), to_unsigned(8110, 32), to_unsigned(1675, 32), to_unsigned(8121, 32), to_unsigned(2949, 32), to_unsigned(4442, 32), to_unsigned(7176, 32), to_unsigned(10192, 32), to_unsigned(6617, 32), to_unsigned(8573, 32), to_unsigned(2801, 32), to_unsigned(1588, 32), to_unsigned(6402, 32), to_unsigned(1080, 32), to_unsigned(3129, 32), to_unsigned(9284, 32), to_unsigned(3326, 32), to_unsigned(3517, 32), to_unsigned(9775, 32), to_unsigned(193, 32), to_unsigned(6859, 32), to_unsigned(11707, 32), to_unsigned(2365, 32), to_unsigned(5763, 32), to_unsigned(10990, 32), to_unsigned(6130, 32), to_unsigned(1202, 32), to_unsigned(1775, 32), to_unsigned(2794, 32), to_unsigned(3595, 32), to_unsigned(6571, 32), to_unsigned(9869, 32), to_unsigned(6787, 32), to_unsigned(796, 32), to_unsigned(11915, 32), to_unsigned(5695, 32), to_unsigned(906, 32), to_unsigned(1920, 32), to_unsigned(8824, 32), to_unsigned(6317, 32), to_unsigned(10366, 32), to_unsigned(11835, 32), to_unsigned(7560, 32), to_unsigned(6406, 32), to_unsigned(154, 32), to_unsigned(1849, 32), to_unsigned(11775, 32), to_unsigned(2622, 32), to_unsigned(4688, 32), to_unsigned(748, 32), to_unsigned(12203, 32), to_unsigned(11245, 32), to_unsigned(11356, 32), to_unsigned(10461, 32), to_unsigned(1208, 32), to_unsigned(8504, 32), to_unsigned(7932, 32), to_unsigned(953, 32), to_unsigned(4018, 32), to_unsigned(7197, 32), to_unsigned(9312, 32), to_unsigned(10405, 32), to_unsigned(3706, 32), to_unsigned(2243, 32), to_unsigned(11747, 32), to_unsigned(9206, 32), to_unsigned(7088, 32), to_unsigned(7767, 32), to_unsigned(4148, 32), to_unsigned(5504, 32), to_unsigned(4881, 32), to_unsigned(12228, 32), to_unsigned(9222, 32), to_unsigned(11267, 32), to_unsigned(11703, 32), to_unsigned(12035, 32), to_unsigned(4180, 32), to_unsigned(1656, 32), to_unsigned(4586, 32), to_unsigned(4520, 32), to_unsigned(3629, 32), to_unsigned(6698, 32), to_unsigned(1234, 32), to_unsigned(7323, 32), to_unsigned(1124, 32), to_unsigned(7800, 32), to_unsigned(7778, 32), to_unsigned(3147, 32), to_unsigned(5683, 32), to_unsigned(11338, 32), to_unsigned(808, 32), to_unsigned(12259, 32), to_unsigned(9493, 32), to_unsigned(5885, 32), to_unsigned(9117, 32), to_unsigned(10366, 32), to_unsigned(9323, 32), to_unsigned(11678, 32), to_unsigned(2483, 32), to_unsigned(10629, 32), to_unsigned(2228, 32), to_unsigned(6602, 32), to_unsigned(9122, 32), to_unsigned(8434, 32), to_unsigned(1944, 32), to_unsigned(9712, 32), to_unsigned(6836, 32), to_unsigned(12196, 32), to_unsigned(10364, 32), to_unsigned(7431, 32), to_unsigned(8581, 32), to_unsigned(10032, 32), to_unsigned(10789, 32), to_unsigned(8006, 32), to_unsigned(7048, 32), to_unsigned(648, 32), to_unsigned(5505, 32), to_unsigned(7399, 32), to_unsigned(11415, 32), to_unsigned(9336, 32), to_unsigned(9400, 32), to_unsigned(4917, 32), to_unsigned(10484, 32), to_unsigned(10081, 32), to_unsigned(8972, 32), to_unsigned(2991, 32), to_unsigned(1418, 32), to_unsigned(10627, 32), to_unsigned(1576, 32), to_unsigned(155, 32), to_unsigned(2375, 32), to_unsigned(3576, 32), to_unsigned(2760, 32), to_unsigned(5277, 32), to_unsigned(6743, 32), to_unsigned(1555, 32), to_unsigned(10404, 32), to_unsigned(2084, 32), to_unsigned(571, 32), to_unsigned(12044, 32), to_unsigned(8165, 32), to_unsigned(4721, 32), to_unsigned(6747, 32), to_unsigned(6543, 32), to_unsigned(2890, 32), to_unsigned(1456, 32), to_unsigned(10274, 32), to_unsigned(8219, 32), to_unsigned(5284, 32), to_unsigned(9523, 32), to_unsigned(6439, 32), to_unsigned(9322, 32), to_unsigned(10178, 32), to_unsigned(5791, 32), to_unsigned(7734, 32), to_unsigned(9318, 32), to_unsigned(6195, 32), to_unsigned(1292, 32), to_unsigned(3593, 32), to_unsigned(1425, 32), to_unsigned(2647, 32), to_unsigned(8332, 32), to_unsigned(5900, 32), to_unsigned(7189, 32), to_unsigned(5638, 32), to_unsigned(6928, 32), to_unsigned(10142, 32), to_unsigned(10025, 32), to_unsigned(11823, 32), to_unsigned(10508, 32), to_unsigned(2108, 32), to_unsigned(602, 32), to_unsigned(10427, 32), to_unsigned(2003, 32), to_unsigned(10212, 32), to_unsigned(10722, 32), to_unsigned(11476, 32), to_unsigned(7723, 32), to_unsigned(2936, 32), to_unsigned(1783, 32), to_unsigned(5439, 32), to_unsigned(9029, 32), to_unsigned(1519, 32), to_unsigned(2090, 32), to_unsigned(3685, 32), to_unsigned(1309, 32), to_unsigned(4300, 32), to_unsigned(11649, 32), to_unsigned(666, 32), to_unsigned(1254, 32), to_unsigned(10250, 32), to_unsigned(6897, 32), to_unsigned(8618, 32), to_unsigned(4144, 32), to_unsigned(11003, 32), to_unsigned(2143, 32), to_unsigned(444, 32), to_unsigned(1190, 32), to_unsigned(6046, 32), to_unsigned(946, 32), to_unsigned(3223, 32), to_unsigned(6956, 32), to_unsigned(4369, 32), to_unsigned(1595, 32), to_unsigned(3678, 32), to_unsigned(2446, 32), to_unsigned(3526, 32), to_unsigned(2147, 32), to_unsigned(10368, 32), to_unsigned(220, 32), to_unsigned(4823, 32), to_unsigned(3661, 32), to_unsigned(1544, 32), to_unsigned(6620, 32), to_unsigned(5129, 32), to_unsigned(10306, 32), to_unsigned(8197, 32), to_unsigned(11050, 32), to_unsigned(10812, 32), to_unsigned(5415, 32), to_unsigned(12220, 32), to_unsigned(3493, 32), to_unsigned(212, 32), to_unsigned(9998, 32), to_unsigned(1280, 32), to_unsigned(8254, 32), to_unsigned(5457, 32), to_unsigned(2756, 32), to_unsigned(9860, 32), to_unsigned(9093, 32), to_unsigned(6089, 32), to_unsigned(8886, 32), to_unsigned(108, 32), to_unsigned(8489, 32), to_unsigned(11603, 32), to_unsigned(7725, 32), to_unsigned(1353, 32), to_unsigned(5913, 32), to_unsigned(743, 32), to_unsigned(6899, 32), to_unsigned(10318, 32), to_unsigned(4174, 32), to_unsigned(747, 32), to_unsigned(2158, 32), to_unsigned(8558, 32), to_unsigned(7368, 32), to_unsigned(6893, 32), to_unsigned(9850, 32), to_unsigned(8848, 32), to_unsigned(1805, 32), to_unsigned(7278, 32), to_unsigned(6931, 32), to_unsigned(7212, 32), to_unsigned(907, 32), to_unsigned(9726, 32), to_unsigned(7538, 32), to_unsigned(11374, 32), to_unsigned(3264, 32), to_unsigned(9188, 32), to_unsigned(3327, 32), to_unsigned(3794, 32), to_unsigned(9730, 32), to_unsigned(7506, 32), to_unsigned(11176, 32), to_unsigned(8167, 32), to_unsigned(2507, 32), to_unsigned(7753, 32), to_unsigned(2719, 32), to_unsigned(2500, 32), to_unsigned(3750, 32), to_unsigned(2879, 32), to_unsigned(5853, 32), to_unsigned(12003, 32), to_unsigned(10631, 32), to_unsigned(8663, 32), to_unsigned(10322, 32), to_unsigned(12151, 32), to_unsigned(9349, 32), to_unsigned(3599, 32), to_unsigned(11146, 32), to_unsigned(8994, 32), to_unsigned(11904, 32), to_unsigned(11611, 32), to_unsigned(10352, 32), to_unsigned(10109, 32), to_unsigned(5477, 32), to_unsigned(3636, 32), to_unsigned(11754, 32), to_unsigned(8119, 32), to_unsigned(7336, 32), to_unsigned(12054, 32), to_unsigned(3100, 32), to_unsigned(8647, 32), to_unsigned(182, 32), to_unsigned(7462, 32), to_unsigned(3226, 32), to_unsigned(9670, 32), to_unsigned(3941, 32), to_unsigned(188, 32), to_unsigned(2476, 32), to_unsigned(9564, 32), to_unsigned(2801, 32), to_unsigned(2380, 32), to_unsigned(83, 32), to_unsigned(10683, 32), to_unsigned(269, 32), to_unsigned(6323, 32), to_unsigned(6799, 32), to_unsigned(11438, 32), to_unsigned(5928, 32), to_unsigned(6151, 32), to_unsigned(11715, 32), to_unsigned(7737, 32), to_unsigned(5663, 32), to_unsigned(9199, 32), to_unsigned(956, 32), to_unsigned(4138, 32), to_unsigned(6532, 32), to_unsigned(5859, 32), to_unsigned(10538, 32), to_unsigned(1866, 32), to_unsigned(1608, 32), to_unsigned(11362, 32), to_unsigned(1097, 32), to_unsigned(377, 32), to_unsigned(12261, 32), to_unsigned(5833, 32), to_unsigned(7711, 32), to_unsigned(6421, 32), to_unsigned(4464, 32), to_unsigned(4513, 32), to_unsigned(3317, 32), to_unsigned(11240, 32), to_unsigned(3725, 32), to_unsigned(9298, 32), to_unsigned(8033, 32), to_unsigned(3957, 32), to_unsigned(7789, 32), to_unsigned(5800, 32), to_unsigned(1076, 32), to_unsigned(8827, 32), to_unsigned(9914, 32), to_unsigned(9725, 32), to_unsigned(2868, 32), to_unsigned(5117, 32), to_unsigned(4876, 32), to_unsigned(3211, 32), to_unsigned(3573, 32), to_unsigned(9112, 32), to_unsigned(5498, 32), to_unsigned(11182, 32), to_unsigned(5341, 32), to_unsigned(11887, 32), to_unsigned(978, 32), to_unsigned(7849, 32), to_unsigned(1238, 32), to_unsigned(11214, 32), to_unsigned(6325, 32), to_unsigned(7646, 32), to_unsigned(6966, 32), to_unsigned(11097, 32), to_unsigned(5562, 32), to_unsigned(3269, 32), to_unsigned(9384, 32), to_unsigned(6610, 32), to_unsigned(9319, 32), to_unsigned(9009, 32), to_unsigned(7989, 32), to_unsigned(5500, 32), to_unsigned(5126, 32), to_unsigned(4758, 32), to_unsigned(3811, 32), to_unsigned(11214, 32), to_unsigned(2652, 32), to_unsigned(7981, 32), to_unsigned(5642, 32), to_unsigned(8192, 32), to_unsigned(8532, 32), to_unsigned(7339, 32), to_unsigned(4711, 32), to_unsigned(6139, 32), to_unsigned(9776, 32), to_unsigned(4792, 32), to_unsigned(10452, 32), to_unsigned(8544, 32), to_unsigned(3334, 32), to_unsigned(12247, 32), to_unsigned(5043, 32), to_unsigned(1371, 32), to_unsigned(11046, 32), to_unsigned(9984, 32), to_unsigned(6018, 32), to_unsigned(7269, 32), to_unsigned(2187, 32), to_unsigned(2553, 32), to_unsigned(11527, 32), to_unsigned(2106, 32), to_unsigned(6602, 32), to_unsigned(3278, 32), to_unsigned(3832, 32), to_unsigned(1024, 32), to_unsigned(6509, 32), to_unsigned(4518, 32), to_unsigned(2931, 32), to_unsigned(11025, 32), to_unsigned(10216, 32), to_unsigned(267, 32), to_unsigned(1761, 32), to_unsigned(11395, 32), to_unsigned(10165, 32), to_unsigned(4396, 32), to_unsigned(12089, 32), to_unsigned(3271, 32), to_unsigned(1716, 32), to_unsigned(6990, 32), to_unsigned(11078, 32), to_unsigned(9173, 32), to_unsigned(1158, 32), to_unsigned(1084, 32), to_unsigned(8026, 32), to_unsigned(8503, 32), to_unsigned(6886, 32), to_unsigned(9188, 32), to_unsigned(7380, 32), to_unsigned(2553, 32), to_unsigned(2857, 32), to_unsigned(1260, 32), to_unsigned(1281, 32), to_unsigned(5765, 32), to_unsigned(2084, 32), to_unsigned(2540, 32), to_unsigned(750, 32), to_unsigned(6850, 32), to_unsigned(6242, 32), to_unsigned(388, 32), to_unsigned(12004, 32), to_unsigned(3362, 32), to_unsigned(30, 32), to_unsigned(493, 32), to_unsigned(1194, 32), to_unsigned(9112, 32), to_unsigned(4295, 32), to_unsigned(3564, 32), to_unsigned(1631, 32), to_unsigned(5122, 32), to_unsigned(7207, 32), to_unsigned(12073, 32), to_unsigned(8029, 32), to_unsigned(2922, 32), to_unsigned(9749, 32), to_unsigned(5191, 32), to_unsigned(765, 32), to_unsigned(1801, 32), to_unsigned(4480, 32), to_unsigned(7348, 32), to_unsigned(6287, 32), to_unsigned(10769, 32), to_unsigned(7680, 32), to_unsigned(4703, 32), to_unsigned(6549, 32), to_unsigned(8649, 32), to_unsigned(11853, 32), to_unsigned(2583, 32), to_unsigned(5599, 32), to_unsigned(10558, 32), to_unsigned(1589, 32), to_unsigned(9136, 32), to_unsigned(5376, 32), to_unsigned(6848, 32), to_unsigned(1802, 32), to_unsigned(12081, 32), to_unsigned(1034, 32), to_unsigned(8801, 32), to_unsigned(3889, 32), to_unsigned(5179, 32), to_unsigned(4556, 32), to_unsigned(12099, 32), to_unsigned(7514, 32), to_unsigned(10184, 32), to_unsigned(1693, 32), to_unsigned(617, 32), to_unsigned(4407, 32), to_unsigned(437, 32), to_unsigned(10635, 32), to_unsigned(8795, 32), to_unsigned(9529, 32), to_unsigned(7636, 32), to_unsigned(2728, 32), to_unsigned(1652, 32), to_unsigned(3964, 32), to_unsigned(5645, 32), to_unsigned(2855, 32), to_unsigned(6803, 32), to_unsigned(2811, 32), to_unsigned(8120, 32), to_unsigned(10714, 32), to_unsigned(6084, 32), to_unsigned(274, 32), to_unsigned(6952, 32), to_unsigned(11457, 32), to_unsigned(1362, 32), to_unsigned(3611, 32), to_unsigned(11510, 32), to_unsigned(6257, 32), to_unsigned(2147, 32), to_unsigned(2359, 32), to_unsigned(1206, 32));

  signal y1 : ram_type := (to_unsigned(110, 32), to_unsigned(12250, 32), to_unsigned(12096, 32), to_unsigned(209, 32), to_unsigned(7, 32), to_unsigned(12282, 32), to_unsigned(12131, 32), to_unsigned(97, 32), to_unsigned(142, 32), to_unsigned(12210, 32), to_unsigned(115, 32), to_unsigned(12113, 32), to_unsigned(12005, 32), to_unsigned(253, 32), to_unsigned(209, 32), to_unsigned(231, 32), to_unsigned(12047, 32), to_unsigned(12259, 32), to_unsigned(12145, 32), to_unsigned(254, 32), to_unsigned(47, 32), to_unsigned(15, 32), to_unsigned(12271, 32), to_unsigned(251, 32), to_unsigned(282, 32), to_unsigned(12173, 32), to_unsigned(12121, 32), to_unsigned(28, 32), to_unsigned(12061, 32), to_unsigned(11930, 32), to_unsigned(12191, 32), to_unsigned(177, 32), to_unsigned(214, 32), to_unsigned(12162, 32), to_unsigned(12225, 32), to_unsigned(50, 32), to_unsigned(12237, 32), to_unsigned(11921, 32), to_unsigned(168, 32), to_unsigned(11910, 32), to_unsigned(310, 32), to_unsigned(11785, 32), to_unsigned(12281, 32), to_unsigned(12061, 32), to_unsigned(69, 32), to_unsigned(12182, 32), to_unsigned(12285, 32), to_unsigned(12020, 32), to_unsigned(267, 32), to_unsigned(12029, 32), to_unsigned(220, 32), to_unsigned(364, 32), to_unsigned(12233, 32), to_unsigned(12202, 32), to_unsigned(171, 32), to_unsigned(12140, 32), to_unsigned(208, 32), to_unsigned(23, 32), to_unsigned(668, 32), to_unsigned(11948, 32), to_unsigned(70, 32), to_unsigned(70, 32), to_unsigned(187, 32), to_unsigned(12219, 32), to_unsigned(12090, 32), to_unsigned(12195, 32), to_unsigned(38, 32), to_unsigned(12084, 32), to_unsigned(12271, 32), to_unsigned(85, 32), to_unsigned(117, 32), to_unsigned(12237, 32), to_unsigned(12264, 32), to_unsigned(11887, 32), to_unsigned(295, 32), to_unsigned(12121, 32), to_unsigned(71, 32), to_unsigned(11977, 32), to_unsigned(12013, 32), to_unsigned(65, 32), to_unsigned(212, 32), to_unsigned(282, 32), to_unsigned(340, 32), to_unsigned(0, 32), to_unsigned(12150, 32), to_unsigned(11953, 32), to_unsigned(12180, 32), to_unsigned(28, 32), to_unsigned(12054, 32), to_unsigned(34, 32), to_unsigned(12208, 32), to_unsigned(56, 32), to_unsigned(11985, 32), to_unsigned(12240, 32), to_unsigned(12213, 32), to_unsigned(111, 32), to_unsigned(11782, 32), to_unsigned(96, 32), to_unsigned(12226, 32), to_unsigned(230, 32), to_unsigned(310, 32), to_unsigned(19, 32), to_unsigned(172, 32), to_unsigned(12037, 32), to_unsigned(69, 32), to_unsigned(12021, 32), to_unsigned(12246, 32), to_unsigned(12234, 32), to_unsigned(11985, 32), to_unsigned(23, 32), to_unsigned(12175, 32), to_unsigned(12234, 32), to_unsigned(282, 32), to_unsigned(232, 32), to_unsigned(12216, 32), to_unsigned(61, 32), to_unsigned(12183, 32), to_unsigned(12136, 32), to_unsigned(147, 32), to_unsigned(12279, 32), to_unsigned(11928, 32), to_unsigned(12195, 32), to_unsigned(245, 32), to_unsigned(108, 32), to_unsigned(155, 32), to_unsigned(11801, 32), to_unsigned(11945, 32), to_unsigned(12154, 32), to_unsigned(12141, 32), to_unsigned(11889, 32), to_unsigned(94, 32), to_unsigned(78, 32), to_unsigned(11979, 32), to_unsigned(4, 32), to_unsigned(12244, 32), to_unsigned(12159, 32), to_unsigned(12131, 32), to_unsigned(12082, 32), to_unsigned(12151, 32), to_unsigned(101, 32), to_unsigned(8, 32), to_unsigned(12058, 32), to_unsigned(45, 32), to_unsigned(23, 32), to_unsigned(143, 32), to_unsigned(50, 32), to_unsigned(125, 32), to_unsigned(292, 32), to_unsigned(12219, 32), to_unsigned(196, 32), to_unsigned(12116, 32), to_unsigned(60, 32), to_unsigned(248, 32), to_unsigned(111, 32), to_unsigned(171, 32), to_unsigned(12162, 32), to_unsigned(12239, 32), to_unsigned(12190, 32), to_unsigned(12081, 32), to_unsigned(12058, 32), to_unsigned(12242, 32), to_unsigned(11956, 32), to_unsigned(11980, 32), to_unsigned(143, 32), to_unsigned(12263, 32), to_unsigned(12196, 32), to_unsigned(12155, 32), to_unsigned(112, 32), to_unsigned(11944, 32), to_unsigned(80, 32), to_unsigned(492, 32), to_unsigned(11970, 32), to_unsigned(41, 32), to_unsigned(271, 32), to_unsigned(49, 32), to_unsigned(96, 32), to_unsigned(12029, 32), to_unsigned(12010, 32), to_unsigned(226, 32), to_unsigned(239, 32), to_unsigned(353, 32), to_unsigned(104, 32), to_unsigned(59, 32), to_unsigned(12063, 32), to_unsigned(274, 32), to_unsigned(82, 32), to_unsigned(12259, 32), to_unsigned(260, 32), to_unsigned(394, 32), to_unsigned(11692, 32), to_unsigned(414, 32), to_unsigned(11904, 32), to_unsigned(12137, 32), to_unsigned(129, 32), to_unsigned(11765, 32), to_unsigned(12041, 32), to_unsigned(1, 32), to_unsigned(12150, 32), to_unsigned(3, 32), to_unsigned(501, 32), to_unsigned(12192, 32), to_unsigned(12172, 32), to_unsigned(287, 32), to_unsigned(12137, 32), to_unsigned(12249, 32), to_unsigned(12182, 32), to_unsigned(12239, 32), to_unsigned(29, 32), to_unsigned(12176, 32), to_unsigned(12257, 32), to_unsigned(12005, 32), to_unsigned(12256, 32), to_unsigned(190, 32), to_unsigned(12231, 32), to_unsigned(12259, 32), to_unsigned(12122, 32), to_unsigned(288, 32), to_unsigned(5, 32), to_unsigned(168, 32), to_unsigned(111, 32), to_unsigned(86, 32), to_unsigned(12074, 32), to_unsigned(12282, 32), to_unsigned(11905, 32), to_unsigned(9, 32), to_unsigned(12166, 32), to_unsigned(181, 32), to_unsigned(11871, 32), to_unsigned(57, 32), to_unsigned(44, 32), to_unsigned(12110, 32), to_unsigned(12114, 32), to_unsigned(34, 32), to_unsigned(398, 32), to_unsigned(24, 32), to_unsigned(111, 32), to_unsigned(258, 32), to_unsigned(11996, 32), to_unsigned(1, 32), to_unsigned(226, 32), to_unsigned(234, 32), to_unsigned(302, 32), to_unsigned(12235, 32), to_unsigned(377, 32), to_unsigned(12197, 32), to_unsigned(12261, 32), to_unsigned(12169, 32), to_unsigned(6, 32), to_unsigned(475, 32), to_unsigned(59, 32), to_unsigned(137, 32), to_unsigned(12108, 32), to_unsigned(10, 32), to_unsigned(12138, 32), to_unsigned(41, 32), to_unsigned(199, 32), to_unsigned(12160, 32), to_unsigned(329, 32), to_unsigned(12233, 32), to_unsigned(163, 32), to_unsigned(12232, 32), to_unsigned(211, 32), to_unsigned(12275, 32), to_unsigned(12230, 32), to_unsigned(12075, 32), to_unsigned(68, 32), to_unsigned(12171, 32), to_unsigned(12044, 32), to_unsigned(280, 32), to_unsigned(192, 32), to_unsigned(12222, 32), to_unsigned(12169, 32), to_unsigned(439, 32), to_unsigned(277, 32), to_unsigned(12235, 32), to_unsigned(12045, 32), to_unsigned(311, 32), to_unsigned(12175, 32), to_unsigned(433, 32), to_unsigned(12137, 32), to_unsigned(16, 32), to_unsigned(36, 32), to_unsigned(163, 32), to_unsigned(12277, 32), to_unsigned(11827, 32), to_unsigned(12287, 32), to_unsigned(12267, 32), to_unsigned(12284, 32), to_unsigned(12213, 32), to_unsigned(11866, 32), to_unsigned(144, 32), to_unsigned(12228, 32), to_unsigned(12165, 32), to_unsigned(15, 32), to_unsigned(188, 32), to_unsigned(0, 32), to_unsigned(12263, 32), to_unsigned(11901, 32), to_unsigned(36, 32), to_unsigned(39, 32), to_unsigned(12009, 32), to_unsigned(12160, 32), to_unsigned(12086, 32), to_unsigned(12123, 32), to_unsigned(432, 32), to_unsigned(12078, 32), to_unsigned(12171, 32), to_unsigned(365, 32), to_unsigned(130, 32), to_unsigned(12241, 32), to_unsigned(180, 32), to_unsigned(121, 32), to_unsigned(390, 32), to_unsigned(12144, 32), to_unsigned(134, 32), to_unsigned(12257, 32), to_unsigned(12237, 32), to_unsigned(204, 32), to_unsigned(122, 32), to_unsigned(12279, 32), to_unsigned(11754, 32), to_unsigned(190, 32), to_unsigned(225, 32), to_unsigned(11977, 32), to_unsigned(12167, 32), to_unsigned(47, 32), to_unsigned(12183, 32), to_unsigned(363, 32), to_unsigned(17, 32), to_unsigned(12258, 32), to_unsigned(11966, 32), to_unsigned(12265, 32), to_unsigned(93, 32), to_unsigned(11982, 32), to_unsigned(241, 32), to_unsigned(12043, 32), to_unsigned(12007, 32), to_unsigned(415, 32), to_unsigned(12217, 32), to_unsigned(12276, 32), to_unsigned(304, 32), to_unsigned(12281, 32), to_unsigned(12050, 32), to_unsigned(104, 32), to_unsigned(11968, 32), to_unsigned(193, 32), to_unsigned(86, 32), to_unsigned(220, 32), to_unsigned(242, 32), to_unsigned(12009, 32), to_unsigned(12249, 32), to_unsigned(69, 32), to_unsigned(303, 32), to_unsigned(12064, 32), to_unsigned(46, 32), to_unsigned(78, 32), to_unsigned(169, 32), to_unsigned(182, 32), to_unsigned(12221, 32), to_unsigned(11899, 32), to_unsigned(251, 32), to_unsigned(12280, 32), to_unsigned(12161, 32), to_unsigned(11912, 32), to_unsigned(12047, 32), to_unsigned(424, 32), to_unsigned(12164, 32), to_unsigned(12047, 32), to_unsigned(150, 32), to_unsigned(12176, 32), to_unsigned(12225, 32), to_unsigned(12181, 32), to_unsigned(181, 32), to_unsigned(12092, 32), to_unsigned(12252, 32), to_unsigned(12115, 32), to_unsigned(12163, 32), to_unsigned(135, 32), to_unsigned(422, 32), to_unsigned(126, 32), to_unsigned(11726, 32), to_unsigned(151, 32), to_unsigned(27, 32), to_unsigned(12082, 32), to_unsigned(12018, 32), to_unsigned(269, 32), to_unsigned(408, 32), to_unsigned(110, 32), to_unsigned(305, 32), to_unsigned(513, 32), to_unsigned(12161, 32), to_unsigned(12155, 32), to_unsigned(305, 32), to_unsigned(171, 32), to_unsigned(64, 32), to_unsigned(47, 32), to_unsigned(12195, 32), to_unsigned(202, 32), to_unsigned(12041, 32), to_unsigned(12184, 32), to_unsigned(12067, 32), to_unsigned(97, 32), to_unsigned(12050, 32), to_unsigned(11999, 32), to_unsigned(161, 32), to_unsigned(11775, 32), to_unsigned(330, 32), to_unsigned(492, 32), to_unsigned(12053, 32), to_unsigned(280, 32), to_unsigned(175, 32), to_unsigned(32, 32), to_unsigned(12051, 32), to_unsigned(39, 32), to_unsigned(12133, 32), to_unsigned(23, 32), to_unsigned(208, 32), to_unsigned(12266, 32), to_unsigned(12121, 32), to_unsigned(11942, 32), to_unsigned(226, 32), to_unsigned(12039, 32), to_unsigned(11806, 32), to_unsigned(292, 32), to_unsigned(12056, 32), to_unsigned(12147, 32), to_unsigned(149, 32), to_unsigned(33, 32), to_unsigned(12087, 32), to_unsigned(12237, 32), to_unsigned(12061, 32), to_unsigned(293, 32), to_unsigned(12247, 32), to_unsigned(11904, 32), to_unsigned(11913, 32), to_unsigned(54, 32), to_unsigned(11787, 32), to_unsigned(12256, 32), to_unsigned(324, 32), to_unsigned(18, 32), to_unsigned(11827, 32), to_unsigned(206, 32), to_unsigned(26, 32), to_unsigned(12001, 32), to_unsigned(192, 32), to_unsigned(249, 32), to_unsigned(116, 32), to_unsigned(232, 32), to_unsigned(136, 32), to_unsigned(294, 32), to_unsigned(12185, 32), to_unsigned(19, 32), to_unsigned(340, 32), to_unsigned(12111, 32), to_unsigned(358, 32), to_unsigned(85, 32), to_unsigned(126, 32), to_unsigned(35, 32), to_unsigned(12113, 32), to_unsigned(197, 32), to_unsigned(12185, 32), to_unsigned(12272, 32), to_unsigned(623, 32), to_unsigned(301, 32), to_unsigned(12235, 32), to_unsigned(2, 32), to_unsigned(11872, 32), to_unsigned(126, 32), to_unsigned(11767, 32), to_unsigned(12226, 32), to_unsigned(12099, 32), to_unsigned(311, 32), to_unsigned(6, 32), to_unsigned(12269, 32), to_unsigned(12154, 32), to_unsigned(12146, 32), to_unsigned(11975, 32), to_unsigned(12258, 32), to_unsigned(125, 32), to_unsigned(92, 32), to_unsigned(11819, 32), to_unsigned(12256, 32), to_unsigned(341, 32), to_unsigned(161, 32), to_unsigned(12209, 32), to_unsigned(57, 32), to_unsigned(242, 32), to_unsigned(268, 32), to_unsigned(12251, 32), to_unsigned(26, 32), to_unsigned(11950, 32), to_unsigned(12260, 32), to_unsigned(12219, 32), to_unsigned(12122, 32), to_unsigned(253, 32), to_unsigned(12208, 32), to_unsigned(124, 32), to_unsigned(12187, 32), to_unsigned(155, 32), to_unsigned(12128, 32), to_unsigned(52, 32), to_unsigned(12248, 32), to_unsigned(11757, 32), to_unsigned(438, 32), to_unsigned(320, 32), to_unsigned(12165, 32), to_unsigned(277, 32), to_unsigned(12071, 32), to_unsigned(12062, 32), to_unsigned(12267, 32), to_unsigned(163, 32), to_unsigned(37, 32));

  signal y2 : ram_type := (to_unsigned(284, 32), to_unsigned(12174, 32), to_unsigned(0, 32), to_unsigned(55, 32), to_unsigned(12096, 32), to_unsigned(12207, 32), to_unsigned(299, 32), to_unsigned(12152, 32), to_unsigned(12027, 32), to_unsigned(12227, 32), to_unsigned(12223, 32), to_unsigned(12031, 32), to_unsigned(12189, 32), to_unsigned(12264, 32), to_unsigned(12274, 32), to_unsigned(12001, 32), to_unsigned(11960, 32), to_unsigned(12170, 32), to_unsigned(12205, 32), to_unsigned(637, 32), to_unsigned(12285, 32), to_unsigned(12123, 32), to_unsigned(12025, 32), to_unsigned(12015, 32), to_unsigned(121, 32), to_unsigned(12173, 32), to_unsigned(12182, 32), to_unsigned(65, 32), to_unsigned(12243, 32), to_unsigned(12173, 32), to_unsigned(11956, 32), to_unsigned(198, 32), to_unsigned(11856, 32), to_unsigned(83, 32), to_unsigned(12271, 32), to_unsigned(11902, 32), to_unsigned(376, 32), to_unsigned(350, 32), to_unsigned(77, 32), to_unsigned(128, 32), to_unsigned(12041, 32), to_unsigned(182, 32), to_unsigned(242, 32), to_unsigned(12287, 32), to_unsigned(149, 32), to_unsigned(12227, 32), to_unsigned(12273, 32), to_unsigned(12281, 32), to_unsigned(11885, 32), to_unsigned(12042, 32), to_unsigned(12189, 32), to_unsigned(210, 32), to_unsigned(410, 32), to_unsigned(193, 32), to_unsigned(231, 32), to_unsigned(12286, 32), to_unsigned(11985, 32), to_unsigned(174, 32), to_unsigned(12175, 32), to_unsigned(12022, 32), to_unsigned(12242, 32), to_unsigned(12186, 32), to_unsigned(276, 32), to_unsigned(12135, 32), to_unsigned(236, 32), to_unsigned(25, 32), to_unsigned(12034, 32), to_unsigned(324, 32), to_unsigned(342, 32), to_unsigned(12279, 32), to_unsigned(12174, 32), to_unsigned(11839, 32), to_unsigned(11978, 32), to_unsigned(12143, 32), to_unsigned(43, 32), to_unsigned(97, 32), to_unsigned(37, 32), to_unsigned(12287, 32), to_unsigned(74, 32), to_unsigned(12249, 32), to_unsigned(12203, 32), to_unsigned(346, 32), to_unsigned(12226, 32), to_unsigned(222, 32), to_unsigned(12170, 32), to_unsigned(12004, 32), to_unsigned(402, 32), to_unsigned(12251, 32), to_unsigned(11795, 32), to_unsigned(327, 32), to_unsigned(166, 32), to_unsigned(12265, 32), to_unsigned(12157, 32), to_unsigned(12082, 32), to_unsigned(1, 32), to_unsigned(12, 32), to_unsigned(403, 32), to_unsigned(12153, 32), to_unsigned(23, 32), to_unsigned(12208, 32), to_unsigned(584, 32), to_unsigned(328, 32), to_unsigned(12079, 32), to_unsigned(12121, 32), to_unsigned(80, 32), to_unsigned(12049, 32), to_unsigned(12202, 32), to_unsigned(12168, 32), to_unsigned(12158, 32), to_unsigned(12260, 32), to_unsigned(64, 32), to_unsigned(81, 32), to_unsigned(12245, 32), to_unsigned(12246, 32), to_unsigned(12284, 32), to_unsigned(12286, 32), to_unsigned(11962, 32), to_unsigned(94, 32), to_unsigned(12261, 32), to_unsigned(12074, 32), to_unsigned(12033, 32), to_unsigned(8, 32), to_unsigned(12134, 32), to_unsigned(26, 32), to_unsigned(12144, 32), to_unsigned(117, 32), to_unsigned(12158, 32), to_unsigned(12231, 32), to_unsigned(20, 32), to_unsigned(129, 32), to_unsigned(12116, 32), to_unsigned(12142, 32), to_unsigned(12112, 32), to_unsigned(12248, 32), to_unsigned(76, 32), to_unsigned(11962, 32), to_unsigned(281, 32), to_unsigned(12123, 32), to_unsigned(168, 32), to_unsigned(12200, 32), to_unsigned(2, 32), to_unsigned(406, 32), to_unsigned(363, 32), to_unsigned(12151, 32), to_unsigned(256, 32), to_unsigned(12187, 32), to_unsigned(110, 32), to_unsigned(11980, 32), to_unsigned(11933, 32), to_unsigned(12082, 32), to_unsigned(49, 32), to_unsigned(12019, 32), to_unsigned(11799, 32), to_unsigned(71, 32), to_unsigned(12210, 32), to_unsigned(334, 32), to_unsigned(12271, 32), to_unsigned(12011, 32), to_unsigned(201, 32), to_unsigned(12096, 32), to_unsigned(80, 32), to_unsigned(68, 32), to_unsigned(133, 32), to_unsigned(108, 32), to_unsigned(59, 32), to_unsigned(213, 32), to_unsigned(12061, 32), to_unsigned(91, 32), to_unsigned(12089, 32), to_unsigned(12203, 32), to_unsigned(12209, 32), to_unsigned(117, 32), to_unsigned(233, 32), to_unsigned(11986, 32), to_unsigned(12224, 32), to_unsigned(12158, 32), to_unsigned(72, 32), to_unsigned(38, 32), to_unsigned(12178, 32), to_unsigned(405, 32), to_unsigned(158, 32), to_unsigned(12262, 32), to_unsigned(12126, 32), to_unsigned(12183, 32), to_unsigned(12125, 32), to_unsigned(470, 32), to_unsigned(151, 32), to_unsigned(175, 32), to_unsigned(12224, 32), to_unsigned(85, 32), to_unsigned(103, 32), to_unsigned(12239, 32), to_unsigned(123, 32), to_unsigned(239, 32), to_unsigned(104, 32), to_unsigned(12157, 32), to_unsigned(12257, 32), to_unsigned(12221, 32), to_unsigned(56, 32), to_unsigned(12227, 32), to_unsigned(12203, 32), to_unsigned(110, 32), to_unsigned(11954, 32), to_unsigned(11860, 32), to_unsigned(12044, 32), to_unsigned(12208, 32), to_unsigned(10, 32), to_unsigned(12209, 32), to_unsigned(173, 32), to_unsigned(107, 32), to_unsigned(320, 32), to_unsigned(18, 32), to_unsigned(40, 32), to_unsigned(244, 32), to_unsigned(12198, 32), to_unsigned(12065, 32), to_unsigned(12250, 32), to_unsigned(2, 32), to_unsigned(83, 32), to_unsigned(12178, 32), to_unsigned(12097, 32), to_unsigned(12153, 32), to_unsigned(166, 32), to_unsigned(12144, 32), to_unsigned(242, 32), to_unsigned(12076, 32), to_unsigned(11894, 32), to_unsigned(12283, 32), to_unsigned(11829, 32), to_unsigned(59, 32), to_unsigned(12181, 32), to_unsigned(11966, 32), to_unsigned(12150, 32), to_unsigned(23, 32), to_unsigned(11986, 32), to_unsigned(130, 32), to_unsigned(12250, 32), to_unsigned(42, 32), to_unsigned(98, 32), to_unsigned(72, 32), to_unsigned(136, 32), to_unsigned(12180, 32), to_unsigned(86, 32), to_unsigned(12183, 32), to_unsigned(193, 32), to_unsigned(11917, 32), to_unsigned(12179, 32), to_unsigned(11806, 32), to_unsigned(12209, 32), to_unsigned(12062, 32), to_unsigned(266, 32), to_unsigned(12085, 32), to_unsigned(14, 32), to_unsigned(12204, 32), to_unsigned(53, 32), to_unsigned(12201, 32), to_unsigned(12077, 32), to_unsigned(12234, 32), to_unsigned(89, 32), to_unsigned(425, 32), to_unsigned(111, 32), to_unsigned(119, 32), to_unsigned(12086, 32), to_unsigned(134, 32), to_unsigned(354, 32), to_unsigned(12088, 32), to_unsigned(128, 32), to_unsigned(367, 32), to_unsigned(12168, 32), to_unsigned(76, 32), to_unsigned(203, 32), to_unsigned(12056, 32), to_unsigned(12022, 32), to_unsigned(12005, 32), to_unsigned(169, 32), to_unsigned(12127, 32), to_unsigned(11991, 32), to_unsigned(182, 32), to_unsigned(73, 32), to_unsigned(12190, 32), to_unsigned(182, 32), to_unsigned(87, 32), to_unsigned(12166, 32), to_unsigned(194, 32), to_unsigned(628, 32), to_unsigned(12236, 32), to_unsigned(12214, 32), to_unsigned(110, 32), to_unsigned(12115, 32), to_unsigned(12207, 32), to_unsigned(11949, 32), to_unsigned(12101, 32), to_unsigned(12153, 32), to_unsigned(12066, 32), to_unsigned(12170, 32), to_unsigned(12079, 32), to_unsigned(12284, 32), to_unsigned(12, 32), to_unsigned(141, 32), to_unsigned(11905, 32), to_unsigned(12160, 32), to_unsigned(141, 32), to_unsigned(12249, 32), to_unsigned(12009, 32), to_unsigned(12048, 32), to_unsigned(11977, 32), to_unsigned(12180, 32), to_unsigned(272, 32), to_unsigned(472, 32), to_unsigned(116, 32), to_unsigned(12260, 32), to_unsigned(174, 32), to_unsigned(195, 32), to_unsigned(48, 32), to_unsigned(285, 32), to_unsigned(281, 32), to_unsigned(372, 32), to_unsigned(12216, 32), to_unsigned(11930, 32), to_unsigned(148, 32), to_unsigned(450, 32), to_unsigned(283, 32), to_unsigned(12085, 32), to_unsigned(12167, 32), to_unsigned(12053, 32), to_unsigned(12053, 32), to_unsigned(11934, 32), to_unsigned(430, 32), to_unsigned(11879, 32), to_unsigned(123, 32), to_unsigned(12284, 32), to_unsigned(103, 32), to_unsigned(7, 32), to_unsigned(74, 32), to_unsigned(229, 32), to_unsigned(12070, 32), to_unsigned(12204, 32), to_unsigned(12105, 32), to_unsigned(263, 32), to_unsigned(235, 32), to_unsigned(178, 32), to_unsigned(12018, 32), to_unsigned(156, 32), to_unsigned(104, 32), to_unsigned(12057, 32), to_unsigned(139, 32), to_unsigned(12208, 32), to_unsigned(12174, 32), to_unsigned(183, 32), to_unsigned(12103, 32), to_unsigned(12141, 32), to_unsigned(12284, 32), to_unsigned(11916, 32), to_unsigned(11978, 32), to_unsigned(12140, 32), to_unsigned(81, 32), to_unsigned(193, 32), to_unsigned(12170, 32), to_unsigned(12141, 32), to_unsigned(12132, 32), to_unsigned(12190, 32), to_unsigned(12061, 32), to_unsigned(42, 32), to_unsigned(111, 32), to_unsigned(12253, 32), to_unsigned(229, 32), to_unsigned(165, 32), to_unsigned(12035, 32), to_unsigned(57, 32), to_unsigned(278, 32), to_unsigned(90, 32), to_unsigned(12086, 32), to_unsigned(279, 32), to_unsigned(324, 32), to_unsigned(245, 32), to_unsigned(169, 32), to_unsigned(12241, 32), to_unsigned(240, 32), to_unsigned(327, 32), to_unsigned(385, 32), to_unsigned(12112, 32), to_unsigned(80, 32), to_unsigned(34, 32), to_unsigned(429, 32), to_unsigned(12272, 32), to_unsigned(293, 32), to_unsigned(12058, 32), to_unsigned(176, 32), to_unsigned(12274, 32), to_unsigned(12109, 32), to_unsigned(12183, 32), to_unsigned(9, 32), to_unsigned(283, 32), to_unsigned(12020, 32), to_unsigned(221, 32), to_unsigned(93, 32), to_unsigned(471, 32), to_unsigned(178, 32), to_unsigned(12243, 32), to_unsigned(56, 32), to_unsigned(12145, 32), to_unsigned(149, 32), to_unsigned(20, 32), to_unsigned(22, 32), to_unsigned(202, 32), to_unsigned(12206, 32), to_unsigned(120, 32), to_unsigned(258, 32), to_unsigned(27, 32), to_unsigned(12209, 32), to_unsigned(12148, 32), to_unsigned(11894, 32), to_unsigned(12160, 32), to_unsigned(104, 32), to_unsigned(138, 32), to_unsigned(23, 32), to_unsigned(12255, 32), to_unsigned(12103, 32), to_unsigned(12229, 32), to_unsigned(12262, 32), to_unsigned(12068, 32), to_unsigned(69, 32), to_unsigned(296, 32), to_unsigned(55, 32), to_unsigned(372, 32), to_unsigned(11998, 32), to_unsigned(2, 32), to_unsigned(12218, 32), to_unsigned(11974, 32), to_unsigned(12282, 32), to_unsigned(113, 32), to_unsigned(12116, 32), to_unsigned(318, 32), to_unsigned(41, 32), to_unsigned(241, 32), to_unsigned(565, 32), to_unsigned(12102, 32), to_unsigned(12076, 32), to_unsigned(12275, 32), to_unsigned(14, 32), to_unsigned(105, 32), to_unsigned(21, 32), to_unsigned(12249, 32), to_unsigned(187, 32), to_unsigned(11937, 32), to_unsigned(12228, 32), to_unsigned(107, 32), to_unsigned(186, 32), to_unsigned(12266, 32), to_unsigned(11806, 32), to_unsigned(12245, 32), to_unsigned(47, 32), to_unsigned(12199, 32), to_unsigned(12227, 32), to_unsigned(12288, 32), to_unsigned(12175, 32), to_unsigned(82, 32), to_unsigned(11799, 32), to_unsigned(12018, 32), to_unsigned(206, 32), to_unsigned(267, 32), to_unsigned(74, 32), to_unsigned(1, 32), to_unsigned(71, 32), to_unsigned(12232, 32), to_unsigned(193, 32), to_unsigned(12264, 32), to_unsigned(11980, 32), to_unsigned(12249, 32), to_unsigned(12055, 32), to_unsigned(12068, 32), to_unsigned(373, 32), to_unsigned(67, 32), to_unsigned(111, 32), to_unsigned(240, 32), to_unsigned(171, 32), to_unsigned(83, 32), to_unsigned(12148, 32), to_unsigned(136, 32), to_unsigned(342, 32), to_unsigned(88, 32), to_unsigned(12276, 32), to_unsigned(12257, 32), to_unsigned(12183, 32), to_unsigned(139, 32), to_unsigned(12207, 32), to_unsigned(12259, 32), to_unsigned(467, 32), to_unsigned(166, 32), to_unsigned(85, 32), to_unsigned(11851, 32), to_unsigned(12005, 32), to_unsigned(344, 32), to_unsigned(12206, 32), to_unsigned(170, 32), to_unsigned(263, 32), to_unsigned(11919, 32), to_unsigned(12285, 32), to_unsigned(24, 32), to_unsigned(174, 32), to_unsigned(12092, 32), to_unsigned(11920, 32), to_unsigned(11947, 32), to_unsigned(12035, 32), to_unsigned(12154, 32), to_unsigned(89, 32), to_unsigned(99, 32), to_unsigned(165, 32), to_unsigned(12222, 32), to_unsigned(150, 32), to_unsigned(544, 32), to_unsigned(108, 32));

  signal start_test     : std_logic := '0';
  signal counter_coeff  : integer   := 0;
  signal counter_poly   : integer   := 0;
  signal wait_counter   : integer   := 0;
  signal rehash_message : std_logic := '0';
  signal reset          : std_logic := '0';
  
begin

  process (clk)
  begin  -- process
    if rising_edge(clk) then
      if reset = '1' or rehash_message = '1' then
        counter_coeff <= 0;
        counter_poly  <= 0;
        wait_counter  <= 0;
      end if;



      ay1_wr_en <= '0';
      y1_wr_en  <= '0';
      y2_wr_en  <= '0';

      if counter_coeff = 0 and wait_counter < 50 then
        wait_counter <= wait_counter+1;
      else
        if start_test = '1' and counter_poly < 4 then
          addr_in <= std_logic_vector(to_unsigned(counter_coeff, addr_in'length));

          if counter_coeff = N_ELEMENTS-1 then
            counter_coeff <= 0;
            wait_counter  <= 0;
            counter_poly  <= counter_poly+1;
          else
            counter_coeff <= counter_coeff+1;
          end if;

          if counter_poly = 0 then
            data_in   <= std_logic_vector(resize(ay(counter_coeff), data_in'length));
            ay1_wr_en <= '1';
          end if;

          if counter_poly = 1 then
            data_in  <= std_logic_vector(resize(y2(counter_coeff), data_in'length));
            y2_wr_en <= '1';
          end if;

          if counter_poly = 2 then
            data_in  <= std_logic_vector(resize(y1(counter_coeff), data_in'length));
            y1_wr_en <= '1';
          end if;

        end if;
        
      end if;
    end if;
  end process;




  finalization_top_1 : entity work.finalization_top
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
      c_delay          => c_delay,
      MAX_RES_WIDTH    => MAX_RES_WIDTH)
    port map (
      clk              => clk,
      --start            => start,
      --ready            => ready,
      rehash_message   => rehash_message,
      reset            => reset,
      ready_message    => ready_message,
      message_finished => message_finished,
      message_din      => message_din,
      message_valid    => message_valid,
      s1_addr          => s1_addr,
      s1_in            => s1_in,
      s1_wr_en         => s1_wr_en,
      s2_addr          => s2_addr,
      s2_in            => s2_in,
      s2_wr_en         => s2_wr_en,
      coeff_sc1_out    => coeff_sc1_out,
      coeff_sc1_addr   => coeff_sc1_addr,
      coeff_sc1_valid  => coeff_sc1_valid,
      coeff_sc2_out    => coeff_sc2_out,
      coeff_sc2_addr   => coeff_sc2_addr,
      coeff_sc2_valid  => coeff_sc2_valid,
      addr_in          => addr_in,
      data_in          => data_in,
      ay1_wr_en        => ay1_wr_en,
      y1_wr_en         => y1_wr_en,
      y2_wr_en         => y2_wr_en
      );

  clk_process : process
  begin
    if end_of_simulation = '0' then
      clk           <= '0';
      wait for clk_period/2;
      clk           <= '1';
      wait for clk_period/2;
      cycle_counter <= cycle_counter+1;
    end if;
  end process;
  end_of_simulation_out <= end_of_simulation;




  -- Stimulus process
  stim_proc : process
  begin
    -- hold reset state for 100 ns.
    wait for 100 ns;

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
    start_test <= '1';

    wait for clk_period*15000;

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
    --DO something for reset
    reset <= '1';
    wait for clk_period;
    reset <= '0';
    wait for clk_period*10;
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------


    --Write the message
    for i in 0 to 15 loop
      message_din   <= (others => '0');
      message_valid <= '1';
      wait for clk_period;
    end loop;  -- i
    message_valid <= '0';

    --State that the message is finished
    message_finished <= '1';
    wait for clk_period;
    message_finished <= '0';

    wait for clk_period*10;
    start_test <= '1';
    wait for clk_period;


    wait for clk_period*15000;


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
    --DO something for reset (rehash)
    start_test     <= '0';
    wait for clk_period;
    rehash_message <= '1';
    wait for clk_period;
    rehash_message <= '0';
    wait for clk_period*10;
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------

    wait for clk_period*1000;


    wait for clk_period*10;
    start_test <= '1';

    wait for clk_period*15000;


    if error_happened = '1' then
      report "ERROR";
    else
      report "OK";
    end if;

    end_of_simulation <= '1';
    wait;

    -- insert stimulus here 

    wait;
  end process;

  
end;
