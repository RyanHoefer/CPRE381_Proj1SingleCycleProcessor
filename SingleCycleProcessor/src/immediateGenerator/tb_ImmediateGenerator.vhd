
library IEEE;
use IEEE.std_logic_1164.all;
use std.env.all;

entity tb_ImmediateGenerator is
    generic (
        gCLK_HPER : time := 10 ns;
        DATA_WIDTH : integer := 32
    );
end tb_ImmediateGenerator;

architecture mixed of tb_ImmediateGenerator is

    component ImmediateGenerator is
        port (
        i_Instruction : in  std_logic_vector(31 downto 0);
        i_ImmType     : in  std_logic_vector(2 downto 0);
        o_Immediate   : out std_logic_vector(31 downto 0)
    );
    end component;

    signal CLK : std_logic := '0';

    signal Instruction : std_logic_vector(31 downto 0)
                        := (others => '0');


        signal ImmType     :   std_logic_vector(2 downto 0);
        signal Immediate   :   std_logic_vector(31 downto 0);

begin

    DUT: entity work.ImmediateGenerator
        port map (
            i_Instruction    => Instruction,
            i_ImmType         => ImmType,
            o_Immediate     => Immediate
           
        );

    -- Clock used only as a waveform timing reference.
    P_CLK: process
    begin
        CLK <= '1';
        wait for gCLK_HPER;
        CLK <= '0';
        wait for gCLK_HPER;
    end process;

    P_TEST_CASES: process

        -- Apply one instruction and check all control signals.
        -- Unspecified expected values default to zero.

        procedure check_immediate (
            constant test_name : in string;
            constant c_Instruction     : in std_logic_vector(31 downto 0);
            constant c_ImmType     : in std_logic_vector(2 downto 0);
            constant c_Immediate     : in std_logic_vector(31 downto 0)
            
        ) is
        begin

            Instruction <= c_Instruction;
            ImmType <= c_ImmType;
            wait for gCLK_HPER * 2;

            assert Immediate = c_Immediate
                report test_name & ": Immediate incorrect"
                severity error;
            report "Completed test: " & test_name
                severity note;

        end procedure;

    begin

        wait for gCLK_HPER / 2;

        --------------------------------------------------
        -- I-TYPE INSTRUCTIONS
        --------------------------------------------------

         -- ADDI x3, x1, 5
        check_immediate(
            "I-type positive", x"00508193",
            "000", x"00000005"
        );

        -- ADDI x3, x1, -1
        check_immediate(
            "I-type negative", x"FFF08193",
            "000", x"FFFFFFFF"
        );

        -- ADDI x3, x1, -2048
        check_immediate(
            "I-type minimum", x"80008193",
            "000", x"FFFFF800"
        );

        --------------------------------------------------
        -- SB-TYPE INSTRUCTIONS
        --------------------------------------------------

        -- SW x1, 4(x3)
        check_immediate(
            "SB-type positive", x"0011A223",
            "001", x"00000004"
        );

        -- SH x2, 2047(x10)
        check_immediate(
            "SB-type maximum", x"7E251FA3",
            "001", x"000007FF"
        );

        --------------------------------------------------
        -- U-TYPE INSTRUCTIONS
        --------------------------------------------------

        -- LUI x1, 0x10010
        check_immediate(
            "U-type base", x"100100B7",
            "010", x"10010000"
        );

        -- auipc x1, 0xFFFFF
        check_immediate(
            "U-type minumum", x"FFFFF097",
            "010", x"FFFFF000"
        );

        --------------------------------------------------
        -- B-TYPE INSTRUCTIONS
        --------------------------------------------------

        -- BEQ x1, x2, 8
        check_immediate(
            "B-type positive", x"00208463",
            "011", x"00000008"
        );

        -- BEQ x1, x2, -4
        check_immediate(
            "B-type negative", x"FE208EE3",
            "011", x"FFFFFFFC"
        );

        -- BEQ x1, x2, 4094
        check_immediate(
            "B-type maximum", x"7E208FE3",
            "011", x"00000FFE"
        );

        -- BEQ x1, x2, -4096
        check_immediate(
            "B-type minimum", x"80208063",
            "011", x"FFFFF000"
        );

        --------------------------------------------------
        -- J-TYPE INSTRUCTIONS
        --------------------------------------------------

        -- JAL x1, 8
        check_immediate(
            "J-type positive", x"008000EF",
            "100", x"00000008"
        );

        -- JAL x1, -4
        check_immediate(
            "J-type negative", x"FFDFF0EF",
            "100", x"FFFFFFFC"
        );

        -- JAL x1, 1048574
        check_immediate(
            "J-type maximum", x"7FFFF0EF",
            "100", x"000FFFFE"
        );

        -- JAL x1, -1048576
        check_immediate(
            "J-type minimum", x"800000EF",
            "100", x"FFF00000"
        );


        --------------------------------------------------
        -- END OF TESTING
        --------------------------------------------------

        report "All 3 test cases completed."
            severity note;

        finish;

        wait;

    end process;

end mixed;
