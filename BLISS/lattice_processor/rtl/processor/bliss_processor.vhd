--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:07:18 02/05/2014 
-- Design Name: 
-- Module Name:    bliss_processor - Behavioral 
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
use work.lattice_processor.all;
use work.lyu512_pkg.all;


entity bliss_processor is
  generic (
    PARAMETER_SET                       :integer :=1;
    SAMPLER          : string  := "dual_cdt_gauss";  --"none", "bernoulli_gauss", "dual_cdt_gauss"
    GAUSS_SIGMA      : real    := 215.0;
    NUM_BER_SAMPLERS : integer := 2;
    MODE             : string  := "BOTH"
    );
  port (
    clk : in std_logic;

    data_avail  : out std_logic := '0';
    copy_data   : in  std_logic := '0';
    data_copied : out std_logic := '0';

    data_out : out std_logic_vector(13 downto 0);
    addr_out : out std_logic_vector(8 downto 0);

    we_ayy : out std_logic;
    we_y1  : out std_logic;
    we_y2  : out std_logic;

    ver_rd_fin : out std_logic := '0';

    command  : in  std_logic_vector(LYU_ARITH_COMMAND_SIZE-1 downto 0) := LYU_ARITH_SIGN_MODE;
    finished : out std_logic;

    data_in : in  std_logic_vector(13 downto 0) := (others => '0');  --For verify
    addr_in : out std_logic_vector(8 downto 0)  --For verify
    );
end bliss_processor;


