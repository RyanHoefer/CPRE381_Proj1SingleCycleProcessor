library IEEE;
use IEEE.std_logic_1164.all;

entity AddSub_N is
    generic(
        N : integer := 32
    );
    port(
        i_A      : in  std_logic_vector(N-1 downto 0);
        i_B      : in  std_logic_vector(N-1 downto 0);
        nAdd_Sub : in  std_logic;
        o_Result : out std_logic_vector(N-1 downto 0);
        o_Cout   : out std_logic
    );
end AddSub_N;

architecture structural of AddSub_N is

    component OnesComp_N
        generic(
            N : integer := 32
        );
        port(
            i_A : in  std_logic_vector(N-1 downto 0);
            o_F : out std_logic_vector(N-1 downto 0)
        );
    end component;

    component mux2t1_N
        generic(
            N : integer := 32
        );
        port(
            i_D0 : in  std_logic_vector(N-1 downto 0);
            i_D1 : in  std_logic_vector(N-1 downto 0);
            i_S  : in  std_logic;
            o_O  : out std_logic_vector(N-1 downto 0)
        );
    end component;

    component NBitAdder
        generic(
            N : integer := 32
        );
        port(
            i_A    : in  std_logic_vector(N-1 downto 0);
            i_B    : in  std_logic_vector(N-1 downto 0);
            i_Cin  : in  std_logic;
            o_Sum  : out std_logic_vector(N-1 downto 0);
            o_Cout : out std_logic
        );
    end component;

    signal s_NotB : std_logic_vector(N-1 downto 0);
    signal s_MuxB : std_logic_vector(N-1 downto 0);

begin

    g_InvertB: OnesComp_N
        generic map(
            N => N
        )
        port map(
            i_A => i_B,
            o_F => s_NotB
        );

    g_MuxB: mux2t1_N
        generic map(
            N => N
        )
        port map(
            i_D0 => i_B,
            i_D1 => s_NotB,
            i_S  => nAdd_Sub,
            o_O  => s_MuxB
        );

    g_Adder: NBitAdder
        generic map(
            N => N
        )
        port map(
            i_A    => i_A,
            i_B    => s_MuxB,
            i_Cin  => nAdd_Sub,
            o_Sum  => o_Result,
            o_Cout => o_Cout
        );

end structural;