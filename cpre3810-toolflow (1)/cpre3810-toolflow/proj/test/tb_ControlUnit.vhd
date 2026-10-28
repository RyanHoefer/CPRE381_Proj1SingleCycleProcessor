
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_ControlUnit is
end tb_ControlUnit;

architecture Behavioral of tb_ControlUnit is

    signal s_Instruction : std_logic_vector(31 downto 0) := (others => '0');
    signal s_ALUSrc      : std_logic;
    signal s_ALUControl  : std_logic;
    signal s_ImmType     : std_logic_vector(2 downto 0);
    signal s_ResultSrc   : std_logic_vector(2 downto 0);
    signal s_MemWrite    : std_logic;
    signal s_RegWrite    : std_logic;

begin

    DUT: entity work.ControlUnit
        port map (
            i_Instruction => s_Instruction,
            o_ALUSrc      => s_ALUSrc,
            o_ALUControl  => s_ALUControl,
            o_ImmType     => s_ImmType,
            o_ResultSrc   => s_ResultSrc,
            o_MemWrite    => s_MemWrite,
            o_RegWrite    => s_RegWrite
        );

    process
    begin

        -- ADDI x5, x0, 10
        s_Instruction <= x"00A00293";
        wait for 10 ns;
        assert s_ALUSrc = '1' and s_ALUControl = '0'
           and s_ImmType = "000" and s_ResultSrc = "00"
           and s_MemWrite = '0' and s_RegWrite = '1'
           report "ADDI failed" severity error;

        -- ADD x8, x6, x7
        s_Instruction <= x"00730433";
        wait for 10 ns;
        assert s_ALUSrc = '0' and s_ALUControl = '0'
           and s_ResultSrc = "00" and s_MemWrite = '0'
           and s_RegWrite = '1'
           report "ADD failed" severity error;

        -- SUB x9, x7, x6
        s_Instruction <= x"406384B3";
        wait for 10 ns;
        assert s_ALUSrc = '0' and s_ALUControl = '1'
           and s_ResultSrc = "00" and s_MemWrite = '0'
           and s_RegWrite = '1'
           report "SUB failed" severity error;

        -- LW x10, 0(x5)
        s_Instruction <= x"0002A503";
        wait for 10 ns;
        assert s_ALUSrc = '1' and s_ALUControl = '0'
           and s_ImmType = "000" and s_ResultSrc = "01"
           and s_MemWrite = '0' and s_RegWrite = '1'
           report "LW failed" severity error;

        -- SW x8, 0(x5)
        s_Instruction <= x"0082A023";
        wait for 10 ns;
        assert s_ALUSrc = '1' and s_ALUControl = '0'
           and s_ImmType = "001" and s_MemWrite = '1'
           and s_RegWrite = '0'
           report "SW failed" severity error;

        -- LUI x5, 0x1
        s_Instruction <= x"000012B7";
        wait for 10 ns;
        assert s_ImmType = "010" and s_ResultSrc = "10"
           and s_MemWrite = '0' and s_RegWrite = '1'
           report "LUI failed" severity error;

        -- Unsupported instruction must not write anything
        s_Instruction <= x"FFFFFFFF";
        wait for 10 ns;
        assert s_MemWrite = '0' and s_RegWrite = '0'
           report "Invalid instruction safety test failed"
           severity error;

        report "All 7 Control Unit tests passed!" severity note;
        wait;
    end process;

end Behavioral;
