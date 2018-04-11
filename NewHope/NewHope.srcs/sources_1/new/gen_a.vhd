--/****************************************************************************/
--Copyright (C) by Tobias Oder and the Chair for Security Engineering of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY gen_a IS
    GENERIC(
        paramQ         : UNSIGNED     := to_unsigned(12289, 14)
    );
    PORT( 
        clk         :  IN STD_LOGIC;
        reset       :  IN STD_LOGIC;
        en          :  IN STD_LOGIC;
        keccak_out  :  IN STD_LOGIC_VECTOR(1343 DOWNTO 0);
        keccak_done :  IN STD_LOGIC; 
        coeff_out1  : OUT STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
        coeff_out2  : OUT STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
        coeff_out3  : OUT STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0)
    );
END gen_a;

ARCHITECTURE Behavioral OF gen_a IS

    SIGNAL index                            : INTEGER range 0 to 31 := 0;
    SIGNAL buffer_1a, buffer_1b, buffer_1c  : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    SIGNAL buffer_2a, buffer_2b, buffer_2c  : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    SIGNAL buffer_3a, buffer_3b, buffer_3c  : STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
    SIGNAL buffer_sets                      : STD_LOGIC_VECTOR(8 DOWNTO 0);
    
    SIGNAL sel1, sel2, sel3                 : STD_LOGIC_VECTOR(3 DOWNTO 0);
    
    SIGNAL keccak_out_intern                : STD_LOGIC_VECTOR(1343 DOWNTO 0);

