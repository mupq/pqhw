--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.lattice_processor.all;

entity decoder is
  port (
    clk : in std_logic;

    --commands from outsite
    proc_ready : out std_logic                                   := '0';
    proc_start : in  std_logic                                   := '0';
    proc_op    : in  std_logic_vector(PROC_INST_SIZE-1 downto 0) := (others => '0');
    proc_arg0  : in  std_logic_vector(PROC_ARG1_SIZE-1 downto 0) := (others => '0');
    proc_arg1  : in  std_logic_vector(PROC_ARG2_SIZE-1 downto 0) := (others => '0');

    --control signal for the super memory
    smem_rd_p1_ctl         : out unsigned(3 downto 0) := (others => '0');
    smem_rd_p2_ctl         : out unsigned(3 downto 0) := (others => '0');
    smem_wr_p1_ctl         : out unsigned(3 downto 0) := (others => '0');
    smem_stable            : in  std_logic            := '0';  --muxer stable after change
    smem_enable_copy_to_io : out std_logic            := '0';

    --control signals for sampler
    uni_samp_ready : in  std_logic := '0';
    uni_samp_start : out std_logic := '0';
    uni_samp_stop  : out std_logic := '0';

    --control signals for the ntt core
    ntt_ready : in  std_logic                                  := '0';
    ntt_start : out std_logic                                  := '0';
    ntt_op    : out std_logic_vector(NTT_INST_SIZE-1 downto 0) := (others => '0');

    --control signal for the alu
    alu_dec_ready : in  std_logic                    := '0';
    alu_dec_start : out std_logic                    := '0';
    alu_dec_op    : out std_logic_vector(2 downto 0) := (others => '0')

    --sampler probably does not neet ctl signals as its just a RAM/FIFO
    );

end decoder;

architecture Behavioral of decoder is

  type eg_state is (IDLE, NTT_BITREV_A, NTT_BITREV_B, NTT_BITREV_WAIT , NTT_NTT_A, NTT_NTT_B, NTT_WAIT_READY, NTT_POINTWISE_MUL, NTT_INTT, NTT_INV_PSI, NTT_INV_N, NTT_GP_MODE, PROC_MOV, PROC_ADD, PROC_SUB, PROC_ALU_WAIT, PROC_WAIT_UNI_SAMPLER_READY, PROC_IN, PROC_OUT, PROC_OUT_WAIT, PROC_OUT_WAIT_temp, PROC_SAMPLE_WAIT, PROC_ENABLE_COPY_TO_IO, PROC_DISABLE_COPY_TO_IO);

  signal state_reg              : eg_state             := IDLE;
  signal ret_state_reg          : eg_state             := IDLE;
  signal small_counter          : unsigned(3 downto 0) := (others => '0');
  signal enable_copy_to_io_flag : std_logic            := '0';
  signal ntt_start_intern       : std_logic            := '0';
  signal alu_dec_start_intern   : std_logic            := '0';

  --Measurement - internal not to be synthesized
  signal clk_counter      : unsigned(40 downto 0) := (others => '0');
  signal start_clk        : unsigned(40 downto 0) := (others => '0');
  signal end_clk          : unsigned(40 downto 0) := (others => '0');
  signal command_executed : std_logic             := '0';

  type   array_type_bench is array (0 to 2**PROC_INST_SIZE-1) of unsigned(40 downto 0);  --first define the type of array.
  signal array_bench   : array_type_bench;  --array_name1 is a 4 element array of integers.
  signal executed_inst : std_logic_vector(PROC_INST_SIZE-1 downto 0) := (others => '0');
  
