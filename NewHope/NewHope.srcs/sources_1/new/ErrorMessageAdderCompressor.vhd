--/****************************************************************************/
--Copyright (C) by Tobias Oder and the Chair for Security Engineering of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ErrorMessageAdderCompressor IS
        GENERIC(
            paramQ          : UNSIGNED     := to_unsigned(12289, 14);
            paramQhalf      : UNSIGNED     := to_unsigned(6144, 16);
            paramN          : INTEGER      := 1024
        );
        PORT( 
            clk             : IN  STD_LOGIC;
            reset           : IN  STD_LOGIC;
            en              : IN  STD_LOGIC;
            addr            : OUT STD_LOGIC_VECTOR(10-1 DOWNTO 0);
            data1           : IN  STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
            data_add        : IN  STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
            data_msg        : IN  STD_LOGIC;
            data_res        : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);            
            add_done        : OUT STD_LOGIC;
            poly_add_done   : OUT STD_LOGIC
        );
END ErrorMessageAdderCompressor;

ARCHITECTURE Behavioral OF ErrorMessageAdderCompressor IS

SIGNAL delay_cnt        : UNSIGNED(3 DOWNTO 0);

CONSTANT paramQ_15bits  : UNSIGNED(14 DOWNTO 0) := '0' & paramQ;
CONSTANT paramQ_16bits  : UNSIGNED(15 DOWNTO 0) := "00" & paramQ;
CONSTANT paramQ2_16bits : UNSIGNED(15 DOWNTO 0) := '0' & paramQ & '0';

CONSTANT paramQ_17bits  : UNSIGNED(16 DOWNTO 0) := "000" & paramQ;
CONSTANT paramQ2_17bits : UNSIGNED(16 DOWNTO 0) := "00" & paramQ & '0';
CONSTANT paramQ3_17bits : UNSIGNED(16 DOWNTO 0) := paramQ2_17bits + paramQ_17bits;
CONSTANT paramQ4_17bits : UNSIGNED(16 DOWNTO 0) := "0" & paramQ & "00";
CONSTANT paramQ5_17bits : UNSIGNED(16 DOWNTO 0) := paramQ4_17bits + paramQ_17bits;
CONSTANT paramQ6_17bits : UNSIGNED(16 DOWNTO 0) := paramQ3_17bits + paramQ3_17bits;
CONSTANT paramQ7_17bits : UNSIGNED(16 DOWNTO 0) := paramQ4_17bits + paramQ3_17bits;
CONSTANT paramQ8_17bits : UNSIGNED(16 DOWNTO 0) := paramQ & "000";

SIGNAL after_first_add  : UNSIGNED(14 DOWNTO 0);
SIGNAL after_second_add : UNSIGNED(15 DOWNTO 0);

SIGNAL no_red           : UNSIGNED(15 DOWNTO 0);
SIGNAL one_red          : UNSIGNED(15 DOWNTO 0);
SIGNAL two_red          : UNSIGNED(15 DOWNTO 0);

SIGNAL after_mul8       : UNSIGNED(16 DOWNTO 0);
SIGNAL after_addQhalf   : UNSIGNED(16 DOWNTO 0);

SIGNAL all_msg          : UNSIGNED(15 DOWNTO 0);

BEGIN
    
    all_msg <= (OTHERS => data_msg);
    
    ADD_PROC : PROCESS(clk)
       VARIABLE i : UNSIGNED(10 DOWNTO 0);
       BEGIN
            IF RISING_EDGE(clk) THEN
                IF reset='1' THEN
                    i := (OTHERS => '0');
                    delay_cnt       <= "1000";
                    addr            <= STD_LOGIC_VECTOR(i(9 DOWNTO 0));
                    poly_add_done   <= '0';
                    add_done        <= '0';
                    
                ELSIF en = '1' THEN  
                
                   after_first_add       <= UNSIGNED('0' & data1) + UNSIGNED('0' & data_add);    
                   after_second_add      <= ('0' & after_first_add) + (paramQhalf and all_msg);
                   
                   no_red <= after_second_add;            
                   one_red <= after_second_add - paramQ_16bits; 
                   two_red <= after_second_add - paramQ2_16bits; 
                   
                   IF(after_second_add >= paramQ2_16bits) THEN
                        after_mul8 <= two_red(13 DOWNTO 0) & "000";
                   ELSIF(after_second_add >= paramQ_16bits) THEN
                        after_mul8 <= one_red(13 DOWNTO 0) & "000";
                   ELSE
                        after_mul8 <= no_red(13 DOWNTO 0) & "000";
                   END IF;
                    
                   after_addQhalf <= after_mul8 + ("000" + paramQhalf);
                   
                   IF(after_addQhalf >= paramQ8_17bits) THEN
                        data_res <= "000";
                   ELSIF(after_addQhalf >= paramQ7_17bits) THEN 
                        data_res <= "111"; 
                   ELSIF(after_addQhalf >= paramQ6_17bits) THEN 
                        data_res <= "110";
                   ELSIF(after_addQhalf >= paramQ5_17bits) THEN 
                        data_res <= "101"; 
                   ELSIF(after_addQhalf >= paramQ4_17bits) THEN 
                        data_res <= "100";
                   ELSIF(after_addQhalf >= paramQ3_17bits) THEN 
                        data_res <= "011";
                   ELSIF(after_addQhalf >= paramQ2_17bits) THEN 
                        data_res <= "010";
                   ELSIF(after_addQhalf >= paramQ_17bits) THEN 
                        data_res <= "001";  
                   ELSE
                        data_res <= "000";
                   END IF;
                   
                   IF i = "10000000001" THEN
                        poly_add_done <= '1';
                   END IF;      
                                      
                   add_done <= '0';
                        
                   IF delay_cnt = "1000" THEN
                        delay_cnt <= "0000";                     
                        addr <= STD_LOGIC_VECTOR(i(9 DOWNTO 0));
                        i := i+1;
                    ELSIF delay_cnt = "0111" THEN
                        add_done <= '1';
                        delay_cnt <= delay_cnt + 1;     
                    ELSE
                        delay_cnt <= delay_cnt + 1;
                    END IF;                                   
                END IF;
            END IF;
    END PROCESS;


END Behavioral;
