library IEEE;
use IEEE.std_logic_1164.all;

entity tb_Extenders is
end tb_Extenders;

architecture behavior of tb_Extenders is

    -- 12-bit input for sign and zero extenders
    signal s_Imm     : std_logic_vector(11 downto 0);
    signal s_SignExt : std_logic_vector(31 downto 0);
    signal s_ZeroExt : std_logic_vector(31 downto 0);

    -- 20-bit input for zero appender
    signal s_Imm20   : std_logic_vector(19 downto 0);
    signal s_ZeroApp : std_logic_vector(31 downto 0);

begin

    --------------------------------------------------
    -- Sign Extender
    --------------------------------------------------
    SIGN_EXT : entity work.SignExtender
        port map (
            i_Imm => s_Imm,
            o_Ext => s_SignExt
        );

    --------------------------------------------------
    -- Zero Extender
    --------------------------------------------------
    ZERO_EXT : entity work.ZeroExtender
        port map (
            i_Imm => s_Imm,
            o_Ext => s_ZeroExt
        );

    --------------------------------------------------
    -- Zero Appender
    --------------------------------------------------
    ZERO_APP : entity work.ZeroAppender
        port map (
            i_Imm => s_Imm20,
            o_Ext => s_ZeroApp
        );

    --------------------------------------------------
    -- Test Process
    --------------------------------------------------
    test_process : process
    begin

        -- Test 1
        s_Imm   <= x"001";
        s_Imm20 <= x"00001";
        wait for 20 ns;

        -- Test 2
        s_Imm   <= x"7FF";
        s_Imm20 <= x"12345";
        wait for 20 ns;

        -- Test 3
        s_Imm   <= x"FFF";
        s_Imm20 <= x"ABCDE";
        wait for 20 ns;

        -- Test 4
        s_Imm   <= x"FDD";
        s_Imm20 <= x"FFFFF";
        wait for 20 ns;

        -- Test 5
        s_Imm   <= x"800";
        s_Imm20 <= x"80000";
        wait for 20 ns;

        wait;

    end process;

end behavior;