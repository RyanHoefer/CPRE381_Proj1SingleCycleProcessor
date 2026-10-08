library IEEE;
use IEEE.std_logic_1164.all;

entity ZeroAppender is
    port (
        i_Imm : in  std_logic_vector(19 downto 0);
        o_Ext : out std_logic_vector(31 downto 0)
    );
end ZeroAppender;

architecture dataflow of ZeroAppender is
begin

    o_Ext(31 downto 12) <= i_Imm;
    o_Ext(11 downto 0)  <= (others => '0');

end dataflow;