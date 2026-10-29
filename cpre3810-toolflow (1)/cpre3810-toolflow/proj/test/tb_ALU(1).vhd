library IEEE;
use IEEE.std_logic_1164.all;
use std.env.all;

entity tb_ALU is
    generic(
        gCLK_HPER : time := 10 ns;
        DATA_WIDTH : integer := 32
    );
end tb_ALU;

architecture mixed of tb_ALU is

    component ALU is
        generic(N : integer := 32);
        port(
            rs1            : in std_logic_vector(N-1 downto 0);
            rs2            : in std_logic_vector(N-1 downto 0);
            i_imm          : in std_logic_vector(N-1 downto 0);
            i_selectOutput : in std_logic_vector(2 downto 0);
            i_aluSrc       : in std_logic;
            i_addSub       : in std_logic;
            i_unsigned     : in std_logic;
            i_dir          : in std_logic;
            i_arith        : in std_logic;
            alu_out        : out std_logic_vector(N-1 downto 0)
        );
    end component;

    signal CLK : std_logic := '0';

    signal rs1Data, rs2Data, immediate
        : std_logic_vector(31 downto 0) := (others => '0');

    signal selectOutput : std_logic_vector(2 downto 0)
                          := "000";

    signal aluSrc, addSub, unsignedMode, dir, arith
        : std_logic := '0';

    signal aluResult : std_logic_vector(31 downto 0);

