library IEEE;
use IEEE.std_logic_1164.all;

entity LoadFormatter is
    port(
        i_memData    : in std_logic_vector(31 downto 0);
        i_addr       : in std_logic_vector(1 downto 0);
        i_dataSize   : in std_logic_vector(1 downto 0);
        i_sign       : in std_logic;
        o_loadData   : out std_logic_vector(31 downto 0)
    );
end LoadFormatter;

architecture structural of LoadFormatter is

    component mux2t1_N is
        generic(N : integer := 16);
        port(
            i_S  : in std_logic;
            i_D0 : in std_logic_vector(N-1 downto 0);
            i_D1 : in std_logic_vector(N-1 downto 0);
            o_O  : out std_logic_vector(N-1 downto 0)
        );
    end component;

    component mux4t1_N is
        generic(N : integer := 16);
        port(
            i_S  : in std_logic_vector(1 downto 0);
            i_D0 : in std_logic_vector(N-1 downto 0);
            i_D1 : in std_logic_vector(N-1 downto 0);
            i_D2 : in std_logic_vector(N-1 downto 0);
            i_D3 : in std_logic_vector(N-1 downto 0);
            o_O  : out std_logic_vector(N-1 downto 0)
        );
    end component;

    component extender_N is
        generic(N : integer := 12);
        port(
            i_A    : in std_logic_vector(N-1 downto 0);
            i_sign : in std_logic;
            o_F    : out std_logic_vector(31 downto 0)
        );
    end component;

    signal s_selectedByte : std_logic_vector(7 downto 0);
    signal s_selectedHalf : std_logic_vector(15 downto 0);

    signal s_extendedByte, s_extendedHalf
        : std_logic_vector(31 downto 0);

begin

    -- Select the addressed byte.
    byteMux : mux4t1_N
        generic map(N => 8)
        port map(
            i_S  => i_addr,
            i_D0 => i_memData(7 downto 0),
            i_D1 => i_memData(15 downto 8),
            i_D2 => i_memData(23 downto 16),
            i_D3 => i_memData(31 downto 24),
            o_O  => s_selectedByte
        );

    -- Select the addressed aligned halfword.
    halfwordMux : mux2t1_N
        generic map(N => 16)
        port map(
            i_S  => i_addr(1),
            i_D0 => i_memData(15 downto 0),
            i_D1 => i_memData(31 downto 16),
            o_O  => s_selectedHalf
        );

    byteExtender : extender_N
        generic map(N => 8)
        port map(
            i_A    => s_selectedByte,
            i_sign => i_sign,
            o_F    => s_extendedByte
        );

    halfExtender : extender_N
        generic map(N => 16)
        port map(
            i_A    => s_selectedHalf,
            i_sign => i_sign,
            o_F    => s_extendedHalf
        );

    -- Select LW, LH/LHU, or LB/LBU result.
    selectDataFromMemory : mux4t1_N
        generic map(N => 32)
        port map(
            i_S  => i_dataSize,
            i_D0 => i_memData,
            i_D1 => s_extendedHalf,
            i_D2 => s_extendedByte,
            i_D3 => (others => '0'),
            o_O  => o_loadData
        );

end structural;