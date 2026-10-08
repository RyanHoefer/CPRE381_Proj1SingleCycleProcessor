library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity decoder5to32 is
    port(
        i_D : in  std_logic_vector(4 downto 0);
        o_Q : out std_logic_vector(31 downto 0)
    );
end decoder5to32;

architecture dataflow of decoder5to32 is
begin

    process(i_D)
        variable temp : std_logic_vector(31 downto 0);
    begin
        temp := (others => '0');
        temp(to_integer(unsigned(i_D))) := '1';
        o_Q <= temp;
    end process;

end dataflow;