library IEEE;
use IEEE.std_logic_1164.all;

entity ZeroExtender is
    port (
        i_Imm : in  std_logic_vector(11 downto 0);
        o_Ext : out std_logic_vector(31 downto 0)
    );
end ZeroExtender;

architecture dataflow of ZeroExtender is
begin

    o_Ext(11 downto 0) <= i_Imm;
    o_Ext(31 downto 12) <= (others => '0');

end dataflow;