library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity or_N is

  generic (N : positive := 32);
    port (
        i_A : in  std_logic_vector(N-1 downto 0);
        i_B : in  std_logic_vector(N-1 downto 0);
        o_F : out std_logic_vector(N-1 downto 0)
    );

end or_N;

architecture structural of or_N is

    component org2 
        port (i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
    end component;


begin
    generateOR : for i in 0 to N-1 generate
        bitOR: org2
            port map (
                i_A => i_A(i),
                i_B => i_B(i),
                o_F => o_F(i)
            );
    end generate generateOR;
end structural;
