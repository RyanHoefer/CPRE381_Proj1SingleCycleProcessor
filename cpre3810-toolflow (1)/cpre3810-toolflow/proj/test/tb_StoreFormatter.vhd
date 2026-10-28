library IEEE;
use IEEE.std_logic_1164.all;
use std.env.all;

entity tb_StoreFormatter is
    generic(
        gCLK_HPER : time := 10 ns;
        DATA_WIDTH : integer := 32
    );
end tb_StoreFormatter;

architecture mixed of tb_StoreFormatter is

    component StoreFormatter is
        port(
            i_rs2Data    : in std_logic_vector(31 downto 0);
            i_addr       : in std_logic_vector(1 downto 0);
            i_dataSize   : in std_logic_vector(1 downto 0);
            o_storeData  : out std_logic_vector(31 downto 0);
            o_byteEnable : out std_logic_vector(3 downto 0)
        );
    end component;

    signal CLK : std_logic := '0';

    signal rs2Data : std_logic_vector(31 downto 0)
                     := (others => '0');

    signal addr : std_logic_vector(1 downto 0)
                  := (others => '0');

    signal dataSize : std_logic_vector(1 downto 0)
                      := (others => '0');

    signal storeData  : std_logic_vector(31 downto 0);
    signal byteEnable : std_logic_vector(3 downto 0);

begin

    DUT: StoreFormatter
        port map(
            i_rs2Data    => rs2Data,
            i_addr       => addr,
            i_dataSize   => dataSize,
            o_storeData  => storeData,
            o_byteEnable => byteEnable
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

        -- Apply register data and store controls.
        -- Check positioned data and enabled byte lanes.
        procedure check_data(
            constant test_name    : in string;
            constant c_rs2Data    : in std_logic_vector(31 downto 0);
            constant c_addr       : in std_logic_vector(1 downto 0);
            constant c_dataSize   : in std_logic_vector(1 downto 0);
            constant c_storeData  : in std_logic_vector(31 downto 0);
            constant c_byteEnable : in std_logic_vector(3 downto 0)
        ) is
        begin

            rs2Data <= c_rs2Data;
            addr <= c_addr;
            dataSize <= c_dataSize;

            wait for gCLK_HPER * 2;

            assert storeData = c_storeData
                report test_name & ": Store Data incorrect"
                severity error;

            assert byteEnable = c_byteEnable
                report test_name & ": Byte Enable incorrect"
                severity error;

            report "Completed test: " & test_name
                severity note;

        end procedure;

    begin

        wait for gCLK_HPER / 2;

        --------------------------------------------------
        -- store full word
        --------------------------------------------------

        check_data(
            "1 SW full word", x"00000001",
            "00", "00", x"00000001", "1111"
        );

        check_data(
            "2 SW all ones", x"FFFFFFFF",
            "00", "00", x"FFFFFFFF", "1111"
        );

        --------------------------------------------------
        -- SB
        --------------------------------------------------

        check_data(
            "3 SB byte lane 0", x"A1B2C3D4",
            "00", "10", x"000000D4", "0001"
        );

        check_data(
            "4 SB byte lane 1", x"A1B2C3D4",
            "01", "10", x"0000D400", "0010"
        );

        check_data(
            "5 SB byte lane 2", x"A1B2C3D4",
            "10", "10", x"00D40000", "0100"
        );

        check_data(
            "6 SB byte lane 3", x"A1B2C3D4",
            "11", "10", x"D4000000", "1000"
        );

        --------------------------------------------------
        -- SH
        --------------------------------------------------

        check_data(
            "7 SH lower half", x"A1B2C3D4",
            "00", "01", x"0000C3D4", "0011"
        );

        check_data(
            "8 SH upper half", x"A1B2C3D4",
            "10", "01", x"C3D40000", "1100"
        );

        --------------------------------------------------
        -- END OF TESTING
        --------------------------------------------------

        report "All 8 test cases completed."
            severity note;

        finish;
        wait;

    end process;

end mixed;