library IEEE;
use IEEE.std_logic_1164.all;

entity OnesComp_N is
    generic(
        N : integer := 32
    );
    port(
        i_A : in  std_logic_vector(N-1 downto 0);
        o_F : out std_logic_vector(N-1 downto 0)
    );
end OnesComp_N;

architecture dataflow of OnesComp_N is
begin

-- We use this later for 2's complement calculation
    o_F <= not i_A;

end dataflow;