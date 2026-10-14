
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_ImmediateGenerator is
end tb_ImmediateGenerator;

architecture Behavioral of tb_ImmediateGenerator is

    signal s_Instruction : std_logic_vector(31 downto 0);
    signal s_ImmType     : std_logic_vector(2 downto 0);
    signal s_Immediate   : std_logic_vector(31 downto 0);

begin

    DUT: entity work.ImmediateGenerator
        port map (
            i_Instruction => s_Instruction,
            i_ImmType     => s_ImmType,
            o_Immediate   => s_Immediate
        );

    process
    begin

        -- Test 1: I-type, immediate = 10
        s_Instruction <= x"00A00093";
        s_ImmType <= "000";
        wait for 10 ns;
        assert s_Immediate = x"0000000A"
            report "I-type positive failed"
            severity error;

        -- Test 2: I-type, immediate = -5
        s_Instruction <= x"FFB00093";
        s_ImmType <= "000";
        wait for 10 ns;
        assert s_Immediate = x"FFFFFFFB"
            report "I-type negative failed"
            severity error;

        -- Test 3: S-type, immediate = 8
        s_Instruction <= x"00512423";
        s_ImmType <= "001";
        wait for 10 ns;
        assert s_Immediate = x"00000008"
            report "S-type positive failed"
            severity error;

        -- Test 4: S-type, immediate = -4
        s_Instruction <= x"FE512E23";
        s_ImmType <= "001";
        wait for 10 ns;
        assert s_Immediate = x"FFFFFFFC"
            report "S-type negative failed"
            severity error;

        -- Test 5: U-type
        s_Instruction <= x"123452B7";
        s_ImmType <= "010";
        wait for 10 ns;
        assert s_Immediate = x"12345000"
            report "U-type failed"
            severity error;

        report "All Immediate Generator tests passed!"
            severity note;

        wait;
    end process;

end Behavioral;
