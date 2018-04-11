--/****************************************************************************/
--Copyright (C) by Tobias Oder and the Chair for Security Engineering of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY bin_sample IS
    GENERIC(
        paramQ : UNSIGNED  := to_unsigned(12289, 14);
        paramK : integer := 11;
        KEY    : STD_LOGIC_VECTOR := X"21646e6172202e78616d"
    );
    PORT( 
        clk         : IN  STD_LOGIC;
        en          : IN  STD_LOGIC;
        reset       : IN  STD_LOGIC;
        sample_done : OUT STD_LOGIC;
        gauss_out   : OUT STD_LOGIC_VECTOR (paramQ'length-1 DOWNTO 0)
    );
END bin_sample;

ARCHITECTURE Behavioral OF bin_sample IS

    -- TODO: 80 bits sufficient?!
    COMPONENT trivium_rub IS
      PORT (clk          : IN  STD_LOGIC;
            reset        : IN  STD_LOGIC;
            clk_en       : IN  STD_LOGIC;   --will cause pause when '0'     
            KEY          : IN  STD_LOGIC_VECTOR(79 DOWNTO 0);  --key meant as LE input 
            IV           : IN  STD_LOGIC_VECTOR(79 DOWNTO 0);  --IV meant as LE input 
            stream       : OUT STD_LOGIC);              
    END COMPONENT;
    
    SIGNAL sum      : SIGNED(paramQ'length-1 DOWNTO 0);
    SIGNAL sum_pos  : SIGNED(paramQ'length-1 DOWNTO 0);
    SIGNAL cycle_cnt : integer := 0;

    TYPE states is(ADD, SUB);
    SIGNAL state : states;
    SIGNAL in_vec : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL rand_stream : STD_LOGIC;
    SIGNAL done_intern : STD_LOGIC;

BEGIN

    sample_done <= done_intern;

    trivium1 : trivium_rub
      PORT MAP (
        clk => clk,
        reset => reset,
         clk_en => en,
         KEY => KEY,
         IV => X"00000000000000000000",
         stream => rand_stream
      );
    
    sum_pos <= sum + SIGNED(STD_LOGIC_VECTOR(paramQ));    
    
    in_vec(0) <= rand_stream;
    in_vec(1) <= '0';
    
    REG0 : PROCESS(clk)
        BEGIN
        IF RISING_EDGE(clk) THEN
            IF(en = '1') THEN
                IF(sum >= 0) THEN
                    gauss_out <= STD_LOGIC_VECTOR(sum);
                ELSE
                    gauss_out <= STD_LOGIC_VECTOR(sum_pos);
                END IF;
            END IF;
        END IF;
    END PROCESS;
    
    FSM : PROCESS(clk)
        BEGIN
            IF RISING_EDGE(clk) THEN
                IF (reset = '1') THEN
                    sum <= to_signed(0, sum'length);
                    state <= ADD;
                ELSIF (done_intern = '1') THEN
                    sum <= signed("000000000000" & in_vec);	
                    state <= SUB;	
                ELSE 
                    IF en = '1' THEN
                        IF (state = ADD) THEN
                            sum <= sum + signed(in_vec);
                            state <= SUB;
                        ELSE
                            sum <= sum - signed(in_vec);
                            state <= ADD;
                        END IF;
                    END IF;
                END IF;						
            END IF;
    END PROCESS;
    
    DONE_PROC : PROCESS(clk)
        BEGIN
            IF RISING_EDGE(clk) THEN
                IF (reset = '1') THEN
                    cycle_cnt <= 0;
                    done_intern <= '0';    
                ELSIF en = '1' THEN
                    IF(cycle_cnt = 2*paramK) THEN
                        cycle_cnt <= 0;
                        done_intern <= '1';
                    ELSE
                        done_intern <= '0';
                        cycle_cnt <= cycle_cnt + 1;
                    END IF;
                END IF;
            END IF;
    END PROCESS;

END Behavioral;

