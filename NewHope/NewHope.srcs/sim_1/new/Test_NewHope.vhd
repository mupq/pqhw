LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
LIBRARY STD;
USE STD.TEXTIO.ALL;


ENTITY Test_NewHope is
END Test_NewHope;

ARCHITECTURE Behavioral of Test_NewHope IS

    COMPONENT NewHope_Server IS
        GENERIC (
            paramQ  : unsigned     := to_unsigned(12289, 14);
            paramN  : integer      := 1024;
            paramK  : integer      := 16
        );
        PORT (  
            clk           : IN  STD_LOGIC;
            reset         : IN  STD_LOGIC;
            en            : IN STD_LOGIC;
            a_seed        : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            poly_b        : OUT STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
            poly_u        : IN STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
            poly_c        : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            streaming     : OUT STD_LOGIC;
            done_first    : OUT STD_LOGIC;
            done_second   : OUT STD_LOGIC;
            finalize      : IN  STD_LOGIC;
            request_c     : OUT  STD_LOGIC;
            key           : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;
    
    COMPONENT NewHope_Client IS
        GENERIC (
        paramQ          : UNSIGNED     := to_unsigned(12289, 14);
        paramN          : INTEGER      := 1024;
        paramNlength    : INTEGER      := 10;
        paramK          : INTEGER      := 16
    );
    PORT (  
        clk           : IN  STD_LOGIC;
        reset         : IN  STD_LOGIC;
        en            : IN STD_LOGIC;
        a_seed        : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        poly_b        : IN STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
        poly_u        : OUT STD_LOGIC_VECTOR(paramQ'length-1 DOWNTO 0);
        poly_c        : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        streaming     : OUT STD_LOGIC;
        request_b     : OUT STD_LOGIC;
        done          : OUT STD_LOGIC;
        key           : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
    END COMPONENT;

    SIGNAL CLK   : STD_LOGIC := '0';
    SIGNAL EN, en_client     : STD_LOGIC := '0';
    SIGNAL RST, rst_client   : STD_LOGIC := '0';
    SIGNAL DONE1 : STD_LOGIC := '0';
    SIGNAL DONE2 : STD_LOGIC := '0';
    SIGNAL done_client : STD_LOGIC := '0';
    SIGNAL finalize : STD_LOGIC := '0';
    SIGNAL streaminga, streamingb : STD_LOGIC;
    SIGNAL request_b : STD_LOGIC;
    SIGNAL request_c  :  STD_LOGIC;
    SIGNAL poly_c : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL poly_u : STD_LOGIC_VECTOR(13 DOWNTO 0);
    SIGNAL poly_b : STD_LOGIC_VECTOR(13 DOWNTO 0);
    SIGNAL poly_c_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL poly_u_out : STD_LOGIC_VECTOR(13 DOWNTO 0);
    SIGNAL poly_b_out : STD_LOGIC_VECTOR(13 DOWNTO 0);
    SIGNAL key_outa, key_outb : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL a_seed_server, a_seed_client : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL a_seed_fix : STD_LOGIC_VECTOR(255 DOWNTO 0) := X"4847464544434241383736353433323128272625242322211817161514131211";

    CONSTANT CLK_PERIOD : TIME := 10 NS;
    
    procedure do_check(first, second:std_logic_vector) is
        variable msg:line;
        begin
        if(first=second) then
            write(msg,string'("Test"));
            write(msg,string'(" OK"));
        else
            write(msg,string'("Test"));
            write(msg,string'(" Failed "));
            write(msg,first);
            write (msg, string'(" should be "));
            write(msg,second);
        end if;
        assert (first=second) report msg.all severity error;
        assert (first/=second) report msg.all severity note;
    end procedure do_check;

BEGIN

    server : NewHope_Server
    PORT MAP(
        clk         => CLK,
        reset       => RST,
        en          => EN,
        a_seed      => a_seed_server,
        poly_b      => poly_b_out,
        poly_u      => poly_u,
        poly_c      => poly_c,
        done_first  => DONE1,
        done_second => DONE2,
        streaming   => streaminga,
        finalize    => finalize,
        request_c   => request_c,
        key         => key_outb
    );

    client : NewHope_Client
    PORT MAP(
        clk         => CLK,
        reset       => rst_client,
        en          => en_client,
        a_seed      => a_seed_client,
        poly_b      => poly_b,
        poly_u      => poly_u_out,
        poly_c      => poly_c_out,
        streaming   => streamingb,
        request_b   => request_b,
        done        => done_client,
        key         => key_outa
    );


    CLK_PROC : PROCESS
    BEGIN
        CLK <= '1'; WAIT FOR CLK_PERIOD/2;
        CLK <= '0'; WAIT FOR CLK_PERIOD/2;
    END PROCESS;
    
    STIM_PROC : PROCESS
    BEGIN
        WAIT FOR 100 NS;
        
        RST <= '1';
        rst_client <= '1';
        
        EN <= '0';
        en_client <= '0';
        
        WAIT FOR 2*CLK_PERIOD;
        
        RST <= '0';
        EN <= '1';
        
        WAIT UNTIL streaminga = '1';
        WAIT FOR 4*CLK_PERIOD;
        
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2cdf#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#ef6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#bd4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#bc1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1008#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2f1c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2dc9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#225c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2f55#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1e0b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1876#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1758#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#731#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#f84#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#702#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1f47#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1541#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#25a7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#143d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#27a7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1866#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1e34#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2a66#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2745#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2780#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#29f4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2a09#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1c31#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1906#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#922#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#16ac#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#ed#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#56#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2db4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#10e4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#15f6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#4dc#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#148#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#d63#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#273f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#13ad#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2087#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#238e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#240d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#131e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1483#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1c18#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#d3d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1177#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#16ed#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#817#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2731#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#6af#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#c3e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2d6f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1d11#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#ab4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1194#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#a3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1c3d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2e47#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2fb9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1e8e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#19#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#18c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#289f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1f47#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#20b1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1904#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#4ff#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2777#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1be0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2624#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2692#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#f30#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1a84#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#24f6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#e4d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#20cb#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#820#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1eac#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#127f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#29ae#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1d68#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1dd1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2ab7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#a5a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2f50#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#29b9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2ccb#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#27ff#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#595#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#bb7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1f48#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2b53#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1452#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#71c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#23f3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#28d4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#212a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#276c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2889#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#258f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1964#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2f7b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#14ad#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1f51#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#98#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#256c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#d5c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1171#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#17db#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#23e9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1d08#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2ac7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#110f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#185b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1ae9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#896#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#283d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1fd8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2b8c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2685#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#18f0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2515#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#25d7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#e48#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1a39#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2233#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#80a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#154c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2fe8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#ca6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#163b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2979#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#10e5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#13e3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2024#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1be3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#926#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1946#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2eb8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#be3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2862#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#111a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#179e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2075#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1a7c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#141#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1cb8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1f50#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#17c7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1192#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#25ca#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1e5f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1e16#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#d1b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1db8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#160d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1ae4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2844#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1bf8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2bbf#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1590#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1dd6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#270a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#16b1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#a92#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#b1c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#18f3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2781#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#15f1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1196#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#77f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#12c7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1d7c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2017#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2973#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1578#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1e57#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#18d0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#39c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#16fb#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#21bd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2096#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#400#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2907#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#90f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1dc9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#246e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2a89#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#20db#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1664#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2231#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#270c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#29e9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1f92#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2136#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1471#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1ad5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#650#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#191f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#831#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2802#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2cd4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#f70#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1817#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1b51#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#aa6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#7df#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#36#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2c03#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2c08#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2f3a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2a61#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#e6a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#163f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#970#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#25ce#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1759#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1a42#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#abb#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2c9b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2fb5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1a44#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#12a4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2862#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#28b2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1c3b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2bb6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#23f1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2d57#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1b05#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1a19#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1ea6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#24c0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#4d1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#136c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2746#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#7a0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#495#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1cb0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#558#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1dd3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2f0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#303#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#ff5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#24bd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#5f9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1dff#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#327#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#4b9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#27bd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#a85#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2565#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#25a8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2140#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2b69#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1575#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#c8b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1253#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2022#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2800#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#a9b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#98b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#556#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#de3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1c9e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2c59#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2591#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#a93#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#b5a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2b12#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#a9a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#8d1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1745#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1009#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#88a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#967#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1aba#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#22a8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#763#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#267d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#f74#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1934#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2c56#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2676#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1b6e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#e5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1c64#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#138d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#10ae#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#23f2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#6b6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#295e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2e98#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2b02#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#570#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#ca9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1760#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#272c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#fbf#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#16f7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#27a5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#544#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1bbe#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2832#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#22bd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2a5a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2561#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#3b1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2ebd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2db1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2a8c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1e02#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1de9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2aa9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#749#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2425#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#8e6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#225d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1cf3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2df8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#883#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1b65#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#7f3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2c36#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#583#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2a66#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1690#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#673#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#3d0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#66d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#25d8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#6fd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1912#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#169d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#26bb#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#19f5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2a3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#ebe#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1fb5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#23f3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#9e8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2a8a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1c91#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#28be#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#b4c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1c51#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1312#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2cfa#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1612#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#141#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#7c0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#37d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2b5d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2496#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#19b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#6c4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1bda#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1762#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1bd2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#24d5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#206#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2b7a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2686#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#714#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#a9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2e8c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#14e5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1d7b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2681#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1e9f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#b12#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#4f7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#d32#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2dad#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#172b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#ced#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#447#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1e59#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#12bf#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#a41#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1a23#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#26be#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1f1c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2cb7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2e1f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#e87#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#196e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1a7d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1066#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2b08#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1a5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#223d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#212e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#186f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#288c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1eb3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#179f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2004#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#885#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#fc2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1e21#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1e1f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1428#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#145f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2fe2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#15fc#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2b9b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1a28#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1555#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2e2a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#16dd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#205f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#5d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#210f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1789#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#f9a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#140f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1877#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#813#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2e59#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2bad#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1a89#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#74f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#26e5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#173a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2b5f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2d1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#185d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1e87#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#c88#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#94b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#6b3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2685#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2798#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#a3b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2642#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#c33#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1956#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1b05#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#14ed#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#e67#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2927#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1b39#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#16c3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#181e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#ca8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#156b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#fa4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2f23#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#ed9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#d10#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#12ec#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#bd6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#51c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#199a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#18eb#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1320#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#111b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#29ad#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#152f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#58d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1d5a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2ca8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2835#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#dfb#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#30f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#87b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#cb4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#20dc#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1742#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2ac5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2290#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#de#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#27e9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#bc3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1a4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#15ff#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#782#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2318#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#acf#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#21b5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#13b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1d0a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#14#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#43a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1047#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2cc1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#24cc#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#82#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#25ba#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#c69#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#9d4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#181c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1008#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#d1d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#19d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#22e6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#9da#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#13b1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2cf#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#bd1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#66#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#107c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1d3e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#9e7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1508#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2051#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1d07#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#219b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1832#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#148f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#7c6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#27b1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2e2f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2d2c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#14b5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2524#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#53c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2f20#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#26a1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#cc1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1a0b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#5cb#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1702#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1064#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2e5f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#52#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#c6f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#22b1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#173c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2ae#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#acd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2ccd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#b1c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1d53#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#899#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1b32#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#289f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1eba#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#5d2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1de1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1265#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#bbb#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#200a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2b1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2b24#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#17a4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1962#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#504#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#20f2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#72#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1132#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#228#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#17b7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2d98#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1df1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#11a3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#4b3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#f68#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#a7d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#241#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#16a9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2db5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1f37#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#25bb#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#17d2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1f23#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1fec#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#10#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1420#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2d27#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1592#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#275f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#ead#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1535#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1a39#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#108a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#20d4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#ff9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#20f2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#c42#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1ef6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#17e2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#dd8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#147a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2a9a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1e12#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#25f9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1bfe#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#290e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#998#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2c9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1eb8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2ec1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2290#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#c9e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2da3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2a2d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#501#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#60#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1a5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#21bf#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#83a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2eb9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2d50#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#23c4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#d72#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2fb#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#23d3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2caa#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1e31#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1530#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2b91#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1cb#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1dad#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#328#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#211b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#222d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1f0a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#e79#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2b37#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2f5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#242b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1ef8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1491#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2e1f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1c0f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#237e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#171#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1054#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1ec9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2565#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#b56#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#767#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#14f2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#186b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2cdf#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#155d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2b1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#3f4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#3f5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1847#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#7e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#acd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#d12#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#101b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#c1d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1d6c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#adf#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#24d9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2926#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2636#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2d1c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2485#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2d2d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2bde#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1628#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#6fb#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#12e4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#884#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#33c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#143b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#26e7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2a3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#c99#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#838#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2d02#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#f82#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#12c6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#11a4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#662#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2235#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#13b2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1196#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1108#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#b86#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1a7b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1d07#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1e26#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#229f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2879#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#25ad#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#292a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#739#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#201#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#7b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2530#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2e5c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#fee#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#182d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#b67#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#228a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#9d3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#9df#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#808#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#a71#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1fbc#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#129c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1ae7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2382#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#e31#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2d8f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#21a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#27e7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2555#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#23f4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1c94#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#389#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#14bf#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1046#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1d4c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#b8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#134a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2647#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2ea9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2da7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1f39#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#15db#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1124#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#296a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#16aa#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#26fd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#a2a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#5d1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#cf8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1c83#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#10a5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2eea#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#12f6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#222c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2d9c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#af7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#94f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#433#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#16b1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#15c6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#19bd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#24d8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#23aa#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2e7b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1288#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#71f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#e39#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#16fe#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#cd9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#a54#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#7dc#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#28d4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#42a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1d18#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#9d7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#201#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#21d9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#f2f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#c42#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2c0e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1f40#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#bb1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#8b4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1b4b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#c0e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2a11#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2643#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2870#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#28e0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1d5c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1701#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1b8e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#de7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1f65#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#850#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#28a1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#5b2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#a9e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#169e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#18b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#e6b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#b29#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#11f8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#23a7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1a33#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#b59#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1ac1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2073#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#194c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#12b5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2fff#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#a7d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1bf2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#9b5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2baa#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#279e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2c3b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2254#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1602#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1090#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#275d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2c55#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1e00#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1b4d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#72d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#125#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1a31#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#8b4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2667#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#162b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#6ea#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2620#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#895#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1c6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#10f0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#bae#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2799#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#740#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#11f4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#3e1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2ccd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#21d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2d7a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#7b0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1705#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#358#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1d6f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1ec7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2d95#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#d37#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1211#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1b8c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#bf#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#111a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#574#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1b31#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1649#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#116f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1080#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2159#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2211#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2ed5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1dc#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2e70#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#23e9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#296#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1f50#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#67d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#9f3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#913#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#293a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2c66#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1a99#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#ee6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#202e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#e26#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#92e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2aec#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#f0f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2dff#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2a2a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1532#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#115c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#5d0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1869#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#27d5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2aa1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#dfd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2600#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#23e6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1517#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#db0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#153c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#a1f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1499#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#15c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2895#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#22c6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1d80#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#132e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#ffb#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#285f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#257d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#4fc#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#21e8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#642#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#28ae#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1cee#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1bb6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#9a5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#275c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2711#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#153a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#299a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#27d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2354#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#226f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2ed5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1533#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2c41#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2093#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2cf3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#19c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#c4a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2974#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2f97#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#f29#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#118b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#15#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#e7b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2c0e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2db3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#213a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1b11#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1310#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#18c6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#10a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1c37#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#134c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#e38#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1dcd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#103d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#29ca#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1f5b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2f5f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#19af#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2a76#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1f4d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2075#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#6e9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#18e2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#8b1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#f00#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2da5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2aaf#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1110#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#27b7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#7af#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#212c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1e67#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#340#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#294d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1d48#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#317#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#6e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#9ba#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1ee6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#148#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2af0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#71c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#25af#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1878#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1599#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#280f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#ea#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1f52#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#fdd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#15e7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#f14#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#bf8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#11fe#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2999#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2230#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#63d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#596#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#145f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#f56#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#299a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#22c5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#e13#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#19bf#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1d40#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#82c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2e28#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#195b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1cf7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#218d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2fbd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1b1f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2943#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#187a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1c66#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#b4b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#627#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#788#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2a28#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2fd5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#147d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2590#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#9b5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#f8b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#66b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1735#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1f73#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#208f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#e2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1416#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#229b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#695#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#5bf#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1a83#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2a68#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2e4d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1c58#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#13fc#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#11db#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#2d7b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1e86#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#de4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#f77#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#26e1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1f05#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#371#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#1b8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#f5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_b_out,std_logic_vector(to_unsigned(16#bc3#,14)));WAIT FOR CLK_PERIOD;
        --do_check(poly_b_out,std_logic_vector(to_unsigned(16#1625#,14)));WAIT FOR CLK_PERIOD;
        --do_check(poly_b_out,std_logic_vector(to_unsigned(16#1eec#,14)));WAIT FOR CLK_PERIOD;
        --do_check(poly_b_out,std_logic_vector(to_unsigned(16#24db#,14)));WAIT FOR CLK_PERIOD;
        --do_check(poly_b_out,std_logic_vector(to_unsigned(16#2336#,14)));WAIT FOR CLK_PERIOD;
        --do_check(poly_b_out,std_logic_vector(to_unsigned(16#1730#,14)));WAIT FOR CLK_PERIOD;
        --do_check(poly_b_out,std_logic_vector(to_unsigned(16#164b#,14)));WAIT FOR CLK_PERIOD;

        WAIT UNTIL DONE1 = '1';
        
-- ###########################################################################        
        
        rst_client <= '0';  
        en_client <= '1';
        
        a_seed_client <= a_seed_fix(7 DOWNTO 0);
        
        WAIT FOR 35*CLK_PERIOD;
        
        WAIT FOR 33*CLK_PERIOD; 
        a_seed_client <= a_seed_fix(15 DOWNTO 8);
        
        WAIT FOR 33*CLK_PERIOD;
        a_seed_client <= a_seed_fix(23 DOWNTO 16);
        
        WAIT FOR 33*CLK_PERIOD;
        a_seed_client <= a_seed_fix(31 DOWNTO 24);
        
        WAIT FOR 33*CLK_PERIOD;
        a_seed_client <= a_seed_fix(39 DOWNTO 32);
        
        WAIT FOR 33*CLK_PERIOD;
        a_seed_client <= a_seed_fix(47 DOWNTO 40);
        
        WAIT FOR 33*CLK_PERIOD;
        a_seed_client <= a_seed_fix(55 DOWNTO 48);
        
        WAIT FOR 33*CLK_PERIOD;
        a_seed_client <= a_seed_fix(63 DOWNTO 56);
        
        WAIT FOR 33*CLK_PERIOD;
        a_seed_client <= a_seed_fix(71 DOWNTO 64);
        
        WAIT FOR 33*CLK_PERIOD;
        a_seed_client <= a_seed_fix(79 DOWNTO 72);
        
        WAIT FOR 33*CLK_PERIOD;
        a_seed_client <= a_seed_fix(87 DOWNTO 80);
        
        WAIT FOR 33*CLK_PERIOD;
        a_seed_client <= a_seed_fix(95 DOWNTO 88);
        
        WAIT FOR 33*CLK_PERIOD;
        a_seed_client <= a_seed_fix(103 DOWNTO 96);
                
        WAIT FOR 33*CLK_PERIOD;
        a_seed_client <= a_seed_fix(111 DOWNTO 104);
        
        WAIT FOR 33*CLK_PERIOD;
        a_seed_client <= a_seed_fix(119 DOWNTO 112);
        
        WAIT FOR 33*CLK_PERIOD;
        a_seed_client <= a_seed_fix(127 DOWNTO 120);
        
        WAIT FOR 33*CLK_PERIOD;
        a_seed_client <= a_seed_fix(135 DOWNTO 128);
        
        WAIT FOR 33*CLK_PERIOD;
        a_seed_client <= a_seed_fix(143 DOWNTO 136);
        
        WAIT FOR 33*CLK_PERIOD;
        a_seed_client <= a_seed_fix(151 DOWNTO 144);
        
        WAIT FOR 33*CLK_PERIOD;
        a_seed_client <= a_seed_fix(159 DOWNTO 152);
         
        WAIT FOR 33*CLK_PERIOD;
        a_seed_client <= a_seed_fix(167 DOWNTO 160); 
        
        WAIT FOR 33*CLK_PERIOD;
        a_seed_client <= a_seed_fix(175 DOWNTO 168);
        
        WAIT FOR 33*CLK_PERIOD;
        a_seed_client <= a_seed_fix(183 DOWNTO 176);
        
        WAIT FOR 33*CLK_PERIOD;
        a_seed_client <= a_seed_fix(191 DOWNTO 184);
        
        WAIT FOR 33*CLK_PERIOD;
        a_seed_client <= a_seed_fix(199 DOWNTO 192);
        
        WAIT FOR 33*CLK_PERIOD;
        a_seed_client <= a_seed_fix(207 DOWNTO 200);
        
        WAIT FOR 33*CLK_PERIOD; 
        a_seed_client <= a_seed_fix(215 DOWNTO 208);
        
        WAIT FOR 33*CLK_PERIOD;
        a_seed_client <= a_seed_fix(223 DOWNTO 216);
        
        WAIT FOR 33*CLK_PERIOD;
        a_seed_client <= a_seed_fix(231 DOWNTO 224);
        
        WAIT FOR 33*CLK_PERIOD;
        a_seed_client <= a_seed_fix(239 DOWNTO 232);
        
        WAIT FOR 33*CLK_PERIOD;
        a_seed_client <= a_seed_fix(247 DOWNTO 240);
        
        WAIT FOR 33*CLK_PERIOD;
        a_seed_client <= a_seed_fix(255 DOWNTO 248);

        -- ######        
        WAIT UNTIL streamingb = '1';
        WAIT FOR 4*CLK_PERIOD;
        
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#11ab#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#8d0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#16d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#40a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#b9c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#26f8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#10fd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#6e8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#26d8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2422#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#18c6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1305#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#83#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#23c7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#265c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#7e1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2d0d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2896#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#c2f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#109a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2a4c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#258e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#14c3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#974#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#238a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#20fc#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1b01#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#17ec#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#114b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2aa#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#15e3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1299#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1dbe#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2b91#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#3cb#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2d41#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#36e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#22d4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#19d7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2fc6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#ac0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#20c9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2df2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1682#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#b7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2314#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#7bb#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1038#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1673#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#20bd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1baa#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#193a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1bd1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#584#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2f7a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2c00#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1dc7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#280b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1416#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2cf9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1a0d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#6f3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1fc0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#e67#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2ebf#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2d0d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#188a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2e63#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1096#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2ae2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2184#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2a2a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1529#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#a85#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1ea2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#97d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2a8e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1fb6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#80c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1dd0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#163d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1394#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#89e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2e86#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2401#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#aee#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#100d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1070#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#14c7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2ab7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#ba3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2aa6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1973#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#26f7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#16c9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#7ef#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#690#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2300#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2065#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#12ac#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1c7c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#8da#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2774#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#93b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#182a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2ae8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#8c3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2762#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#271a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1106#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2a3b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#26dd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1c50#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#c90#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1106#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#20f3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#12e5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2655#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#112c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#227d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#24d8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#11ea#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1a82#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#24c2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1a0b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2114#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#20af#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1700#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#301#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#12ef#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1d9f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1f92#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2b70#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#26d5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#16b9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#106#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#24d4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#d2c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1591#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1687#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1ef7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2a67#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2569#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#25b1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#286a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#31c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#13cd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2ff1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#51e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#19eb#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1377#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#f1f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#ffe#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1d7c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1e5f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#4be#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#a8e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#e00#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#c96#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#8fd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2ad9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#74d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2d54#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1364#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1ca7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1b8b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#22a2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#eba#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#db#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1057#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#182e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#e1f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2a25#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1333#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#24f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2b60#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2c5d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2f36#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2dab#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#28d6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1543#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#251#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#a92#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1e6a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#38#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#9fd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#27ea#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1115#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1327#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#60e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#607#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1193#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2fe3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2d5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#144d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#4d7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2408#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#d46#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2aca#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#cbc#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#13af#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#15a0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1d64#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#f78#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#24ec#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2b6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1a55#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#308#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#228a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#d61#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#dac#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#e09#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1c65#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#b99#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#873#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#214#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#16e6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#f0f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1f95#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2a08#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#bd3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#25a8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1224#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1ffc#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1dfb#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#22df#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#60e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#20e6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#11ae#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2902#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2551#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1332#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#257a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2a4f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2eb4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2695#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1bd7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1b21#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2a49#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#15d1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2d0c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2e45#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#25ef#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2d18#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1de7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1f9d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#11af#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#41b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#18d9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#15e8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#81d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2397#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1f8a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1156#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#ea3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#8a5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2830#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#fbe#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#c87#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#58f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#172f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#203b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2ad9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#163d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1442#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2a3f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1d86#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2eb7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1fa6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#224e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#788#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#855#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2744#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#ae3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#227#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#864#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#187b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2944#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2166#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#533#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#869#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#6d0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#f0f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#103b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2698#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1303#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#29c4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#e79#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#17af#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1d8f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#154a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#189#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#253b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#549#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#665#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1559#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2e2a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2bad#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2074#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#b1e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#629#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#af6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1191#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#b09#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#4be#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#d24#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1a92#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1680#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2ac1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#847#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2109#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2628#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#a9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#716#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#a0b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2582#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#26a5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#53d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1e97#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2858#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#c3c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#772#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2019#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#27fc#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#7d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#29f9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2563#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2c29#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1c8f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1d71#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#10c6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1926#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2ebc#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#9b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1762#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#25ab#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#17d7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1cf1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2ca2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#20a0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1393#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#31e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1c77#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#178d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#647#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1a46#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#405#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2ee0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#20dd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2153#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#f25#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#154f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2f10#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#8b1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2fb6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#173a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#f5d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#363#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#5e7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2917#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#19e3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#278#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2a5b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1650#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#70d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1a3f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#507#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#29f8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#dd5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#656#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#f07#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2921#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#95a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1285#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2932#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#3f5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1e2b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2434#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#20ed#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#189a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#38b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2ee9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2d55#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1233#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#a2d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1f59#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2dc#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2599#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2e08#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2054#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2115#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#8cf#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1322#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2666#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2797#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1392#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1f52#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#83#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2982#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2e30#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2426#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#645#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2ae8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1d4d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1068#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2f4f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2ac5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2453#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#209a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1e2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2e4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#a29#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#242e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#29f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1a68#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1b5c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2af0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#511#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#24f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#208f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1e68#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#25ce#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#22ff#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1f64#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2ca5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1fcb#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#7ad#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#dd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2f48#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2262#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2a16#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2c45#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1e32#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2b5d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1971#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1e07#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2a64#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#20c0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#10a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#24c4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#27bc#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#d34#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#8a8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#f27#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#112d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1a15#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#22bb#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#6d2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1f70#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#d9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#13cd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#7b7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#18a5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#297e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#4d7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2802#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#fe8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2629#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#14df#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2ef2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2d0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1e81#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2315#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#784#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#ae2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#f51#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#22d0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1a4e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1644#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#c84#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#e03#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2083#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#40#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2769#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1f4b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#226c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#201a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#4bd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2366#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2507#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#144#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2d80#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2ee#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#17d1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1eb2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#4a8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#4ae#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1d66#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#700#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#123d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2424#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1d32#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#9b0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1387#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#b7b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#114e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#26a1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#266b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#9cc#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#954#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#27b6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2034#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1284#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#65e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2d06#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#28e8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#9c4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2f5d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#10e0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#b9c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#761#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#d2a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#249a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#24f5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1769#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2691#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#8fd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#7d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2f6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2d0a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#230d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#13c2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#ff7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#14e2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#15b7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#10c8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1825#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2d3c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1ee2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1d7e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1a25#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#411#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1e7f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#eb1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#bbb#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#27e3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2ddc#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2af3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2678#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1043#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1957#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2a46#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#24bc#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1038#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#9f4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#126e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#b65#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2794#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1808#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1381#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1866#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1ab7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#724#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#3be#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#3a9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#23c5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1b77#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1ef8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1c6c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2fe3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#a18#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#c2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#9e5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1657#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2fe8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1b45#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#225c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#22ac#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1b30#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1f2f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#251c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2bc0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1851#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2f04#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#81c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1da4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2086#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#c85#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#800#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#db9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#25d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#48b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1eb7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#113e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2d43#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#9a0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#21f0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#58f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#17ad#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#281c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#28f2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#39f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#553#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#7ea#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#f5e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#9e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#a7a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#211c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2755#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2efc#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1aa3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#a82#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#15bd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#14d2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#510#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#c0b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#a71#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2501#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#19cd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2338#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#8d8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#277a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#249c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#43e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#28c9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#ac6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#23c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#bca#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1f53#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#12b3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1845#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#a62#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#17a5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#fe3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#20bb#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#a3c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2653#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#9d8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1fdd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2d7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#8f4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#28b1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#168d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#200#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#21d5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2ddc#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1f9c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#5ca#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#657#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1c0b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#267f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#317#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#165f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#921#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2d0b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2bf2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#21e5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#277b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2dc6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#14c8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2369#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#e74#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#3a2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#4fc#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1a25#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2392#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#7ae#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#17c0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#282a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#280c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2253#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#3b4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#18af#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#737#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2c48#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#83f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1063#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2571#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#263e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#275#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1e5f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#23f8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#c79#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1980#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1a3f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2fdc#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2eb0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#198c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#3d7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#582#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2430#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#22b7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#16ac#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#54f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#267f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2ad2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#111#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2541#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1054#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#dc3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1055#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1f95#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#19c2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2338#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1f2d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#29c6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2ec#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2b1d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#7b2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2250#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#167a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2930#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2bed#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2616#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#21c1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#17ce#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#aa#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1cf7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2574#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1764#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#11dc#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#29ba#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2e9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2ad5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#270#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1705#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#558#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#294#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#a1b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#6f8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#226e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1186#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2067#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#450#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1abe#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#ac9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2ef4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1435#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2929#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#18c5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2baa#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#7a2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#20af#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#182d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#18c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1e05#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#86a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#11b0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#fd6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#4c1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#c8d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#236f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#6af#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1476#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2d9b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#124c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#4c6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#7c1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1598#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1783#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#642#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1061#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#84d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2717#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2b1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#859#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1b8f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2d70#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#191a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#d33#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#180d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2359#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1f77#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2680#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#322#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#257b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#3fe#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#288a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#13b9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#133f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#c55#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1106#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#221a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#29b9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2108#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#265b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#155#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2e59#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#29fa#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#33d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2bf7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#24#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#228b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#28d7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1aaa#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#8f4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#184e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2f22#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#46b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2124#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#6e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#abc#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#27ec#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#9e5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#25b8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#570#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#141e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#a14#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2563#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#134e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#175c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#159a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#51#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2dc0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2b51#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#d52#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#244f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#15b1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#cbd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#309#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#128f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1345#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1205#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2a2f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#197f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#4bb#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2c24#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2ad1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#160#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#fdf#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#40c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#25e6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#679#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2bc2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#f8c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#168b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1cf5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#24b3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#706#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#12b9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1b0f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#79a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2491#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1ce8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#16fc#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2a59#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#3e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#16fb#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#27d6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2144#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#29ba#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#964#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#3f3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1266#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1998#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#159d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2144#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#5ec#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#160f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1f2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#ed1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#217c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#28d5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#187f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2c4c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#151f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1a80#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#e08#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#20d2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#25e9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#23e6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#268d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2081#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#d0a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#194e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#b32#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#dc1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#20fd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#17#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2e1e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1afb#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#cda#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#25c2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#801#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#360#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#64#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#177#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1b09#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#984#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#143b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#e2b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#35d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1cf5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#17ca#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2aac#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2f19#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2055#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1474#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#3e2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#24ed#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#f06#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#aa#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#dc3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#40d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1bc7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2fde#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#259d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#12ac#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2be1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2c2a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2b49#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#28b9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1c6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2b76#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#153d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#14c2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2a82#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#568#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#996#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#277f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#b6b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1f00#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2a1b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1009#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#5e2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#ebb#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#233f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#11ed#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#11c2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2ed8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2785#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#11e6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2df0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#5b1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#3be#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1e10#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2b3f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#28c8#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#c9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#289#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2d71#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1ed9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#18e3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#19c1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1f39#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#a96#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1d6d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1025#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#102e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#210#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1389#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#4d4#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2c61#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2e5f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#318#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2145#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#100e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#c5d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2f84#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2bfd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#fa6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1c8a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#af1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#140b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#c20#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#12ab#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1b0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#214#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1ecf#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#952#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#281b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2037#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1ceb#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#d55#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1bfb#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2ffa#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#196f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#204d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#613#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#182d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2590#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#a9b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#167#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#cd5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#28a7#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1b6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#9b1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#a25#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#cb6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2bfa#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1c6b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1450#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#15cd#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#15c1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#26b1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#523#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#29d2#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#28b6#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#14ac#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#752#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2c8c#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#39#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#256f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2666#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#327#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2554#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#6f1#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#20ab#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#afb#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2a3e#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2b9#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#903#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#19d0#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#581#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1a9b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#215b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#8bc#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1cc#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1a5a#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#2c3f#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#1c8d#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#d7b#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#c27#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#21a5#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#19c3#,14)));WAIT FOR CLK_PERIOD;
        do_check(poly_u_out,std_logic_vector(to_unsigned(16#7b5#,14)));WAIT FOR CLK_PERIOD;
        --do_check(poly_u_out,std_logic_vector(to_unsigned(16#1530#,14)));WAIT FOR CLK_PERIOD;
        --do_check(poly_u_out,std_logic_vector(to_unsigned(16#890#,14)));WAIT FOR CLK_PERIOD;
        --do_check(poly_u_out,std_logic_vector(to_unsigned(16#11cd#,14)));WAIT FOR CLK_PERIOD;
        --do_check(poly_u_out,std_logic_vector(to_unsigned(16#220b#,14)));WAIT FOR CLK_PERIOD;
        --do_check(poly_u_out,std_logic_vector(to_unsigned(16#2e1b#,14)));WAIT FOR CLK_PERIOD;
        --do_check(poly_u_out,std_logic_vector(to_unsigned(16#261f#,14)));WAIT FOR CLK_PERIOD;
        --do_check(poly_u_out,std_logic_vector(to_unsigned(16#2da9#,14)));WAIT FOR CLK_PERIOD;
        
        -- ######         
        WAIT UNTIL request_b = '1';

        poly_b <= "10110011011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111011110110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101111010100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101111000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000000001000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111100011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110111001001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001001011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111101010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111000001011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100001110110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011101011000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011100110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111110000100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011100000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111101000111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010101000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010110100111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010000111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011110100111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100001100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111000110100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101001100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011101000101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011110000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100111110100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101000001001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110000110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100100000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100100100010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011010101100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000011101101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000001010110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110110110100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000011100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010111110110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00010011011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000101001000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110101100011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011100111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01001110101101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000010000111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001110001110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010000001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01001100011110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010010000011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110000011000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110100111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000101110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011011101101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100000010111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011100110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011010101111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110000111110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110101101111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110100010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101010110100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000110010100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000010100011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110000111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111001000111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111110111001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111010001110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000000011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000110001100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100010011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111101000111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000010110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100100000100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00010011111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011101110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101111100000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011000100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011010010010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111100110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101010000100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010011110110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111001001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000011001011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100000100000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111010101100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01001001111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100110101110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110101101000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110111010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101010110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101001011010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111101010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100110111001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110011001011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011111111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00010110010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101110110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111101001000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101101010011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010001010010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011100011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001111110011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100011010100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000100101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011101101100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100010001001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010110001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100101100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111101111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010010101101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111101010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000010011000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010101101100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110101011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000101110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011111011011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001111101001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110100001000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101011000111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000100001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100001011011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101011101001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100010010110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100000111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111111011000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101110001100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011010000101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100011110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010100010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010111010111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111001001000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101000111001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001000110011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100000001010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010101001100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111111101000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110010100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011000111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100101111001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000011100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01001111100011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000000100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101111100011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100100100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100101000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111010111000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101111100011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100001100010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000100011010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011110011110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000001110101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101001111100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000101000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110010111000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111101010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011111000111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000110010010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010111001010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111001011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111000010110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110100011011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110110111000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011000001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101011100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100001000100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101111111000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101110111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010110010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110111010110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011100001010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011010110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101010010010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101100011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100011110011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011110000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010111110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000110010110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011101111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01001011000111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110101111100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000000010111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100101110011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010101111000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111001010111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100011010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001110011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011011111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000110111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000010010110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00010000000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100100000111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100100001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110111001001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010001101110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101010001001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000011011011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011001100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001000110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011100001100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100111101001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111110010010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000100110110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010001110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101011010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011001010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100100011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100000110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100000000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110011010100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111101110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100000010111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101101010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101010100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011111011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000000110110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110000000011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110000001000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111100111010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101001100001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111001101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011000111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100101110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010111001110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011101011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101001000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101010111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110010011011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111110110101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101001000100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01001010100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100001100010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100010110010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110000111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101110110110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001111110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110101010111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101100000101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101000011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111010100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010011000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00010011010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01001101101100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011101000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011110100000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00010010010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110010110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00010101011000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110111010011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001011110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001100000011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111111110101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010010111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00010111111001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110111111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001100100111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00010010111001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011110111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101010000101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010101100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010110101000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000101000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101101101001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010101110101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110010001011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01001001010011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000000100010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100000000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101010011011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100110001011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00010101010110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110111100011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110010011110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110001011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010110010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101010010011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101101011010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101100010010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101010011010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100011010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011101000101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000000001001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100010001010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100101100111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101010111010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001010101000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011101100011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011001111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111101110100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100100110100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110001010110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011001110110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101101101110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000011100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110001100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01001110001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000010101110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001111110010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011010110110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100101011110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111010011000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101100000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00010101110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110010101001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011101100000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011100101100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111110111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011011110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011110100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00010101000100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101110111110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100000110010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001010111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101001011010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010101100001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001110110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111010111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110110110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101010001100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111000000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110111101001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101010101001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011101001001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010000100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100011100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001001011101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110011110011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110111111000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100010000011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101101100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011111110011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110000110110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00010110000011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101001100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011010010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011001110011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001111010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011001101101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010111011000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011011111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100100010010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011010011101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011010111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100111110101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001010100011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111010111110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111110110101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001111110011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100111101000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101010001010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110010010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100010111110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101101001100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110001010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01001100010010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110011111010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011000010010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000101000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011111000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001101111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101101011101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010010010110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000110011011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011011000100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101111011010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011101100010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101111010010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010011010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001000000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101101111010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011010000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011100010100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000010101001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111010001100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010011100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110101111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011010000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111010011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101100010010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00010011110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110100110010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110110101101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011100101011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110011101101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00010001000111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111001011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01001010111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101001000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101000100011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011010111110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111100011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110010110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111000011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111010000111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100101101110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101001111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000001100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101100001000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000110100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001000111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000100101110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100001101111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100010001100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111010110011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011110011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000000000100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100010000101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111111000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111000100001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111000011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010000101000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010001011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111111100010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010111111100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101110011011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101000101000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010101010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111000101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011011011101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000001011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000001011101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000100001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011110001001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111110011010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010000001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100001110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100000010011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111001011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101110101101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101010001001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011101001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011011100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011100111010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101101011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001011010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100001011101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111010000111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110010001000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100101001011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011010110011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011010000101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011110011000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101000111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011001000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110000110011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100101010110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101100000101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010011101101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111001100111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100100100111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101100111001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011011000011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100000011110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110010101000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010101101011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111110100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111100100011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111011011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110100010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01001011101100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101111010110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00010100011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100110011010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100011101011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01001100100000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000100011011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100110101101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010100101111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00010110001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110101011010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110010101000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100000110101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110111111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001100001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100001111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110010110100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000011011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011101000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101011000101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001010010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000011011110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011111101001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101111000011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000110100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010111111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011110000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001100011000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101011001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000110110101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000100111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110100001010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000000010100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00010000111010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000001000111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110011000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010011001100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000010000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010110111010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110001101001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100111010100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100000011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000000001000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110100011101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000110011101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001011100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100111011010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01001110110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001011001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101111010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000001100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000001111100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110100111110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100111100111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010100001000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000001010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110100000111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000110011011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100000110010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010010001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011111000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011110110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111000101111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110100101100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010010110101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010100100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00010100111100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111100100000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011010100001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110011000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101000001011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00010111001011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011100000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000001100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111001011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000001010010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110001101111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001010110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011100111100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001010101110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101011001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110011001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101100011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110101010011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100010011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101100110010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100010011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111010111010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00010111010010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110111100001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01001001100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101110111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000000001010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001010110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101100100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011110100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100101100010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00010100000100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000000011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000011110010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000001110010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000100110010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001000101000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011110110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110110011000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110111110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000110100011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000000001000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00010010110011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111101101000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101001111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001001000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011010101001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110110110101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111100110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010110111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011111010010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111100100011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111111101100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000000010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010000100000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110100100111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010110010010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011101011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111010101101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010100110101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101000111001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000010001010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000011010100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111111111001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000011110010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110001000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111011110110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011111100010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110111011000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010001111010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101010011010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111000010010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010111111001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101111111110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100100001110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100110011000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001011001001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111010111000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111011000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001010010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110010011110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110110100011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101000101101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00010100000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000001100000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000110100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000110111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100000111010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111010111001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110101010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001111000100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110101110010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001011111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001111010011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110010101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111000110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010100110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101110010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000111001011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110110101101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001100101000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000100011011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001000101101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111100001010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111001111001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101100110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001011110101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010000101011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111011111000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010010010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111000011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110000001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001101111110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000101110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000001010100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111011001001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010101100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101101010110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011101100111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010011110010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100001101011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110011011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010101011101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001010110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001111110100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001111110101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100001000111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000001111110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101011001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110100010010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000000011011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110000011101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110101101100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101011011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010011011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100100100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011000110110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110100011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010010000101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110100101101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101111011110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011000101000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011011111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01001011100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100010000100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001100111100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010000111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011011100111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001010100011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110010011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100000111000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110100000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111110000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01001011000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000110100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011001100010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001000110101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01001110110010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000110010110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000100001000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101110000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101001111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110100000111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111000100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001010011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100001111001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010110101101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100100101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011100111001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001000000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000001111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010100110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111001011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111111101110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100000101101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101101100111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001010001010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100111010011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100111011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100000001000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101001110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111110111100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01001010011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101011100111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001110000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111000110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110110001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001000011010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011111100111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010101010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001111110100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110010010100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001110001001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010010111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000001000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110101001100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000010111000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01001101001010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011001000111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111010101001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110110100111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111100111001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010111011011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000100100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100101101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011010101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011011111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101000101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00010111010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110011111000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110010000011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000010100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111011101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01001011110110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001000101100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110110011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101011110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100101001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00010000110011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011010110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010111000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100110111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010011011000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001110101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111001111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01001010001000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011100011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111000111001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011011111110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110011011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101001010100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011111011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100011010100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00010000101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110100011000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100111010111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001000000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000111011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111100101111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110001000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110000001110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111101000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101110110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100010110100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101101001011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110000001110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101000010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011001000011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100001110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100011100000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110101011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011100000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101110001110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110111100111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111101100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100001010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100010100001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00010110110010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101010011110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011010011110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000110001011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111001101011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101100101001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000111111000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001110100111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101000110011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101101011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101011000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000001110011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100101001100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01001010110101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111111111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101001111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101111110010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100110110101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101110101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011110011110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110000111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001001010100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011000000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000010010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011101011101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110001010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111000000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101101001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011100101101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000100100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101000110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100010110100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011001100111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011000101011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011011101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011000100000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100010010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000111000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000011110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101110101110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011110011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011101000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000000011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000111110100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001111100001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110011001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001000011101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110101111010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011110110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011100000101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001101011000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110101101111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111011000111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110110010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110100110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01001000010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101110001100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000010111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000100011010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00010101110100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101100110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011001001001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000101101111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000010000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000101011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001000010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111011010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000111011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111001110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001111101001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001010010110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111101010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011001111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100111110011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100100010011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100100111010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110001100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101010011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111011100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000000101110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111000100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100100101110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101011101100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111100001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110111111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101000101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010100110010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000101011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00010111010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100001101001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011111010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101010100001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110111111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011000000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001111100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010100010111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110110110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010100111100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101000011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010010011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000101011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100010010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001011000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110110000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01001100101110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111111111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100001011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010101111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00010011111100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000111101000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011001000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100010101110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110011101110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101110110110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100110100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011101011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011100010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010100111010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100110011010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001001111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001101010100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001001101111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111011010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010100110011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110001000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000010010011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110011110011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000110011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110001001010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100101110100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111110010111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111100101001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000110001011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000000010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111001111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110000001110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110110110011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000100111010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101100010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01001100010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100011000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000100001010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110000110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01001101001100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111000111000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110111001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000000111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100111001010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111101011011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111101011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100110101111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101001110110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111101001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000001110101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011011101001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100011100010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100010110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111100000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110110100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101010101111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000100010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011110110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011110101111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000100101100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111001100111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001101000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100101001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110101001000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001100010111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000001101110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100110111010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111011100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000101001000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101011110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011100011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010110101111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100001111000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010110011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100000001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000011101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111101010010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111111011101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010111100111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111100010100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101111111000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000111111110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100110011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001000110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011000111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00010110010110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010001011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111101010110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100110011010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001011000101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111000010011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100110111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110101000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100000101100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111000101000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100101011011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110011110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000110001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111110111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101100011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10100101000011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01100001111010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110001100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101101001011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011000100111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011110001000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101000101000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111111010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010001111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010110010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00100110110101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111110001011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011001101011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011100110101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111101110011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10000010001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000011100010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01010000010110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001010011011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00011010010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00010110111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01101010000011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10101001101000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10111001001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01110001011000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01001111111100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01000111011011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10110101111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111010000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00110111100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00111101110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10011011100001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111100000101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00001101110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000110111000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00000011110101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "00101111000011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011000100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01111011101100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10010011011011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "10001100110110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011100110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_b <= "01011001001011";
        
-------------------------------
-- ###

        WAIT UNTIL streamingb = '1';
        WAIT FOR CLK_PERIOD*14;
        
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#0#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        do_check(poly_c_out,std_logic_vector(to_unsigned(16#7#,3)));WAIT FOR CLK_PERIOD*9;
        --do_check(poly_c_out,std_logic_vector(to_unsigned(16#2#,3)));WAIT FOR CLK_PERIOD*9;
        --do_check(poly_c_out,std_logic_vector(to_unsigned(16#3#,3)));WAIT FOR CLK_PERIOD*9;
        --do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        --do_check(poly_c_out,std_logic_vector(to_unsigned(16#1#,3)));WAIT FOR CLK_PERIOD*9;
        --do_check(poly_c_out,std_logic_vector(to_unsigned(16#4#,3)));WAIT FOR CLK_PERIOD*9;
        --do_check(poly_c_out,std_logic_vector(to_unsigned(16#6#,3)));WAIT FOR CLK_PERIOD*9;
        --do_check(poly_c_out,std_logic_vector(to_unsigned(16#5#,3)));WAIT FOR CLK_PERIOD*9;

-- ####
        
        WAIT UNTIL done_client = '1';
        
        finalize <= '1';
        
        poly_u <= "01000110101011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100011010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000101101101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010000001010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101110011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011011111000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000011111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011011101000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011011011000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010000100010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100011000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001100000101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000010000011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001111000111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011001011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011111100001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110100001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100010010110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110000101111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000010011010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101001001100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010110001110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010011000011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100101110100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001110001010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000011111100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101100000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011111101100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000101001011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001010101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010111100011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001010011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110110111110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101110010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001111001011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110101000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001101101110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001011010100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100111010111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111111000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101011000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000011001001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110111110010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011010000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000010110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001100010100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011110111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000000111000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011001110011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000010111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101110101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100100111010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101111010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010110000100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111101111010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110000000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110111000111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100000001011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010000010110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110011111001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101000001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011011110011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111111000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111001100111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111010111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110100001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100010001010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111001100011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000010010110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101011100010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000110000100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101000101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010100101001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101010000101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111010100010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100101111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101010001110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111110110110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100000001100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110111010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011000111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001110010100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100010011110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111010000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010000000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101011101110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000000001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000001110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010011000111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101010110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101110100011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101010100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100101110011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011011110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011011001001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011111101111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011010010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001100000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000001100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001010101100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110001111100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100011011010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011101110100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100100111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100000101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101011101000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100011000011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011101100010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011100011010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000100000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101000111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011011011101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110001010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110010010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000100000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000011110011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001011100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011001010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000100101100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001001111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010011011000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000111101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101010000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010011000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101000001011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000100010100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000010101111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011100000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001100000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001011101111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110110011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111110010010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101101110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011011010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011010111001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000100000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010011010100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110100101100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010110010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011010000111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111011110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101001100111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010101101001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010110110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100001101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001100011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001111001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111111110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010100011110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100111101011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001101110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111100011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111111111110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110101111100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111001011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010010111110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101010001110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111000000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110010010110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100011111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101011011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011101001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110101010100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001101100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110010100111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101110001011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001010100010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111010111010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000011011011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000001010111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100000101110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111000011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101000100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001100110011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001001001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101101100000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110001011101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111100110110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110110101011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100011010110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010101000011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001001010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101010010010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111001101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000000111000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100111111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011111101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000100010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001100100111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011000001110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011000000111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000110010011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111111100011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001011010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010001001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010011010111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010000001000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110101000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101011001010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110010111100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001110101111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010110100000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110101100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111101111000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010011101100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001010110110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101001010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001100001000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001010001010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110101100001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110110101100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111000001001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110001100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101110011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100001110011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001000010100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011011100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111100001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111110010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101000001000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101111010011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010110101000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001000100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111111111100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110111111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001011011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011000001110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000011100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000110101110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100100000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010101010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001100110010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010101111010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101001001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111010110100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011010010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101111010111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101100100001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101001001001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010111010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110100001100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111001000101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010111101111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110100011000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110111100111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111110011101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000110101111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010000011011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100011011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010111101000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100000011101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001110010111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111110001010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000101010110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111010100011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100010100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100000110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111110111110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110010000111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010110001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011100101111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000000111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101011011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011000111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010001000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101000111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110110000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111010110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111110100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001001001110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011110001000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100001010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011101000100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101011100011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001000100111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100001100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100001111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100101000100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000101100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010100110011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100001101001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011011010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111100001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000000111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011010011000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001100000011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100111000100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111001111001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011110101111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110110001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010101001010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000110001001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010100111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010101001001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011001100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010101011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111000101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101110101101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000001110100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101100011110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011000101001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101011110110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000110010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101100001001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010010111110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110100100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101010010010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011010000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101011000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100001000111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000100001001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011000101000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000010101001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011100010110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101000001011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010110000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011010100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010100111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111010010111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100001011000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110000111100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011101110010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000000011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011111111100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000001111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100111111001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010101100011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110000101001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110010001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000000101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110101110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000011000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100100100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111010111100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000010011011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011101100010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010110101011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011111010111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110011110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110010100010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000010100000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001110010011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001100011110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110001110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011110001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011001000111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101001000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010000000101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111011100000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000011011101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000101010011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111100100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010101001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111100010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100010110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111110110110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011100111010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111101011101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001101100011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010111100111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100100010111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100111100011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001001111000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101001011011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011001010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011100001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101000111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010100000111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100111111000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110111010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011001010110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111100000111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100100100001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100101011010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001010000101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100100110010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001111110101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111000101011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010000110100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000011101101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100010011010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001110001011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111011101001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110101010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001000110011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101000101101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111101011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001011011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010110011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111000001000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000001010100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000100010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100011001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001100100010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011001100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011110010111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001110010010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111101010010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000010000011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100110000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111000110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010000100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011001000101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101011101000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110101001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000001101000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111101001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101011000101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010001010011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000010011010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000111100010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001011100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101000101001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010000101110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001010011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101001101000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101101011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101011110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010100010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001001001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000010001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111001101000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010111001110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001011111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111101100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110010100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111111001011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011110101101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000011011101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111101001000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001001100010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101000010110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110001000101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111000110010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101101011101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100101110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111000000111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101001100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000011000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000100001010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010011000100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011110111100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110100110100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100010101000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111100100111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000100101101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101000010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001010111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011011010010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111101110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000011011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001111001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011110110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100010100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100101111110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010011010111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100000000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111111101000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011000101001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010011011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111011110010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001011010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111010000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001100010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011110000100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101011100010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111101010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001011010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101001001110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011001000100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110010000100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111000000011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000010000011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000001000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011101101001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111101001011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001001101100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000000011010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010010111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001101100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010100000111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000101000100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110110000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001011101110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011111010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111010110010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010010101000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010010101110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110101100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011100000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001000111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010000100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110100110010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100110110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001110000111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101101111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000101001110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011010100001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011001101011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100111001100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100101010100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011110110110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000000110100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001010000100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011001011110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110100000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100011101000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100111000100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111101011101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000011100000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101110011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011101100001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110100101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010010011010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010011110101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011101101001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011010010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100011111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000001111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001011110110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110100001010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001100001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001111000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111111110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010011100010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010110110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000011001000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100000100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110100111100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111011100010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110101111110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101000100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010000010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111001111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111010110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101110111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011111100011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110111011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101011110011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011001111000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000001000011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100101010111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101001000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010010111100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000000111000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100111110100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001001101110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101101100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011110010100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100000001000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001110000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100001100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101010110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011100100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001110111110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001110101001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001111000101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101101110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111011111000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110001101100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111111100011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101000011000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000011000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100111100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011001010111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111111101000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101101000101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001001011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001010101100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101100110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111100101111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010100011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101111000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100001010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111100000100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100000011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110110100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000010000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110010000101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100000000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110110111001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001001011101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010010001011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111010110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000100111110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110101000011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100110100000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000111110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010110001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011110101101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100000011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100011110010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001110011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010101010011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011111101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111101011110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000010011110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101001111010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000100011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011101010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111011111100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101010100011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101010000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010110111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010011010010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010100010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110000001011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101001110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010100000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100111001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001100111000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100011011000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011101111010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010010011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010000111110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100011001001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101011000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001000111100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101111001010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111101010011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001010110011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100001000101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101001100010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011110100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111111100011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000010111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101000111100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011001010011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100111011000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111111011101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001011010111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100011110100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100010110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011010001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001000000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000111010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110111011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111110011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010111001010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011001010111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110000001011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011001111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001100010111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011001011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100100100001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110100001011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101111110010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000111100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011101111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110111000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010011001000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001101101001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111001110100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001110100010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010011111100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101000100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001110010010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011110101110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011111000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100000101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100000001100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001001010011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001110110100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100010101111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011100110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110001001000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100000111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000001100011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010101110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011000111110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001001110101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111001011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001111111000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110001111001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100110000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101000111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111111011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111010110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100110001100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001111010111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010110000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010000110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001010110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011010101100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010101001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011001111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101011010010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000100010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010101000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000001010100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110111000011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000001010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111110010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100111000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001100111000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111100101101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100111000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001011101100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101100011101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011110110010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001001010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011001111010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100100110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101111101101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011000010110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000111000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011111001110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000010101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110011110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010101110100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011101100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000111011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100110111010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001011101001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101011010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001001110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011100000101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010101011000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001010010100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101000011011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011011111000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001001101110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000110000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000001100111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010001010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101010111110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101011001001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111011110100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010000110101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100100101001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100011000101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101110101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011110100010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000010101111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100000101101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000110001100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111000000101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100001101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000110110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111111010110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010011000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110010001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001101101111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011010101111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010001110110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110110011011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001001001100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010011000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011111000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010110011000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011110000011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011001000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000001100001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100001001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011100010111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001010110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100001011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101110001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110101110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100100011010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110100110011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100000001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001101011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111101110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011010000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001100100010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010101111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001111111110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100010001010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001110111001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001100111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110001010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000100000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001000011010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100110111001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000100001000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011001011011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000101010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111001011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100111111010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001100111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101111110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000000100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001010001011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100011010111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101010101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100011110100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100001001110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111100100010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010001101011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000100100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000001101110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101010111100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011111101100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100111100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010110111000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010101110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010000011110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101000010100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010101100011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001101001110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011101011100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010110011010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000001010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110111000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101101010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110101010010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010001001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010110110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110010111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001100001001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001010001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001101000101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001000000101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101000101111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100101111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010010111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110000100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101011010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000101100000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111111011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010000001100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010111100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011001111001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101111000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111110001100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011010001011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110011110101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010010110011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011100000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001010111001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101100001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011110011010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010010010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110011101000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011011111100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101001011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000000111110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011011111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011111010110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000101000100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100110111010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100101100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001111110011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001001100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100110011000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010110011101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000101000100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010111101100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011000001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000111110010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111011010001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000101111100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100011010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100001111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110001001100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010100011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101010000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111000001000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000011010010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010111101001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001111100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011010001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000010000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110100001010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100101001110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101100110010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110111000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000011111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000000010111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111000011110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101011111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110011011010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010111000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100000000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001101100000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000001100100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000101110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101100001001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100110000100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010000111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111000101011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001101011101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110011110101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01011111001010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101010101100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111100011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000001010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010001110100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001111100010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010011101101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111100000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000010101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110111000011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010000001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101111000111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111111011110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010110011101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001010101100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101111100001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110000101010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101101001001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100010111001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000111000110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101101110110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010100111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010011000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101010000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010101101000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100110010110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011101111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101101101011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111100000000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101000011011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000000001001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010111100010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111010111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001100111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000111101101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000111000010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111011011000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011110000101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000111100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110111110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010110110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001110111110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111000010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101100111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100011001000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000011001001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001010001001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110101110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111011011001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100011100011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100111000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111100111001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101010010110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110101101101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000000100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000000101110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001000010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001110001001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010011010100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110001100001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111001011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001100011000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000101000101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000000001110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110001011101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111110000100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101111111101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00111110100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110010001010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101011110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010000001011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110000100000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01001010101011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000110110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001000010100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01111011001111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100101010010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100000011011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000000110111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110011101011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110101010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101111111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111111111010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100101101111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000001001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011000010011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100000101101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010110010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101010011011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000101100111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110011010101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100010100111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000110110110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100110110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101000100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110010110110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101111111010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110001101011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010001010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010111001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010111000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011010110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010100100011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100111010010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10100010110110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010010101100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011101010010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110010001100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000000111001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010101101111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011001100110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001100100111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10010101010100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011011110001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000010101011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00101011111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10101000111110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00001010111001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100100000011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100111010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00010110000001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101010011011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000101011011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100010111100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00000111001100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01101001011010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110000111111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01110010001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110101111011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00110000100111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10000110100101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01100111000011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00011110110101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01010100110000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "00100010010000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "01000111001101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10001000001011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10111000011011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10011000011111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_u <= "10110110101001";
        
        WAIT FOR CLK_PERIOD*9;
        
-------------------------------
        -- ***
                
        WAIT UNTIL request_c = '1';   
        
        WAIT FOR CLK_PERIOD;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "000";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "111";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "010";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "011";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "001";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "100";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "110";
        
        WAIT FOR CLK_PERIOD*9;
        
        poly_c <= "101";
        
        WAIT FOR CLK_PERIOD*9;     
                           
        WAIT;
    END PROCESS;

END Behavioral;
