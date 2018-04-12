--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:08:01 02/22/2014 
-- Design Name: 
-- Module Name:    c_ram_module - Behavioral 
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



entity c_ram_module is
  generic (
    N_ELEMENTS : integer := 512;
    ADDR_WIDTH : integer := 9;
    COL_WIDTH  : integer := 1;
    KAPPA      : integer := 23
    );
  port(
    clk               : in  std_logic;
    c_signature_delay : in  integer := 1;
    c_module_delay    : out integer := 1;

    hash_equal         : out std_logic := '0';
    hash_no_equal      : out std_logic := '0';
    reset_c_ram_module : in  std_logic := '0';

    hash_c_in    : in std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');
    hash_c_valid : in std_logic;

    ready  : out std_logic := '0';
    read_c : in  std_logic := '0';

    --Access the c positions from the outside
    c_sig_addr : out std_logic_vector(integer(ceil(log2(real(KAPPA))))-1 downto 0)      := (others => '0');
    c_sig_data : in  std_logic_vector(integer(ceil(log2(real(N_ELEMENTS))))-1 downto 0) := (others => '0');

    --Access port for the verification module
    addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
    dout : out std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0')
    );


end c_ram_module;

architecture Behavioral of c_ram_module is
  component c_ram_c_module_ram
    port (
      a    : in  std_logic_vector(8 downto 0);
      d    : in  std_logic_vector(0 downto 0);
      dpra : in  std_logic_vector(8 downto 0);
      clk  : in  std_logic;
      we   : in  std_logic;
      qdpo : out std_logic_vector(0 downto 0)
      );
  end component;

  type   eg_state is (IDLE, WIPE_RAM, READ_C_RAM);
  signal state_reg : eg_state := IDLE;

  signal ram_c_wea   : std_logic                               := '0';
  signal ram_c_web   : std_logic                               := '0';
  signal ram_c_addra : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal ram_c_addrb : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal ram_c_dia   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal ram_c_dib   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal ram_c_doa   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');
  signal ram_c_dob   : std_logic_vector(COL_WIDTH-1 downto 0)  := (others => '0');

  signal reading_c : std_logic := '0';

  signal wea_reg : std_logic := '0';

  signal counter       : integer range 0 to 512 := 0;
  signal counter_c     : integer range 0 to KAPPA  := 0;
  signal pos_c_counter : integer range 0 to KAPPA  := 0;

  signal c_valid_reg2 : std_logic := '0';
  signal c_valid      : std_logic := '0';
  signal c_valid_reg1 : std_logic := '0';
  signal trigger_fin  : std_logic := '0';

  type   ram_type_c is array (0 to KAPPA-1) of std_logic_vector(c_sig_data'range);
  signal c_vals : ram_type_c;

  signal hash_no_equal_intern : std_logic := '0';
begin

  --Store the bits of c (we need them sorted)
  --Set to zero when reading it out.
  --bram_c : entity work.bram_with_delay
  --  generic map (
  --    SIZE       => N_ELEMENTS,
  --    ADDR_WIDTH => ADDR_WIDTH,
  --    COL_WIDTH  => COL_WIDTH,
  --    add_reg_a  => 0,
  --    add_reg_b  => 0,
  --    InitFile   => ""
  --    )
  --  port map (
  --    clka  => clk,
  --    clkb  => clk,
  --    ena   => '1',
  --    enb   => '1',
  --    wea   => ram_c_wea,
  --    web   => ram_c_web,
  --    addra => ram_c_addra,
  --    addrb => ram_c_addrb,
  --    dia   => ram_c_dia,
  --    dib   => ram_c_dib,
  --    doa   => ram_c_doa,
  --    dob   => ram_c_dob
  --    );


  your_instance_name : c_ram_c_module_ram
    port map (
      a    => ram_c_addra,
      d    => ram_c_dia,
      dpra => ram_c_addrb,
      clk  => clk,
      we   => ram_c_wea,
      qdpo => ram_c_dob
      );


  --Allows readout
  ram_c_addrb <= addr;
  dout        <= ram_c_dob;



  process(clk)
  begin  -- process
    if rising_edge(clk) then
      ready         <= '0';
      wea_reg       <= '0';
      ram_c_wea     <= '0';
      c_valid_reg1  <= '0';
      hash_no_equal <= '0';
      hash_no_equal <= '0';
      trigger_fin   <= '0';

      --Needed to write the c values
      --ram_c_addra <= c_sig_data;        --The data is the addr of one coeffs
-- ram_c_dia   <= "1";
      --ram_c_wea   <= wea_reg;

      if reset_c_ram_module = '1' then
        hash_no_equal <= '0';
        hash_equal    <= '0';
      end if;

      c_valid_reg2 <= c_valid_reg1;
      c_valid      <= c_valid_reg2;


      if hash_c_valid = '1' then
        if hash_c_in /= c_vals(pos_c_counter) then
          hash_no_equal_intern <= '1';
        end if;

        if pos_c_counter < KAPPA-1 then
          pos_c_counter <= pos_c_counter+1;
        else
          pos_c_counter <= 0;
          trigger_fin   <= '1';
        end if;
      end if;

      if trigger_fin = '1' then
        if hash_no_equal_intern = '1' then
          hash_no_equal <= '1';
        else
          hash_equal <= '1';
        end if;
        hash_no_equal_intern <= '0';
      end if;

      if c_valid = '1' then
        ram_c_addra       <= std_logic_vector(resize(unsigned(c_sig_data), ram_c_addra'length));
        ram_c_wea         <= '1';
        ram_c_dia         <= "1";
        c_vals(counter_c) <= c_sig_data;
        counter_c         <= (counter_c+1) mod KAPPA;
      end if;

      case state_reg is
        when IDLE =>
          ready   <= '1';
          counter <= 0;
          if read_c = '1' then
            state_reg <= WIPE_RAM;
          end if;

        when WIPE_RAM =>
          --First wipe the ram
          ram_c_addra <= std_logic_vector(to_unsigned(counter, ram_c_addra'length));
          ram_c_dia   <= (others => '0');
          ram_c_wea   <= '1';
          if counter < N_ELEMENTS-1 then
            counter <= counter+1;
          else
            counter   <= 0;
            state_reg <= READ_C_RAM;
          end if;

        when READ_C_RAM =>
          if counter < KAPPA then
            c_sig_addr   <= std_logic_vector(to_unsigned(counter, c_sig_addr'length));
            c_valid_reg1 <= '1';
            counter      <= counter+1;
          else
            counter   <= 0;
            state_reg <= IDLE;
          end if;
      end case;
    end if;
  end process;
end Behavioral;

