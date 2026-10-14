
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ControlUnit is
    port (
        i_Instruction : in std_logic_vector(31 downto 0);

        o_ALUSrc     : out std_logic;
        o_ALUControl : out std_logic;
        o_ImmType    : out std_logic_vector(2 downto 0);
        o_ResultSrc  : out std_logic_vector(1 downto 0);
        o_MemWrite   : out std_logic;
        o_RegWrite   : out std_logic
    );
end ControlUnit;

architecture Behavioral of ControlUnit is
begin

    process(i_Instruction)
        variable opcode : std_logic_vector(6 downto 0);
        variable funct3 : std_logic_vector(2 downto 0);
        variable funct7 : std_logic_vector(6 downto 0);
    begin
        opcode := i_Instruction(6 downto 0);
        funct3 := i_Instruction(14 downto 12);
        funct7 := i_Instruction(31 downto 25);

        -- Default outputs: no register or memory writes
        o_ALUSrc     <= '0';
        o_ALUControl <= '0';
        o_ImmType    <= "000";
        o_ResultSrc  <= "00";
        o_MemWrite   <= '0';
        o_RegWrite   <= '0';

        case opcode is

            -- ADDI
            when "0010011" =>
                if funct3 = "000" then
                    o_ALUSrc     <= '1';
                    o_ALUControl <= '0';
                    o_ImmType    <= "000";
                    o_ResultSrc  <= "00";
                    o_RegWrite   <= '1';
                end if;

            -- ADD and SUB
            when "0110011" =>
                if funct3 = "000" then
                    if funct7 = "0000000" then
                        -- ADD
                        o_ALUSrc     <= '0';
                        o_ALUControl <= '0';
                        o_RegWrite   <= '1';

                    elsif funct7 = "0100000" then
                        -- SUB
                        o_ALUSrc     <= '0';
                        o_ALUControl <= '1';
                        o_RegWrite   <= '1';
                    end if;
                end if;

            -- LW
            when "0000011" =>
                if funct3 = "010" then
                    o_ALUSrc     <= '1';
                    o_ALUControl <= '0';
                    o_ImmType    <= "000";
                    o_ResultSrc  <= "01";
                    o_RegWrite   <= '1';
                end if;

            -- SW
            when "0100011" =>
                if funct3 = "010" then
                    o_ALUSrc     <= '1';
                    o_ALUControl <= '0';
                    o_ImmType    <= "001";
                    o_MemWrite   <= '1';
                end if;

            -- LUI
            when "0110111" =>
                o_ImmType    <= "010";
                o_ResultSrc  <= "10";
                o_RegWrite   <= '1';

            when others =>
                null;

        end case;
    end process;

end Behavioral;
