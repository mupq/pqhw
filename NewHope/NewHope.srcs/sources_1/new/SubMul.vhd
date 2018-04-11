--/****************************************************************************/
--Copyright (C) by Tobias Oder and the Chair for Security Engineering of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY SubMul IS
    GENERIC(
        paramQ         : UNSIGNED     := to_unsigned(12289, 14);
        paramN         : INTEGER      := 1024;
        paramNINV      : STD_LOGIC_VECTOR(13 DOWNTO 0) := "10111111110101"
    );
    PORT( 
        clk             : IN  STD_LOGIC;
        reset           : IN  STD_LOGIC;
        en              : IN  STD_LOGIC;
        addr            : OUT STD_LOGIC_VECTOR(10-1 DOWNTO 0);
        data1           : IN  STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
        poly_c          : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        data_res        : OUT STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);            
        sub_done        : OUT STD_LOGIC;
        poly_done       : OUT STD_LOGIC;
        dsp_sel         : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        dsp_a           : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
        dsp_b           : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
        dsp_c           : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
        dsp_d           : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
        dsp_res_nored   : IN STD_LOGIC_VECTOR(30 DOWNTO 0)
    );
END SubMul;

ARCHITECTURE Behavioral OF SubMul IS

    COMPONENT red_12289 IS
        port (
        clk   : IN  STD_LOGIC;
        val   : IN  UNSIGNED(2*14-1 DOWNTO 0) := (OTHERS => '0');
        red   : OUT UNSIGNED(14-1 DOWNTO 0)   := (OTHERS => '0')
        );
    END COMPONENT;
    
    SIGNAL res_pos    : STD_LOGIC_VECTOR(30 DOWNTO 0);
    
    SIGNAL data_res_intern : UNSIGNED(paramQ'length-1 DOWNTO 0);
    
    SIGNAL delay_cnt        : UNSIGNED(3 DOWNTO 0) := "0000";

BEGIN

    -- C-A*B
    dsp_sel     <= "01";
    dsp_a       <= "0" & data1;
    dsp_b       <= "0" & paramNINV;
    
    WITH poly_c SELECT dsp_c <=
        (OTHERS => '0')     WHEN "000",
        "000011000000000"   WHEN "001",
        "000110000000000"   WHEN "010",
        "001001000000000"   WHEN "011",
        "001100000000000"   WHEN "100",
        "001111000000001"   WHEN "101",
        "010010000000001"   WHEN "110",
        "010101000000001"   WHEN "111",
        (OTHERS => 'U')     WHEN OTHERS;

    dsp_d       <= (OTHERS => '0');

    WITH dsp_res_nored(30) SELECT res_pos <= 
    STD_LOGIC_VECTOR(SIGNED(dsp_res_nored) + (12289*12289)) WHEN '1',
    dsp_res_nored WHEN OTHERS;    

    
    ntt_red2 : red_12289
    PORT MAP(
        clk => clk,
        val => UNSIGNED(res_pos(27 DOWNTO 0)),
        red => data_res_intern
    );
    
    data_res <= STD_LOGIC_VECTOR(data_res_intern);
    
    SUB_PROC : PROCESS(clk)
       VARIABLE i : UNSIGNED(10 DOWNTO 0);
       BEGIN
            IF RISING_EDGE(clk) THEN
                IF reset='1' THEN
                    i := (OTHERS => '0');
                    delay_cnt <= "1000";
                    addr <= STD_LOGIC_VECTOR(i(9 DOWNTO 0));
                    poly_done <= '0';
                    sub_done <= '0';
                    
                ELSIF en = '1' THEN               
                   IF i = "10000000001" THEN
                        poly_done <= '1';
                   END IF;      
                                      
                   sub_done <= '0';
                        
                   IF delay_cnt = "1000" THEN
                        delay_cnt <= "0000";                     
                        addr <= STD_LOGIC_VECTOR(i(9 DOWNTO 0));
                        i := i+1;
                    ELSIF delay_cnt = "0111" THEN
                        sub_done <= '1';
                        delay_cnt <= delay_cnt + 1;     
                    ELSE
                        delay_cnt <= delay_cnt + 1;
                    END IF;                                   
                END IF;
            END IF;
    END PROCESS;

END Behavioral;
