library IEEE;
use IEEE.std_logic_1164.all;

entity FullAdder is
    port(
        i_A    : in  std_logic;
        i_B    : in  std_logic;
        i_Cin  : in  std_logic;
        o_Sum  : out std_logic;
        o_Cout : out std_logic
    );
end FullAdder;

architecture structural of FullAdder is

-- Sum = A xor B xor Cin
-- Cout = (A and B) or (Cin and (A xor B))

    component xorg2
        port(
            i_A : in  std_logic;
            i_B : in  std_logic;
            o_F : out std_logic
        );
    end component;

    component andg2
        port(
            i_A : in  std_logic;
            i_B : in  std_logic;
            o_F : out std_logic
        );
    end component;

    component org2
        port(
            i_A : in  std_logic;
            i_B : in  std_logic;
            o_F : out std_logic
        );
    end component;

    signal s_Xor1 : std_logic;
    signal s_And1 : std_logic;
    signal s_And2 : std_logic;

begin

    g_Xor1: xorg2
        port map(
            i_A => i_A,
            i_B => i_B,
            o_F => s_Xor1
        );

    g_Xor2: xorg2
        port map(
            i_A => s_Xor1,
            i_B => i_Cin,
            o_F => o_Sum
        );

    g_And1: andg2
        port map(
            i_A => i_A,
            i_B => i_B,
            o_F => s_And1
        );

    g_And2: andg2
        port map(
            i_A => s_Xor1,
            i_B => i_Cin,
            o_F => s_And2
        );

    g_Or1: org2
        port map(
            i_A => s_And1,
            i_B => s_And2,
            o_F => o_Cout
        );

end structural;