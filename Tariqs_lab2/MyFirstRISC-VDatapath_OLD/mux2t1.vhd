library IEEE;
use IEEE.std_logic_1164.all;

entity mux2t1 is
    port(
        i_D0 : in  std_logic;
        i_D1 : in  std_logic;
        i_S  : in  std_logic;
        o_O  : out std_logic
    );
end mux2t1;

architecture structure of mux2t1 is

    component invg
        port(
            i_A : in  std_logic;
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

    signal s_NotS : std_logic;
    signal s_A0   : std_logic;
    signal s_A1   : std_logic;

begin

    g_Not: invg
        port map(
            i_A => i_S,
            o_F => s_NotS
        );

    g_And0: andg2
        port map(
            i_A => i_D0,
            i_B => s_NotS,
            o_F => s_A0
        );

    g_And1: andg2
        port map(
            i_A => i_D1,
            i_B => i_S,
            o_F => s_A1
        );

    g_Or: org2
        port map(
            i_A => s_A0,
            i_B => s_A1,
            o_F => o_O
        );

end structure;