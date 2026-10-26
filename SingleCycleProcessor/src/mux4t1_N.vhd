library IEEE;
use IEEE.std_logic_1164.all;

entity mux4t1_N is
    generic(N : integer := 16);
    port(
        i_S  : in std_logic_vector(1 downto 0);
        i_D0 : in std_logic_vector(N-1 downto 0);
        i_D1 : in std_logic_vector(N-1 downto 0);
        i_D2 : in std_logic_vector(N-1 downto 0);
        i_D3 : in std_logic_vector(N-1 downto 0);
        o_O  : out std_logic_vector(N-1 downto 0)
    );
end mux4t1_N;

architecture structural of mux4t1_N is

    component mux2t1_N is
        generic(N : integer := 16);
        port(
            i_S  : in std_logic;
            i_D0 : in std_logic_vector(N-1 downto 0);
            i_D1 : in std_logic_vector(N-1 downto 0);
            o_O  : out std_logic_vector(N-1 downto 0)
        );
    end component;

    signal s_oneToFinal, s_twoToFinal : std_logic_vector(N-1 downto 0);

begin

    mux1 : mux2t1_N
        generic map(N => N)
        port map(
            i_S  => i_S(0),
            i_D0 => i_D0,
            i_D1 => i_D1,
            o_O  => s_oneToFinal
        );

    mux2 : mux2t1_N
        generic map(N => N)
        port map(
            i_S  => i_S(0),
            i_D0 => i_D2,
            i_D1 => i_D3,
            o_O  => s_twoToFinal
        );

    finalmux : mux2t1_N
        generic map(N => N)
        port map(
            i_S  => i_S(1),
            i_D0 => s_oneToFinal,
            i_D1 => s_twoToFinal,
            o_O  => o_O
        );

end structural;