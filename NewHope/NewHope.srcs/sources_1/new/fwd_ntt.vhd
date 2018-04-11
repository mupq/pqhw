--/****************************************************************************/
--Copyright (C) by Tobias Oder and the Chair for Security Engineering of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY fwd_ntt IS
    GENERIC(
        paramQ  : UNSIGNED     := to_unsigned(12289, 14);
        paramN  : INTEGER      := 1024
    );
    PORT( 
        clk             : IN  STD_LOGIC;
        reset           : IN  STD_LOGIC;
        en              : IN  STD_LOGIC;
        fwd_bwd         : IN  STD_LOGIC;
        addr1           : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        addr2           : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        addr_psi        : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        data1           : IN  STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
        data2           : IN  STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
        data_psi        : IN  STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
        data_res1       : OUT STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
        data_res2       : OUT STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
        butterfly_done  : OUT STD_LOGIC;
        ntt_done        : OUT STD_LOGIC;
        dsp_sel         : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        dsp_a           : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
        dsp_b           : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
        dsp_c           : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
        dsp_d           : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
        dsp_res_red     : IN STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0)
    );
END fwd_ntt;

ARCHITECTURE Behavioral OF fwd_ntt IS

    COMPONENT xbip_dsp48_macro_0 IS
      PORT (
          CLK : IN STD_LOGIC;
          SEL : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
          A : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
          B : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
          C : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
          D : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
          P : OUT STD_LOGIC_VECTOR(30 DOWNTO 0)
        );
    END COMPONENT;
    
    COMPONENT red_12289 IS
        port (
        clk   : IN  STD_LOGIC;
        val   : IN  UNSIGNED(2*14-1 DOWNTO 0) := (OTHERS => '0');
        red   : OUT UNSIGNED(14-1 DOWNTO 0)   := (OTHERS => '0')
        );
    END COMPONENT;
    
    SIGNAL res2_nored  : STD_LOGIC_VECTOR(30 DOWNTO 0);
    SIGNAL res2_pos    : STD_LOGIC_VECTOR(30 DOWNTO 0);
    
    SIGNAL data_res2_intern : UNSIGNED(paramQ'length-1 DOWNTO 0);
    
    SIGNAL delay_cnt     : UNSIGNED(3 DOWNTO 0) := "0000";

BEGIN

    -- A*B+C
    -- A + D
    dsp_sel     <= fwd_bwd & "0";
    dsp_a       <= "0" & data2;
    dsp_b       <= "0" & data_psi;
    dsp_c       <= "0" & data1;
    dsp_d       <= "0" & data1;
    
    -- C-(A*B)
    -- (D-A)*B
    ntt_dsp2: xbip_dsp48_macro_0
    PORT MAP(
        CLK => clk,
        SEL => fwd_bwd & "1",
        A => "0" & data2,
        B => "0" & data_psi,
        C => "0" & data1,
        D => "0" & data1,
        P => res2_nored
    );
    
    WITH res2_nored(30) SELECT 
    res2_pos <= STD_LOGIC_VECTOR(SIGNED(res2_nored) + (12289*12289)) WHEN '1',
    res2_nored WHEN OTHERS;
    

    
    ntt_red2 : red_12289
    PORT MAP(
        clk => clk,
        val => UNSIGNED(res2_pos(27 DOWNTO 0)),
        red => data_res2_intern
    );
    
    data_res1 <= dsp_res_red;
    data_res2 <= STD_LOGIC_VECTOR(data_res2_intern);
    
    -- address generation
    -- following the description from https://eprint.iacr.org/2016/504.pdf
    NTT_PROC : PROCESS(clk)
       VARIABLE m,t,i,j,j1,j2 : UNSIGNED(9 DOWNTO 0);
       BEGIN
            IF RISING_EDGE(clk) THEN
                IF reset='1' THEN
                    IF fwd_bwd='0' THEN                    
                        
                        t := to_unsigned(paramN/2, 10);
                        m := "0000000001";
                        i := (OTHERS => '0');
                        j1 := (OTHERS => '0');
                        j := (OTHERS => '0');
                        j2 := to_unsigned((paramN/2), 10);
                        addr_psi <= STD_LOGIC_VECTOR(m + i);
                        
                    ELSE
                        
                        t := "0000000001";
                        m := to_unsigned(paramN/2, 10); --actually h
                        i := (OTHERS => '0');
                        j1 := (OTHERS => '0');
                        j := (OTHERS => '0');
                        j2 := "0000000001";
                        addr_psi <= STD_LOGIC_VECTOR(m + i);
                        
                    END IF;

                    delay_cnt <= "0110";
                    addr1 <= STD_LOGIC_VECTOR(j);
                    addr2 <= STD_LOGIC_VECTOR(j+t);
                    butterfly_done <= '0';
                    ntt_done <= '0';
                    
                ELSIF en = '1' THEN
                    IF fwd_bwd='0' THEN                   
                       IF m = "0000000000" THEN
                            ntt_done <= '1';
                       END IF;                        
                    ELSE
                        IF m = "0000000000" THEN
                            ntt_done <= '1';
                       END IF; 
                        
                    END IF; 
                    butterfly_done <= '0';
                    IF delay_cnt = "0110" THEN
                        delay_cnt <= "0000"; 
                                               
                        IF fwd_bwd='0' THEN
                            IF j = j2 THEN
                                i := i + 1;
                                j1 := j1 + (t(8 DOWNTO 0) & '0');
                                j2 := j2 + (t(8 DOWNTO 0) & '0');
                                addr_psi <= STD_LOGIC_VECTOR(m + i);
                                j := j1;
                                IF i = m THEN
                                    m := m(8 DOWNTO 0) & '0';
                                    t := '0' & t(9 DOWNTO 1);                          
                                    j1 := (OTHERS => '0');
                                    j2 := t;
                                    i := (OTHERS => '0');
                                END IF;
                            END IF;                        
                                                
                            addr1 <= STD_LOGIC_VECTOR(j);
                            addr2 <= STD_LOGIC_VECTOR(j+t); 
                            j := j+1;
                        ELSE
                            IF j = j2 THEN
                                i := i + 1;
                                j1 := j1 + (t(8 DOWNTO 0) & '0');
                                j2 := j2 + (t(8 DOWNTO 0) & '0');                                
                                j := j1;
                                IF i = m THEN
                                    m := '0' & m(9 DOWNTO 1);
                                    t := t(8 DOWNTO 0) & '0';                          
                                    j1 := (OTHERS => '0');
                                    j2 := t;
                                    i := (OTHERS => '0');
                                END IF;
                                addr_psi <= STD_LOGIC_VECTOR(m + i);
                            END IF;                        
                                            
                            addr1 <= STD_LOGIC_VECTOR(j);
                            addr2 <= STD_LOGIC_VECTOR(j+t); 
                            j := j+1;
                            
                        END IF;
                     ELSIF delay_cnt = "0101" THEN
                        butterfly_done <= '1';
                        delay_cnt <= delay_cnt + 1;     
                     ELSE
                        delay_cnt <= delay_cnt + 1;
                     END IF;                                   
                END IF;
            END IF;
    END PROCESS;
    
    

END Behavioral;
