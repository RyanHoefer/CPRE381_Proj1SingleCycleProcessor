library IEEE;
use IEEE.std_logic_1164.all;

entity NBitAdder is
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
end NBitAdder;

architecture structural of NBitAdder is

    component FullAdder
        port(
            i_A    : in  std_logic;
            i_B    : in  std_logic;
            i_Cin  : in  std_logic;
            o_Sum  : out std_logic;
            o_Cout : out std_logic
        );
    end component;

    signal s_Carry : std_logic_vector(N downto 0);

begin

    -- Initial carry-in
    s_Carry(0) <= i_Cin;

    -- Create N full adders
    g_Adders: for i in 0 to N-1 generate

        g_FullAdder: FullAdder
            port map(
                i_A    => i_A(i),
                i_B    => i_B(i),
                i_Cin  => s_Carry(i),
                o_Sum  => o_Sum(i),
                o_Cout => s_Carry(i+1)
            );

    end generate;

    -- Final carry-out
    o_Cout <= s_Carry(N);

end structural;