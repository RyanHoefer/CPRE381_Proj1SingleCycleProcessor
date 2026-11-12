
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

architecture Dataflow of ControlUnit is

    signal opcode : std_logic_vector(6 downto 0);
    signal funct3 : std_logic_vector(2 downto 0);
    signal funct7 : std_logic_vector(6 downto 0);

    signal isRType  : std_logic;
    signal isIType  : std_logic;
    signal isLoad   : std_logic;
    signal isStore  : std_logic;
    signal isBranch : std_logic;
    signal isJAL    : std_logic;
    signal isJALR   : std_logic;
    signal isLUI    : std_logic;
    signal isAUIPC  : std_logic;

    signal validR     : std_logic;
    signal validI     : std_logic;
    signal validLoad  : std_logic;
    signal validStore : std_logic;

    signal isADD  : std_logic;
    signal isSUB  : std_logic;
    signal isAND  : std_logic;
    signal isOR   : std_logic;
    signal isXOR  : std_logic;
    signal isSLT  : std_logic;
    signal isSLTU : std_logic;
    signal isSLL  : std_logic;
    signal isSRL  : std_logic;
    signal isSRA  : std_logic;

    signal isADDI  : std_logic;
    signal isANDI  : std_logic;
    signal isORI   : std_logic;
    signal isXORI  : std_logic;
    signal isSLTI  : std_logic;
    signal isSLTIU : std_logic;
    signal isSLLI  : std_logic;
    signal isSRLI  : std_logic;
    signal isSRAI  : std_logic;

    signal isLW  : std_logic;
    signal isLH  : std_logic;
    signal isLB  : std_logic;
    signal isLHU : std_logic;
    signal isLBU : std_logic;

    signal isSW : std_logic;
    signal isSH : std_logic;
    signal isSB : std_logic;

