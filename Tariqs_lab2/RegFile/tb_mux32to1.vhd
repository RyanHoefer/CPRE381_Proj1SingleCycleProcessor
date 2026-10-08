library IEEE;
use IEEE.std_logic_1164.all;

entity tb_mux32to1 is
end tb_mux32to1;

architecture behavior of tb_mux32to1 is

    component mux32to1 is
        port(
            i_S : in std_logic_vector(4 downto 0);

            i_D0  : in std_logic_vector(31 downto 0);
            i_D1  : in std_logic_vector(31 downto 0);
            i_D2  : in std_logic_vector(31 downto 0);
            i_D3  : in std_logic_vector(31 downto 0);
            i_D4  : in std_logic_vector(31 downto 0);
            i_D5  : in std_logic_vector(31 downto 0);
            i_D6  : in std_logic_vector(31 downto 0);
            i_D7  : in std_logic_vector(31 downto 0);
            i_D8  : in std_logic_vector(31 downto 0);
            i_D9  : in std_logic_vector(31 downto 0);
            i_D10 : in std_logic_vector(31 downto 0);
            i_D11 : in std_logic_vector(31 downto 0);
            i_D12 : in std_logic_vector(31 downto 0);
            i_D13 : in std_logic_vector(31 downto 0);
            i_D14 : in std_logic_vector(31 downto 0);
            i_D15 : in std_logic_vector(31 downto 0);
            i_D16 : in std_logic_vector(31 downto 0);
            i_D17 : in std_logic_vector(31 downto 0);
            i_D18 : in std_logic_vector(31 downto 0);
            i_D19 : in std_logic_vector(31 downto 0);
            i_D20 : in std_logic_vector(31 downto 0);
            i_D21 : in std_logic_vector(31 downto 0);
            i_D22 : in std_logic_vector(31 downto 0);
            i_D23 : in std_logic_vector(31 downto 0);
            i_D24 : in std_logic_vector(31 downto 0);
            i_D25 : in std_logic_vector(31 downto 0);
            i_D26 : in std_logic_vector(31 downto 0);
            i_D27 : in std_logic_vector(31 downto 0);
            i_D28 : in std_logic_vector(31 downto 0);
            i_D29 : in std_logic_vector(31 downto 0);
            i_D30 : in std_logic_vector(31 downto 0);
            i_D31 : in std_logic_vector(31 downto 0);

            o_Q : out std_logic_vector(31 downto 0)
        );
    end component;

    signal s_S : std_logic_vector(4 downto 0) := "00000";
    signal s_Q : std_logic_vector(31 downto 0);

begin

    DUT : mux32to1
        port map(
            i_S => s_S,

            i_D0  => x"00000000",
            i_D1  => x"11111111",
            i_D2  => x"22222222",
            i_D3  => x"33333333",
            i_D4  => x"44444444",
            i_D5  => x"55555555",
            i_D6  => x"66666666",
            i_D7  => x"77777777",
            i_D8  => x"88888888",
            i_D9  => x"99999999",
            i_D10 => x"AAAAAAAA",
            i_D11 => x"BBBBBBBB",
            i_D12 => x"CCCCCCCC",
            i_D13 => x"DDDDDDDD",
            i_D14 => x"EEEEEEEE",
            i_D15 => x"FFFFFFFF",

            i_D16 => x"00000010",
            i_D17 => x"00000011",
            i_D18 => x"00000012",
            i_D19 => x"00000013",
            i_D20 => x"00000014",
            i_D21 => x"00000015",
            i_D22 => x"00000016",
            i_D23 => x"00000017",
            i_D24 => x"00000018",
            i_D25 => x"00000019",
            i_D26 => x"0000001A",
            i_D27 => x"0000001B",
            i_D28 => x"0000001C",
            i_D29 => x"0000001D",
            i_D30 => x"0000001E",
            i_D31 => x"0000001F",

            o_Q => s_Q
        );

    process
    begin
        s_S <= "00000";
        wait for 10 ns;

        s_S <= "00001";
        wait for 10 ns;

        s_S <= "00101";
        wait for 10 ns;

        s_S <= "01010";
        wait for 10 ns;

        s_S <= "01111";
        wait for 10 ns;

        s_S <= "10000";
        wait for 10 ns;

        s_S <= "11111";
        wait for 10 ns;

        wait;
    end process;

end behavior;