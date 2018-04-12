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
-- Create Date:   08:51:01 02/25/2014
-- Design Name:   
-- Module Name:   C:/Users/thomas/SHA/Projekte/BLISS/code/bliss_arithmetic/lattice_processor/get_entry_dual_tb.vhd
-- Project Name:  lattice_processor
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: get_entry_dual
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
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 use ieee.numeric_std.all;
use ieee.math_real.all;
use work.cdt_sampler_pkg.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY get_entry_dual_tb IS
 generic (
    PARAM_SET : integer := 1
    );
END get_entry_dual_tb;
 
ARCHITECTURE behavior OF get_entry_dual_tb IS 
   constant MAX_INDEX      : integer := get_cdt_max_index(PARAM_SET);
  constant MAX_BYTE_TABLE : integer := get_cdt_max_byte_table(PARAM_SET);
  constant MAX_BYTE       : integer := get_cdt_max_byte(PARAM_SET);

      signal byte_sel  : std_logic_vector(integer(ceil(log2(real(MAX_BYTE))))-1 downto 0)  := (others => '0');
  signal index_sel :  std_logic_vector(integer(ceil(log2(real(MAX_INDEX))))-1 downto 0) := (others => '0');

   
  signal clk        : std_logic;
  signal byte_sel1  : std_logic_vector(integer(ceil(log2(real(MAX_BYTE))))-1 downto 0)  := (others => '0');
  signal index_sel1 : std_logic_vector(integer(ceil(log2(real(MAX_INDEX))))-1 downto 0) := (others => '0');
  signal byte_sel2  : std_logic_vector(integer(ceil(log2(real(MAX_BYTE))))-1 downto 0)  := (others => '0');
  signal index_sel2 : std_logic_vector(integer(ceil(log2(real(MAX_INDEX))))-1 downto 0) := (others => '0');
  signal value_out1 : std_logic_vector(7 downto 0);
  signal value_out2 : std_logic_vector(7 downto 0);
