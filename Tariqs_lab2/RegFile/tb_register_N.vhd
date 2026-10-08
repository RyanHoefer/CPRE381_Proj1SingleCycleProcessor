library IEEE;
use IEEE.std_logic_1164.all;

entity tb_register_N is
end tb_register_N;

architecture behavior of tb_register_N is

    constant N : integer := 32;

    component register_N is
        generic(
            N : integer := 32
        );
        port(
            i_CLK : in  std_logic;
            i_RST : in  std_logic;
            i_WE  : in  std_logic;
            i_D   : in  std_logic_vector(N-1 downto 0);
            o_Q   : out std_logic_vector(N-1 downto 0)
        );
    end component;

    signal s_CLK : std_logic := '0';
    signal s_RST : std_logic := '0';
    signal s_WE  : std_logic := '0';
    signal s_D   : std_logic_vector(N-1 downto 0) := (others => '0');
    signal s_Q   : std_logic_vector(N-1 downto 0);

begin

    DUT : register_N
        generic map(
            N => N
        )
        port map(
            i_CLK => s_CLK,
            i_RST => s_RST,
            i_WE  => s_WE,
            i_D   => s_D,
            o_Q   => s_Q
        );

    -- 10 ns clock period
    clock_process : process
    begin
        s_CLK <= '0';
        wait for 5 ns;
        s_CLK <= '1';
        wait for 5 ns;
    end process;

    test_process : process
    begin

        -- Reset register
        s_RST <= '1';
        wait for 10 ns;
        s_RST <= '0';

        -- Write first value
        s_WE <= '1';
        s_D <= x"12345678";
        wait for 10 ns;

        -- Write second value
        s_D <= x"ABCDEF12";
        wait for 10 ns;

        -- Disable writing: Q should retain previous value
        s_WE <= '0';
        s_D <= x"FFFFFFFF";
        wait for 10 ns;

        -- Reset again
        s_RST <= '1';
        wait for 10 ns;
        s_RST <= '0';

        wait;
    end process;

end behavior;