----------------------------------------------------------------------------------
-- COPYRIGHT (c) 2015 ALL RIGHT RESERVED
--
-- KRYPTOGRAPHIE AUF PROGRAMMIERBARER HARDWARE: REGISTER-FDE
----------------------------------------------------------------------------------



-- IMPORTS
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;



-- ENTITY
----------------------------------------------------------------------------------
ENTITY RegisterFDRE IS
    GENERIC (SIZE : POSITIVE := 8);
    PORT ( CLK      : IN    STD_LOGIC;
           RESET    : IN    STD_LOGIC;
           ENABLE   : IN    STD_LOGIC;
           D        : IN    STD_LOGIC_VECTOR((SIZE - 1) downto 0);
           Q        : OUT   STD_LOGIC_VECTOR((SIZE - 1) downto 0));
END RegisterFDRE;



-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF RegisterFDRE IS

BEGIN

    -- REGISTER PROCESS ----------------------------------------------------------
    PROCESS(CLK)
    BEGIN
        IF RISING_EDGE(CLK) THEN
            IF (RESET = '1') THEN
                Q <= (OTHERS => '0');
            ELSIF (ENABLE = '1') THEN 
                Q <= D;
            END IF;
        END IF;
    END PROCESS;
    ------------------------------------------------------------------------------

END Behavioral;
