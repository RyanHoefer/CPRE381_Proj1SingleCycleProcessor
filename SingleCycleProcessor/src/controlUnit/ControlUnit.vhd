
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ControlUnit is
    port (
        i_Instruction    : in std_logic_vector(31 downto 0);

        o_ALUSrc         : out std_logic;
        o_ALUControl     : out std_logic;
        o_ImmType        : out std_logic_vector(2 downto 0);
        o_ResultSrc      : out std_logic_vector(2 downto 0);
        o_MemWrite       : out std_logic;
        o_RegWrite       : out std_logic;

        o_sign           : out std_logic;
        o_selectDataSize : out std_logic_vector(1 downto 0);
        o_selectAluOut   : out std_logic_vector(2 downto 0);
        o_dir            : out std_logic;
        o_arith          : out std_logic
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

        -- Default control signals
        o_ALUSrc         <= '0';
        o_ALUControl     <= '0';
        o_ImmType        <= "000";
        o_ResultSrc      <= "000";
        o_MemWrite       <= '0';
        o_RegWrite       <= '0';

        o_sign           <= '0';
        o_selectDataSize <= "00";
        o_selectAluOut   <= "000";
        o_dir            <= '0';
        o_arith          <= '0';

        case opcode is

            -- ========================================
            -- R-type instructions
            -- ========================================
            when "0110011" =>
                case funct3 is

                    when "000" =>
                        if funct7 = "0000000" then
                            -- ADD
                            o_ALUControl <= '0';
                            o_RegWrite   <= '1';
                        elsif funct7 = "0100000" then
                            -- SUB
                            o_ALUControl <= '1';
                            o_RegWrite   <= '1';
                        end if;

                    when "111" =>
                        if funct7 = "0000000" then
                            -- AND
                            o_selectAluOut <= "010";
                            o_RegWrite     <= '1';
                        end if;

                    when "110" =>
                        if funct7 = "0000000" then
                            -- OR
                            o_selectAluOut <= "001";
                            o_RegWrite     <= '1';
                        end if;

                    when "100" =>
                        if funct7 = "0000000" then
                            -- XOR
                            o_selectAluOut <= "011";
                            o_RegWrite     <= '1';
                        end if;

                    when "010" =>
                        if funct7 = "0000000" then
                            -- SLT (signed)
                            o_selectAluOut <= "101";
                            o_sign         <= '1';
                            o_RegWrite     <= '1';
                        end if;

                    -- FIX: Added missing SLTU instruction
                    when "011" =>
                        if funct7 = "0000000" then
                            -- SLTU (unsigned)
                            o_selectAluOut <= "101";
                            o_sign         <= '0';
                            o_RegWrite     <= '1';
                        end if;

                    when "001" =>
                        if funct7 = "0000000" then
                            -- SLL
                            o_selectAluOut <= "100";
                            o_dir          <= '1';
                            o_arith        <= '0';
                            o_RegWrite     <= '1';
                        end if;

                    when "101" =>
                        if funct7 = "0000000" then
                            -- SRL
                            o_selectAluOut <= "100";
                            o_dir          <= '0';
                            o_arith        <= '0';
                            o_RegWrite     <= '1';
                        elsif funct7 = "0100000" then
                            -- SRA
                            o_selectAluOut <= "100";
                            o_dir          <= '0';
                            o_arith        <= '1';
                            o_RegWrite     <= '1';
                        end if;

                    when others =>
                        null;
                end case;

            -- ========================================
            -- I-type arithmetic and logic
            -- ========================================
            when "0010011" =>
                o_ALUSrc  <= '1';
                o_ImmType <= "000";

                case funct3 is

                    when "000" =>
                        -- ADDI
                        o_RegWrite <= '1';

                    when "111" =>
                        -- ANDI
                        o_selectAluOut <= "010";
                        o_RegWrite     <= '1';

                    when "110" =>
                        -- ORI
                        o_selectAluOut <= "001";
                        o_RegWrite     <= '1';

                    when "100" =>
                        -- XORI
                        o_selectAluOut <= "011";
                        o_RegWrite     <= '1';

                    when "010" =>
                        -- SLTI (signed)
                        o_selectAluOut <= "101";
                        o_sign         <= '1';
                        o_RegWrite     <= '1';

                    when "011" =>
                        -- SLTIU (unsigned)
                        o_selectAluOut <= "101";
                        o_sign         <= '0';
                        o_RegWrite     <= '1';

                    when "001" =>
                        if funct7 = "0000000" then
                            -- SLLI
                            o_selectAluOut <= "100";
                            o_dir          <= '1';
                            o_arith        <= '0';
                            o_RegWrite     <= '1';
                        end if;

                    when "101" =>
                        if funct7 = "0000000" then
                            -- SRLI
                            o_selectAluOut <= "100";
                            o_dir          <= '0';
                            o_arith        <= '0';
                            o_RegWrite     <= '1';
                        elsif funct7 = "0100000" then
                            -- SRAI
                            o_selectAluOut <= "100";
                            o_dir          <= '0';
                            o_arith        <= '1';
                            o_RegWrite     <= '1';
                        end if;

                    when others =>
                        null;
                end case;

            -- ========================================
            -- Load instructions
            -- ========================================
            when "0000011" =>
                o_ALUSrc        <= '1';
                o_ALUControl    <= '0';
                o_ImmType       <= "000";
                o_ResultSrc     <= "001";
                o_selectAluOut  <= "000";

                case funct3 is

                    when "010" =>
                        -- LW
                        o_selectDataSize <= "00";
                        o_RegWrite <= '1';

                    when "001" =>
                        -- LH
                        o_selectDataSize <= "01";
                        o_sign <= '1';
                        o_RegWrite <= '1';

                    when "000" =>
                        -- LB
                        o_selectDataSize <= "10";
                        o_sign <= '1';
                        o_RegWrite <= '1';

                    when "101" =>
                        -- LHU
                        o_selectDataSize <= "01";
                        o_sign <= '0';
                        o_RegWrite <= '1';

                    when "100" =>
                        -- LBU
                        o_selectDataSize <= "10";
                        o_sign <= '0';
                        o_RegWrite <= '1';

                    when others =>
                        null;
                end case;

            -- ========================================
            -- Store instructions
            -- ========================================
            when "0100011" =>
                o_ALUSrc        <= '1';
                o_ALUControl    <= '0';
                o_ImmType       <= "001";
                o_selectAluOut  <= "000";

                case funct3 is

                    when "010" =>
                        -- SW
                        o_selectDataSize <= "00";
                        o_MemWrite <= '1';

                    when "001" =>
                        -- SH
                        o_selectDataSize <= "01";
                        o_MemWrite <= '1';

                    when "000" =>
                        -- SB
                        o_selectDataSize <= "10";
                        o_MemWrite <= '1';

                    when others =>
                        null;
                end case;

            -- ========================================
            -- Branch instructions
            -- ========================================
            when "1100011" =>
                o_ImmType <= "011";

                -- Branch conditions are decoded
                -- inside FetchModule.

            -- ========================================
            -- JAL
            -- ========================================
            when "1101111" =>
                o_ImmType   <= "100";
                o_ResultSrc <= "011";
                o_RegWrite  <= '1';

            -- ========================================
            -- JALR
            -- ========================================
            when "1100111" =>
                if funct3 = "000" then
                    o_ImmType   <= "000";
                    o_ResultSrc <= "011";
                    o_RegWrite  <= '1';
                end if;

            -- ========================================
            -- LUI
            -- ========================================
            when "0110111" =>
                o_ImmType   <= "010";
                o_ResultSrc <= "010";
                o_RegWrite  <= '1';

            -- ========================================
            -- AUIPC
            -- ========================================
            when "0010111" =>
                o_ImmType   <= "010";
                o_ResultSrc <= "100";
                o_RegWrite  <= '1';

            -- ========================================
            -- WFI
            -- ========================================
            when "1110011" =>
                null;

            when others =>
                null;

        end case;
    end process;

end Behavioral;