signal counter : integer:=0;
   signal error_happened : std_logic := '0';
   
   
   type entry_type is array(0 to 2) of integer;
   type tb_data_type is array(natural range<>) of entry_type;

   constant test_data : tb_data_type :=((83,2,145),
(77,3,144),
(93,3,120),
(86,0,0),
(49,1,84),
(62,3,232),
(90,3,235),
(63,2,242),
(40,2,71),
(72,0,0),
(11,0,151),
(67,1,43),
(82,2,247),
(62,3,232),
(67,3,60),
(29,2,127),
(22,2,120),
(69,3,178),
(93,0,0),
(11,2,70),
(29,1,251),
(21,3,126),
(84,1,1),
(98,0,0),
(15,2,215),
(13,2,224),
(91,0,0),
(56,1,37),
(62,2,77),
(96,1,0),
(5,1,88),
(84,3,169),
(36,1,176),
(46,1,18),
(13,1,169),
(24,3,104),
(82,1,1),
(14,3,184),
(34,0,22),
(43,2,171),
(87,0,0),
(76,2,63),
(88,0,0),
(3,3,32),
(54,3,39),
(32,0,27),
(76,0,0),
(39,0,12),
(26,2,15),
(94,3,75),
(95,2,21),
(34,2,225),
(67,1,43),
(97,2,13),
(17,0,101),
(52,0,2),
(1,0,250),
(86,1,0),
(65,1,62),
(44,3,105),
(40,1,9),
(31,1,75),
(97,3,3),
(81,3,232),
(9,3,89),
(67,0,0),
(97,1,0),
(86,1,0),
(6,3,118),
(19,0,87),
(28,3,94),
(32,1,83),
(3,3,32),
(70,0,0),
(8,3,137),
(40,1,9),
(96,3,230),
(18,1,197),
(46,3,65),
(21,3,126),
(79,0,0),
(64,0,0),
(41,2,129),
(93,0,0),
(34,0,22),
(24,2,130),
(87,0,0),
(43,3,240),
(27,1,191),
(59,0,0),
(32,3,190),
(37,0,15),
(75,3,37),
(74,1,10),
(58,3,1),
(29,1,251),
(35,1,201),
(18,0,94),
(43,3,240),
(28,1,185),
(164,2,0),
(250,7,0),
(44,10,0),
(113,2,0),
(97,2,13),
(120,4,10),
(69,3,178),
(182,1,0),
(218,5,0),
(141,3,0),
(26,3,47),
(136,5,92),
(145,6,138),
(191,10,206),
(173,3,0),
(48,10,0),
(177,11,177),
(223,3,0),
(117,2,0),
(20,3,229),
(89,9,79),
(257,6,0),
(139,2,0),
(40,1,9),
(152,1,0),
(159,3,0),
(4,3,2),
(52,8,168),
(228,2,0),
(106,6,200),
(105,2,1),
(113,1,0),
(168,12,224),
(140,1,0),
(231,0,0),
(135,7,162),
(197,0,0),
(114,11,0),
(128,10,167),
(69,12,0),
(153,6,159),
(16,6,224),
(160,2,0),
(124,6,222),
(209,9,0),
(165,11,204),
(100,5,104),
(233,3,0),
(173,7,18),
(110,7,61),
(169,12,158),
(99,3,168),
(195,3,0),
(78,7,82),
(4,4,188),
(239,1,0),
(193,11,77),
(30,7,182),
(221,0,0),
(39,7,226),
(21,3,126),
(199,12,60),
(40,10,0),
(26,3,47),
(180,11,172),
(253,11,0),
(200,0,0),
(11,3,243),
(20,7,133),
(93,9,199),
(54,6,117),
(157,11,96),
(224,9,0),
(159,7,171),
(160,9,8),
(251,8,0),
(220,10,0),
(200,1,0),
(178,12,51),
(110,0,0),
(182,4,0),
(3,0,229),
(170,3,0),
(153,12,0),
(183,3,0),
(32,0,27),
(215,10,0),
(42,1,152),
(195,7,0),
(181,3,0),
(35,12,0),
(94,7,229),
(257,8,0),
(74,7,32),
(157,1,0),
(168,8,156),
(184,7,0),
(97,1,0),
(83,2,145),
(102,11,0),
(200,0,0),
(200,1,0),
(200,2,0),
(200,3,0),
(200,4,0),
(200,5,0),
(200,6,0),
(200,7,0),
(200,8,0),
(200,9,2),
(200,10,10),
(200,11,120),
(200,12,187),
(200,13,182),
(200,14,0),
(200,15,0),
(200,16,0),
(200,17,0),
(200,18,0),
(200,19,0),
(50,0,2),
(50,1,225),
(50,2,144),
(50,3,238),
(50,4,177),
(50,5,243),
(50,6,49),
(50,7,236),
(50,8,59),
(50,9,0),
(50,10,0),
(50,11,0),
(50,12,0),
(50,13,0),
(50,14,0),
(50,15,0),
(50,16,0),
(50,17,0),
(50,18,0),
(50,19,0),
(0,0,255),
(0,1,255),
(0,2,255),
(0,3,255),
(0,4,255),
(0,5,255),
(0,6,255),
(0,7,255),
(0,8,255),
(0,9,0),
(0,10,0),
(0,11,0),
(0,12,0),
(0,13,0),
(0,14,0),
(0,15,0),
(0,16,0),
(0,17,0),
(0,18,0),
(0,19,0),
(100,5,104),
(101,5,7),
(102,5,53),
(103,5,96),
(104,5,24),
(105,5,48),
(106,5,105),
(107,5,97),
(108,5,235),
(109,5,74),
(110,5,172),
(111,5,78),
(112,5,53),
(113,5,41),
(114,5,241),
(115,5,82),
(116,5,146),
(117,5,118),
(118,5,21),
(119,5,189));
   
   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
  get_entry_dual_1:entity work.get_entry_dual
       port map (
      clk        => clk,
      byte_sel1  => byte_sel1,
      index_sel1 => index_sel1,
      value_out1 => value_out1
      );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;


 -- process(clk)
 -- begin  -- process
--if rising_edge(clk) then
  index_sel1 <= index_sel;
  byte_sel1 <= byte_sel;
--end if;
---    
 -- end process;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

    wait for clk_period*10;
    wait for clk_period*10;

     index_sel <= std_logic_vector(to_unsigned(test_data(0)(0), index_sel1'length));
      byte_sel  <= std_logic_vector(to_unsigned(test_data(0)(1), byte_sel1'length));
     wait for clk_period;       
    for i in 1 to test_data'length-1 loop
      counter <= i;
      if to_integer(Unsigned(value_out1)) /= test_data(i-1)(2)  then
        error_happened <= '1';
      end if;
      index_sel <= std_logic_vector(to_unsigned(test_data(i)(0), index_sel1'length));
      byte_sel  <= std_logic_vector(to_unsigned(test_data(i)(1), byte_sel1'length));
      wait for clk_period;      
    end loop;  -- i
    wait for clk_period;


    -- insert stimulus here 

    wait;
      
      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