begin

    --------------------------------------------------
    -- Instruction fields
    --------------------------------------------------

    opcode <= i_Instruction(6 downto 0);
    funct3 <= i_Instruction(14 downto 12);
    funct7 <= i_Instruction(31 downto 25);

    --------------------------------------------------
    -- Opcode decoding
    --------------------------------------------------

    isRType  <= '1' when opcode = "0110011" else '0';
    isIType  <= '1' when opcode = "0010011" else '0';
    isLoad   <= '1' when opcode = "0000011" else '0';
    isStore  <= '1' when opcode = "0100011" else '0';
    isBranch <= '1' when opcode = "1100011" else '0';
    isJAL    <= '1' when opcode = "1101111" else '0';
    isJALR   <= '1' when opcode = "1100111" and
                         funct3 = "000" else '0';
    isLUI    <= '1' when opcode = "0110111" else '0';
    isAUIPC  <= '1' when opcode = "0010111" else '0';

    --------------------------------------------------
    -- R-type instruction decoding
    --------------------------------------------------

    isADD <= '1' when isRType = '1' and
                      funct3 = "000" and
                      funct7 = "0000000" else '0';

    isSUB <= '1' when isRType = '1' and
                      funct3 = "000" and
                      funct7 = "0100000" else '0';

    isAND <= '1' when isRType = '1' and
                      funct3 = "111" and
                      funct7 = "0000000" else '0';

    isOR <= '1' when isRType = '1' and
                     funct3 = "110" and
                     funct7 = "0000000" else '0';

    isXOR <= '1' when isRType = '1' and
                      funct3 = "100" and
                      funct7 = "0000000" else '0';

    isSLT <= '1' when isRType = '1' and
                      funct3 = "010" and
                      funct7 = "0000000" else '0';

    isSLTU <= '1' when isRType = '1' and
                       funct3 = "011" and
                       funct7 = "0000000" else '0';

    isSLL <= '1' when isRType = '1' and
                      funct3 = "001" and
                      funct7 = "0000000" else '0';

    isSRL <= '1' when isRType = '1' and
                      funct3 = "101" and
                      funct7 = "0000000" else '0';

    isSRA <= '1' when isRType = '1' and
                      funct3 = "101" and
                      funct7 = "0100000" else '0';

    --------------------------------------------------
    -- I-type arithmetic instruction decoding
    --------------------------------------------------

    isADDI <= '1' when isIType = '1' and
                       funct3 = "000" else '0';

    isANDI <= '1' when isIType = '1' and
                       funct3 = "111" else '0';

    isORI <= '1' when isIType = '1' and
                      funct3 = "110" else '0';

    isXORI <= '1' when isIType = '1' and
                       funct3 = "100" else '0';

    isSLTI <= '1' when isIType = '1' and
                       funct3 = "010" else '0';

    isSLTIU <= '1' when isIType = '1' and
                        funct3 = "011" else '0';

    isSLLI <= '1' when isIType = '1' and
                       funct3 = "001" and
                       funct7 = "0000000" else '0';

    isSRLI <= '1' when isIType = '1' and
                       funct3 = "101" and
                       funct7 = "0000000" else '0';

    isSRAI <= '1' when isIType = '1' and
                       funct3 = "101" and
                       funct7 = "0100000" else '0';

    --------------------------------------------------
    -- Load instruction decoding
    --------------------------------------------------

    isLW <= '1' when isLoad = '1' and 
                     funct3 = "010" else '0';

    isLH <= '1' when isLoad = '1' and
                     funct3 = "001" else '0';

    isLB <= '1' when isLoad = '1' and
                     funct3 = "000" else '0';

    isLHU <= '1' when isLoad = '1' and
                      funct3 = "101" else '0';

    isLBU <= '1' when isLoad = '1' and
                      funct3 = "100" else '0';

    --------------------------------------------------
    -- Store instruction decoding
    --------------------------------------------------

    isSW <= '1' when isStore = '1' and
                     funct3 = "010" else '0';

    isSH <= '1' when isStore = '1' and
                     funct3 = "001" else '0';

    isSB <= '1' when isStore = '1' and
                     funct3 = "000" else '0';

    --------------------------------------------------
    -- Valid instruction groups
    --------------------------------------------------

    validR <= isADD or isSUB or isAND or isOR or
              isXOR or isSLT or isSLTU or
              isSLL or isSRL or isSRA;

    validI <= isADDI or isANDI or isORI or isXORI or
              isSLTI or isSLTIU or isSLLI or
              isSRLI or isSRAI;

    validLoad <= isLW or isLH or isLB or isLHU or isLBU;

    validStore <= isSW or isSH or isSB;

    --------------------------------------------------
    -- Control signal outputs
    -- Taria: Replaced the process and case statements
    -- with dataflow logic to match the TA's instructions.
    --------------------------------------------------

    -- ALU second operand
    o_ALUSrc <= isIType or isLoad or isStore;

    -- Subtract only for SUB
    o_ALUControl <= isSUB;

    -- Immediate type:
    -- 000 = I, 001 = S, 010 = U
    -- 011 = B, 100 = J

    o_ImmType <= "001" when isStore = '1' else
                 "010" when isLUI = '1' or
                            isAUIPC = '1' else
                 "011" when isBranch = '1' else
                 "100" when isJAL = '1' else
                 "000";

    -- Writeback selection:
    -- 000 = ALU
    -- 001 = Memory
    -- 010 = Immediate (LUI)
    -- 011 = PC + 4
    -- 100 = PC + Immediate

    o_ResultSrc <= "001" when isLoad = '1' else
                   "010" when isLUI = '1' else
                   "011" when isJAL = '1' or
                              isJALR = '1' else
                   "100" when isAUIPC = '1' else
                   "000";

    -- Memory write enable
    o_MemWrite <= validStore;

    -- Register write enable
    o_RegWrite <= validR or validI or validLoad or
                  isJAL or isJALR or isLUI or isAUIPC;

    -- Signed comparison / signed loads
    o_sign <= isSLT or isSLTI or isLH or isLB;

    -- Memory data size:
    -- 00 = Word, 01 = Halfword, 10 = Byte

    o_selectDataSize <= "01" when isLH = '1' or
                                  isLHU = '1' or
                                  isSH = '1' else
                        "10" when isLB = '1' or
                                  isLBU = '1' or
                                  isSB = '1' else
                        "00";

    -- ALU output selection:
    -- 000 = Add/Sub
    -- 001 = OR
    -- 010 = AND
    -- 011 = XOR
    -- 100 = Shift
    -- 101 = Less than

    o_selectAluOut <= "001" when isOR = '1' or
                                isORI = '1' else
                      "010" when isAND = '1' or
                                isANDI = '1' else
                      "011" when isXOR = '1' or
                                isXORI = '1' else
                      "100" when isSLL = '1' or
                                isSRL = '1' or
                                isSRA = '1' or
                                isSLLI = '1' or
                                isSRLI = '1' or
                                isSRAI = '1' else
                      "101" when isSLT = '1' or
                                isSLTU = '1' or
                                isSLTI = '1' or
                                isSLTIU = '1' else
                      "000";

    -- Shift direction: 1 = Left, 0 = Right
    o_dir <= isSLL or isSLLI;

    -- Arithmetic shift enable
    o_arith <= isSRA or isSRAI;

end Dataflow;
