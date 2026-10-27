
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

            -- I-type: addi, lw, jalr, immediate ALU operations
            when "000" =>
                o_Immediate <=
                    (31 downto 12 => i_Instruction(31)) &
                    i_Instruction(31 downto 20);

            -- S-type: sw, sh, sb
            when "001" =>
                o_Immediate <=
                    (31 downto 12 => i_Instruction(31)) &
                    i_Instruction(31 downto 25) &
                    i_Instruction(11 downto 7);

            -- U-type: lui, auipc
            when "010" =>
                o_Immediate <=
                    i_Instruction(31 downto 12) &
                    "000000000000";

            -- B-type: beq, bne, blt, bge, bltu, bgeu
            when "011" =>
                o_Immediate <=
                    (31 downto 13 => i_Instruction(31)) &
                    i_Instruction(31) &
                    i_Instruction(7) &
                    i_Instruction(30 downto 25) &
                    i_Instruction(11 downto 8) &
                    '0';

            -- J-type: jal
            when "100" =>
                o_Immediate <=
                    (31 downto 21 => i_Instruction(31)) &
                    i_Instruction(31) &
                    i_Instruction(19 downto 12) &
                    i_Instruction(20) &
                    i_Instruction(30 downto 21) &
                    '0';

            -- Unsupported immediate types
            when others =>
                o_Immediate <= (others => '0');

        end case;
    end process;

end Behavioral;
