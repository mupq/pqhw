--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/
--
--      Package File Template
--
--      Purpose: This package defines supplemental types, subtypes, 
--               constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

package lattice_processor is

  type my_array_t is array (0 to 9) of integer;
  type init_array_t is array (0 to 9) of integer;


  constant INST_ALU_MOV : std_logic_vector(2 downto 0) := "001";
  constant INST_ALU_ADD : std_logic_vector(2 downto 0) := "010";
  constant INST_ALU_SUB : std_logic_vector(2 downto 0) := "011";
  constant INST_ALU_POINTWISE : std_logic_vector(2 downto 0) := "100";

  constant NTT_INST_SIZE : integer := 4;


  constant INST_NTT_BITREV_A      : std_logic_vector(NTT_INST_SIZE-1 downto 0) := std_logic_vector(to_unsigned(1, NTT_INST_SIZE));
  constant INST_NTT_BITREV_B      : std_logic_vector(NTT_INST_SIZE-1 downto 0) := std_logic_vector(to_unsigned(2, NTT_INST_SIZE));
  constant INST_NTT_NTT_A         : std_logic_vector(NTT_INST_SIZE-1 downto 0) := std_logic_vector(to_unsigned(3, NTT_INST_SIZE));
  constant INST_NTT_NTT_B         : std_logic_vector(NTT_INST_SIZE-1 downto 0) := std_logic_vector(to_unsigned(4, NTT_INST_SIZE));
  constant INST_NTT_POINTWISE_MUL : std_logic_vector(NTT_INST_SIZE-1 downto 0) := std_logic_vector(to_unsigned(5, NTT_INST_SIZE));
  constant INST_NTT_INTT          : std_logic_vector(NTT_INST_SIZE-1 downto 0) := std_logic_vector(to_unsigned(6, NTT_INST_SIZE));
  constant INST_NTT_INV_PSI       : std_logic_vector(NTT_INST_SIZE-1 downto 0) := std_logic_vector(to_unsigned(7, NTT_INST_SIZE));
  constant INST_NTT_INV_N         : std_logic_vector(NTT_INST_SIZE-1 downto 0) := std_logic_vector(to_unsigned(8, NTT_INST_SIZE));
  constant INST_NTT_GP_MODE       : std_logic_vector(NTT_INST_SIZE-1 downto 0) := std_logic_vector(to_unsigned(9, NTT_INST_SIZE));
  constant INST_NTT_NTT_MODE      : std_logic_vector(NTT_INST_SIZE-1 downto 0) := std_logic_vector(to_unsigned(10, NTT_INST_SIZE));
 


  --Definition of Commands of the System
  constant PROC_ARG1_SIZE : integer := 4;
  constant PROC_ARG2_SIZE : integer := 4;
  constant PROC_INST_SIZE : integer := 5;

  constant INST_PROC_NTT_NOP                : std_logic_vector(PROC_INST_SIZE-1 downto 0) := std_logic_vector(to_unsigned(0, PROC_INST_SIZE));
  constant INST_PROC_NTT_BITREV_A           : std_logic_vector(PROC_INST_SIZE-1 downto 0) := std_logic_vector(to_unsigned(1, PROC_INST_SIZE));
  constant INST_PROC_NTT_BITREV_B           : std_logic_vector(PROC_INST_SIZE-1 downto 0) := std_logic_vector(to_unsigned(2, PROC_INST_SIZE));
  constant INST_PROC_NTT_NTT_A              : std_logic_vector(PROC_INST_SIZE-1 downto 0) := std_logic_vector(to_unsigned(3, PROC_INST_SIZE));
  constant INST_PROC_NTT_NTT_B              : std_logic_vector(PROC_INST_SIZE-1 downto 0) := std_logic_vector(to_unsigned(4, PROC_INST_SIZE));
  constant INST_PROC_NTT_POINTWISE_MUL      : std_logic_vector(PROC_INST_SIZE-1 downto 0) := std_logic_vector(to_unsigned(5, PROC_INST_SIZE));
  constant INST_PROC_NTT_INTT               : std_logic_vector(PROC_INST_SIZE-1 downto 0) := std_logic_vector(to_unsigned(6, PROC_INST_SIZE));
  constant INST_PROC_NTT_INV_PSI            : std_logic_vector(PROC_INST_SIZE-1 downto 0) := std_logic_vector(to_unsigned(7, PROC_INST_SIZE));
  constant INST_PROC_NTT_INV_N              : std_logic_vector(PROC_INST_SIZE-1 downto 0) := std_logic_vector(to_unsigned(8, PROC_INST_SIZE));
  constant INST_PROC_NTT_GP_MODE            : std_logic_vector(PROC_INST_SIZE-1 downto 0) := std_logic_vector(to_unsigned(9, PROC_INST_SIZE));
  constant INST_PROC_MOV                    : std_logic_vector(PROC_INST_SIZE-1 downto 0) := std_logic_vector(to_unsigned(10, PROC_INST_SIZE));
  constant INST_PROC_ADD                    : std_logic_vector(PROC_INST_SIZE-1 downto 0) := std_logic_vector(to_unsigned(11, PROC_INST_SIZE));
  constant INST_PROC_SUB                    : std_logic_vector(PROC_INST_SIZE-1 downto 0) := std_logic_vector(to_unsigned(12, PROC_INST_SIZE));
  constant INST_PROC_WAIT_UNI_SAMPLER_READY : std_logic_vector(PROC_INST_SIZE-1 downto 0) := std_logic_vector(to_unsigned(13, PROC_INST_SIZE));
  constant INST_PROC_IN                     : std_logic_vector(PROC_INST_SIZE-1 downto 0) := std_logic_vector(to_unsigned(14, PROC_INST_SIZE));
  constant INST_PROC_OUT                    : std_logic_vector(PROC_INST_SIZE-1 downto 0) := std_logic_vector(to_unsigned(15, PROC_INST_SIZE));
  --Should be disabled when output is used
  constant INST_PROC_ENABLE_COPY_TO_IO      : std_logic_vector(PROC_INST_SIZE-1 downto 0) := std_logic_vector(to_unsigned(16, PROC_INST_SIZE));
  constant INST_PROC_DISABLE_COPY_TO_IO     : std_logic_vector(PROC_INST_SIZE-1 downto 0) := std_logic_vector(to_unsigned(17, PROC_INST_SIZE));
 constant INST_PROC_POINTWISE_MUL      : std_logic_vector(PROC_INST_SIZE-1 downto 0) := std_logic_vector(to_unsigned(18, PROC_INST_SIZE));


  constant FFT_R0_PORT  : integer := 0;
  constant FFT_R1_PORT  : integer := 1;
  constant SAMPLER_PORT : integer := 2;
  constant IO_PORT      : integer := 3;


  type command_record_t is
  record
    op   : std_logic_vector(PROC_INST_SIZE-1 downto 0);
    arg0 : std_logic_vector(PROC_ARG1_SIZE-1 downto 0);
    arg1 : std_logic_vector(PROC_ARG2_SIZE-1 downto 0);
  end record;


  type inst_list_t is array(natural range <>) of command_record_t;


  function to_comm(op           : std_logic_vector(PROC_INST_SIZE-1 downto 0); arg0, arg1 : integer) return command_record_t;
  function get_init_vector(arg1 : integer) return string;
  function get_y_size(op : string) return integer;
    
