library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
library std;
use std.env.all;
use std.textio.all;

entity tb_ControlUnit is
    generic(gCLK_HPER : time := 10 ns;
            DATA_WIDTH : integer := 32);
end tb_ControlUnit;

architecture mixed of tb_ControlUnit is

    -- Define the total clock period time
    constant cCLK_PER : time := gCLK_HPER * 2;

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
                          := x"00000000";

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

    -- This clock is only a waveform timing reference.
    -- The ControlUnit does not have a clock input.
    P_CLK: process
    begin
        CLK <= '1';
        wait for gCLK_HPER;
        CLK <= '0';
        wait for gCLK_HPER;
    end process;

    P_TEST_CASES: process
    begin
        wait for gCLK_HPER/2;

        --------------------------------------------------
        -- R-type instructions
        --
        -- Expected for all valid R-type tests:
        -- ALUSrc = 0, ResultSrc = 000
        -- MemWrite = 0, RegWrite = 1
        --------------------------------------------------

        -- Test case 1: ADD x3, x1, x2
        -- Expected: selectAluOut = 000, ALUControl = 0
        iInstruction <= x"002081B3";
        wait for gCLK_HPER*2;

        -- Test case 2: SUB x3, x1, x2
        -- Expected: selectAluOut = 000, ALUControl = 1
        iInstruction <= x"402081B3";
        wait for gCLK_HPER*2;

        -- Test case 3: AND x3, x1, x2
        -- Expected: selectAluOut = 010, ALUControl = 0
        iInstruction <= x"0020F1B3";
        wait for gCLK_HPER*2;

        -- Test case 4: OR x3, x1, x2
        -- Expected: selectAluOut = 001
        iInstruction <= x"0020E1B3";
        wait for gCLK_HPER*2;

        -- Test case 5: XOR x3, x1, x2
        -- Expected: selectAluOut = 011
        iInstruction <= x"0020C1B3";
        wait for gCLK_HPER*2;

        -- Test case 6: SLT x3, x1, x2
        -- Expected: selectAluOut = 101, signMode = 1
        iInstruction <= x"0020A1B3";
        wait for gCLK_HPER*2;

        -- Test case 7: SLTU x3, x1, x2
        -- Expected: selectAluOut = 101, signMode = 0
        -- RegWrite must be 1.
        iInstruction <= x"0020B1B3";
        wait for gCLK_HPER*2;

        -- Test case 8: SLL x3, x1, x2
        -- Expected: selectAluOut = 100, dir = 1, arith = 0
        iInstruction <= x"002091B3";
        wait for gCLK_HPER*2;

        -- Test case 9: SRL x3, x1, x2
        -- Expected: selectAluOut = 100, dir = 0, arith = 0
        iInstruction <= x"0020D1B3";
        wait for gCLK_HPER*2;

        -- Test case 10: SRA x3, x1, x2
        -- Expected: selectAluOut = 100, dir = 0, arith = 1
        iInstruction <= x"4020D1B3";
        wait for gCLK_HPER*2;

        --------------------------------------------------
        -- I-type arithmetic and logic
        --
        -- Expected for all valid tests in this group:
        -- ALUSrc = 1, ImmType = 000, ResultSrc = 000
        -- MemWrite = 0, RegWrite = 1, ALUControl = 0
        --------------------------------------------------

        -- Test case 11: ADDI x3, x1, 5
        -- Expected: selectAluOut = 000
        -- arith must return to 0 after SRA.
        iInstruction <= x"00508193";
        wait for gCLK_HPER*2;

        -- Test case 12: ADDI x3, x1, -1
        -- Expected: selectAluOut = 000
        iInstruction <= x"FFF08193";
        wait for gCLK_HPER*2;

        -- Test case 13: ANDI x3, x1, -1
        -- Expected: selectAluOut = 010
        iInstruction <= x"FFF0F193";
        wait for gCLK_HPER*2;

        -- Test case 14: ORI x3, x1, -1
        -- Expected: selectAluOut = 001
        iInstruction <= x"FFF0E193";
        wait for gCLK_HPER*2;

        -- Test case 15: XORI x3, x1, -1
        -- Expected: selectAluOut = 011
        iInstruction <= x"FFF0C193";
        wait for gCLK_HPER*2;

        -- Test case 16: SLTI x3, x1, -1
        -- Expected: selectAluOut = 101, signMode = 1
        iInstruction <= x"FFF0A193";
        wait for gCLK_HPER*2;

        -- Test case 17: SLTIU x3, x1, -1
        -- Expected: selectAluOut = 101, signMode = 0
        iInstruction <= x"FFF0B193";
        wait for gCLK_HPER*2;

        -- Test case 18: SLLI x3, x1, 31
        -- Expected: selectAluOut = 100, dir = 1, arith = 0
        iInstruction <= x"01F09193";
        wait for gCLK_HPER*2;

        -- Test case 19: SRLI x3, x1, 31
        -- Expected: selectAluOut = 100, dir = 0, arith = 0
        iInstruction <= x"01F0D193";
        wait for gCLK_HPER*2;

        -- Test case 20: SRAI x3, x1, 31
        -- Expected: selectAluOut = 100, dir = 0, arith = 1
        iInstruction <= x"41F0D193";
        wait for gCLK_HPER*2;

        --------------------------------------------------
        -- Loads
        --
        -- Expected for all valid loads:
        -- ALUSrc = 1, ALUControl = 0, selectAluOut = 000
        -- ImmType = 000, ResultSrc = 001
        -- MemWrite = 0, RegWrite = 1
        --------------------------------------------------

        -- Test case 21: LB x3, 0(x1)
        -- Expected: selectDataSize = 10, signMode = 1
        -- arith must return to 0 after SRAI.
        iInstruction <= x"00008183";
        wait for gCLK_HPER*2;

        -- Test case 22: LBU x3, 0(x1)
        -- Expected: selectDataSize = 10, signMode = 0
        iInstruction <= x"0000C183";
        wait for gCLK_HPER*2;

        -- Test case 23: LH x3, 0(x1)
        -- Expected: selectDataSize = 01, signMode = 1
        iInstruction <= x"00009183";
        wait for gCLK_HPER*2;

        -- Test case 24: LHU x3, 0(x1)
        -- Expected: selectDataSize = 01, signMode = 0
        iInstruction <= x"0000D183";
        wait for gCLK_HPER*2;

        -- Test case 25: LW x3, 0(x1)
        -- Expected: selectDataSize = 00
        iInstruction <= x"0000A183";
        wait for gCLK_HPER*2;

        --------------------------------------------------
        -- Stores
        --
        -- Expected for all valid stores:
        -- ALUSrc = 1, ALUControl = 0, selectAluOut = 000
        -- ImmType = 001, MemWrite = 1, RegWrite = 0
        --------------------------------------------------

        -- Test case 26: SB x2, 0(x1)
        -- Expected: selectDataSize = 10
        iInstruction <= x"00208023";
        wait for gCLK_HPER*2;

        -- Test case 27: SH x2, 0(x1)
        -- Expected: selectDataSize = 01
        iInstruction <= x"00209023";
        wait for gCLK_HPER*2;

        -- Test case 28: SW x2, 0(x1)
        -- Expected: selectDataSize = 00
        iInstruction <= x"0020A023";
        wait for gCLK_HPER*2;

        --------------------------------------------------
        -- Branch instructions
        --
        -- Expected for every branch:
        -- ImmType = 011, MemWrite = 0, RegWrite = 0
        -- FetchModule handles the branch comparisons.
        --------------------------------------------------

        -- Test case 29: BEQ x1, x2, 8
        iInstruction <= x"00208463";
        wait for gCLK_HPER*2;

        -- Test case 30: BNE x1, x2, 8
        iInstruction <= x"00209463";
        wait for gCLK_HPER*2;

        -- Test case 31: BLT x1, x2, 8
        iInstruction <= x"0020C463";
        wait for gCLK_HPER*2;

        -- Test case 32: BGE x1, x2, 8
        iInstruction <= x"0020D463";
        wait for gCLK_HPER*2;

        -- Test case 33: BLTU x1, x2, 8
        iInstruction <= x"0020E463";
        wait for gCLK_HPER*2;

        -- Test case 34: BGEU x1, x2, 8
        iInstruction <= x"0020F463";
        wait for gCLK_HPER*2;

        --------------------------------------------------
        -- Jumps and upper immediates
        --
        -- Expected for all four:
        -- MemWrite = 0, RegWrite = 1
        --------------------------------------------------

        -- Test case 35: JAL x3, 8
        -- Expected: ImmType = 100, ResultSrc = 011
        iInstruction <= x"008001EF";
        wait for gCLK_HPER*2;

        -- Test case 36: JALR x3, 0(x1)
        -- Expected: ImmType = 000, ResultSrc = 011
        iInstruction <= x"000081E7";
        wait for gCLK_HPER*2;

        -- Test case 37: LUI x3, 0x12345
        -- Expected: ImmType = 010, ResultSrc = 010
        iInstruction <= x"123451B7";
        wait for gCLK_HPER*2;

        -- Test case 38: AUIPC x3, 0x12345
        -- Expected: ImmType = 010, ResultSrc = 100
        iInstruction <= x"12345197";
        wait for gCLK_HPER*2;

        --------------------------------------------------
        -- Halt and unsupported instructions
        --------------------------------------------------

        -- Test case 39: WFI
        -- Expected: MemWrite = 0, RegWrite = 0
        -- The top-level detects the halt instruction.
        iInstruction <= x"10500073";
        wait for gCLK_HPER*2;

        -- Test case 40: Invalid opcode
        -- Expected: all control outputs return to zero
        iInstruction <= x"FFFFFFFF";
        wait for gCLK_HPER*2;

        -- Test case 41: MUL x3, x1, x2
        -- Unsupported M-extension instruction.
        -- Expected: MemWrite = 0, RegWrite = 0
        iInstruction <= x"022081B3";
        wait for gCLK_HPER*2;

        -- Test case 42: Invalid SLLI upper bits
        -- Expected: MemWrite = 0, RegWrite = 0
        iInstruction <= x"02009193";
        wait for gCLK_HPER*2;

        -- Test case 43: Invalid JALR funct3
        -- Expected: MemWrite = 0, RegWrite = 0
        iInstruction <= x"000091E7";
        wait for gCLK_HPER*2;

        --------------------------------------------------
        -- Check that previous controls are cleared
        --------------------------------------------------

        -- Test case 44: SH x2, 0(x1)
        -- Expected: MemWrite = 1, RegWrite = 0
        -- ALUSrc = 1, ImmType = 001, selectDataSize = 01
        iInstruction <= x"00209023";
        wait for gCLK_HPER*2;

        -- Test case 45: Invalid instruction after SH
        -- Expected: all control outputs return to zero
        -- In particular, MemWrite must return to 0.
        iInstruction <= x"FFFFFFFF";
        wait for gCLK_HPER*2;

        wait;
    end process;

end mixed;