BEGIN

                    
    sel1 <= buffer_sets(0) & buffer_sets(7) & buffer_sets(5) & buffer_sets(4);
    sel2 <= buffer_sets(3) & buffer_sets(1) & buffer_sets(8) & buffer_sets(7);
    sel3 <= buffer_sets(6) & buffer_sets(4) & buffer_sets(2) & buffer_sets(1);

    GEN_PROC : PROCESS(clk)       
       BEGIN
       IF RISING_EDGE(clk) THEN
            IF reset='1' THEN
                index       <= 0;
                buffer_1a   <= (OTHERS => '0');
                buffer_1b   <= (OTHERS => '0');
                buffer_1c   <= (OTHERS => '0');
                buffer_2a   <= (OTHERS => '0');
                buffer_2b   <= (OTHERS => '0');
                buffer_2c   <= (OTHERS => '0');
                buffer_3a   <= (OTHERS => '0');
                buffer_3b   <= (OTHERS => '0');
                buffer_3c   <= (OTHERS => '0');
                buffer_sets <= (OTHERS => '0');
                
            ELSIF en = '1' THEN   
                IF(keccak_done = '1') THEN
                    index <= 0;
                    buffer_1a   <= (OTHERS => '0');
                    buffer_1b   <= (OTHERS => '0');
                    buffer_1c   <= (OTHERS => '0');
                    buffer_2a   <= (OTHERS => '0');
                    buffer_2b   <= (OTHERS => '0');
                    buffer_2c   <= (OTHERS => '0');
                    buffer_3a   <= (OTHERS => '0');
                    buffer_3b   <= (OTHERS => '0');
                    buffer_3c   <= (OTHERS => '0');
                    buffer_sets <= (OTHERS => '0');
                    keccak_out_intern <= keccak_out;
                    
                    --output logic                    
                    CASE sel1 IS
                        WHEN "0001" =>
                            coeff_out1 <= buffer_2b;
                        WHEN "0010" =>
                            coeff_out1 <= buffer_2c;
                        WHEN "0011" =>
                            coeff_out1 <= buffer_2c;
                        WHEN "0100" =>
                            coeff_out1 <= buffer_3b;
                        WHEN "0101" =>
                            coeff_out1 <= buffer_3b;
                        WHEN "0110" =>
                            coeff_out1 <= buffer_3b;
                        WHEN "0111" =>
                            coeff_out1 <= buffer_3b;
                        WHEN "1000" =>
                            coeff_out1 <= buffer_1a;
                        WHEN "1001" =>
                            coeff_out1 <= buffer_1a;
                        WHEN "1010" =>
                            coeff_out1 <= buffer_1a;
                        WHEN "1011" =>
                            coeff_out1 <= buffer_1a;
                        WHEN "1100" =>
                            coeff_out1 <= buffer_1a;
                        WHEN "1101" =>
                            coeff_out1 <= buffer_1a;
                        WHEN "1110" =>
                            coeff_out1 <= buffer_1a;
                        WHEN "1111" =>
                            coeff_out1 <= buffer_1a;
                        WHEN OTHERS =>
                            coeff_out1 <= (OTHERS => '0');
                    END CASE;
                    
                    CASE sel2 IS
                        WHEN "0001" =>
                            coeff_out2 <= buffer_3b;
                        WHEN "0010" =>
                            coeff_out2 <= buffer_3c;
                        WHEN "0011" =>
                            coeff_out2 <= buffer_3c;
                        WHEN "0100" =>
                            coeff_out2 <= buffer_1b;
                        WHEN "0101" =>
                            coeff_out2 <= buffer_1b;
                        WHEN "0110" =>
                            coeff_out2 <= buffer_1b;
                        WHEN "0111" =>
                            coeff_out2 <= buffer_1b;
                        WHEN "1000" =>
                            coeff_out2 <= buffer_2a;
                        WHEN "1001" =>
                            coeff_out2 <= buffer_2a;
                        WHEN "1010" =>
                            coeff_out2 <= buffer_2a;
                        WHEN "1011" =>
                            coeff_out2 <= buffer_2a;
                        WHEN "1100" =>
                            coeff_out2 <= buffer_2a;
                        WHEN "1101" =>
                            coeff_out2 <= buffer_2a;
                        WHEN "1110" =>
                            coeff_out2 <= buffer_2a;
                        WHEN "1111" =>
                            coeff_out2 <= buffer_2a;
                        WHEN OTHERS =>
                            coeff_out2 <= (OTHERS => '0');
                    END CASE;
                    
                    CASE sel3 IS
                        WHEN "0001" =>
                            coeff_out3 <= buffer_1b;
                        WHEN "0010" =>
                            coeff_out3 <= buffer_1c;
                        WHEN "0011" =>
                            coeff_out3 <= buffer_1c;
                        WHEN "0100" =>
                            coeff_out3 <= buffer_2b;
                        WHEN "0101" =>
                            coeff_out3 <= buffer_2b;
                        WHEN "0110" =>
                            coeff_out3 <= buffer_2b;
                        WHEN "0111" =>
                            coeff_out3 <= buffer_2b;
                        WHEN "1000" =>
                            coeff_out3 <= buffer_3a;
                        WHEN "1001" =>
                            coeff_out3 <= buffer_3a;
                        WHEN "1010" =>
                            coeff_out3 <= buffer_3a;
                        WHEN "1011" =>
                            coeff_out3 <= buffer_3a;
                        WHEN "1100" =>
                            coeff_out3 <= buffer_3a;
                        WHEN "1101" =>
                            coeff_out3 <= buffer_3a;
                        WHEN "1110" =>
                            coeff_out3 <= buffer_3a;
                        WHEN "1111" =>
                            coeff_out3 <= buffer_3a;
                        WHEN OTHERS =>
                            coeff_out3 <= (OTHERS => '0');
                    END CASE;
                    
                ELSE
                    -- skip two bits to make it more efficient in sw (16 bit intervals but 14 bit words)
                    IF(unsigned(keccak_out_intern((index+1)*16-3 DOWNTO index*16)) < paramQ) THEN
                        IF(buffer_sets(0) = '0') THEN
                            buffer_sets(0) <= '1';
                            buffer_1a <= keccak_out_intern((index+1)*16-3 DOWNTO index*16);
                        ELSIF(buffer_sets(1) = '0') THEN
                            buffer_sets(1) <= '1';
                            buffer_1b <= keccak_out_intern((index+1)*16-3 DOWNTO index*16);
                        ELSIF(buffer_sets(2) = '0') THEN
                            buffer_sets(2) <= '1';
                            buffer_1c <= keccak_out_intern((index+1)*16-3 DOWNTO index*16);
                        END IF;
                    END IF;
                    
                    IF(unsigned(keccak_out_intern((25*16)+(index+1)*16-3 DOWNTO (25*16)+index*16)) < paramQ) THEN
                        IF(buffer_sets(3) = '0') THEN
                            buffer_sets(3) <= '1';
                            buffer_2a <= keccak_out_intern((25*16)+(index+1)*16-3 DOWNTO (25*16)+index*16);
                        ELSIF(buffer_sets(4) = '0') THEN
                            buffer_sets(4) <= '1';
                            buffer_2b <= keccak_out_intern((25*16)+(index+1)*16-3 DOWNTO (25*16)+index*16);
                        ELSIF(buffer_sets(5) = '0') THEN
                            buffer_sets(5) <= '1';
                            buffer_2c <= keccak_out_intern((25*16)+(index+1)*16-3 DOWNTO (25*16)+index*16);
                        END IF;
                    END IF;
                    
                    IF(unsigned(keccak_out_intern((50*16)+(index+1)*16-3 DOWNTO (50*16)+index*16)) < paramQ) THEN
                        IF(buffer_sets(6) = '0') THEN
                            buffer_sets(6) <= '1';
                            buffer_3a <= keccak_out_intern((50*16)+(index+1)*16-3 DOWNTO (50*16)+index*16);
                        ELSIF(buffer_sets(7) = '0') THEN
                            buffer_sets(7) <= '1';
                            buffer_3b <= keccak_out_intern((50*16)+(index+1)*16-3 DOWNTO (50*16)+index*16);
                        ELSIF(buffer_sets(8) = '0') THEN
                            buffer_sets(8) <= '1';
                            buffer_3c <= keccak_out_intern((50*16)+(index+1)*16-3 DOWNTO (50*16)+index*16);
                        END IF;
                    END IF;
                    
                    index <= index+1;
                END IF;
            END IF;
        END IF;
    END PROCESS;

END Behavioral;
