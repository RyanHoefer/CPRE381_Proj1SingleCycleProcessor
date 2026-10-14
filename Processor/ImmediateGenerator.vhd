
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ImmediateGenerator is
    port (
        i_Instruction : in  std_logic_vector(31 downto 0);
        i_ImmType     : in  std_logic_vector(2 downto 0);
        o_Immediate   : out std_logic_vector(31 downto 0)
    );
end ImmediateGenerator;

architecture Behavioral of ImmediateGenerator is
begin

    process(i_Instruction, i_ImmType)
    begin
        case i_ImmType is

            -- I-type: addi, lw
            when "000" =>
                o_Immediate <=
                    (31 downto 12 => i_Instruction(31)) &
                    i_Instruction(31 downto 20);

            -- S-type: sw
            when "001" =>
                o_Immediate <=
                    (31 downto 12 => i_Instruction(31)) &
                    i_Instruction(31 downto 25) &
                    i_Instruction(11 downto 7);

            -- U-type: lui
            when "010" =>
                o_Immediate <=
                    i_Instruction(31 downto 12) &
                    "000000000000";

            -- Unsupported immediate types
            when others =>
                o_Immediate <= (others => '0');

        end case;
    end process;

end Behavioral;

