--/****************************************************************************/
--Copyright (C) by Tobias Oder and the Chair for Security Engineering of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/

LIBRARY IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY abs_mod IS
    GENERIC (
            paramQ          : SIGNED  := to_signed(12289, 15);
            paramQhalf      : SIGNED  := to_signed(6144, 15)
    );
    PORT ( 
            val_in   : IN STD_LOGIC_VECTOR(paramQ'length-2 DOWNTO 0);
            val_out  : OUT STD_LOGIC_VECTOR(paramQ'length-2 DOWNTO 0)
    );
END abs_mod;

ARCHITECTURE Behavioral OF abs_mod IS

    SIGNAL val_in_signed, val_after_sub, val_out_signed   : SIGNED(paramQ'length-1 DOWNTO 0);

BEGIN

    val_in_signed   <= SIGNED('0' & val_in);
    val_after_sub   <= val_in_signed WHEN (val_in_signed<=paramQhalf)   ELSE (val_in_signed-paramQ);
    val_out_signed  <= val_after_sub WHEN (val_after_sub>=0)            ELSE (TO_SIGNED(0,15)-val_after_sub);
    val_out         <= STD_LOGIC_VECTOR(val_out_signed(paramQ'length-2 DOWNTO 0));
    

END Behavioral;
