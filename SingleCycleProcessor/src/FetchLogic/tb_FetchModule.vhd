
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_FetchModule is
end tb_FetchModule;

architecture Behavioral of tb_FetchModule is

    signal CLK : std_logic := '0';
    signal reset : std_logic := '0';

    signal i_rs1_data : std_logic_vector(31 downto 0) := (others => '0');
    signal i_rs2_data : std_logic_vector(31 downto 0) := (others => '0');
    signal i_instruction : std_logic_vector(31 downto 0) := (others => '0');
    signal pc_addr_imm : std_logic_vector(31 downto 0) := (others => '0');

    signal o_pc : std_logic_vector(31 downto 0);
    signal o_pc_plus4 : std_logic_vector(31 downto 0);
    signal o_pc_plus_imm : std_logic_vector(31 downto 0);

    constant NORMAL_INST : std_logic_vector(31 downto 0) := x"00000013";

    -- These instruction values are used for their opcode
    -- and funct3 fields. The offset comes from pc_addr_imm.
    constant BEQ_INST  : std_logic_vector(31 downto 0) := x"00000063";
    constant BNE_INST  : std_logic_vector(31 downto 0) := x"00001063";
    constant BLT_INST  : std_logic_vector(31 downto 0) := x"00004063";
    constant BGE_INST  : std_logic_vector(31 downto 0) := x"00005063";
    constant BLTU_INST : std_logic_vector(31 downto 0) := x"00006063";
    constant BGEU_INST : std_logic_vector(31 downto 0) := x"00007063";

    constant JAL_INST  : std_logic_vector(31 downto 0) := x"0000006F";
    constant JALR_INST : std_logic_vector(31 downto 0) := x"00000067";