begin

    DUT: ALU
        generic map(N => DATA_WIDTH)
        port map(
            rs1            => rs1Data,
            rs2            => rs2Data,
            i_imm          => immediate,
            i_selectOutput => selectOutput,
            i_aluSrc       => aluSrc,
            i_addSub       => addSub,
            i_unsigned     => unsignedMode,
            i_dir          => dir,
            i_arith        => arith,
            alu_out        => aluResult
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

        -- Apply operands and ALU controls, then check the result.
        -- Controls not supplied in a call default to zero.
        procedure check_alu(
            constant test_name  : in string;
            constant c_rs1      : in std_logic_vector(31 downto 0);
            constant c_rs2      : in std_logic_vector(31 downto 0);
            constant c_imm      : in std_logic_vector(31 downto 0);
            constant c_select   : in std_logic_vector(2 downto 0);
            constant c_expected : in std_logic_vector(31 downto 0);
            constant c_src      : in std_logic := '0';
            constant c_sub      : in std_logic := '0';
            constant c_unsigned : in std_logic := '0';
            constant c_dir      : in std_logic := '0';
            constant c_arith    : in std_logic := '0'
        ) is
        begin

            rs1Data <= c_rs1;
            rs2Data <= c_rs2;
            immediate <= c_imm;
            selectOutput <= c_select;
            aluSrc <= c_src;
            addSub <= c_sub;
            unsignedMode <= c_unsigned;
            dir <= c_dir;
            arith <= c_arith;

            wait for gCLK_HPER * 2;

            assert aluResult = c_expected
                report test_name & ": ALU result incorrect"
                severity error;

            report "Completed test: " & test_name
                severity note;

        end procedure;

    begin

        wait for gCLK_HPER / 2;

        --------------------------------------------------
        -- ADDITION AND SUBTRACTION
        -- selectOutput = 000
        --------------------------------------------------

        -- ADD: 5 + 4 = 9.
        -- Nonzero immediate must be ignored when aluSrc = 0.
        check_alu(
            "1 ADD", x"00000005", x"00000004", x"00000063",
            "000", x"00000009"
        );

        -- Addition wraps around at 32 bits.
        check_alu(
            "2 ADD wraparound",
            x"FFFFFFFF", x"00000001", x"00000000",
            "000", x"00000000"
        );

        -- Signed overflow does not prevent the wrapped result.
        check_alu(
            "3 ADD signed overflow",
            x"7FFFFFFF", x"00000001", x"00000000",
            "000", x"80000000"
        );

        -- SUB: 9 - 4 = 5.
        check_alu(
            "4 SUB", x"00000009", x"00000004", x"00000000",
            "000", x"00000005",
            c_sub => '1'
        );

        -- SUB: 4 - 9 = -5.
        check_alu(
            "5 SUB negative",
            x"00000004", x"00000009", x"00000000",
            "000", x"FFFFFFFB",
            c_sub => '1'
        );

        -- Equal operands subtract to zero.
        check_alu(
            "6 SUB equal",
            x"12345678", x"12345678", x"00000000",
            "000", x"00000000",
            c_sub => '1'
        );

        -- ADDI: select immediate 3 rather than rs2 = 100.
        check_alu(
            "7 ADDI operand selection",
            x"00000005", x"00000064", x"00000003",
            "000", x"00000008",
            c_src => '1'
        );

        -- ADDI: the supplied immediate is already sign-extended.
        -- 5 + (-1) = 4.
        check_alu(
            "8 ADDI negative",
            x"00000005", x"00000064", x"FFFFFFFF",
            "000", x"00000004",
            c_src => '1'
        );

        --------------------------------------------------
        -- BITWISE LOGIC
        -- OR = 001, AND = 010, XOR = 011
        --------------------------------------------------

        check_alu(
            "9 AND",
            x"A5A5A5A5", x"0F0F0F0F", x"00000000",
            "010", x"05050505"
        );

        check_alu(
            "10 OR",
            x"A5A5A5A5", x"0F0F0F0F", x"00000000",
            "001", x"AFAFAFAF"
        );

        check_alu(
            "11 XOR",
            x"A5A5A5A5", x"0F0F0F0F", x"00000000",
            "011", x"AAAAAAAA"
        );

        -- ANDI: use the immediate mask, ignoring rs2.
        check_alu(
            "12 ANDI",
            x"12345678", x"FFFFFFFF", x"000000FF",
            "010", x"00000078",
            c_src => '1'
        );

        -- ORI: use the immediate operand, ignoring rs2.
        check_alu(
            "13 ORI",
            x"12345600", x"FFFFFFFF", x"000000AB",
            "001", x"123456AB",
            c_src => '1'
        );

        -- XORI with -1 inverts every input bit.
        check_alu(
            "14 XORI",
            x"FFFF0000", x"00000000", x"FFFFFFFF",
            "011", x"0000FFFF",
            c_src => '1'
        );

        --------------------------------------------------
        -- SET LESS THAN
        -- selectOutput = 101
        -- unsignedMode = 0: signed, 1: unsigned
        --------------------------------------------------

        -- Signed: -1 < 1 is true.
        check_alu(
            "15 SLT true",
            x"FFFFFFFF", x"00000001", x"00000000",
            "101", x"00000001"
        );

        -- Signed: 1 < -1 is false.
        check_alu(
            "16 SLT false",
            x"00000001", x"FFFFFFFF", x"00000000",
            "101", x"00000000"
        );

        -- Equal operands must produce zero.
        check_alu(
            "17 SLT equal",
            x"80000000", x"80000000", x"00000000",
            "101", x"00000000"
        );

        -- Signed minimum < signed maximum.
        -- This catches comparisons based only on subtraction's sign bit.
        check_alu(
            "18 SLT extreme values",
            x"80000000", x"7FFFFFFF", x"00000000",
            "101", x"00000001"
        );

        -- Unsigned: 1 < 0xFFFFFFFF is true.
        check_alu(
            "19 SLTU true",
            x"00000001", x"FFFFFFFF", x"00000000",
            "101", x"00000001",
            c_unsigned => '1'
        );

        -- Unsigned: 0xFFFFFFFF < 1 is false.
        check_alu(
            "20 SLTU false",
            x"FFFFFFFF", x"00000001", x"00000000",
            "101", x"00000000",
            c_unsigned => '1'
        );

        -- SLTI: signed -2 < immediate -1 is true.
        check_alu(
            "21 SLTI",
            x"FFFFFFFE", x"00000000", x"FFFFFFFF",
            "101", x"00000001",
            c_src => '1'
        );

        -- SLTIU: compare unsigned 1 against the already
        -- sign-extended immediate 0xFFFFFFFF.
        check_alu(
            "22 SLTIU",
            x"00000001", x"00000000", x"FFFFFFFF",
            "101", x"00000001",
            c_src => '1',
            c_unsigned => '1'
        );

        --------------------------------------------------
        -- SHIFTS
        -- selectOutput = 100
        -- dir = 1: left, dir = 0: right
        --------------------------------------------------

        -- Left shift discards the high bit and inserts zero.
        check_alu(
            "23 SLL",
            x"80000001", x"00000001", x"00000000",
            "100", x"00000002",
            c_dir => '1'
        );

        -- Logical right shift inserts zero.
        check_alu(
            "24 SRL",
            x"80000001", x"00000001", x"00000000",
            "100", x"40000000"
        );

        -- Arithmetic right shift repeats the original sign bit.
        check_alu(
            "25 SRA negative",
            x"80000001", x"00000001", x"00000000",
            "100", x"C0000000",
            c_arith => '1'
        );

        -- Positive values receive zero fill even for SRA.
        check_alu(
            "26 SRA positive",
            x"40000000", x"00000001", x"00000000",
            "100", x"20000000",
            c_arith => '1'
        );

        -- Immediate shift amount 31 must override rs2 = 0.
        check_alu(
            "27 SLLI by 31",
            x"00000001", x"00000000", x"0000001F",
            "100", x"80000000",
            c_src => '1',
            c_dir => '1'
        );

        check_alu(
            "28 SRLI by 31",
            x"80000000", x"00000000", x"0000001F",
            "100", x"00000001",
            c_src => '1'
        );

        -- Raw SRAI I-immediate includes its upper function bits.
        -- Only the low five bits select the shift amount.
        check_alu(
            "29 SRAI by 31",
            x"80000000", x"00000000", x"0000041F",
            "100", x"FFFFFFFF",
            c_src => '1',
            c_arith => '1'
        );

        -- Shifting by zero preserves the input.
        check_alu(
            "30 Shift by zero",
            x"89ABCDEF", x"00000000", x"00000000",
            "100", x"89ABCDEF",
            c_arith => '1'
        );

        -- Register shift amount 33 has low five bits equal to 1.
        check_alu(
            "31 Shift uses low five bits",
            x"00000003", x"00000021", x"00000000",
            "100", x"00000006",
            c_dir => '1'
        );

        --------------------------------------------------
        -- UNUSED OUTPUT SELECTIONS
        --------------------------------------------------

        check_alu(
            "32 Unused selection 110",
            x"FFFFFFFF", x"FFFFFFFF", x"FFFFFFFF",
            "110", x"00000000"
        );

        check_alu(
            "33 Unused selection 111",
            x"FFFFFFFF", x"FFFFFFFF", x"FFFFFFFF",
            "111", x"00000000"
        );

        --------------------------------------------------
        -- END OF TESTING
        --------------------------------------------------

        report "All 33 test cases completed."
            severity note;

        finish;
        wait;

    end process;

end mixed;