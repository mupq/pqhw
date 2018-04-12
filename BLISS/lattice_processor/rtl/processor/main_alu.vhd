--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use work.lattice_processor.all;


--Implements the move, add, sub commands using the butterfly (mar_xxx)
entity main_alu is
  generic (
    ADDR_WIDTH  : integer := 10;
    COL_WIDTH   : integer := 10;
    ELEMENTS    : integer := 512;
    CONNECTIONS : integer := 5
    );
  port (
    clk   : in  std_logic;
    delay : out integer := 1;

    ------------------------------ Memory  ------------------------------------------
    --connected to super_memory
    ram_super_memory_delay : in  integer                                 := 10;
    ram_rd_p1_addr         : out std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
    ram_rd_p1_do           : in  std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');

    ram_rd_p2_addr : out std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
    ram_rd_p2_do   : in  std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');

    ram_wr_p1_addr : out std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
    ram_wr_p1_di   : out std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
    ram_wr_p1_we   : out std_logic;

    ------------------------------ MAR  ------------------------------------------
    --connected to the processing element exported by the fft
    mar_w_in      : out unsigned(COL_WIDTH-1 downto 0) := (others => '0');
    mar_a_in      : out unsigned(COL_WIDTH-1 downto 0) := (others => '0');
    mar_b_in      : out unsigned(COL_WIDTH-1 downto 0) := (others => '0');
    --parallel output
    mar_x_add_out : in  unsigned(COL_WIDTH-1 downto 0) := (others => '0');
    mar_x_sub_out : in  unsigned(COL_WIDTH-1 downto 0) := (others => '0');
    mar_delay     : in  integer                        := 20;

    ------------------------------ Decoder  ------------------------------------------
    --connection to the decoder
    dec_ready : out std_logic                    := '0';
    dec_start : in  std_logic                    := '0';
    dec_op    : in  std_logic_vector(2 downto 0) := (others => '0')

    );
end main_alu;

