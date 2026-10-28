
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_barrelShifter is
end tb_barrelShifter;

architecture Behavioral of tb_barrelShifter is

    signal i_A     : std_logic_vector(31 downto 0) := (others => '0');
    signal i_amt   : std_logic_vector(4 downto 0) := (others => '0');
    signal i_dir   : std_logic := '0';
    signal i_arith : std_logic := '0';

    signal result  : std_logic_vector(31 downto 0);

begin

    DUT: entity work.barrelShifter
        port map (
            i_A     => i_A,
            i_amt   => i_amt,
            i_dir   => i_dir,
            i_arith => i_arith,
            result  => result
        );

    P_TEST: process

        -- Taria: Added automatic checks so we can
        -- find which shift operation fails.

        procedure check_shift (
            constant test_name  : in string;
            constant input_val  : in std_logic_vector(31 downto 0);
            constant amount     : in natural;
            constant direction  : in std_logic;
            constant arithmetic : in std_logic;
            constant expected   : in std_logic_vector(31 downto 0)
        ) is
        begin

            i_A     <= input_val;
            i_amt   <= std_logic_vector(to_unsigned(amount, 5));
            i_dir   <= direction;
            i_arith <= arithmetic;

            wait for 20 ns;

            assert result = expected
                report "FAILED: " & test_name
                severity error;

            report "Completed test: " & test_name
                severity note;

        end procedure;

    begin

        --------------------------------------------------
        -- SHIFT BY ZERO
        --------------------------------------------------

        check_shift(
            "1 SRL shift by 0",
            x"12345678", 0, '0', '0', x"12345678"
        );

        check_shift(
            "2 SLL shift by 0",
            x"12345678", 0, '1', '0', x"12345678"
        );

        check_shift(
            "3 SRA shift by 0",
            x"87654321", 0, '0', '1', x"87654321"
        );

        --------------------------------------------------
        -- LOGICAL LEFT SHIFTS
        --------------------------------------------------

        check_shift(
            "4 SLL by 1",
            x"00000001", 1, '1', '0', x"00000002"
        );

        check_shift(
            "5 SLL by 2",
            x"00000001", 2, '1', '0', x"00000004"
        );

        check_shift(
            "6 SLL by 4",
            x"00000001", 4, '1', '0', x"00000010"
        );

        check_shift(
            "7 SLL by 8",
            x"00000001", 8, '1', '0', x"00000100"
        );

        check_shift(
            "8 SLL by 16",
            x"00000001", 16, '1', '0', x"00010000"
        );

        check_shift(
            "9 SLL by 31",
            x"00000001", 31, '1', '0', x"80000000"
        );

        check_shift(
            "10 SLL overflow",
            x"80000000", 1, '1', '0', x"00000000"
        );

        --------------------------------------------------
        -- LOGICAL RIGHT SHIFTS
        --------------------------------------------------

        check_shift(
            "11 SRL by 1",
            x"00000010", 1, '0', '0', x"00000008"
        );

        check_shift(
            "12 SRL by 2",
            x"00000010", 2, '0', '0', x"00000004"
        );

        check_shift(
            "13 SRL by 4",
            x"00000100", 4, '0', '0', x"00000010"
        );

        check_shift(
            "14 SRL by 8",
            x"00010000", 8, '0', '0', x"00000100"
        );

        check_shift(
            "15 SRL by 16",
            x"00010000", 16, '0', '0', x"00000001"
        );

        check_shift(
            "16 SRL by 31",
            x"80000000", 31, '0', '0', x"00000001"
        );

        check_shift(
            "17 SRL zero fill",
            x"F0000000", 4, '0', '0', x"0F000000"
        );

        --------------------------------------------------
        -- ARITHMETIC RIGHT SHIFTS
        --------------------------------------------------

        check_shift(
            "18 SRA negative by 1",
            x"80000000", 1, '0', '1', x"C0000000"
        );

        check_shift(
            "19 SRA negative by 2",
            x"80000000", 2, '0', '1', x"E0000000"
        );

        check_shift(
            "20 SRA negative by 4",
            x"80000000", 4, '0', '1', x"F8000000"
        );

        check_shift(
            "21 SRA negative by 8",
            x"80000000", 8, '0', '1', x"FF800000"
        );

        check_shift(
            "22 SRA negative by 16",
            x"80000000", 16, '0', '1', x"FFFF8000"
        );

        check_shift(
            "23 SRA negative by 31",
            x"80000000", 31, '0', '1', x"FFFFFFFF"
        );

        check_shift(
            "24 SRA positive by 1",
            x"40000000", 1, '0', '1', x"20000000"
        );

        check_shift(
            "25 SRA negative one",
            x"FFFFFFFF", 8, '0', '1', x"FFFFFFFF"
        );

        --------------------------------------------------
        -- MIXED SHIFT AMOUNTS
        --------------------------------------------------

        check_shift(
            "26 SLL by 3",
            x"00000003", 3, '1', '0', x"00000018"
        );

        check_shift(
            "27 SRL by 5",
            x"00000400", 5, '0', '0', x"00000020"
        );

        check_shift(
            "28 SRA by 7",
            x"80000000", 7, '0', '1', x"FF000000"
        );

        check_shift(
            "29 SLL by 13",
            x"00000001", 13, '1', '0', x"00002000"
        );

        check_shift(
            "30 SRL by 24",
            x"FF000000", 24, '0', '0', x"000000FF"
        );

        --------------------------------------------------
        -- CONTROL TRANSITION TESTS
        --------------------------------------------------

        check_shift(
            "31 SRL after SRA",
            x"80000000", 1, '0', '0', x"40000000"
        );

        check_shift(
            "32 SLL after SRL",
            x"00000001", 4, '1', '0', x"00000010"
        );

        check_shift(
            "33 SRA after SLL",
            x"F0000000", 4, '0', '1', x"FF000000"
        );

        --------------------------------------------------
        -- END OF TESTING
        --------------------------------------------------

        report "All 33 barrel shifter test cases completed."
            severity note;

        wait;

    end process;

end Behavioral;