end lattice_processor;



package body lattice_processor is

  function to_comm(op : std_logic_vector(PROC_INST_SIZE-1 downto 0); arg0, arg1 : integer) return command_record_t is
    variable command : command_record_t;
  begin
    command.op   := op;
    command.arg0 := std_logic_vector(to_unsigned(arg0, PROC_ARG1_SIZE));
    command.arg1 := std_logic_vector(to_unsigned(arg1, PROC_ARG2_SIZE));

    return command;
    
  end to_comm;



  function get_y_size(op : string) return integer is
  begin
    if op = "BOTH" or op="SIGN" then
      return 23;
    else
      return 0;
    end if;
  end get_y_size;




  function get_init_vector(arg1 : integer) return string is
  begin
    if arg1 = 0 then
      return "";
    elsif arg1 = 1 then
      return "C:\Users\thomas\SHA\Projekte\rewrite_signature\lattice_processor\lattice_processor\rtl\lwe_encryption\init\p.data";
      --return "p.data";
    elsif arg1 = 2 then
      return "C:\Users\thomas\SHA\Projekte\rewrite_signature\lattice_processor\lattice_processor\rtl\lwe_encryption\init\a.data";
      --return "a.data";
    elsif arg1 = 3 then
      return "C:\Users\thomas\SHA\Projekte\rewrite_signature\lattice_processor\lattice_processor\rtl\lwe_encryption\init\r2.data";
      --return "r2.data";
    elsif arg1 = 11 then
      return "C:\Users\thomas\SHA\Projekte\rewrite_signature\lattice_processor\lattice_processor\rtl\lyu_signature\set1\a_bin";
    elsif arg1 = 12 then
      return "C:\Users\thomas\SHA\Projekte\rewrite_signature\lattice_processor\lattice_processor\rtl\lyu_signature\set1\t_bin";
    elsif arg1 = 13 then
      return "C:\Users\thomas\SHA\Projekte\rewrite_signature\lattice_processor\lattice_processor\rtl\lyu_signature\set1\s_bin";
    elsif arg1 = 14 then
      return "C:\Users\thomas\SHA\Projekte\rewrite_signature\lattice_processor\lattice_processor\rtl\lyu_signature\set1\y1_bin";
    elsif arg1 = 15 then
      return "C:\Users\thomas\SHA\Projekte\rewrite_signature\lattice_processor\lattice_processor\rtl\lyu_signature\set1\y2_bin";


    --BLISS
     elsif arg1 = 42 then
      --return "C:\Users\thomas\SHA\Projekte\BLISS\code\bliss_arithmetic\lattice_processor\key\old_params\a_bin";
      return "C:\Users\thomas\SHA\Projekte\BLISS\code\bliss_arithmetic\lattice_processor\key\param_1\param1_a.txt";
      elsif arg1 = 43 then
      --return "C:\Users\thomas\SHA\Projekte\BLISS\code\bliss_arithmetic\lattice_processor\key\old_params\a_bin";
      return "C:\Users\thomas\SHA\Projekte\BLISS\code\bliss_arithmetic\lattice_processor\key\param_3\param3_a.txt";
       elsif arg1 = 44 then
      --return "C:\Users\thomas\SHA\Projekte\BLISS\code\bliss_arithmetic\lattice_processor\key\old_params\a_bin";
      return "C:\Users\thomas\SHA\Projekte\BLISS\code\bliss_arithmetic\lattice_processor\key\param_4\param4_a.txt";
    end if;



    return "";
    
  end get_init_vector;


end lattice_processor;