architecture Behavioral of bliss_processor is

  -- BLISS specific definition of the processor system
  constant PRIME_P       : unsigned := to_unsigned(12289, 14);
  constant PRIME_P_WIDTH : integer  := PRIME_P'length;
  constant XN            : integer  := -1;  --ring (-1 or 1)
  constant N_ELEMENTS    : integer  := 512;
  constant PSI           : unsigned := to_unsigned(49, PRIME_P_WIDTH);
  constant OMEGA         : unsigned := to_unsigned(2401, PRIME_P_WIDTH);
  constant PSI_INVERSE   : unsigned := to_unsigned(1254, PRIME_P_WIDTH);
  constant OMEGA_INVERSE : unsigned := to_unsigned(11813, PRIME_P_WIDTH);
  constant N_INVERSE     : unsigned := to_unsigned(12265, PRIME_P_WIDTH);
  constant S1_MAX        : unsigned := to_unsigned(2*(2**14)-1, 16);

  --Decide depending on verify-only or both how many RAMs are needed
  function rams_func(mode : string)return integer is
  begin
    if MODE = "BOTH" then
      return 1;
    elsif MODE = "VERIFY" then
      return 0;
    else
      --return 2;
    end if;
  end rams_func;

  constant RAM_WIDTHs : my_array_t := (PRIME_P_WIDTH, 0, 0, 0 , 0, 0, 0, 0, 0, 0);
  constant INIT_ARRAY : init_array_t := (0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  constant INIT_ARRAY_VALUE_FFT :integer :=get_bliss_get_a_path(PARAMETER_SET);
  
  signal fft_proc_ready : std_logic                                                          := '0';
  signal fft_proc_start : std_logic                                                          := '0';
  signal fft_proc_op    : std_logic_vector(PROC_INST_SIZE-1 downto 0)                        := (others => '0');
  signal fft_proc_arg0  : std_logic_vector(PROC_ARG1_SIZE-1 downto 0)                        := (others => '0');
  signal fft_proc_arg1  : std_logic_vector(PROC_ARG2_SIZE-1 downto 0)                        := (others => '0');
  signal fft_io_rd_addr : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal fft_io_rd_do   : std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');
  signal fft_io_wr_addr : std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
  signal fft_io_wr_di   : std_logic_vector(PRIME_P_WIDTH-1 downto 0)                         := (others => '0');
  signal fft_io_wr_we   : std_logic;

  signal data_in_reg1 : std_logic_vector(13 downto 0) := (others => '0');  --For verify
  signal data_in_reg2 : std_logic_vector(13 downto 0) := (others => '0');  --For verify

  type eg_state is (IDLE, DECIDE_EXEC, EXECUTE_COMMAND, WAIT_PROC_READY_S1, WAIT_PROC_READY, WAIT_PROC_STOPPED);
  signal state_reg : eg_state := IDLE;
  signal program_counter : unsigned(5 downto 0)                                       := (others => '0');
  signal addr_counter    : unsigned(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');

  --Info:
  -- r_0-1 : FFT
  -- r_2-3 : I/O, Sampler
  -- r_4   : y1 (23bit) - result for verification is accumulated here
  -- r_5   : y2 (15 bit)
  -- r_6   : a
  -- r_7   : t
  
  constant inst_list : inst_list_t := (

    --Some room for optimization. Leave a in FFT format in the core
    --Sample y2 directly from the sampler
    --Use copy to Io when doing InvPsi

    ------ Signing -----
    to_comm(INST_PROC_NTT_GP_MODE, 0, 0),
    --to_comm(INST_PROC_MOV, 0, 4),  --Load a into port a
    to_comm(INST_PROC_NTT_NOP, 0, 0),
    to_comm(INST_PROC_WAIT_UNI_SAMPLER_READY, 0, 0),
    to_comm(INST_PROC_MOV, 4, SAMPLER_PORT),  --XXX TODO
    --to_comm(INST_PROC_NTT_NOP, 0, 0),
    to_comm(INST_PROC_NTT_BITREV_B, 4, 0),
    to_comm(INST_PROC_NTT_NTT_B, 0, 0),
    to_comm(INST_PROC_NTT_POINTWISE_MUL, 0, 0),
    --to_comm(INST_PROC_NTT_NOP, 0, 0),
    to_comm(INST_PROC_NTT_INTT, 0, 0),
    --to_comm(INST_PROC_WAIT_UNI_SAMPLER_READY, 0, 0),
    to_comm(INST_PROC_NTT_NOP, 0, 0),
    --to_comm(INST_PROC_MOV, 5, SAMPLER_PORT),  --XXX TODO1
    to_comm(INST_PROC_NTT_NOP, 0, 0),   --XXX TODO1
    to_comm(INST_PROC_NTT_INV_N, 0, 0),
    to_comm(INST_PROC_NTT_INV_PSI, 0, 0),
    --When output is ready
    --to_comm(INST_PROC_NTT_GP_MODE, 0, 0),
    to_comm(INST_PROC_WAIT_UNI_SAMPLER_READY, 0, 0),
    --to_comm(INST_PROC_ENABLE_COPY_TO_IO, 0, 0),
    to_comm(INST_PROC_NTT_GP_MODE, 0, 0),
    to_comm(INST_PROC_OUT, 1, 0),
    to_comm(INST_PROC_DISABLE_COPY_TO_IO, 0, 0),
    --to_comm(INST_PROC_OUT, 5, 0),
    to_comm(INST_PROC_OUT, SAMPLER_PORT, 0),
    to_comm(INST_PROC_OUT, 4, 0),

    --------------------------------------------------------------------------
    -- 
    --------------------------------------------------------------------------
    ------ Verify -----
    --Compute az_1
    to_comm(INST_PROC_NTT_GP_MODE, 0, 0),
    --to_comm(INST_PROC_MOV, 0, 4),  --Load a into port a
    to_comm(INST_PROC_NTT_NOP, 0, 0),
    to_comm(INST_PROC_NTT_BITREV_B, IO_PORT, 0),  --Load z_1
    to_comm(INST_PROC_NTT_NTT_B, 0, 0),           --Transform z_1
    to_comm(INST_PROC_NTT_POINTWISE_MUL, 0, 0),
    to_comm(INST_PROC_NTT_INTT, 0, 0),
    to_comm(INST_PROC_NTT_INV_N, 0, 0),
    to_comm(INST_PROC_NTT_INV_PSI, 0, 0),
    --to_comm(INST_PROC_NTT_NOP, 0, 0),
    --to_comm(INST_PROC_NTT_NOP, 0, 0),
    --to_comm(INST_PROC_NTT_NOP, 0, 0),
    to_comm(INST_PROC_NTT_GP_MODE, 0, 0),
    --to_comm(INST_PROC_MOV, 4, 1),
    to_comm(INST_PROC_OUT, 1, 0)

    --Add z2
    --to_comm(INST_PROC_ENABLE_COPY_TO_IO, 0, 0),
    --to_comm(INST_PROC_ADD, 4, IO_PORT),
    --to_comm(INST_PROC_DISABLE_COPY_TO_IO, 0, 0),
    ----to_comm(INST_PROC_OUT, 4, 0),
    ----Compute and substract tc and then output
    --to_comm(INST_PROC_NTT_GP_MODE, 0, 0),
    --to_comm(INST_PROC_MOV, 0, 7),  --Load a into port a (not in FFT format)
    ----to_comm(INST_PROC_NTT_GP_MODE, 0, 0),
    --to_comm(INST_PROC_NTT_BITREV_B, IO_PORT, 0),  --Load c
    --to_comm(INST_PROC_NTT_NTT_B, 0, 0),           --Transform c
    --to_comm(INST_PROC_NTT_POINTWISE_MUL, 0, 0),

    --to_comm(INST_PROC_NTT_GP_MODE, 0, 0),
    --to_comm(INST_PROC_ADD, 1, 4),

    --to_comm(INST_PROC_NTT_INTT, 0, 0),
    --to_comm(INST_PROC_NTT_INV_N, 0, 0),
    --to_comm(INST_PROC_NTT_INV_PSI, 0, 0),
    --to_comm(INST_PROC_NTT_GP_MODE, 0, 0),
    --to_comm(INST_PROC_MOV, 4, 1)        --subtract tc from az_1+z_2 - This is a
    --hack - somreqhere the negative/positive
    --relation of c is not correct. However,
    --this way it works (should be SUB)
    );

  constant LABEL_LOAD_A            : integer := 1;
  constant LABEL_WRITE_AYY         : integer := 14;
  constant LABEL_WRITE_Y1          : integer := 17;
  constant LABEL_WRITE_Y2          : integer := 16;
  constant LABEL_START_COMPUTE_AZ1 : integer := 18;
  constant LABEL_END_COMPUTE_AZ1   : integer := 28;
  constant LABEL_START_ADD_Z2      : integer := 28;
  constant LABEL_END_ADD_Z2        : integer := 31;
  constant LABEL_START_SUB_TC      : integer := 31;
  constant LABEL_END_SUB_TC        : integer := 43;
  constant LABEL_WRITE_RESULT      : integer := 29;
  constant LABEL_VER_READ_FIN_Z1   : integer := LABEL_START_COMPUTE_AZ1+3;
  constant LABEL_VER_READ_FIN_C    : integer := LABEL_START_SUB_TC+4;

  signal   data_out_intern : std_logic_vector(data_out'length-1 downto 0);
  constant FIFO_DATA_WIDTH : integer                                      := data_out'length;
  signal   free_run_mode   : std_logic                                    := '1';
  signal   temp_val        : std_logic_vector(FIFO_DATA_WIDTH-1 downto 0) := (others => '0');
  signal   debug_negativ   : std_logic_vector(FIFO_DATA_WIDTH-1 downto 0);

  signal a_already_loaded : std_logic := '0';
begin

  --with_sampler : if MODE = "BOTH" or MODE = "SIGN" generate
  fft_proc_1 : entity work.processor
    generic map (
      PARAMETER_SET => PARAMETER_SET,
      INIT_ARRAY_VALUE_FFT => INIT_ARRAY_VALUE_FFT,
      --Configurable from toplevel
      MODE             => MODE,
      SAMPLER          => SAMPLER,
      GAUSS_SIGMA      => GAUSS_SIGMA,
      NUM_BER_SAMPLERS => NUM_BER_SAMPLERS,
      --Fixed for BLISS and not configurable from toplevel
      XN               => XN,
      N_ELEMENTS       => N_ELEMENTS,
      PRIME_P_WIDTH    => PRIME_P_WIDTH,
      PRIME_P          => PRIME_P,
      --NTT constants
      PSI              => PSI,
      OMEGA            => OMEGA,
      PSI_INVERSE      => PSI_INVERSE,
      OMEGA_INVERSE    => OMEGA_INVERSE,
      N_INVERSE        => N_INVERSE,
      --Rams
      RAMS             => rams_func(mode),
      INIT_ARRAY       => INIT_ARRAY ,
      RAM_WIDTHs       => RAM_WIDTHs
      )
    port map (
      clk        => clk,
      proc_ready => fft_proc_ready,
      proc_start => fft_proc_start,
      proc_op    => fft_proc_op,
      proc_arg0  => fft_proc_arg0,
      proc_arg1  => fft_proc_arg1,
      io_rd_addr => fft_io_rd_addr,
      io_rd_do   => fft_io_rd_do,
      io_wr_addr => fft_io_wr_addr,
      io_wr_di   => fft_io_wr_di,
      io_wr_we   => fft_io_wr_we
      );
  --end generate with_sampler;




  data_out      <= std_logic_vector(resize(unsigned(data_out_intern), data_out'length));
  debug_negativ <= std_logic_vector(resize(unsigned(data_out_intern), debug_negativ'length));

  process (clk)
  begin  -- process
    if rising_edge(clk) then            -- rising clock edge
      fft_proc_start <= '0';
      data_avail     <= '0';
      data_copied    <= '0';
      finished       <= '0';
      ver_rd_fin     <= '0';

      --Used for verification

      data_in_reg1 <= data_in;

      --hacky XXX TODO
      if signed(data_in_reg1) < 0 then
        data_in_reg2 <= std_logic_vector(resize(unsigned(signed(data_in_reg1)+signed("0"&PRIME_P)), data_in_reg2'length));
      else
        data_in_reg2 <= std_logic_vector(resize(unsigned(data_in_reg1), data_in_reg2'length));
      end if;

      fft_io_rd_do <= data_in_reg2;

      addr_in <= fft_io_rd_addr;


      data_out_intern <= fft_io_wr_di;
      addr_out        <= std_logic_vector(addr_counter);

      we_ayy <= '0';
      we_y1  <= '0';
      we_y2  <= '0';



      if fft_io_wr_we = '1' then
        addr_counter <= addr_counter+1;
      end if;

      --Output logic
      if program_counter = LABEL_WRITE_AYY or program_counter = LABEL_END_COMPUTE_AZ1-1 then
        we_ayy <= fft_io_wr_we;
      end if;

      if program_counter = LABEL_WRITE_Y1 then
        if unsigned(fft_io_wr_di) > resize(S1_MAX, fft_io_wr_di'length) then
          data_out_intern                             <= (others => '0');
          data_out_intern(FIFO_DATA_WIDTH-1 downto 0) <= std_logic_vector(resize(signed("0"&(unsigned(fft_io_wr_di)))-signed("0"&PRIME_P) , FIFO_DATA_WIDTH));
        end if;
        we_y1 <= fft_io_wr_we;
      end if;

      if program_counter = LABEL_WRITE_Y2 then
        if unsigned(fft_io_wr_di) > resize(S1_MAX, fft_io_wr_di'length) then
          data_out_intern                             <= (others => '0');
          data_out_intern(FIFO_DATA_WIDTH-1 downto 0) <= std_logic_vector(resize(signed("0"&(unsigned(fft_io_wr_di)))-signed("0"&PRIME_P) , FIFO_DATA_WIDTH));
        end if;
        we_y2 <= fft_io_wr_we;
      end if;

      if program_counter = LABEL_WRITE_RESULT then
        we_ayy <= fft_io_wr_we;
      end if;


      case state_reg is
        when IDLE =>
          --Start directly to generate values. No start signal needed.
          state_reg       <= DECIDE_EXEC;
          program_counter <= (others => '0');

          --State Logic
        when DECIDE_EXEC =>
          -- If no command is set, then just wait for one


          --if program_counter = LABEL_VER_READ_FIN_Z1 or program_counter = LABEL_VER_READ_FIN_C then
          -- ver_rd_fin <= '1';
          -- end if;

          if (program_counter = 0 and command = LYU_ARITH_SIGN_MODE) then
            --Just a new free run
            free_run_mode   <= '1';
            program_counter <= to_unsigned(0, program_counter'length);
            state_reg       <= EXECUTE_COMMAND;
          elsif (program_counter = 0 and command = LYU_ARITH_COMP_AZ1) then
            program_counter <= to_unsigned(LABEL_START_COMPUTE_AZ1, program_counter'length);
            state_reg       <= EXECUTE_COMMAND;
            --elsif (program_counter = 0 and command = LYU_ARITH_ADD_Z2) then
            -- program_counter <= to_unsigned(LABEL_START_ADD_Z2, program_counter'length);
            --  state_reg       <= EXECUTE_COMMAND;
            --elsif (program_counter = 0 and command = LYU_ARITH_SUB_TC) then
            --program_counter <= to_unsigned(LABEL_START_SUB_TC, program_counter'length);
            --state_reg       <= EXECUTE_COMMAND;
          end if;

          --For Signing Mode
          if program_counter = 10 then
            --We have to wait first if ready
            data_avail <= '1';
            if copy_data = '1' then
              state_reg <= EXECUTE_COMMAND;
            end if;
          elsif program_counter = 16+2 then
            data_copied     <= '1';
            program_counter <= (others => '0');
            state_reg       <= EXECUTE_COMMAND;
          elsif free_run_mode = '1' or program_counter > 0 then
            state_reg <= EXECUTE_COMMAND;
          end if;

          --For Verification Mode
          if (program_counter = LABEL_END_COMPUTE_AZ1) or (program_counter = LABEL_END_ADD_Z2) or (program_counter = LABEL_END_SUB_TC) then
            finished        <= '1';
            program_counter <= (others => '0');
            state_reg       <= DECIDE_EXEC;
          end if;

          if program_counter = LABEL_LOAD_A then
            --a_already_loaded <= '1';
          end if;

          if program_counter = LABEL_LOAD_A and a_already_loaded = '1' then
            --Jump over the loading of a
            program_counter <= program_counter+1;
          end if;


          --Just execute the next command
        when EXECUTE_COMMAND =>
          fft_proc_start <= '1';
          fft_proc_op    <= inst_list(to_integer(program_counter)).op;
          fft_proc_arg0  <= inst_list(to_integer(program_counter)).arg0;
          fft_proc_arg1  <= inst_list(to_integer(program_counter)).arg1;

          state_reg <= WAIT_PROC_READY_S1;

        when WAIT_PROC_READY_S1 =>
          state_reg <= WAIT_PROC_READY;

          --Wait until the command has been executed
        when WAIT_PROC_READY =>
          if fft_proc_ready = '1' then
            program_counter <= program_counter +1;
            state_reg       <= DECIDE_EXEC;
          end if;

        when WAIT_PROC_STOPPED =>
          if fft_proc_ready = '1' then
            program_counter <= (others => '0');
            state_reg       <= DECIDE_EXEC;
            finished        <= '1';
          end if;
          
      end case;


      --A stop command has been issue - stop current execution and then become
      --ready
      if command = LYU_ARITH_STOP_SIGN then
        state_reg     <= WAIT_PROC_STOPPED;
        free_run_mode <= '0';
      end if;


    end if;
  end process;
  
end Behavioral;










