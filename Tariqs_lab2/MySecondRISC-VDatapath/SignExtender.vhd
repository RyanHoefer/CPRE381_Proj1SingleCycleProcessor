library IEEE;
use IEEE.std_logic_1164.all;

entity SignExtender is
    port (
        i_Imm : in  std_logic_vector(11 downto 0);
        o_Ext : out std_logic_vector(31 downto 0)
    );
end SignExtender;

architecture dataflow of SignExtender is
begin

    o_Ext(11 downto 0) <= i_Imm;
    o_Ext(31 downto 12) <= (others => i_Imm(11));

end dataflow;