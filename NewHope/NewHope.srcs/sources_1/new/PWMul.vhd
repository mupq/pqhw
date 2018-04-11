--/****************************************************************************/
--Copyright (C) by Tobias Oder and the Chair for Security Engineering of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY PWMul IS
        GENERIC(
            paramQ         : UNSIGNED     := to_unsigned(12289, 14);
            paramN         : INTEGER      := 1024
        );
        PORT( 
            clk         : IN  STD_LOGIC;
            reset       : IN  STD_LOGIC;
            en          : IN  STD_LOGIC;
            addr        : OUT STD_LOGIC_VECTOR(10-1 DOWNTO 0);
            data1       : IN  STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
            data2       : IN  STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
            data_add    : IN  STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
            data_res    : OUT STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);            
            mul_done    : OUT STD_LOGIC;
            poly_done   : OUT STD_LOGIC;
            dsp_sel     : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            dsp_a       : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
            dsp_b       : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
            dsp_c       : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
            dsp_d       : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
            dsp_res_red : IN STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0)
        );
END PWMul;

ARCHITECTURE Behavioral OF PWMul IS
    
    SIGNAL delay_cnt        : UNSIGNED(3 DOWNTO 0) := "0000";

BEGIN

    -- A*B+C
    dsp_sel     <= "00";
    dsp_a       <= "0" & data1;
    dsp_b       <= "0" & data2;
    dsp_c       <= "0" & data_add;
    dsp_d       <= (OTHERS => '0');

    data_res <= dsp_res_red;
    
    NTT_PROC : PROCESS(clk)
       VARIABLE i : UNSIGNED(10 DOWNTO 0);
       BEGIN
            IF RISING_EDGE(clk) THEN
                IF reset='1' THEN
                    i := (OTHERS => '0');
                    delay_cnt <= "1000";
                    addr <= STD_LOGIC_VECTOR(i(9 DOWNTO 0));
                    poly_done <= '0';
                    mul_done <= '0';
                    
                ELSIF en = '1' THEN               
                   IF i = "10000000001" THEN
                        poly_done <= '1';
                   END IF;      
                                      
                   mul_done <= '0';
                        
                   IF delay_cnt = "1000" THEN
                        delay_cnt <= "0000";                     
                        addr <= STD_LOGIC_VECTOR(i(9 DOWNTO 0));
                        i := i+1;
                    ELSIF delay_cnt = "0111" THEN
                        mul_done <= '1';
                        delay_cnt <= delay_cnt + 1;     
                    ELSE
                        delay_cnt <= delay_cnt + 1;
                    END IF;                                   
                END IF;
            END IF;
    END PROCESS;


END Behavioral;
