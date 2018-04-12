--------------------------------------------------------------------------------
-- Company: 
-- Engineer            :
--
-- Create Date:   16:32:25 11/11/2009
-- Design Name:   
-- Module Name:   C:/Users/oliver/work/Diplomarbeit/AES_tiny/aes_tiny_tb.vhd
-- Project Name:  AES_tiny
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: aes_tiny
-- 
-- Dependencies        :
-- 
-- Revision            :
-- Revision 0.01 - File Created
-- Additional Comments :
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
library ieee; 
  use ieee.std_logic_1164.all; 
               use ieee.std_logic_unsigned.all; 
                                use ieee.numeric_std.all; 
                                                 
                                                 entity aes_tiny_tb is
                                                         end aes_tiny_tb; 
                                                                        
                                                                        architecture behavior of aes_tiny_tb is 
                                                                                                                
                                        -- Component Declaration for the Unit Under Test (UUT)
                                                                                                                
                                                                                                                component aes_tiny
                                                                                                                                    port(
                                                                                                                                         clk    : in  std_logic; 
                                                                                                                                         rst    : in  std_logic; 
                                                                                                                                         enable : in  std_logic; 
                                                                                                                                         din    : in  std_logic_vector(127 downto 0); 
                                                                                                                                         key    : in  std_logic_vector(127 downto 0); 
                                                                                                                                         dout   : out std_logic_vector(127 downto 0); 
                                                                                                                                         done   : out std_logic
                                                                                                                                         );
                                                                                                                end component; 
                                                                                                                                             
                                                                                                                                             
                                        --Inputs
                                                                                                                                             signal clk : std_logic := '0'; 
                                                                                                                                signal rst : std_logic := '0'; 
                                                                                                                                                                             signal enable : std_logic := '0'; 
                                                                                                                                                                signal din : std_logic_vector(127 downto 0) := (others => '0'); 
                                                                                                                                                                                                                signal key : std_logic_vector(127 downto 0) := (others => '0'); 
                                                                                                                                                                                                                                 
                                        --Outputs
                                                                                                                                                                                                                                 signal dout : std_logic_vector(127 downto 0); 
                                                                                                                                                                                                                                                                                 signal done : std_logic; 
                                                                                                                                                                                                                                                                                
                                        -- Clock period definitions
                                                                                                                                                                                                                                                                                constant clk_period : time := 100 ns; 
                                                                                                                                                                                                                                                                                                           
                                                                         begin
                                                                              
                                        -- Instantiate the Unit Under Test (UUT)
                                                                              uut : aes_tiny port map (
                                                                                                      clk    => clk, 
                                                                                                      rst    => rst, 
                                                                                                      enable => enable, 
                                                                                                      din    => din, 
                                                                                                      key    => key, 
                                                                                                      dout   => dout, 
                                                                                                      done   => done
                                                                                                      );
                                                                                
                                        -- Clock process definitions
                                                                                clk_process : process
                                                                                begin
                                                                                     clk <= '1'; 
                                                                                       wait for clk_period/2; 
                                                                                                  clk <= '0'; 
                                                                                                               wait for clk_period/2; 
                                                                                end process; 
                                                                                                                                       
                                                                                                                                       
                                        -- Stimulus process
                                                                                                                                       stim_proc : process
                                                                                                                                       begin 
                                        -- hold reset state for 100ms.
                                                                                                                                                        rst <= '1'; 
                                                                                                                                                          wait for 1 us; 
                                                                                                                                                                     rst <= '0'; 
                                                                                                                                                                          wait for clk_period*2; 
                                                                                                                                                                                  din <= x"00112233445566778899aabbccddeeff"; 
                                                                                                                                                                                                  key <= x"000102030405060708090a0b0c0d0e0f"; 
--              key <= x"2b7e151628aed2a6abf7158809cf4f3c";
--              din <= x"3243f6a8885a308d313198a2e0370734";
                                                                                                                                                                                                                               wait for clk_period;
                                                                                                                                                        enable <= '1';
                                                                                                                                                        wait for clk_period*4;
                                                                                                                                                        enable <= '0';
                                                                                                                                                        wait for clk_period*40;
                                                                                                                                                        enable <= '1';
                                                                                                                                                        wait until done = '1'; 
                                                                                                                                                          wait for clk_period;
                                                                                                                                                        enable <= '0'; 
                                                                                                                                                                  
                                                                                                                                                                  wait for clk_period*10; 
                                                                                                                                                                          key <= x"2b7e151628aed2a6abf7158809cf4f3c";
                                                                                                                                                        din    <= x"3243f6a8885a308d313198a2e0370734";
                                                                                                                                                        enable <= '1';
                                                                                                                                                        wait until done = '1'; 
                                                                                                                                                          wait for clk_period;
                                                                                                                                                        enable <= '0'; 
                                                                                                                                                                  
                                        -- insert stimulus here 
                                                                                                                                                                  
                                                                                                                                                                  wait; 
                                                                                                                                       end process; 
                                                                                                                                                                         
                                                                         end; 
