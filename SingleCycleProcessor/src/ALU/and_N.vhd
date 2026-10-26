library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity and_N is

  generic (N : positive := 32);
    port (
        i_A : in  std_logic_vector(N-1 downto 0);
        i_B : in  std_logic_vector(N-1 downto 0);
        o_F : out std_logic_vector(N-1 downto 0)
    );

end and_N;

architecture structural of and_N is

    component andg2 
        port (i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
    end component;


begin
    generateAND : for i in 0 to N-1 generate
        bitAND : andg2
            port map (
                i_A => i_A(i),
                i_B => i_B(i),
                o_F => o_F(i)
            );
    end generate generateAND;
end structural;