architecture Behavioral of main_alu is

  signal counter1 : unsigned(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal counter2 : unsigned(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal counter3 : unsigned(ADDR_WIDTH-1 downto 0) := (others => '0');

  signal mov_delay    : integer := 0;
  signal addsub_delay : integer := 0;

  type   eg_state is (IDLE, ALU_MOV, ALU_MOV_WAIT, ALU_ADD, ALU_ADD_WAIT, ALU_SUB_WAIT, ALU_SUB);
  signal state_reg : eg_state := IDLE;

  --mov
  signal ram_wr_p1_addr_mov_delay : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal ram_wr_p1_we_mov_delay   : std_logic_vector(0 downto 0)            := (others => '0');

  signal ram_wr_p1_addr_mov_delay_out : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal ram_wr_p1_we_mov_delay_out   : std_logic_vector(0 downto 0)            := (others => '0');

  --add/sub
  signal ram_wr_p1_addr_addsub_delay : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal ram_wr_p1_we_addsub_delay   : std_logic_vector(0 downto 0)            := (others => '0');

  signal ram_wr_p1_addr_addsub_delay_out : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal ram_wr_p1_we_addsub_delay_out   : std_logic_vector(0 downto 0)            := (others => '0');

  signal dec_ready_intern : std_logic := '0';



  
begin

  -- Can perform three operations:
  -- 1) MOV: wr_p1 <= rd_p1 
  -- 2) ADD: wr_p1 <= rd_p1 + rd_p2
  -- 3) SUB: wr_p1 <= rd_p1 - rd_p2
  -- The component does not care about selection of RAM. This is handled by the
  -- decoder. It just requestst the data and writes the result back


  -----------------------------------------------------------------------------
  -- MOV
  -----------------------------------------------------------------------------
  mov_delay <= ram_super_memory_delay;
  mov_delay_addr : entity work.dyn_shift_reg
    generic map (
      max_depth => 15,
      width     => ADDR_WIDTH
      )
    port map (
      clk    => clk,
      depth  => mov_delay,
      Input  => ram_wr_p1_addr_mov_delay,
      Output => ram_wr_p1_addr_mov_delay_out
      );

  mov_delay_wr : entity work.dyn_shift_reg
    generic map (
      max_depth => 15,
      width     => 1
      )
    port map (
      clk    => clk,
      depth  => mov_delay,
      Input  => ram_wr_p1_we_mov_delay,
      Output => ram_wr_p1_we_mov_delay_out
      );

  -----------------------------------------------------------------------------
  -- ADD/SUB
  -----------------------------------------------------------------------------
  addsub_delay <= ram_super_memory_delay + mar_delay +1;
  addsub_delay_addr : entity work.dyn_shift_reg
    generic map (
      max_depth => 15,
      width     => ADDR_WIDTH
      )
    port map (
      clk    => clk,
      depth  => addsub_delay,
      Input  => ram_wr_p1_addr_addsub_delay,
      Output => ram_wr_p1_addr_addsub_delay_out
      );

  addsub_delay_wr : entity work.dyn_shift_reg
    generic map (
      max_depth => 15,
      width     => 1
      )
    port map (
      clk    => clk,
      depth  => addsub_delay,
      Input  => ram_wr_p1_we_addsub_delay,
      Output => ram_wr_p1_we_addsub_delay_out
      );


  --Select from which source we take the new output (mov, add, sub)
  ram_wr_p1_di <= ram_rd_p1_do when (state_reg = ALU_MOV or state_reg = ALU_MOV_WAIT) else
                  (others => '0');
  
  ram_wr_p1_addr <= ram_wr_p1_addr_mov_delay_out when (state_reg = ALU_MOV or state_reg = ALU_MOV_WAIT)
                    else (others => '0');
  
  ram_wr_p1_we <= ram_wr_p1_we_mov_delay_out(0)when (state_reg = ALU_MOV or state_reg = ALU_MOV_WAIT)
                                                       else '0';



  --Select from which source we take the new output (mov, add, sub)
  ram_wr_p1_di <= ram_rd_p1_do when (state_reg = ALU_MOV or state_reg = ALU_MOV_WAIT) else
                  (others => '0');
  
  ram_wr_p1_addr <= ram_wr_p1_addr_mov_delay_out when (state_reg = ALU_MOV or state_reg = ALU_MOV_WAIT)
                    else (others => '0');
  
  ram_wr_p1_we <= ram_wr_p1_we_mov_delay_out(0)when (state_reg = ALU_MOV or state_reg = ALU_MOV_WAIT)
                                                       else '0';


  
  dec_ready <= dec_ready_intern and (not dec_start);


  process(clk)
  begin  -- process c
    if rising_edge(clk) then

      dec_ready_intern             <= '0';
      ram_wr_p1_we_mov_delay(0)    <= '0';
      ram_wr_p1_we_addsub_delay(0) <= '0';  -- has to be delayed

      --datae into MAR
      mar_w_in <= unsigned(to_unsigned(1, mar_w_in'length));  --
      mar_a_in <= unsigned(ram_rd_p1_do);
      mar_b_in <= unsigned(ram_rd_p2_do);


      case state_reg is
        -----------------------------------------------------------------------
        -- IDLE
        -----------------------------------------------------------------------
        when IDLE =>
          dec_ready_intern <= '1';

          counter1 <= (others => '0');
          counter2 <= (others => '0');
          counter3 <= (others => '0');

          if dec_start = '1' then
            dec_ready_intern <= '0';
            if dec_op = INST_ALU_MOV then
              state_reg <= ALU_MOV;
            elsif dec_op = INST_ALU_ADD then
              state_reg <= ALU_ADD;
            elsif dec_op = INST_ALU_SUB then
              state_reg <= ALU_SUB;
            end if;
          end if;

          ---------------------------------------------------------------------
          -- MOV
          ---------------------------------------------------------------------
        when ALU_MOV =>
          --We do not need the PE
          ram_rd_p1_addr            <= std_logic_vector(counter1);
          ram_wr_p1_addr_mov_delay  <= std_logic_vector(counter1);  --has to be delayed
          ram_wr_p1_we_mov_delay(0) <= '1';  -- has to be delayed

          if counter1 = ELEMENTS-1 then
            state_reg <= ALU_MOV_WAIT;
          else
            counter1 <= counter1+1;
          end if;

        when ALU_MOV_WAIT =>
          if counter2 = mov_delay then
            state_reg <= IDLE;
          else
            counter2 <= counter2+1;
          end if;

          -------------------------------------------------------------------------------
          -- ADD
          -------------------------------------------------------------------------------
          -- a_in +- w_in* b_in
        when ALU_ADD =>
          report "NOT SUPPORTED OPERATION" severity error;
           state_reg <= IDLE;
          
          ---- Now we need the PE = more latency
          ----We do not need the PE
          --ram_rd_p1_addr               <= std_logic_vector(counter1);
          --ram_rd_p2_addr               <= std_logic_vector(counter1);
          --ram_wr_p1_addr_addsub_delay  <= std_logic_vector(counter1);  --has to be delayed
          --ram_wr_p1_we_addsub_delay(0) <= '1';  -- has to be delayed

          --if counter1 = ELEMENTS-1 then
          --  state_reg <= ALU_ADD_WAIT;
          --else
          --  counter1 <= counter1+1;
          --end if;

          ---------------------------------------------------------------------
          -- SUB
          ---------------------------------------------------------------------
        when ALU_SUB =>
          report "NOT SUPPORTED OPERATION" severity error;
           state_reg <= IDLE;
        
          --ram_rd_p1_addr               <= std_logic_vector(counter1);
          --ram_rd_p2_addr               <= std_logic_vector(counter1);
          --ram_wr_p1_addr_addsub_delay  <= std_logic_vector(counter1);  --has to be delayed
          --ram_wr_p1_we_addsub_delay(0) <= '1';  -- has to be delayed

          --if counter1 = ELEMENTS-1 then
          --  state_reg <= ALU_SUB_WAIT;
          --else
          --  counter1 <= counter1+1;
          --end if;

          ---------------------------------------------------------------------
          -- ADDSUB WAIT
          ---------------------------------------------------------------------
          
        when ALU_ADD_WAIT =>
          report "NOT SUPPORTED OPERATION" severity error;
           state_reg <= IDLE;
        
          --if counter2 = addsub_delay then
          --  state_reg <= IDLE;
          --else
          --  counter2 <= counter2+1;
          --end if;


        when ALU_SUB_WAIT =>
          report "NOT SUPPORTED OPERATION" severity error;
           state_reg <= IDLE;
        
          --if counter2 = addsub_delay then
          --  state_reg <= IDLE;
          --else
          --  counter2 <= counter2+1;
          --end if;
          
      end case;

    end if;
  end process;

end Behavioral;

