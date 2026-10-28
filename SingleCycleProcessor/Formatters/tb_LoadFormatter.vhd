
library IEEE;
use IEEE.std_logic_1164.all;
use std.env.all;

entity tb_LoadFormatter is
    generic (
        gCLK_HPER : time := 10 ns;
        DATA_WIDTH : integer := 32
    );
end tb_LoadFormatter;

architecture mixed of tb_LoadFormatter is

    component LoadFormatter is
         port(
        i_memData    : in std_logic_vector(31 downto 0);
        i_addr       : in std_logic_vector(1 downto 0);
        i_dataSize   : in std_logic_vector(1 downto 0);
        i_sign       : in std_logic;
        o_loadData   : out std_logic_vector(31 downto 0)
    );
    end component;

    signal CLK : std_logic := '0';

    signal memData : std_logic_vector(31 downto 0)
                        := (others => '0');


       signal addr       : std_logic_vector(1 downto 0);
       signal dataSize   : std_logic_vector(1 downto 0);
       signal s_sign       : std_logic;
      signal  loadData   : std_logic_vector(31 downto 0);

begin

    DUT: entity work.LoadFormatter
        port map (
            i_memData    => memData,
            i_addr         => addr,
            i_dataSize    => dataSize,
            i_sign         => s_sign,
            o_loadData     => loadData
           
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

        procedure check_data (
            constant test_name : in string;
            constant c_memData     : in std_logic_vector(31 downto 0);
            constant c_addr     : in std_logic_vector(1 downto 0);
            constant c_dataSize     : in std_logic_vector(1 downto 0);
            constant c_sign     : in std_logic;
            constant c_loadData     : in std_logic_vector(31 downto 0)
            
        ) is
        begin

            memData <= c_memData;
            addr <= c_addr;
            dataSize <= c_dataSize;
            s_sign <= c_sign;
            wait for gCLK_HPER * 2;

            assert loadData = c_loadData
                report test_name & ": Load Data incorrect"
                severity error;
            report "Completed test: " & test_name
                severity note;

        end procedure;

    begin

        wait for gCLK_HPER / 2;

        --------------------------------------------------
        -- Load Full Word
        --------------------------------------------------

         
        check_data(
            "Load Full Word from mem", x"00000001",
            "00", "00", '0', x"00000001"
        );

        check_data(
            "Load Full Word from mem max", x"FFFFFFFF",
            "00", "00", '0', x"FFFFFFFF"
        );

        --------------------------------------------------
        -- LBU 
        --------------------------------------------------

         
        check_data(
            "LBU byte 0", x"807FFF01",
            "00", "10", '0', x"00000001"
        );

        check_data(
            "LBU byte 1", x"807FFF01",
            "01", "10", '0', x"000000FF"
        );

        check_data(
            "LBU byte 2", x"807FFF01",
            "10", "10", '0', x"0000007F"
        );

        check_data(
            "LBU byte 3", x"807FFF01",
            "11", "10", '0', x"00000080"
        );

        --------------------------------------------------
        -- LOAD BYTE SIGNED
        -- dataSize = 10, sign = 1
        --------------------------------------------------

        check_data(
            "LB byte 0 ", x"807FFF01",
            "00", "10", '1', x"00000001"
        );

        check_data(
            "LB byte 1 ", x"807FFF01",
            "01", "10", '1', x"FFFFFFFF"
        );

        check_data(
            "LB byte 2 ", x"807FFF01",
            "10", "10", '1', x"0000007F"
        );

        check_data(
            "LB byte 3 ", x"807FFF01",
            "11", "10", '1', x"FFFFFF80"
        );

        --------------------------------------------------
        -- LOAD HALFWORD UNSIGNED
        -- dataSize = 01, sign = 0
        --------------------------------------------------

        check_data(
            "LHU lower half", x"8001FFFF",
            "00", "01", '0', x"0000FFFF"
        );

        check_data(
            "LHU upper half", x"8001FFFF",
            "10", "01", '0', x"00008001"
        );

         --------------------------------------------------
        -- LOAD HALFWORD SIGNED
        -- dataSize = 01, sign = 1
        --------------------------------------------------

        check_data(
            "13 LH lower half negative", x"8001FFFF",
            "00", "01", '1', x"FFFFFFFF"
        );

        check_data(
            "14 LH upper half negative", x"8001FFFF",
            "10", "01", '1', x"FFFF8001"
        );

        check_data(
            "15 LH lower half maximum positive", x"80007FFF",
            "00", "01", '1', x"00007FFF"
        );

        check_data(
            "16 LH upper half minimum negative", x"80007FFF",
            "10", "01", '1', x"FFFF8000"
        );

        -- The word's sign bit must not determine the
        -- sign extension of the selected lower halfword.
        check_data(
            "17 LH lower half positive", x"FFFF0001",
            "00", "01", '1', x"00000001"
        );

        -- The selected upper halfword has its own sign bit.
        check_data(
            "18 LH upper half positive", x"0001FFFF",
            "10", "01", '1', x"00000001"
        );

       
       


    


        --------------------------------------------------
        -- END OF TESTING
        --------------------------------------------------

        report "All 2 test cases completed."
            severity note;

        finish;

        wait;

    end process;

end mixed;
