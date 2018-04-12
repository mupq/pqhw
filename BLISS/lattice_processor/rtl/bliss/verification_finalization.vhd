--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:42:44 02/22/2014 
-- Design Name: 
-- Module Name:    verification_finalization - Behavioral 
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
use work.lyu512_pkg.all;






entity verification_finalization is
  
  generic (
    PARAMETER_SET : integer :=1;
    MODULUS_P_BLISS : unsigned := to_unsigned(24, 5);
    PRIME_P         : unsigned := to_unsigned(12289, 14);
    ZETA            : unsigned := to_unsigned(6145, 13);
    D_BLISS         : integer  := 10
    );
  port (
    clk : in std_logic;


    --Gets as input the the output from the multiplier, the c, and z1
    reset_norms  : in  std_logic                                           := '0';
    norm_invalid : out std_logic                                           := '0';
    z1_data      : in  std_logic_vector(PRIME_P'length-1 downto 0)         := (others => '0');
    az1_data     : in  std_logic_vector(PRIME_P'length-1 downto 0)         := (others => '0');
    c_data       : in  std_logic_vector(0 downto 0)                        := "0";
    z2_data      : in  std_logic_vector(MODULUS_P_BLISS'length-1 downto 0) := (others => '0');
    coeff_we     : in  std_logic                                           := '0';  --valid

    --Output the u values as input to the hash
    u_out   : out std_logic_vector(MODULUS_P_BLISS'length-1 downto 0) := (others => '0');
    u_wr_en : out std_logic                                           := '0'


    );
end verification_finalization;

architecture Behavioral of verification_finalization is

  signal z2_data_reg          : std_logic_vector(z2_data'range)             := (others => '0');
  signal z2_data_reg1         : std_logic_vector(z2_data'range)             := (others => '0');
  signal z2_data_reg2         : std_logic_vector(z2_data'range)             := (others => '0');
  signal z2_data_reg2_delayed : std_logic_vector(z2_data'range)             := (others => '0');
  signal c_data_reg           : std_logic_vector(0 downto 0)                := "0";
  signal az1_data_reg         : std_logic_vector(PRIME_P'length-1 downto 0) := (others => '0');

  signal mul_zeta_res   : unsigned(2*PRIME_P'length+1-1 downto 0) := (others => '0');
  signal dropped_result : unsigned(PRIME_P'length+ZETA'length-D_BLISS+2-1 downto 0);
  signal result         : signed(PRIME_P'length+ZETA'length-D_BLISS+2-1 downto 0);
  signal res            : unsigned(PRIME_P'length downto 0);
  signal result_reg         : signed(PRIME_P'length+ZETA'length-D_BLISS+2-1 downto 0);

  signal valid_reg_1 : std_logic := '0';
  signal valid_reg_2 : std_logic := '0';
  signal valid_reg_3 : std_logic := '0';
  signal valid_reg_4 : std_logic := '0';
  signal valid_reg_5 : std_logic := '0';



  signal red_val   : unsigned(2*(PRIME_P'length)+3-1 downto 0) := (others => '0');
  signal red_val_reg   : unsigned(2*(PRIME_P'length)+3-1 downto 0) := (others => '0');
  signal red_red   : unsigned(PRIME_P'length+1-1 downto 0)     := (others => '0');
  signal red_delay : integer                                   := 2;

  signal shift1_depth  : integer range 0 to 511          := 1;
  signal shift1_Input  : std_logic_vector(z2_data'range) := (others => '0');
  signal shift1_Output : std_logic_vector(z2_data'range) := (others => '0');


  signal valid_delay   : integer range 0 to 511       := 1;
  signal shift2_Input  : std_logic_vector(0 downto 0) := (others => '0');
  signal shift2_Output : std_logic_vector(0 downto 0) := (others => '0');

  signal valid_counter : integer := 0;
  signal z2_delay_val  : integer := 20;

  signal infinity_counter : integer := 0;


  
  
 -- constant b_zwei     : integer := ;

  signal infi_norm1 : integer range -15000 to 15000 := 0;
  signal infi_norm2 : integer range -15000 to 15000   := 0;
  signal z2_val     : std_logic_vector(PRIME_P'length-1 downto 0);

  signal norm1_coeff_sc1_out   : std_logic_vector(PRIME_P'length-1 downto 0) := (others => '0');
  signal norm1_coeff_sc1_valid : std_logic                                   := '0';
  signal norm1_coeff_sc2_out   : std_logic_vector(PRIME_P'length-1 downto 0) := (others => '0');
  signal norm1_coeff_sc2_valid : std_logic                                   := '0';
  signal norm1_norm            : std_logic_vector(31-1 downto 0)             := (others => '0');
  signal norm1_norm_valid      : std_logic                                   := '0';
  signal norm1_norm_reg        : std_logic_vector(31-1 downto 0)             := (others => '0');
  signal norm1_norm_valid_reg  : std_logic                                   := '0';

  signal norm_invalid_reg : std_logic := '0';


  signal z1_data_reg  : std_logic_vector(PRIME_P'length-1 downto 0) := (others => '0');
  signal z2_val_reg   : std_logic_vector(PRIME_P'length-1 downto 0);
  signal coeff_we_reg : std_logic                                   := '0';
signal    u_out_reg   :  std_logic_vector(MODULUS_P_BLISS'length-1 downto 0) := (others => '0');


  signal data_in_V : STD_LOGIC_VECTOR (13 downto 0);
  signal c_reg_V   : STD_LOGIC_VECTOR (0 downto 0);
  signal ap_return : STD_LOGIC_VECTOR (14 downto 0);
  
begin



  --z2_val <= std_logic_vector(resize((to_signed(1, 15)sll D_BLISS)*resize(signed(z2_data),4), z2_val'length));
  z2_val <= std_logic_vector(resize(resize(signed(z2_data), 16) sll D_BLISS, z2_val'length));


  --Infinity norm
  process(clk)
  begin  -- process
    if rising_edge(clk) then
      z1_data_reg  <= z1_data;
      coeff_we_reg <= coeff_we_reg;
      z2_val_reg   <= z2_val;


      --Check the infinity norm
      

        
      norm1_norm       <= norm1_norm_reg;
      norm1_norm_valid <= norm1_norm_valid_reg;
      norm_invalid         <= norm_invalid_reg;

      if reset_norms = '1' then
        norm_invalid_reg <= '0';
        infi_norm1       <= 0;
        infi_norm2       <= 0;
      end if;

      --Check infinity norm
      if (abs(to_integer(signed(z1_data))) >  get_bliss_BInfty(PARAMETER_SET)) then
        norm_invalid_reg <= '1';
      end if;

      if (abs(to_integer(signed(z2_val))) >  get_bliss_BInfty(PARAMETER_SET)) then
        norm_invalid_reg <= '1';
      end if;

      
      --Check norm2
      if norm1_norm_valid = '1' then
        if to_integer(abs(signed(norm1_norm))) > (get_bliss_B2(PARAMETER_SET)**2) then
          norm_invalid_reg <= '1';
        end if;
      end if;

    
      --Compute the infinity norm
      --if coeff_we = '1' then
      --  if to_integer(signed(z1_data)) > infi_norm1 and to_integer(signed(z1_data)) > 0 then
      --   infi_norm1 <= to_integer(signed(z1_data));
      -- elsif to_integer(signed(z1_data)) < -infi_norm1 and to_integer(signed(z1_data)) < 0 then
      --    infi_norm1 <= to_integer(-signed(z1_data));
      -- end if;

      --  if to_integer(signed(z2_val)) > infi_norm1 and to_integer(signed(z2_val)) > 0 then
      --    infi_norm2 <= to_integer(signed(z2_val));
      --  elsif to_integer(signed(z2_val)) < infi_norm2 and to_integer(signed(z2_val)) < 0 then
      --    infi_norm2 <= to_integer(signed(z2_val));
      --  end if;  
      --end if;
      
    end if;
  end process;


  norm_1 : entity work.norm
    generic map (
       NORM2_ACTIVE =>  1,               --deactivate second norm
      PRIME_P       => PRIME_P,
      MAX_RES_WIDTH => PRIME_P'length,
      OUTPUT_WIDTH  => 31,
      DEPTH         => 512
      )
    port map (
      clk             => clk,
      reset           => reset_norms,
      coeff_sc1_out   => z1_data_reg,
      coeff_sc1_valid => coeff_we,
      coeff_sc2_out   => z2_val_reg,
      coeff_sc2_valid => coeff_we,
      norm            => norm1_norm_reg,
      norm_valid      => norm1_norm_valid_reg
      );


  z2_delay_val <= red_delay+1;
  dyn_shift_reg_1 : entity work.dyn_shift_reg
    generic map (
      width     => z2_data'length,
      max_depth => 50
      )
    port map (
      clk    => clk,
      depth  => z2_delay_val ,
      Input  => z2_data_reg2,
      Output => z2_data_reg2_delayed
      );

  valid_delay <= red_delay+7+1;
  dyn_shift_reg_2 : entity work.dyn_shift_reg
    generic map (
      width     => shift2_Input'length ,
      max_depth => 50
      )
    port map (
      clk    => clk,
      depth  => valid_delay,
      Input  => shift2_Input,
      Output => shift2_Output
      );


  data_in_V <= az1_data_reg;
  c_reg_V <= c_data_reg;
  red_red <= unsigned(ap_return);
  mul_zeta_12289_6145_verify_1:entity work.mul_zeta_12289_6145_verify
    port map (
      ap_clk    => clk,
      ap_rst    => '0',
      data_in_V => data_in_V,
      c_reg_V   => c_reg_V,
      ap_return => ap_return
      );


  shift2_Input(0) <= coeff_we;
  u_wr_en         <= shift2_Output(0);

  process(clk)
  begin  -- process
    if rising_edge(clk) then
--Debug
      if coeff_we = '1' then
        valid_counter <= (valid_counter+1) mod 512;
      end if;

      --Stage 1
      z2_data_reg  <= z2_data;
      c_data_reg   <= c_data;
      az1_data_reg <= az1_data;

      --Stage2
      --red_val_reg     <= resize(ZETA*(2*unsigned(az1_data_reg) + PRIME_P*unsigned(c_data_reg)), red_val'length);
      z2_data_reg1 <= z2_data_reg;

      --Put into reduction
      --red_val <= red_val_reg;
      z2_data_reg2   <= z2_data_reg1;

      
      --Stage3
      dropped_result <= resize(((2*resize(red_red, red_red'length+2)+((to_unsigned(1, 2*(red_red'length)) sll D_BLISS))) srl (D_BLISS+1)), dropped_result'length);

      --Stage4
      --dropped_result
      result_reg <= resize(signed("0"&dropped_result) + signed(z2_data_reg2_delayed), result'length);

      --Stage5
--if signed(result) >= signed("0"&(MODULUS_P_BLISS)) then
result <= result_reg;

      if signed(result) > resize(signed("0"&(MODULUS_P_BLISS/2)), result'length) then
        u_out_reg <= std_logic_vector(resize(signed("0"&result) - signed("0"&MODULUS_P_BLISS), u_out'length));
      else
        u_out_reg <= std_logic_vector(resize(signed(result), u_out'length));
      end if;

      --Stage6
      u_out <= u_out_reg;
    end if;


    
  end process;

  --assert result <= 24 report "RES TOO LARGE";
  --assert result >= 0 report "SMALLER";
--assert signed(u_out)<=signed("0"&MODULUS_P_BLISS/2) and signed(u_out)>-signed("0"&(MODULUS_P_BLISS/2)) report "RESULT BAD";

end Behavioral;

