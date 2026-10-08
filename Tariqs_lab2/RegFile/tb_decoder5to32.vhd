library IEEE;
use IEEE.std_logic_1164.all;

entity tb_decoder5to32 is
end tb_decoder5to32;

architecture behavior of tb_decoder5to32 is

    component decoder5to32 is
        port(
            i_D : in  std_logic_vector(4 downto 0);
            o_Q : out std_logic_vector(31 downto 0)
        );
    end component;

    signal s_D : std_logic_vector(4 downto 0) := "00000";
    signal s_Q : std_logic_vector(31 downto 0);

begin

    DUT : decoder5to32
        port map(
            i_D => s_D,
            o_Q => s_Q
        );

    process
    begin
        s_D <= "00000";
        wait for 10 ns;

        s_D <= "00001";
        wait for 10 ns;

        s_D <= "00010";
        wait for 10 ns;

        s_D <= "00101";
        wait for 10 ns;

        s_D <= "01010";
        wait for 10 ns;

        s_D <= "11111";
        wait for 10 ns;

        wait;
    end process;

end behavior;