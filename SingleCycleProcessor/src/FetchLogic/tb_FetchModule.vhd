
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_FetchModule is
end tb_FetchModule;

architecture Behavioral of tb_FetchModule is

    constant PC_BASE : std_logic_vector(31 downto 0) := x"00400000";

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

    -- Instruction values used for opcode and funct3 decoding.
    -- Branch/jump offsets are supplied through pc_addr_imm.
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
            i_rs1_data    => i_rs1_data,
            i_rs2_data    => i_rs2_data,
            i_instruction => i_instruction,
            pc_addr_imm   => pc_addr_imm,
            CLK           => CLK,
            reset         => reset,
            o_pc          => o_pc,
            o_pc_plus4    => o_pc_plus4,
            o_pc_plus_imm => o_pc_plus_imm
        );

    P_TEST : process

        variable test_count : integer := 0;
        variable error_count : integer := 0;

        -- Check actual absolute PC values.
        procedure check_pc (
            constant test_name : in string;
            constant expected_pc : in std_logic_vector(31 downto 0)
        ) is
            variable expected_plus4 : std_logic_vector(31 downto 0);
        begin
            wait for 2 ns;

            expected_plus4 :=
                std_logic_vector(unsigned(expected_pc) + 4);

            if o_pc /= expected_pc then
                error_count := error_count + 1;
                assert false
                    report "FAILED: " & test_name & " (PC)"
                    severity error;
            end if;

            if o_pc_plus4 /= expected_plus4 then
                error_count := error_count + 1;
                assert false
                    report "FAILED: " & test_name & " (PC+4)"
                    severity error;
            end if;

            test_count := test_count + 1;

            report "Completed test " & integer'image(test_count) &
                   ": " & test_name
                severity note;
        end procedure;

        -- Apply instruction and advance one clock cycle.
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

        -- Reset should restore PC to 0x00400000.
        procedure reset_pc (
            constant test_name : in string
        ) is
        begin
            CLK <= '0';
            reset <= '1';

            wait for 5 ns;

            CLK <= '1';
            wait for 5 ns;

            check_pc(test_name, PC_BASE);

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
             x"00000000", x"00400004");

        step("PC 4 to 8",
             NORMAL_INST, x"00000000", x"00000000",
             x"00000000", x"00400008");

        step("PC 8 to 12",
             NORMAL_INST, x"00000000", x"00000000",
             x"00000000", x"0040000C");

        step("PC 12 to 16",
             NORMAL_INST, x"00000000", x"00000000",
             x"00000000", x"00400010");

        --------------------------------------------------
        -- BEQ
        --------------------------------------------------

        step("BEQ equal taken",
             BEQ_INST, x"00000005", x"00000005",
             x"00000010", x"00400020");

        step("BEQ not equal",
             BEQ_INST, x"00000005", x"00000006",
             x"00000010", x"00400024");

        --------------------------------------------------
        -- BNE
        --------------------------------------------------

        step("BNE different taken",
             BNE_INST, x"00000005", x"00000006",
             x"00000010", x"00400034");

        step("BNE equal not taken",
             BNE_INST, x"00000005", x"00000005",
             x"00000010", x"00400038");

        --------------------------------------------------
        -- BLT SIGNED
        --------------------------------------------------

        step("BLT negative less than positive",
             BLT_INST, x"FFFFFFFF", x"00000001",
             x"00000010", x"00400048");

        step("BLT positive not less than negative",
             BLT_INST, x"00000001", x"FFFFFFFF",
             x"00000010", x"0040004C");

        --------------------------------------------------
        -- BGE SIGNED
        --------------------------------------------------

        step("BGE positive greater than negative",
             BGE_INST, x"00000001", x"FFFFFFFF",
             x"00000010", x"0040005C");

        step("BGE negative less than positive",
             BGE_INST, x"FFFFFFFF", x"00000001",
             x"00000010", x"00400060");

        --------------------------------------------------
        -- BLTU UNSIGNED
        --------------------------------------------------

        step("BLTU unsigned 1 less than FFFFFFFF",
             BLTU_INST, x"00000001", x"FFFFFFFF",
             x"00000010", x"00400070");

        step("BLTU unsigned FFFFFFFF not less than 1",
             BLTU_INST, x"FFFFFFFF", x"00000001",
             x"00000010", x"00400074");

        --------------------------------------------------
        -- BGEU UNSIGNED
        --------------------------------------------------

        step("BGEU unsigned FFFFFFFF greater than 1",
             BGEU_INST, x"FFFFFFFF", x"00000001",
             x"00000010", x"00400084");

        step("BGEU unsigned 1 less than FFFFFFFF",
             BGEU_INST, x"00000001", x"FFFFFFFF",
             x"00000010", x"00400088");

        --------------------------------------------------
        -- JAL
        --------------------------------------------------

        step("JAL forward 32 bytes",
             JAL_INST, x"00000000", x"00000000",
             x"00000020", x"004000A8");

        step("JAL backward 16 bytes",
             JAL_INST, x"00000000", x"00000000",
             x"FFFFFFF0", x"00400098");

        --------------------------------------------------
        -- JALR
        -- Absolute targets: no PC_BASE added.
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
             x"00000000", x"00400004");

        step("Sequential after reset 2",
             NORMAL_INST, x"00000000", x"00000000",
             x"00000000", x"00400008");

        step("Sequential after reset 3",
             NORMAL_INST, x"00000000", x"00000000",
             x"00000000", x"0040000C");

        --------------------------------------------------
        -- FINISH
        --------------------------------------------------

        report "All " & integer'image(test_count) &
               " Fetch Module test cases completed."
            severity note;

        if error_count = 0 then
            report "PASS: All 25 Fetch Module tests passed."
                severity note;
        else
            assert false
                report "FAIL: " & integer'image(error_count) &
                       " assertion checks failed."
                severity error;
        end if;

        wait;

    end process;

end Behavioral;
