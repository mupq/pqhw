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


package lyu512_pkg is

  constant LYU_ARITH_COMMAND_SIZE : integer := 4;

  constant LYU_ARITH_NO_COMMAND : std_logic_vector(LYU_ARITH_COMMAND_SIZE-1 downto 0) := std_logic_vector(to_unsigned(0, LYU_ARITH_COMMAND_SIZE));

  constant LYU_ARITH_SIGN_MODE : std_logic_vector(LYU_ARITH_COMMAND_SIZE-1 downto 0) := std_logic_vector(to_unsigned(1, LYU_ARITH_COMMAND_SIZE));

  constant LYU_ARITH_COMP_AZ1 : std_logic_vector(LYU_ARITH_COMMAND_SIZE-1 downto 0) := std_logic_vector(to_unsigned(2, LYU_ARITH_COMMAND_SIZE));

  constant LYU_ARITH_ADD_Z2 : std_logic_vector(LYU_ARITH_COMMAND_SIZE-1 downto 0) := std_logic_vector(to_unsigned(3, LYU_ARITH_COMMAND_SIZE));

  constant LYU_ARITH_SUB_TC : std_logic_vector(LYU_ARITH_COMMAND_SIZE-1 downto 0) := std_logic_vector(to_unsigned(4, LYU_ARITH_COMMAND_SIZE));

  constant LYU_ARITH_STOP_SIGN : std_logic_vector(LYU_ARITH_COMMAND_SIZE-1 downto 0) := std_logic_vector(to_unsigned(5, LYU_ARITH_COMMAND_SIZE));


  function get_bliss_kappa(param_set    : integer) return integer;
  function get_bliss_d(param_set        : integer) return integer;
  function get_bliss_B2(param_set       : integer) return integer;
  function get_bliss_BInfty(param_set   : integer) return integer;
  function get_bliss_p(param_set        : integer) return unsigned;
  function get_bliss_p_length(param_set : integer) return integer ;
  function get_bliss_s1_length(param_set : integer) return integer ;
  function get_bliss_s2_length(param_set : integer) return integer ;
  function get_bliss_get_a_path(param_set : integer) return integer ;

  function get_bliss_M(param_set : integer) return integer ;


  
end lyu512_pkg;

package body lyu512_pkg is

  
  function get_bliss_M(param_set : integer) return integer is
  begin
    if param_set = 1 then
      return 46539;
    elsif param_set = 3 then
      return 128113;
    elsif param_set = 4 then
      return 244186;
      
    end if;
  end;


  
   function get_bliss_get_a_path(param_set : integer) return integer is
  begin
    if param_set = 1 then
      return 42;
    elsif param_set = 3 then
      return 43;
    elsif param_set = 4 then
      return 44;
      
    end if;
  end;

  
  function get_bliss_s1_length(param_set : integer) return integer is
  begin
    if param_set = 1 then
      return 2;
    elsif param_set = 3 then
      return 3;
    elsif param_set = 4 then
      return 3;
    end if;
  end;

  
  function get_bliss_s2_length(param_set : integer) return integer is
  begin
    if param_set = 1 then
      return 3;
    elsif param_set = 3 then
      return 4;
    elsif param_set = 4 then
      return 4;
    end if;
  end;
  

  function get_bliss_kappa(param_set : integer) return integer is
  begin
    if param_set = 1 then
      return 23;
    elsif param_set = 3 then
      return 30;
    elsif param_set = 4 then
      return 39;
    end if;
  end get_bliss_kappa;



  function get_bliss_d(param_set : integer) return integer is
  begin
    if param_set = 1 then
      return 10;
    elsif param_set = 3 then
      return 9;
    elsif param_set = 4 then
      return 8;
    end if;
  end;


  function get_bliss_B2(param_set : integer) return integer is
  begin
    if param_set = 1 then
      return 12872;
    elsif param_set = 3 then
      return 10206;
    elsif param_set = 4 then
      return 9901;
    end if;
  end;


  function get_bliss_BInfty(param_set : integer) return integer is
  begin
    if param_set = 1 then
      return 2100;
    elsif param_set = 3 then
      return 1760;
    elsif param_set = 4 then
      return 1613;
    end if;
  end;


  function get_bliss_p(param_set : integer) return unsigned is
  begin
    if param_set = 1 then
      return to_unsigned(24, 5);
    elsif param_set = 3 then
      return to_unsigned(48, 6);
    elsif param_set = 4 then
      return to_unsigned(96, 7);
    end if;
  end;


  function get_bliss_p_length(param_set : integer) return integer is
    constant p_bliss : unsigned := get_bliss_p(param_set);
  begin
    return p_bliss'length;
  end;


end lyu512_pkg;
