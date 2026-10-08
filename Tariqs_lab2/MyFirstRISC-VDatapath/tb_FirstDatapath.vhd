library IEEE;
use IEEE.std_logic_1164.all;

entity tb_FirstDatapath is
end tb_FirstDatapath;

architecture behavior of tb_FirstDatapath is

    component FirstDatapath is
        port(
            i_A       : in  std_logic_vector(31 downto 0);
            i_B       : in  std_logic_vector(31 downto 0);
            i_Imm     : in  std_logic_vector(31 downto 0);
            i_ALUSrc  : in  std_logic;
            i_AddSub  : in  std_logic;
            o_Result  : out std_logic_vector(31 downto 0);
            o_Cout    : out std_logic
        );
    end component;

    signal s_A       : std_logic_vector(31 downto 0);
    signal s_B       : std_logic_vector(31 downto 0);
    signal s_Imm     : std_logic_vector(31 downto 0);
    signal s_ALUSrc  : std_logic;
    signal s_AddSub  : std_logic;
    signal s_Result  : std_logic_vector(31 downto 0);
    signal s_Cout    : std_logic;

begin

    DUT : FirstDatapath
        port map(
            i_A      => s_A,
            i_B      => s_B,
            i_Imm    => s_Imm,
            i_ALUSrc => s_ALUSrc,
            i_AddSub => s_AddSub,
            o_Result => s_Result,
            o_Cout   => s_Cout
        );

    test_process : process
    begin

        ------------------------------------------------
        -- Test 1: Register addition
        -- 5 + 3 = 8
        ------------------------------------------------
        s_A      <= x"00000005";
        s_B      <= x"00000003";
        s_Imm    <= x"0000000A";
        s_ALUSrc <= '0';
        s_AddSub <= '0';
        wait for 10 ns;

        ------------------------------------------------
        -- Test 2: Immediate addition
        -- 5 + 10 = 15 = 0F
        ------------------------------------------------
        s_ALUSrc <= '1';
        s_AddSub <= '0';
        wait for 10 ns;

        ------------------------------------------------
        -- Test 3: Register subtraction
        -- 5 - 3 = 2
        ------------------------------------------------
        s_ALUSrc <= '0';
        s_AddSub <= '1';
        wait for 10 ns;

        ------------------------------------------------
        -- Test 4: Immediate subtraction
        -- 5 - 10 = -5 = FFFFFFFB
        ------------------------------------------------
        s_ALUSrc <= '1';
        s_AddSub <= '1';
        wait for 10 ns;

        wait;
    end process;

end behavior;