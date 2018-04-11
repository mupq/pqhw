LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY compress IS
    GENERIC (
        paramQ          : UNSIGNED                      := to_unsigned(12289, 14)
    );
    PORT ( 
        in_coeff        : IN  STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
        out_coeff       : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END compress;

ARCHITECTURE Behavioral OF compress IS

    SIGNAL in_unsigned  :  UNSIGNED(paramQ'length-1 DOWNTO 0);

BEGIN

    in_unsigned <= UNSIGNED(in_coeff);
    
    
    out_coeff <= "0000";

END Behavioral;
