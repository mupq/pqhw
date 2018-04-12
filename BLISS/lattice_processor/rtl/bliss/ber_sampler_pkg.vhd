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

package ber_sampler_pkg is
  constant GLOBAL_PRECISION : integer := 128;

  function get_ber_k (param         : integer) return integer;
  function get_ber_precision (param : integer) return integer;
  function get_ber_max_x (param     : integer) return integer;
  function get_ber_max_sigma(param  : integer) return integer;
  function get_ber_sigma(param      : integer) return real;




  
end ber_sampler_pkg;

package body ber_sampler_pkg is

  function get_ber_sigma(param : integer) return real is
  begin
    if param = 1 then
      return 215.7277372731568368513;
    elsif param = 3 then
      return 250.5499310849656176028;
    elsif param = 4 then
      return 270.9336542918780746282;
    end if;
  end get_ber_sigma;

  function get_ber_max_sigma(param : integer) return integer is
  begin
    return get_ber_k(param)*get_ber_max_x(param)+get_ber_k(param)-1;
  end get_ber_max_sigma;

  function get_ber_k(param : integer) return integer is
  begin
    if param = 1 then
      return 254;
    elsif param =3  then
      return 295;
    elsif param =4  then
      return 320;
    end if;
  end;


  function get_ber_precision(param : integer) return integer is
  begin
    if param = 1 then
      return GLOBAL_PRECISION;
    elsif param = 3 then
      return GLOBAL_PRECISION;
    elsif param = 4 then
      return GLOBAL_PRECISION;
    end if;
  end;


  function get_ber_max_x(param : integer) return integer is
  begin
    if param = 1 then
      return 10;
    elsif param = 3 then
      return 10;
    elsif param = 4 then
      return 10;
    end if;
  end;

  
end ber_sampler_pkg;
