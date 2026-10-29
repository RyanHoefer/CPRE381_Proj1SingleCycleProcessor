library IEEE;
use IEEE.std_logic_1164.all;
use std.env.all;

entity tb_ControlUnit is
    generic(
        gCLK_HPER : time := 10 ns;
        DATA_WIDTH : integer := 32
    );
end tb_ControlUnit;

architecture mixed of tb_ControlUnit is

    component ControlUnit is
        port(
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
    end component;

    signal CLK : std_logic := '0';

    signal iInstruction : std_logic_vector(31 downto 0)
                          := (others => '0');

    signal ALUSrc         : std_logic;
    signal ALUControl     : std_logic;
    signal ImmType        : std_logic_vector(2 downto 0);
    signal ResultSrc      : std_logic_vector(2 downto 0);
    signal MemWrite       : std_logic;
    signal RegWrite       : std_logic;
    signal signMode       : std_logic;
    signal selectDataSize : std_logic_vector(1 downto 0);
    signal selectAluOut   : std_logic_vector(2 downto 0);
    signal dir            : std_logic;
    signal arith          : std_logic;

begin

    DUT: ControlUnit
        port map(
            i_Instruction    => iInstruction,
            o_ALUSrc         => ALUSrc,
            o_ALUControl     => ALUControl,
            o_ImmType        => ImmType,
            o_ResultSrc      => ResultSrc,
            o_MemWrite       => MemWrite,
            o_RegWrite       => RegWrite,
            o_sign           => signMode,
            o_selectDataSize => selectDataSize,
            o_selectAluOut   => selectAluOut,
            o_dir            => dir,
            o_arith          => arith
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

        -- Apply one instruction and check all control outputs.
        -- Expected values not supplied in a call default to zero.
        procedure check_instruction(
            constant test_name : in string;
            constant instr    : in std_logic_vector(31 downto 0);
            constant e_src    : in std_logic := '0';
            constant e_sub    : in std_logic := '0';
            constant e_imm    : in std_logic_vector(2 downto 0)
                               := "000";
            constant e_result : in std_logic_vector(2 downto 0)
                               := "000";
            constant e_mem    : in std_logic := '0';
            constant e_reg    : in std_logic := '0';
            constant e_sign   : in std_logic := '0';
            constant e_size   : in std_logic_vector(1 downto 0)
                               := "00";
            constant e_alu    : in std_logic_vector(2 downto 0)
                               := "000";
            constant e_dir    : in std_logic := '0';
            constant e_arith  : in std_logic := '0'
        ) is
        begin

            iInstruction <= instr;
            wait for gCLK_HPER * 2;

            assert ALUSrc = e_src
                report test_name & ": ALUSrc incorrect"
                severity error;

            assert ALUControl = e_sub
                report test_name & ": ALUControl incorrect"
                severity error;

            assert ImmType = e_imm
                report test_name & ": ImmType incorrect"
                severity error;

            assert ResultSrc = e_result
                report test_name & ": ResultSrc incorrect"
                severity error;

            assert MemWrite = e_mem
                report test_name & ": MemWrite incorrect"
                severity error;

            assert RegWrite = e_reg
                report test_name & ": RegWrite incorrect"
                severity error;

            assert signMode = e_sign
                report test_name & ": signMode incorrect"
                severity error;

            assert selectDataSize = e_size
                report test_name & ": selectDataSize incorrect"
                severity error;

            assert selectAluOut = e_alu
                report test_name & ": selectAluOut incorrect"
                severity error;

            assert dir = e_dir
                report test_name & ": dir incorrect"
                severity error;

            assert arith = e_arith
                report test_name & ": arith incorrect"
                severity error;

            report "Completed test: " & test_name
                severity note;

        end procedure;

    begin

        wait for gCLK_HPER / 2;

        --------------------------------------------------
        -- R-TYPE INSTRUCTIONS
        --------------------------------------------------

        -- ADD x3, x1, x2
        -- Select register operands and addition.
        -- Write the ALU result to x3.
        check_instruction(
            "1 ADD", x"002081B3",
            e_reg => '1'
        );

        -- SUB x3, x1, x2
        -- Select register operands and subtraction.
        -- Write the ALU result to x3.
        check_instruction(
            "2 SUB", x"402081B3",
            e_sub => '1',
            e_reg => '1'
        );

        -- AND x3, x1, x2
        -- Select the bitwise AND result and enable register writing.
        check_instruction(
            "3 AND", x"0020F1B3",
            e_reg => '1',
            e_alu => "010"
        );

        -- OR x3, x1, x2
        -- Select the bitwise OR result and enable register writing.
        check_instruction(
            "4 OR", x"0020E1B3",
            e_reg => '1',
            e_alu => "001"
        );

        -- XOR x3, x1, x2
        -- Select the bitwise XOR result and enable register writing.
        check_instruction(
            "5 XOR", x"0020C1B3",
            e_reg => '1',
            e_alu => "011"
        );

        -- SLT x3, x1, x2
        -- Select less-than comparison with signMode = 1
        -- to compare signed operands.
        check_instruction(
            "6 SLT", x"0020A1B3",
            e_reg => '1',
            e_sign => '1',
            e_alu => "101"
        );

        -- SLTU x3, x1, x2
        -- Select less-than comparison with signMode = 0
        -- to compare unsigned operands.
        check_instruction(
            "7 SLTU", x"0020B1B3",
            e_reg => '1',
            e_alu => "101"
        );

        -- SLL x3, x1, x2
        -- Select the shifter with dir = 1 for a logical left shift.
        check_instruction(
            "8 SLL", x"002091B3",
            e_reg => '1',
            e_alu => "100",
            e_dir => '1'
        );

        -- SRL x3, x1, x2
        -- Select dir = 0 and arith = 0 for a logical right shift.
        check_instruction(
            "9 SRL", x"0020D1B3",
            e_reg => '1',
            e_alu => "100"
        );

        -- SRA x3, x1, x2
        -- Select dir = 0 and arith = 1 for an arithmetic right shift.
        check_instruction(
            "10 SRA", x"4020D1B3",
            e_reg => '1',
            e_alu => "100",
            e_arith => '1'
        );

        --------------------------------------------------
        -- I-TYPE ARITHMETIC AND LOGIC
        --------------------------------------------------

        -- ADDI x3, x1, 5
        -- Select the I-type immediate as the second operand and add.
        check_instruction(
            "11 ADDI", x"00508193",
            e_src => '1',
            e_reg => '1'
        );

        -- ADDI x3, x1, -1
        -- A negative immediate must still select addition.
        -- Immediate sign extension is tested separately.
        check_instruction(
            "12 ADDI negative", x"FFF08193",
            e_src => '1',
            e_reg => '1'
        );

        -- ANDI x3, x1, -1
        -- Select an I-type immediate operand and bitwise AND.
        check_instruction(
            "13 ANDI", x"FFF0F193",
            e_src => '1',
            e_reg => '1',
            e_alu => "010"
        );

        -- ORI x3, x1, -1
        -- Select an I-type immediate operand and bitwise OR.
        check_instruction(
            "14 ORI", x"FFF0E193",
            e_src => '1',
            e_reg => '1',
            e_alu => "001"
        );

        -- XORI x3, x1, -1
        -- Select an I-type immediate operand and bitwise XOR.
        check_instruction(
            "15 XORI", x"FFF0C193",
            e_src => '1',
            e_reg => '1',
            e_alu => "011"
        );

        -- SLTI x3, x1, -1
        -- Select immediate less-than comparison with signMode = 1.
        check_instruction(
            "16 SLTI", x"FFF0A193",
            e_src => '1',
            e_reg => '1',
            e_sign => '1',
            e_alu => "101"
        );

        -- SLTIU x3, x1, -1
        -- Select immediate less-than comparison with signMode = 0.
        -- The immediate is still sign-extended before comparison.
        check_instruction(
            "17 SLTIU", x"FFF0B193",
            e_src => '1',
            e_reg => '1',
            e_alu => "101"
        );

        -- SLLI x3, x1, 31
        -- Select the immediate operand and logical left-shift controls.
        check_instruction(
            "18 SLLI", x"01F09193",
            e_src => '1',
            e_reg => '1',
            e_alu => "100",
            e_dir => '1'
        );

        -- SRLI x3, x1, 31
        -- Select the immediate operand and logical right-shift controls.
        check_instruction(
            "19 SRLI", x"01F0D193",
            e_src => '1',
            e_reg => '1',
            e_alu => "100"
        );

        -- SRAI x3, x1, 31
        -- Select the immediate operand and arithmetic right-shift controls.
        check_instruction(
            "20 SRAI", x"41F0D193",
            e_src => '1',
            e_reg => '1',
            e_alu => "100",
            e_arith => '1'
        );

        --------------------------------------------------
        -- LOAD INSTRUCTIONS
        --------------------------------------------------

        -- LB x3, 0(x1)
        -- Select address addition using the I-type offset.
        -- Select byte size, sign extension, and memory writeback.
        check_instruction(
            "21 LB", x"00008183",
            e_src => '1',
            e_result => "001",
            e_reg => '1',
            e_sign => '1',
            e_size => "10"
        );

        -- LBU x3, 0(x1)
        -- Select byte size and zero extension for memory writeback.
        check_instruction(
            "22 LBU", x"0000C183",
            e_src => '1',
            e_result => "001",
            e_reg => '1',
            e_size => "10"
        );

        -- LH x3, 0(x1)
        -- Select halfword size and sign extension for memory writeback.
        check_instruction(
            "23 LH", x"00009183",
            e_src => '1',
            e_result => "001",
            e_reg => '1',
            e_sign => '1',
            e_size => "01"
        );

        -- LHU x3, 0(x1)
        -- Select halfword size and zero extension for memory writeback.
        check_instruction(
            "24 LHU", x"0000D183",
            e_src => '1',
            e_result => "001",
            e_reg => '1',
            e_size => "01"
        );

        -- LW x3, 0(x1)
        -- Select full-word memory writeback.
        -- Enable register writing and disable memory writing.
        check_instruction(
            "25 LW", x"0000A183",
            e_src => '1',
            e_result => "001",
            e_reg => '1'
        );

        --------------------------------------------------
        -- STORE INSTRUCTIONS
        --------------------------------------------------

        -- SB x2, 0(x1)
        -- Select address addition using the S-type offset and byte size.
        -- Enable memory writing and disable register writing.
        check_instruction(
            "26 SB", x"00208023",
            e_src => '1',
            e_imm => "001",
            e_mem => '1',
            e_size => "10"
        );

        -- SH x2, 0(x1)
        -- Select the S-type offset and halfword store size.
        -- Enable memory writing and disable register writing.
        check_instruction(
            "27 SH", x"00209023",
            e_src => '1',
            e_imm => "001",
            e_mem => '1',
            e_size => "01"
        );

        -- SW x2, 0(x1)
        -- Select the S-type offset and full-word store size.
        -- Enable memory writing and disable register writing.
        check_instruction(
            "28 SW", x"0020A023",
            e_src => '1',
            e_imm => "001",
            e_mem => '1'
        );

        --------------------------------------------------
        -- BRANCH INSTRUCTIONS
        -- These tests check decoding, not branch decisions.
        --------------------------------------------------

        -- BEQ x1, x2, 8
        -- Select the B-type immediate and disable both write enables.
        -- FetchModule separately checks operand equality.
        check_instruction(
            "29 BEQ", x"00208463",
            e_imm => "011"
        );

        -- BNE x1, x2, 8
        -- Select the B-type immediate and disable both write enables.
        -- FetchModule separately checks operand inequality.
        check_instruction(
            "30 BNE", x"00209463",
            e_imm => "011"
        );

        -- BLT x1, x2, 8
        -- Select the B-type immediate.
        -- FetchModule separately performs signed less-than comparison.
        check_instruction(
            "31 BLT", x"0020C463",
            e_imm => "011"
        );

        -- BGE x1, x2, 8
        -- Select the B-type immediate.
        -- FetchModule separately performs signed greater-or-equal comparison.
        check_instruction(
            "32 BGE", x"0020D463",
            e_imm => "011"
        );

        -- BLTU x1, x2, 8
        -- Select the B-type immediate.
        -- FetchModule separately performs unsigned less-than comparison.
        check_instruction(
            "33 BLTU", x"0020E463",
            e_imm => "011"
        );

        -- BGEU x1, x2, 8
        -- Select the B-type immediate.
        -- FetchModule separately performs unsigned greater-or-equal comparison.
        check_instruction(
            "34 BGEU", x"0020F463",
            e_imm => "011"
        );

        --------------------------------------------------
        -- JUMPS AND UPPER IMMEDIATES
        --------------------------------------------------

        -- JAL x3, 8
        -- Select the J-type immediate and PC + 4 writeback.
        -- Enable writing the return address to x3.
        check_instruction(
            "35 JAL", x"008001EF",
            e_imm => "100",
            e_result => "011",
            e_reg => '1'
        );

        -- JALR x3, 0(x1)
        -- Select the I-type immediate and PC + 4 writeback.
        -- FetchModule separately calculates and aligns the target's low bit.
        check_instruction(
            "36 JALR", x"000081E7",
            e_result => "011",
            e_reg => '1'
        );

        -- LUI x3, 0x12345
        -- Select the U-type immediate directly for register writeback.
        check_instruction(
            "37 LUI", x"123451B7",
            e_imm => "010",
            e_result => "010",
            e_reg => '1'
        );

        -- AUIPC x3, 0x12345
        -- Select the U-type immediate and PC + immediate writeback.
        check_instruction(
            "38 AUIPC", x"12345197",
            e_imm => "010",
            e_result => "100",
            e_reg => '1'
        );

        --------------------------------------------------
        -- HALT AND INVALID INSTRUCTIONS
        --------------------------------------------------

        -- WFI
        -- Disable register and memory writes.
        -- The top-level logic separately detects the halt instruction.
        check_instruction(
            "39 WFI", x"10500073"
        );

        -- Invalid opcode
        -- An unrecognized opcode must not enable either write operation.
        check_instruction(
            "40 Invalid opcode", x"FFFFFFFF"
        );

        -- MUL x3, x1, x2
        -- The M extension is unsupported.
        -- Register and memory writes must remain disabled.
        check_instruction(
            "41 Unsupported MUL", x"022081B3"
        );

        -- Invalid SLLI encoding
        -- Invalid upper bits must prevent register writing.
        -- ALUSrc remains 1 because the opcode is still I-type arithmetic.
        check_instruction(
            "42 Invalid SLLI", x"02009193",
            e_src => '1'
        );

        -- Invalid JALR encoding
        -- funct3 is not 000, so neither write enable may be asserted.
        check_instruction(
            "43 Invalid JALR", x"000091E7"
        );

        --------------------------------------------------
        -- CONTROL SIGNAL RECOVERY TEST
        --------------------------------------------------

        -- SH x2, 0(x1)
        -- Assert memory writing and halfword selection before the next test.
        check_instruction(
            "44 SH before invalid", x"00209023",
            e_src => '1',
            e_imm => "001",
            e_mem => '1',
            e_size => "01"
        );

        -- Invalid instruction after SH
        -- Verify that the previous store controls do not remain asserted.
        -- This checks combinational recovery, not a hardware reset.
        check_instruction(
            "45 Invalid after SH", x"FFFFFFFF"
        );

        --------------------------------------------------
        -- END OF TESTING
        --------------------------------------------------

        report "All 45 test cases completed."
            severity note;

        finish;
        wait;

    end process;

end mixed;