begin

    DUT : entity work.FetchModule
        port map (
            i_rs1_data   => i_rs1_data,
            i_rs2_data   => i_rs2_data,
            i_instruction => i_instruction,
            pc_addr_imm  => pc_addr_imm,
            CLK          => CLK,
            reset        => reset,
            o_pc         => o_pc,
            o_pc_plus4   => o_pc_plus4,
            o_pc_plus_imm => o_pc_plus_imm
        );

    -- Taria: Added automatic checks for PC updates,
    -- branches, jumps, and reset.

    P_TEST : process

        variable test_count : integer := 0;

        procedure check_pc (
            constant test_name : in string;
            constant expected_pc : in std_logic_vector(31 downto 0)
        ) is
        begin
            wait for 2 ns;

            assert o_pc = expected_pc
                report "FAILED: " & test_name & " (PC)"
                severity error;

            assert o_pc_plus4 =
                   std_logic_vector(unsigned(expected_pc) + 4)
                report "FAILED: " & test_name & " (PC+4)"
                severity error;

            test_count := test_count + 1;

            report "Completed test " & integer'image(test_count) &
                   ": " & test_name
                severity note;
        end procedure;

        procedure step (
            constant test_name : in string;
            constant inst : in std_logic_vector(31 downto 0);
            constant rs1 : in std_logic_vector(31 downto 0);
            constant rs2 : in std_logic_vector(31 downto 0);
            constant imm : in std_logic_vector(31 downto 0);
            constant expected_next_pc : in std_logic_vector(31 downto 0)
        ) is
        begin
            CLK <= '0';
            i_instruction <= inst;
            i_rs1_data <= rs1;
            i_rs2_data <= rs2;
            pc_addr_imm <= imm;

            wait for 5 ns;

            CLK <= '1';
            wait for 5 ns;

            check_pc(test_name, expected_next_pc);

            CLK <= '0';
            wait for 3 ns;
        end procedure;

        procedure reset_pc (
            constant test_name : in string
        ) is
        begin
            CLK <= '0';
            reset <= '1';

            wait for 5 ns;

            CLK <= '1';
            wait for 5 ns;

            check_pc(test_name, x"00000000");

            CLK <= '0';
            reset <= '0';
            wait for 3 ns;
        end procedure;

    begin

        --------------------------------------------------
        -- RESET AND SEQUENTIAL PC
        --------------------------------------------------

        reset_pc("Initial reset");

        step("PC 0 to 4",
             NORMAL_INST, x"00000000", x"00000000",
             x"00000000", x"00000004");

        step("PC 4 to 8",
             NORMAL_INST, x"00000000", x"00000000",
             x"00000000", x"00000008");

        step("PC 8 to 12",
             NORMAL_INST, x"00000000", x"00000000",
             x"00000000", x"0000000C");

        step("PC 12 to 16",
             NORMAL_INST, x"00000000", x"00000000",
             x"00000000", x"00000010");

        --------------------------------------------------
        -- BEQ
        --------------------------------------------------

        step("BEQ equal taken",
             BEQ_INST, x"00000005", x"00000005",
             x"00000010", x"00000020");

        step("BEQ not equal",
             BEQ_INST, x"00000005", x"00000006",
             x"00000010", x"00000024");

        --------------------------------------------------
        -- BNE
        --------------------------------------------------

        step("BNE different taken",
             BNE_INST, x"00000005", x"00000006",
             x"00000010", x"00000034");

        step("BNE equal not taken",
             BNE_INST, x"00000005", x"00000005",
             x"00000010", x"00000038");

        --------------------------------------------------
        -- BLT SIGNED
        --------------------------------------------------

        step("BLT negative less than positive",
             BLT_INST, x"FFFFFFFF", x"00000001",
             x"00000010", x"00000048");

        step("BLT positive not less than negative",
             BLT_INST, x"00000001", x"FFFFFFFF",
             x"00000010", x"0000004C");

        --------------------------------------------------
        -- BGE SIGNED
        --------------------------------------------------

        step("BGE positive greater than negative",
             BGE_INST, x"00000001", x"FFFFFFFF",
             x"00000010", x"0000005C");

        step("BGE negative less than positive",
             BGE_INST, x"FFFFFFFF", x"00000001",
             x"00000010", x"00000060");

        --------------------------------------------------
        -- BLTU UNSIGNED
        --------------------------------------------------

        step("BLTU unsigned 1 less than FFFFFFFF",
             BLTU_INST, x"00000001", x"FFFFFFFF",
             x"00000010", x"00000070");

        step("BLTU unsigned FFFFFFFF not less than 1",
             BLTU_INST, x"FFFFFFFF", x"00000001",
             x"00000010", x"00000074");

        --------------------------------------------------
        -- BGEU UNSIGNED
        --------------------------------------------------

        step("BGEU unsigned FFFFFFFF greater than 1",
             BGEU_INST, x"FFFFFFFF", x"00000001",
             x"00000010", x"00000084");

        step("BGEU unsigned 1 less than FFFFFFFF",
             BGEU_INST, x"00000001", x"FFFFFFFF",
             x"00000010", x"00000088");

        --------------------------------------------------
        -- JAL
        --------------------------------------------------

        step("JAL forward 32 bytes",
             JAL_INST, x"00000000", x"00000000",
             x"00000020", x"000000A8");

        step("JAL backward 16 bytes",
             JAL_INST, x"00000000", x"00000000",
             x"FFFFFFF0", x"00000098");

        --------------------------------------------------
        -- JALR
        --------------------------------------------------

        step("JALR base 100 offset 8",
             JALR_INST, x"00000100", x"00000000",
             x"00000008", x"00000108");

        step("JALR clears bit zero",
             JALR_INST, x"00000101", x"00000000",
             x"00000004", x"00000104");

        --------------------------------------------------
        -- RESET AFTER JUMPS
        --------------------------------------------------

        reset_pc("Reset after jumps");

        --------------------------------------------------
        -- CONSECUTIVE PC INCREMENTS
        --------------------------------------------------

        step("Sequential after reset 1",
             NORMAL_INST, x"00000000", x"00000000",
             x"00000000", x"00000004");

        step("Sequential after reset 2",
             NORMAL_INST, x"00000000", x"00000000",
             x"00000000", x"00000008");

        step("Sequential after reset 3",
             NORMAL_INST, x"00000000", x"00000000",
             x"00000000", x"0000000C");

        --------------------------------------------------
        -- FINISH
        --------------------------------------------------

        report "All " & integer'image(test_count) &
               " Fetch Module test cases completed."
            severity note;

        wait;

    end process;

end Behavioral;
