library IEEE;
use IEEE.std_logic_1164.all;

entity tb_regfile is
end tb_regfile;

architecture behavior of tb_regfile is

    component regfile is
        port(
            i_CLK    : in  std_logic;
            i_RST    : in  std_logic;
            i_WE     : in  std_logic;
            i_WAddr  : in  std_logic_vector(4 downto 0);
            i_WData  : in  std_logic_vector(31 downto 0);
            i_RAddr1 : in  std_logic_vector(4 downto 0);
            i_RAddr2 : in  std_logic_vector(4 downto 0);
            o_RData1 : out std_logic_vector(31 downto 0);
            o_RData2 : out std_logic_vector(31 downto 0)
        );
    end component;

    signal s_CLK    : std_logic := '0';
    signal s_RST    : std_logic := '0';
    signal s_WE     : std_logic := '0';

    signal s_WAddr  : std_logic_vector(4 downto 0) := "00000";
    signal s_WData  : std_logic_vector(31 downto 0) := (others => '0');

    signal s_RAddr1 : std_logic_vector(4 downto 0) := "00000";
    signal s_RAddr2 : std_logic_vector(4 downto 0) := "00000";

    signal s_RData1 : std_logic_vector(31 downto 0);
    signal s_RData2 : std_logic_vector(31 downto 0);

begin

    DUT : regfile
        port map(
            i_CLK    => s_CLK,
            i_RST    => s_RST,
            i_WE     => s_WE,
            i_WAddr  => s_WAddr,
            i_WData  => s_WData,
            i_RAddr1 => s_RAddr1,
            i_RAddr2 => s_RAddr2,
            o_RData1 => s_RData1,
            o_RData2 => s_RData2
        );

    -- 10 ns clock
    clock_process : process
    begin
        s_CLK <= '0';
        wait for 5 ns;
        s_CLK <= '1';
        wait for 5 ns;
    end process;

    test_process : process
    begin

        -- Reset register file
        s_RST <= '1';
        wait for 10 ns;
        s_RST <= '0';

        -- Write 11111111 into x1
        s_WE    <= '1';
        s_WAddr <= "00001";
        s_WData <= x"11111111";
        wait for 10 ns;

        -- Write 22222222 into x2
        s_WAddr <= "00010";
        s_WData <= x"22222222";
        wait for 10 ns;

        -- Write AAAAAAAA into x5
        s_WAddr <= "00101";
        s_WData <= x"AAAAAAAA";
        wait for 10 ns;

        -- Stop writing
        s_WE <= '0';

        -- Read x1 and x2 simultaneously
        s_RAddr1 <= "00001";
        s_RAddr2 <= "00010";
        wait for 10 ns;

        -- Read x5 and x1 simultaneously
        s_RAddr1 <= "00101";
        s_RAddr2 <= "00001";
        wait for 10 ns;

        -- Attempt to write FFFFFFFF to x0
        s_WE    <= '1';
        s_WAddr <= "00000";
        s_WData <= x"FFFFFFFF";
        wait for 10 ns;

        -- Verify x0 still reads zero
        s_WE     <= '0';
        s_RAddr1 <= "00000";
        s_RAddr2 <= "00101";
        wait for 10 ns;

        wait;
    end process;

end behavior;