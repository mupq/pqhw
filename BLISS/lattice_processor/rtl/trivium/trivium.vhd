--/****************************************************************************/
--Copyright (C) by Thomas Pöppelmann and the Hardware Security Group of Ruhr-Universitaet Bochum. 
--All rights reserved.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--Please see licence.rtf and readme.txt for licence and further instructions.
--/****************************************************************************/

library ieee;
use ieee.std_logic_1164.all;

entity trivium is
  port(clk, rst : in  std_logic;
       clk_en   : in  std_logic:='1';
       key      : in  std_logic_vector(79 downto 0);
       IV       : in  std_logic_vector(79 downto 0);
       o_vld    : out std_logic;
       z        : out std_logic);
end trivium;


architecture Behavioral of trivium is

  constant sel : string := "RUB";
  
begin

  --stern_triv: if sel="STERN" generate
  --   trivium_stern_1:entity work.trivium_stern
  --  port map (
  --    clk    => clk,
  --    rst    => rst,
  --    clk_en => clk_en,
  --    key    => key,
  --    IV     => IV,
  --    o_vld  => o_vld,
  --    z      => z
  --    );
  --end generate stern_triv;

  rub_triv: if sel="RUB" generate
   trivium_1:entity work.trivium_rub
      port map (
        clk          => clk,
        reset        => rst,
        clk_en       => clk_en,
        KEY          => KEY,
        IV           => IV,
        stream_ready => o_vld,
        stream       => z
        );
  end generate rub_triv;

end Behavioral;
