-- The Keccak sponge function, designed by Guido Bertoni, Joan Daemen,
-- Michaël Peeters and Gilles Van Assche. For more information, feedback or
-- questions, please refer to our website: http://keccak.noekeon.org/

-- Implementation by the designers,
-- hereby denoted as "the implementer".

-- To the extent possible under law, the implementer has waived all copyright
-- and related or neighboring rights to the source code in this file.
-- http://creativecommons.org/publicdomain/zero/1.0/
library STD;
 use STD.textio.all;


  library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_misc.all;
    use IEEE.std_logic_arith.all;
    

library work;


package keccak_globals32 is


constant num_plane : integer := 5;
constant num_sheet : integer := 5;
constant logD : integer :=4;
constant N : integer := 64;

-- the following 5 blocks of declaration are used for parametrize the core


-- uncomment these 3 lines for 2 blocks of slices
--constant num_slices : integer := 2;
--constant bits_num_slices : integer :=1;
--constant bit_per_sub_lane : integer :=32;

-- uncomment these 3 lines for 4 blocks of slices
--constant num_slices : integer := 4;
--constant bits_num_slices : integer :=2;
--constant bit_per_sub_lane : integer :=16;

-- uncomment these 3 lines for 8 blocks of slices
--constant num_slices : integer := 8;
--constant bits_num_slices : integer :=3;
--constant bit_per_sub_lane : integer :=8;

-- uncomment these 3 lines for 16 blocks of slices
--constant num_slices : integer := 16;
--constant bits_num_slices : integer :=4;
--constant bit_per_sub_lane : integer :=4;

-- uncomment these 3 lines for 32 blocks of slices
constant num_slices : integer := 32;
constant bits_num_slices : integer :=5;
constant bit_per_sub_lane : integer :=2;


constant num_round : integer := 24;






--types
 type k_lane        is  array ((N-1) downto 0)  of std_logic; 
 type k_row	is array ( 4 downto 0) of std_logic;
 type k_slice	is array ( 4 downto 0) of k_row;
 type sub_lane	is array ((bit_per_sub_lane-1) downto 0) of std_logic;
 type sub_plane is array (4 downto 0) of sub_lane;
 type sub_state is array (4 downto 0) of sub_plane;   
 type k_plane        is array ((num_sheet-1) downto 0)  of k_lane;    
 type k_state        is array ((num_plane-1) downto 0)  of k_plane;  

end package;