begin

  process (clk)
  begin  -- process
    if rising_edge(clk) then
      clk_counter <= clk_counter+1;
    end if;
  end process;




  ntt_start              <= ntt_start_intern;
  alu_dec_start          <= alu_dec_start_intern;
  smem_enable_copy_to_io <= enable_copy_to_io_flag;

  process(clk)
  begin
    if rising_edge(clk) then
      --Benchmarking
      

      proc_ready           <= '0';
      ntt_start_intern     <= '0';
      alu_dec_start_intern <= '0';
      uni_samp_stop        <= '0';

      --always enable the sampler
      uni_samp_start <= '1';
      case state_reg is
        when IDLE =>
          if command_executed = '1' then
            array_bench(to_integer(unsigned(executed_inst))) <= clk_counter - start_clk;
            command_executed                                 <= '0';
          end if;

          proc_ready <= '1';

          --State machine that jumps into a state depending on the instruction
          --to be executed
          if proc_start = '1' then
            --Benchmarking
            start_clk        <= clk_counter;
            command_executed <= '1';
            executed_inst    <= proc_op;

            proc_ready    <= '0';
            small_counter <= (others => '0');
            if proc_op = INST_PROC_NTT_BITREV_A then
              state_reg <= NTT_BITREV_A;
            elsif proc_op = INST_PROC_NTT_BITREV_B then
              state_reg <= NTT_BITREV_B;
            elsif proc_op = INST_PROC_NTT_NTT_A then
              state_reg <= NTT_NTT_A;
            elsif proc_op = INST_PROC_NTT_NTT_B then
              state_reg <= NTT_NTT_B;
            elsif proc_op = INST_PROC_NTT_POINTWISE_MUL then
              state_reg <= NTT_POINTWISE_MUL;
            elsif proc_op = INST_PROC_NTT_INTT then
              state_reg <= NTT_INTT;
            elsif proc_op = INST_PROC_NTT_INV_N then
              state_reg <= NTT_INV_N;
            elsif proc_op = INST_PROC_NTT_INV_PSI then
              state_reg <= NTT_INV_PSI;
            elsif proc_op = INST_PROC_NTT_GP_MODE then
              state_reg <= NTT_GP_MODE;
            elsif proc_op = INST_PROC_MOV then
              state_reg <= PROC_MOV;
            elsif proc_op = INST_PROC_ADD then
              state_reg <= PROC_ADD;
            --elsif proc_op = INST_PROC_POINTWISE_MUL then
            --  state_reg <= PROC_POINTWISE_MUL; 
            elsif proc_op = INST_PROC_SUB then
              state_reg <= PROC_SUB;
            elsif proc_op = INST_PROC_WAIT_UNI_SAMPLER_READY then
              state_reg <= PROC_WAIT_UNI_SAMPLER_READY;
            elsif proc_op = INST_PROC_IN then
              state_reg <= PROC_IN;
            elsif proc_op = INST_PROC_OUT then
              state_reg <= PROC_OUT;
            elsif proc_op = INST_PROC_ENABLE_COPY_TO_IO then
              state_reg <= PROC_ENABLE_COPY_TO_IO;
            elsif proc_op = INST_PROC_DISABLE_COPY_TO_IO then
              state_reg <= PROC_DISABLE_COPY_TO_IO;
            end if;
          end if;

        when NTT_BITREV_A =>
          report "NOT SUPPORTED" severity error;
          state_reg <= IDLE;
          ----Read from ARG0 Port
          --smem_rd_p1_ctl <= resize(unsigned(proc_arg0), smem_rd_p1_ctl 'length);
          ----Write into the first Port of the FFT
          --smem_wr_p1_ctl <= to_unsigned(FFT_R0_PORT, smem_rd_p1_ctl'length);

          ----Wait for everything to be ready
          --if smem_stable = '1' and ntt_ready = '1' and alu_dec_ready = '1' then
          --  ntt_op               <= INST_NTT_BITREV_A;
          --  ntt_start_intern     <= '1';
          --  alu_dec_op           <= INST_ALU_MOV;
          --  alu_dec_start_intern <= '1';
          --  state_reg            <= NTT_BITREV_WAIT;
          --end if;

          
        when NTT_BITREV_B =>
          --Read from ARG0 Port
          smem_rd_p1_ctl <= resize(unsigned(proc_arg0), smem_rd_p1_ctl 'length);
          --Write into the first Port of the FFT
          smem_wr_p1_ctl <= to_unsigned(FFT_R1_PORT, smem_rd_p1_ctl'length);

          --Wait for everything to be ready
          if smem_stable = '1' and ntt_ready = '1' and alu_dec_ready = '1' then
            ntt_op               <= INST_NTT_BITREV_B;
            ntt_start_intern     <= '1';
            alu_dec_op           <= INST_ALU_MOV;
            alu_dec_start_intern <= '1';
            state_reg            <= NTT_BITREV_WAIT;
          end if;

        when NTT_BITREV_WAIT =>
          if ntt_ready = '1' and alu_dec_ready = '1' and ntt_start_intern = '0' then
            state_reg <= IDLE;
          end if;

        when NTT_NTT_A =>
           report "NOT SUPPORTED" severity error;
          state_reg <= IDLE;
           
          --if ntt_ready = '1' then
          --  ntt_op           <= INST_NTT_NTT_A;
          --  ntt_start_intern <= '1';
          --  state_reg        <= NTT_WAIT_READY;
          --end if;

        when NTT_NTT_B =>
          if ntt_ready = '1' then
            ntt_op           <= INST_NTT_NTT_B;
            ntt_start_intern <= '1';
            state_reg        <= NTT_WAIT_READY;
          end if;

        when NTT_WAIT_READY =>
          if ntt_ready = '1' and ntt_start_intern = '0' then
            state_reg <= IDLE;
          end if;

          
        when NTT_POINTWISE_MUL =>
            if ntt_ready = '1' then
            ntt_op           <= INST_NTT_POINTWISE_MUL;
            ntt_start_intern <= '1';
            state_reg        <= NTT_WAIT_READY;
          end if;
          
           
        

        when NTT_INTT =>
          if ntt_ready = '1' then
            ntt_op           <= INST_NTT_INTT;
            ntt_start_intern <= '1';
            state_reg        <= NTT_WAIT_READY;
          end if;
          
        when NTT_INV_PSI =>
          if ntt_ready = '1' then
            ntt_op           <= INST_NTT_INV_PSI;
            ntt_start_intern <= '1';
            state_reg        <= NTT_WAIT_READY;
          end if;

        when NTT_INV_N =>
          --Read from ARG0 Port
          smem_rd_p1_ctl <= resize(unsigned(proc_arg1), smem_rd_p1_ctl 'length);
          --Write into
          smem_wr_p1_ctl <= resize(unsigned(proc_arg0), smem_wr_p1_ctl'length);

          if ntt_ready = '1' then
            ntt_op           <= INST_NTT_INV_N;
            ntt_start_intern <= '1';
            state_reg        <= NTT_WAIT_READY;
          end if;

        when NTT_GP_MODE =>
          if ntt_ready = '1' then
            ntt_op           <= INST_NTT_GP_MODE;
            ntt_start_intern <= '1';
            state_reg        <= NTT_WAIT_READY;
          end if;

        when PROC_MOV =>
          --Read from ARG0 Port
          smem_rd_p1_ctl <= resize(unsigned(proc_arg1), smem_rd_p1_ctl 'length);
          --Write into
          smem_wr_p1_ctl <= resize(unsigned(proc_arg0), smem_wr_p1_ctl'length);

          if smem_stable = '1' and alu_dec_ready = '1' then
            alu_dec_op           <= INST_ALU_MOV;
            alu_dec_start_intern <= '1';
            state_reg            <= PROC_ALU_WAIT;
          end if;

        when PROC_ADD =>
          --Read from ARG0 and ARG1 Port
          smem_rd_p1_ctl <= resize(unsigned(proc_arg0), smem_rd_p1_ctl 'length);
          smem_rd_p2_ctl <= resize(unsigned(proc_arg1), smem_rd_p1_ctl 'length);
          --Write into 
          smem_wr_p1_ctl <= resize(unsigned(proc_arg0), smem_wr_p1_ctl'length);

          if smem_stable = '1' and alu_dec_ready = '1' then
            alu_dec_op           <= INST_ALU_ADD;
            alu_dec_start_intern <= '1';
            state_reg            <= PROC_ALU_WAIT;
          end if;
          

        when PROC_SUB =>
          --Read from ARG0 and ARG1 Port
          smem_rd_p1_ctl <= resize(unsigned(proc_arg0), smem_rd_p1_ctl 'length);
          smem_rd_p2_ctl <= resize(unsigned(proc_arg1), smem_rd_p1_ctl 'length);
          --Write into the first Port of the FFT
          smem_wr_p1_ctl <= resize(unsigned(proc_arg0), smem_wr_p1_ctl'length);

          if smem_stable = '1' and alu_dec_ready = '1' then
            alu_dec_op           <= INST_ALU_SUB;
            alu_dec_start_intern <= '1';
            state_reg            <= PROC_ALU_WAIT;
          end if;
          
        when PROC_ALU_WAIT =>
          if alu_dec_ready = '1' and alu_dec_start_intern = '0' then
            state_reg <= IDLE;
          end if;

        when PROC_WAIT_UNI_SAMPLER_READY =>
          if uni_samp_ready = '1' then
            state_reg <= IDLE;
          end if;

        when PROC_SAMPLE_WAIT =>
          if alu_dec_ready = '1' then
            state_reg     <= IDLE;
            uni_samp_stop <= '1';
          end if;
          
        when PROC_OUT =>
          smem_rd_p1_ctl <= resize(unsigned(proc_arg0), smem_rd_p1_ctl 'length);
          smem_wr_p1_ctl <= to_unsigned(IO_PORT, smem_wr_p1_ctl'length);
          state_reg      <= PROC_OUT_WAIT_temp;
          
        when PROC_OUT_WAIT_temp =>
          state_reg <= PROC_OUT_WAIT;

        when PROC_OUT_WAIT =>
          if smem_stable = '1' and alu_dec_ready = '1' and alu_dec_start_intern = '0' then
            alu_dec_op           <= INST_ALU_MOV;
            alu_dec_start_intern <= '1';
            state_reg            <= PROC_ALU_WAIT;
          end if;
          
        when PROC_IN =>
          smem_rd_p1_ctl <= to_unsigned(IO_PORT, smem_wr_p1_ctl'length);
          smem_wr_p1_ctl <= resize(unsigned(proc_arg0), smem_rd_p1_ctl 'length);

          if smem_stable = '1' and alu_dec_ready = '1' then
            alu_dec_op           <= INST_ALU_MOV;
            alu_dec_start_intern <= '1';
            state_reg            <= PROC_ALU_WAIT;
          end if;
          
        when PROC_ENABLE_COPY_TO_IO =>
          enable_copy_to_io_flag <= '1';
          state_reg              <= IDLE;

        when PROC_DISABLE_COPY_TO_IO =>
          enable_copy_to_io_flag <= '0';
          state_reg              <= IDLE;
      end case;
    end if;
  end process;

end Behavioral;

