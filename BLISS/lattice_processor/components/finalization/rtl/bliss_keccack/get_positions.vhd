--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:49:12 02/07/2014 
-- Design Name: 
-- Module Name:    get_positions - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;



-- We use Keccak with rate 1024. Thus we just need squeezing.


entity get_positions is
  generic (
    --------------------------General --------------------------------------
    N_ELEMENTS    : integer  := 512;
    PRIME_P_WIDTH : integer  := 14;
    PRIME_P       : unsigned := to_unsigned(12289, 14);
    -----------------------  Sparse Mul Core ------------------------------------------
    KAPPA         : integer  := 23;
    HASH_BLOCKS   : integer  := 4;
    USE_MOCKUP    : integer  := 0;
    HASH_WIDTH    : integer  := 64
    ---------------------------------------------------------------------------

    );

  port (
    clk : in std_logic;

    start : in  std_logic := '0';
    ready : out std_logic := '0';

    --Hash is finished
    hash_ready   : in  std_logic := '0';
    --hash_squeeze
    hash_squeeze : out std_logic := '0';

    --Access the output of the hash function from a distributed RAM (simpler
    --than FIFO which is expensive in terms of area)
    hash_in               : in  std_logic_vector(HASH_WIDTH-1 downto 0);
    c_pos_signature       : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    c_pos_signature_valid : out std_logic                                                          := '0';
    c_addr                : in  std_logic_vector(integer(ceil(log2(real(KAPPA))))-1 downto 0)      := (others => '0');
    c_out                 : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0')
    );

end get_positions;



