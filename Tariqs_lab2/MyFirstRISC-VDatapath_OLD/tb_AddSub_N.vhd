library IEEE;
use IEEE.std_logic_1164.all;

entity tb_AddSub_N is
end tb_AddSub_N;

architecture behavior of tb_AddSub_N is

    signal s_A      : std_logic_vector(31 downto 0);
    signal s_B      : std_logic_vector(31 downto 0);
    signal s_AddSub : std_logic;
    signal s_Result : std_logic_vector(31 downto 0);
    signal s_Cout   : std_logic;

begin

    DUT : entity work.AddSub_N
        generic map(
            N => 32
        )
        port map(
            i_A      => s_A,
            i_B      => s_B,
            nAdd_Sub => s_AddSub,
            o_Result => s_Result,
            o_Cout   => s_Cout
        );

    process
    begin

        -- 5 + 3 = 8
        s_A      <= x"00000005";
        s_B      <= x"00000003";
        s_AddSub <= '0';
        wait for 10 ns;

        -- 5 - 3 = 2
        s_AddSub <= '1';
        wait for 10 ns;

        wait;
    end process;

end behavior;