architecture Behavioral of get_positions is

  component c_ram
    port (
      a    : in  std_logic_vector(4 downto 0);
      d    : in  std_logic_vector(8 downto 0);
      clk  : in  std_logic;
      we   : in  std_logic;
      qspo : out std_logic_vector(8 downto 0)
      );
  end component;


  
  component c_ram_64
    port (
      a    : in  std_logic_vector(5 downto 0);
      d    : in  std_logic_vector(8 downto 0);
      clk  : in  std_logic;
      we   : in  std_logic;
      qspo : out std_logic_vector(8 downto 0)
      );
  end component;


  component already_set_ram
    port (
      a   : in  std_logic_vector(8 downto 0);
      d   : in  std_logic_vector(0 downto 0);
      clk : in  std_logic;
      we  : in  std_logic;
      spo : out std_logic_vector(0 downto 0)
      );
  end component;


  constant ADDR_WIDTH     : integer := integer(ceil(log2(real(N_ELEMENTS))));
  constant HASH_RAM_DEPTH : integer := 16;
  constant MAX_POSITIONS  : integer := integer(floor(real(HASH_WIDTH)/real(ADDR_WIDTH)));


  signal c_addr_intern  : std_logic_vector(c_addr'range) := (others => '0');
  signal c_addr_ram     : std_logic_vector(c_addr'range) := (others => '0');
  signal c_din_intern   : std_logic_vector(c_out'range)  := (others => '0');
  signal c_wr_en_intern : std_logic                      := '0';
  signal c_dout_intern  : std_logic_vector(c_out'range)  := (others => '0');

  type   eg_state is (IDLE, EXTRACT_POSITIONS, SAVE_POSITION, PROCESS_POSITION, WAIT_CYCLE, FINISHED);
  signal state_reg : eg_state := IDLE;


  --Which position of 64 bit input has been covered
  signal position_counter : integer range 0 to MAX_POSITIONS+1 := 0;
  --How many positions have been set
  signal success_counter  : integer range 0 to KAPPA+1         := 0;

  --Contains positions already set
  --Make this slr
  --signal already_set : unsigned(N_ELEMENTS-1 downto 0)         := (others => '0');
  signal pos         : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal pos_reg         : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');

signal cleanup_counter : integer := 0;
  
  signal already_addr : std_logic_vector(8 downto 0);
  signal already_din  : std_logic_vector(0 downto 0);
  signal already_we   : std_logic;
  signal already_dout : std_logic_vector(0 downto 0);
begin

  N_EL : if N_ELEMENTS = 512 generate
    your_instance_name : already_set_ram
      port map (
        a   => already_addr,
        d   => already_din,
        clk => clk,
        we  => already_we,
        spo => already_dout
        );
  end generate N_EL;

  already_addr <= pos_reg or pos;


  process(clk)
  begin
    if rising_edge(clk) then
      pos                   <= (others => '0');
      ready                 <= '0';
      hash_squeeze          <= '0';
      c_wr_en_intern        <= '0';
      c_pos_signature_valid <= '0';
      already_din           <= "0";
      already_we            <= '0';
      pos_reg <= pos;
      
      case state_reg is
        when IDLE =>
          ready            <= '1';
          --already_set      <= (others => '0');
          success_counter  <= 0;
          position_counter <= 0;
          c_wr_en_intern   <= '0';

          --Hash has to be ready (finished). Ohterwise we do not start
          if start = '1' and hash_ready = '1' then
            ready        <= '0';
            hash_squeeze <= '1';
            state_reg    <= WAIT_CYCLE;
          end if;

        when WAIT_CYCLE =>
          --Wait so that we get the hash part
          state_reg <= EXTRACT_POSITIONS;

        when EXTRACT_POSITIONS =>
          --Extract the positions from the hash output.
          --We get 7 positions (9 bit) out of 64 bit blocks    
          if position_counter < MAX_POSITIONS then
            pos       <= std_logic_vector(resize(unsigned(hash_in) srl position_counter, ADDR_WIDTH));
            state_reg <= PROCESS_POSITION;
          else
            hash_squeeze     <= '1';
            position_counter <= 0;
            state_reg        <= WAIT_CYCLE;
          end if;


        when PROCESS_POSITION =>
          --XXX/TODO optimize to use SLR
          --if already_set(to_integer(unsigned(pos))) = '0' then
          if already_dout = "0" then
            already_din <= "1";
            already_we  <= '1';

            --already_set(to_integer(unsigned(pos))) <= '1';
            position_counter      <= position_counter+1;
            success_counter       <= success_counter+1;
            c_addr_intern         <= std_logic_vector(to_unsigned(success_counter, c_addr_intern'length));
            --Write into the memory and also to the ouput 
            c_din_intern          <= std_logic_vector(pos);
            c_pos_signature       <= std_logic_vector(pos);
            c_pos_signature_valid <= '1';
            c_wr_en_intern        <= '1';

            state_reg <= SAVE_POSITION;

            if success_counter = KAPPA-1 then
              --We now have KAPPA-1+1 values
              state_reg <= FINISHED;
              pos       <= (others => '0');
            end if;
          else
            position_counter <= position_counter+1;
            state_reg        <= EXTRACT_POSITIONS;
          end if;

        when SAVE_POSITION =>
          --already_set(to_integer(unsigned(pos))) <= '1';
          state_reg <= EXTRACT_POSITIONS;
          

        when FINISHED =>
          --Clean the RAM
          pos_reg <= (others => '0');
          already_din <= "0";
          already_we  <= '1';
          if unsigned(pos) < N_ELEMENTS-1 then
            pos <= std_logic_vector(unsigned(pos)+1);
          else
            pos <= std_logic_vector(unsigned(pos)+1);
          state_reg <= IDLE;            
          end if;



          
      end case;
    end if;
  end process;


  c_addr_ram <= c_addr when state_reg = IDLE else c_addr_intern;
  c_out      <= c_dout_intern;

  --no_mock : if USE_MOCKUP = 0 generate
   KAPP_RAM : if KAPPA < 32 generate
      c_ram_inst : c_ram
        port map (
          clk  => clk,
          a    => c_addr_ram,
          d    => c_din_intern,
          we   => c_wr_en_intern,
          qspo => c_dout_intern
          );
   end generate KAPP_RAM;

   KAPP_RAM64 : if KAPPA >= 32 and KAPPA<64 generate
      c_ram_inst : c_ram_64
        port map (
          clk  => clk,
          a    => c_addr_ram,
          d    => c_din_intern,
          we   => c_wr_en_intern,
          qspo => c_dout_intern
          );
   end generate KAPP_RAM64;

  
  

 -- end generate no_mock;


  --mock : if USE_MOCKUP = 1 generate
  --  KAPP_RAM : if KAPPA < 32 generate
  --    c_ram_inst : c_ram
  --      port map (
  --        clk  => clk,
  --        a    => c_addr_ram,
  --        d    => c_din_intern,
  --        we   => '0',
  --        qspo => c_dout_intern
  --        );
  --  end generate KAPP_RAM;

  --end generate mock;


  

  
end Behavioral;




























--library IEEE;
--use IEEE.STD_LOGIC_1164.all;
--use ieee.numeric_std.all;
--use ieee.math_real.all;



---- We use Keccak with rate 1024. Thus we just need squeezing.


--entity get_positions is
--  generic (
--    --------------------------General --------------------------------------
--    N_ELEMENTS    : integer  := 512;
--    PRIME_P_WIDTH : integer  := 14;
--    PRIME_P       : unsigned := to_unsigned(12289, 14);
--    -----------------------  Sparse Mul Core ------------------------------------------
--    KAPPA         : integer  := 23;
--    HASH_BLOCKS   : integer  := 4;
--    USE_MOCKUP    : integer  := 0;
--    HASH_WIDTH    : integer  := 64
--    ---------------------------------------------------------------------------

--    );

--  port (
--    clk : in std_logic;

--    start : in  std_logic := '0';
--    ready : out std_logic := '0';

--    --Hash is finished
--    hash_ready   : in  std_logic := '0';
--    --hash_squeeze
--    hash_squeeze : out std_logic := '0';

--    --Access the output of the hash function from a distributed RAM (simpler
--    --than FIFO which is expensive in terms of area)
--    hash_in               : in  std_logic_vector(HASH_WIDTH-1 downto 0);
--    c_pos_signature       : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
--    c_pos_signature_valid : out std_logic                                                          := '0';
--    c_addr                : in  std_logic_vector(integer(ceil(log2(real(KAPPA))))-1 downto 0)      := (others => '0');
--    c_out                 : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0')
--    );

--end get_positions;



--architecture Behavioral of get_positions is

--  component c_ram
--    port (
--      a    : in  std_logic_vector(4 downto 0);
--      d    : in  std_logic_vector(8 downto 0);
--      clk  : in  std_logic;
--      we   : in  std_logic;
--      qspo : out std_logic_vector(8 downto 0)
--      );
--  end component;


--  component already_set_ram
--    port (
--      a   : in  std_logic_vector(8 downto 0);
--      d   : in  std_logic_vector(0 downto 0);
--      clk : in  std_logic;
--      we  : in  std_logic;
--      spo : out std_logic_vector(0 downto 0)
--      );
--  end component;


--  constant ADDR_WIDTH     : integer := integer(ceil(log2(real(N_ELEMENTS))));
--  constant HASH_RAM_DEPTH : integer := 16;
--  constant MAX_POSITIONS  : integer := integer(floor(real(HASH_WIDTH)/real(ADDR_WIDTH)));


--  signal c_addr_intern  : std_logic_vector(c_addr'range) := (others => '0');
--  signal c_addr_ram     : std_logic_vector(c_addr'range) := (others => '0');
--  signal c_din_intern   : std_logic_vector(c_out'range)  := (others => '0');
--  signal c_wr_en_intern : std_logic                      := '0';
--  signal c_dout_intern  : std_logic_vector(c_out'range)  := (others => '0');

--  type   eg_state is (IDLE, EXTRACT_POSITIONS, SAVE_POSITION, PROCESS_POSITION, WAIT_CYCLE, FINISHED);
--  signal state_reg : eg_state := IDLE;


--  --Which position of 64 bit input has been covered
--  signal position_counter : integer range 0 to MAX_POSITIONS+1 := 0;
--  --How many positions have been set
--  signal success_counter  : integer range 0 to KAPPA+1         := 0;

--  --Contains positions already set
--  --Make this slr
--  --signal already_set : unsigned(N_ELEMENTS-1 downto 0)         := (others => '0');
--  signal pos         : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');


--  signal already_addr : std_logic_vector(8 downto 0);
--  signal already_din  : std_logic_vector(0 downto 0);
--  signal already_we   : std_logic;
--  signal already_dout : std_logic_vector(0 downto 0);
--begin

--  N_EL : if N_ELEMENTS = 512 generate
--    your_instance_name : already_set_ram
--      port map (
--        a   => already_addr,
--        d   => already_din,
--        clk => clk,
--        we  => already_we,
--        spo => already_dout
--        );
--  end generate N_EL;

--  already_addr <= pos;


--  process(clk)
--  begin
--    if rising_edge(clk) then
--      pos                   <= (others => '0');
--      ready                 <= '0';
--      hash_squeeze          <= '0';
--      c_wr_en_intern        <= '0';
--      c_pos_signature_valid <= '0';
--      already_din           <= "0";
--      already_we            <= '0';

--      case state_reg is
--        when IDLE =>
--          ready            <= '1';
--          --already_set      <= (others => '0');
--          success_counter  <= 0;
--          position_counter <= 0;
--          c_wr_en_intern   <= '0';

--          --Hash has to be ready (finished). Ohterwise we do not start
--          if start = '1' and hash_ready = '1' then
--            ready        <= '0';
--            hash_squeeze <= '1';
--            state_reg    <= WAIT_CYCLE;
--          end if;

--        when WAIT_CYCLE =>
--          --Wait so that we get the hash part
--          state_reg <= EXTRACT_POSITIONS;

--        when EXTRACT_POSITIONS =>
--          --Extract the positions from the hash output.
--          --We get 7 positions (9 bit) out of 64 bit blocks    
--          if position_counter < MAX_POSITIONS then
--            pos       <= std_logic_vector(resize(unsigned(hash_in) srl position_counter, ADDR_WIDTH));
--            state_reg <= PROCESS_POSITION;
--          else
--            hash_squeeze     <= '1';
--            position_counter <= 0;
--            state_reg        <= WAIT_CYCLE;
--          end if;


--        when PROCESS_POSITION =>
--          --XXX/TODO optimize to use SLR
--          --if already_set(to_integer(unsigned(pos))) = '0' then
--          if already_dout = "0" then
--            already_din <= "1";
--            already_we  <= '1';

--            --already_set(to_integer(unsigned(pos))) <= '1';
--            position_counter      <= position_counter+1;
--            success_counter       <= success_counter+1;
--            c_addr_intern         <= std_logic_vector(to_unsigned(success_counter, c_addr_intern'length));
--            --Write into the memory and also to the ouput 
--            c_din_intern          <= std_logic_vector(pos);
--            c_pos_signature       <= std_logic_vector(pos);
--            c_pos_signature_valid <= '1';
--            c_wr_en_intern        <= '1';

--            state_reg <= SAVE_POSITION;

--            if success_counter = KAPPA-1 then
--              --We now have KAPPA-1+1 values
--              state_reg <= FINISHED;
--              pos       <= (others => '0');
--            end if;
--          else
--            position_counter <= position_counter+1;
--            state_reg        <= EXTRACT_POSITIONS;
--          end if;

--        when SAVE_POSITION =>
--          --already_set(to_integer(unsigned(pos))) <= '1';
--          state_reg <= EXTRACT_POSITIONS;
          

--        when FINISHED =>
--          --Clean the RAM
--          already_din <= "0";
--          already_we  <= '1';
--          if unsigned(pos) < N_ELEMENTS-1 then
--            pos <= std_logic_vector(unsigned(pos)+1);
--          else
--            pos <= std_logic_vector(unsigned(pos)+1);
--          state_reg <= IDLE;            
--          end if;



          
--      end case;
--    end if;
--  end process;


--  c_addr_ram <= c_addr when state_reg = IDLE else c_addr_intern;
--  c_out      <= c_dout_intern;

--  no_mock : if USE_MOCKUP = 0 generate
--    KAPP_RAM : if KAPPA < 32 generate
--      c_ram_inst : c_ram
--        port map (
--          clk  => clk,
--          a    => c_addr_ram,
--          d    => c_din_intern,
--          we   => c_wr_en_intern,
--          qspo => c_dout_intern
--          );
--    end generate KAPP_RAM;

--  end generate no_mock;


--  mock : if USE_MOCKUP = 1 generate
--    KAPP_RAM : if KAPPA < 32 generate
--      c_ram_inst : c_ram
--        port map (
--          clk  => clk,
--          a    => c_addr_ram,
--          d    => c_din_intern,
--          we   => '0',
--          qspo => c_dout_intern
--          );
--    end generate KAPP_RAM;

--  end generate mock;


  

  
--end Behavioral;

































































-- Company: 
-- Engineer: 

-- Create Date:    16:49:12 02/07/2014 
-- Design Name: 
-- Module Name:    get_positions - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 

-- Dependencies: 

-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 


--library IEEE;
--use IEEE.STD_LOGIC_1164.all;
--use ieee.numeric_std.all;
--use ieee.math_real.all;



-- We use Keccak with rate 1024. Thus we just need squeezing.


--entity get_positions is
--  generic (
--    General --------------------------------------
--    N_ELEMENTS    : integer  := 512;
--    PRIME_P_WIDTH : integer  := 14;
--    PRIME_P       : unsigned := to_unsigned(12289, 14);
--      Sparse Mul Core ------------------------------------------
--    KAPPA         : integer  := 23;
--    HASH_BLOCKS   : integer  := 4;
--    USE_MOCKUP    : integer  := 0;
--    HASH_WIDTH    : integer  := 64


--    );

--  port (
--    clk : in std_logic;

--    start : in  std_logic := '0';
--    ready : out std_logic := '0';

--    Hash is finished
--    hash_ready   : in  std_logic := '0';
--    hash_squeeze
--    hash_squeeze : out std_logic := '0';

--    Access the output of the hash function from a distributed RAM (simpler
--    than FIFO which is expensive in terms of area)
--    hash_in               : in  std_logic_vector(HASH_WIDTH-1 downto 0);
--    c_pos_signature       : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
--    c_pos_signature_valid : out std_logic                                                          := '0';
--    c_addr                : in  std_logic_vector(integer(ceil(log2(real(KAPPA))))-1 downto 0)      := (others => '0');
--    c_out                 : out std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0')
--    );

--end get_positions;



--architecture Behavioral of get_positions is

--  component c_ram
--    port (
--      a    : in  std_logic_vector(4 downto 0);
--      d    : in  std_logic_vector(8 downto 0);
--      clk  : in  std_logic;
--      we   : in  std_logic;
--      qspo : out std_logic_vector(8 downto 0)
--      );
--  end component;


--  constant ADDR_WIDTH     : integer := integer(ceil(log2(real(N_ELEMENTS))));
--  constant HASH_RAM_DEPTH : integer := 16;
--  constant MAX_POSITIONS  : integer := integer(floor(real(HASH_WIDTH)/real(ADDR_WIDTH)));


--  signal c_addr_intern  : std_logic_vector(c_addr'range) := (others => '0');
--  signal c_addr_ram     : std_logic_vector(c_addr'range) := (others => '0');
--  signal c_din_intern   : std_logic_vector(c_out'range)  := (others => '0');
--  signal c_wr_en_intern : std_logic                      := '0';
--  signal c_dout_intern  : std_logic_vector(c_out'range)  := (others => '0');

--  type   eg_state is (IDLE, EXTRACT_POSITIONS, SAVE_POSITION, PROCESS_POSITION, WAIT_CYCLE, FINISHED);
--  signal state_reg : eg_state := IDLE;


--  Which position of 64 bit input has been covered
--  signal position_counter : integer range 0 to MAX_POSITIONS+1 := 0;
--  How many positions have been set
--  signal success_counter  : integer range 0 to KAPPA+1         := 0;

--  Contains positions already set
--  Make this slr
--  signal already_set : unsigned(N_ELEMENTS-1 downto 0)         := (others => '0');
--  signal pos         : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
--begin



--  process(clk)
--  begin
--    if rising_edge(clk) then
--      pos                   <= (others => '0');
--      ready                 <= '0';
--      hash_squeeze          <= '0';
--      c_wr_en_intern        <= '0';
--      c_pos_signature_valid <= '0';

--      case state_reg is
--        when IDLE =>
--          ready            <= '1';
--          already_set      <= (others => '0');
--          success_counter  <= 0;
--          position_counter <= 0;
--          c_wr_en_intern   <= '0';

--          Hash has to be ready (finished). Ohterwise we do not start
--          if start = '1' and hash_ready = '1' then
--            ready        <= '0';
--            hash_squeeze <= '1';
--            state_reg    <= WAIT_CYCLE;
--          end if;



--        when WAIT_CYCLE =>
--          Wait so that we get the hash part
--          state_reg <= EXTRACT_POSITIONS;


--        when EXTRACT_POSITIONS =>
--          Extract the positions from the hash output.
--          We get 7 positions (9 bit) out of 64 bit blocks    
--          if position_counter < MAX_POSITIONS then
--            pos       <= std_logic_vector(resize(unsigned(hash_in) srl position_counter, ADDR_WIDTH));
--            state_reg <= PROCESS_POSITION;
--          else
--            hash_squeeze     <= '1';
--            position_counter <= 0;
--            state_reg        <= WAIT_CYCLE;
--          end if;

--        when PROCESS_POSITION =>
--          XXX/TODO optimize to use SLR
--          if already_set(to_integer(unsigned(pos))) = '0' then
--            already_set(to_integer(unsigned(pos))) <= '1';
--            position_counter                       <= position_counter+1;
--            success_counter                        <= success_counter+1;
--            c_addr_intern                          <= std_logic_vector(to_unsigned(success_counter, c_addr_intern'length));
--            Write into the memory and also to the ouput 
--            c_din_intern                           <= std_logic_vector(pos);
--            c_pos_signature                        <= std_logic_vector(pos);
--            c_pos_signature_valid                  <= '1';
--            c_wr_en_intern                         <= '1';

--            state_reg <= SAVE_POSITION;

--            if success_counter = KAPPA-1 then
--              We now have KAPPA-1+1 values
--              state_reg <= FINISHED;
--            end if;
--          else
--            position_counter <= position_counter+1;
--            state_reg        <= EXTRACT_POSITIONS;
--          end if;

--        when SAVE_POSITION =>
--          already_set(to_integer(unsigned(pos))) <= '1';
--          state_reg                              <= EXTRACT_POSITIONS;

--        when FINISHED =>
--          state_reg <= IDLE;


--      end case;
--    end if;
--  end process;


--  c_addr_ram <= c_addr when state_reg = IDLE else c_addr_intern;
--  c_out      <= c_dout_intern;

--  no_mock : if USE_MOCKUP = 0 generate
--    KAPP_RAM : if KAPPA < 32 generate
--      c_ram_inst : c_ram
--        port map (
--          clk  => clk,
--          a    => c_addr_ram,
--          d    => c_din_intern,
--          we   => c_wr_en_intern,
--          qspo => c_dout_intern
--          );
--    end generate KAPP_RAM;

--  end generate no_mock;


--  mock : if USE_MOCKUP = 1 generate
--    KAPP_RAM : if KAPPA < 32 generate
--      c_ram_inst : c_ram
--        port map (
--          clk  => clk,
--          a    => c_addr_ram,
--          d    => c_din_intern,
--          we   => '0',
--          qspo => c_dout_intern
--          );
--    end generate KAPP_RAM;

--  end generate mock;





--end Behavioral;

