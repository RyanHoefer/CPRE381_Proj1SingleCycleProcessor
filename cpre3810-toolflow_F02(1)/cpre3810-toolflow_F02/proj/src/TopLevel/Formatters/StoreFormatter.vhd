library IEEE;
use IEEE.std_logic_1164.all;

entity StoreFormatter is
    port(
        i_rs2Data   : in std_logic_vector(31 downto 0);
        i_addr      : in std_logic_vector(1 downto 0);
        i_dataSize  : in std_logic_vector(1 downto 0);
        o_storeData : out std_logic_vector(31 downto 0);
        o_byteEnable : out std_logic_vector(3 downto 0)
    );
end StoreFormatter;

architecture structural of StoreFormatter is

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

    signal s_storeByte0, s_storeByte1,
           s_storeByte2, s_storeByte3,
           s_storeHalfWord0, s_storeHalfWord1,
           s_selectedByteToStore, s_selectedHalfToStore
        : std_logic_vector(31 downto 0);

    signal s_byteBE, s_halfBE : std_logic_vector(3 downto 0);

begin

    -- Position the lowest register byte in each memory lane.
    s_storeByte0 <= X"000000" & i_rs2Data(7 downto 0);
    s_storeByte1 <= X"0000" & i_rs2Data(7 downto 0) & X"00";
    s_storeByte2 <= X"00" & i_rs2Data(7 downto 0) & X"0000";
    s_storeByte3 <= i_rs2Data(7 downto 0) & X"000000";

    selectByteToStore : mux4t1_N
        generic map(N => 32)
        port map(
            i_S  => i_addr,
            i_D0 => s_storeByte0,
            i_D1 => s_storeByte1,
            i_D2 => s_storeByte2,
            i_D3 => s_storeByte3,
            o_O  => s_selectedByteToStore
        );

    -- Position the lowest register halfword.
    s_storeHalfWord0 <= X"0000" & i_rs2Data(15 downto 0);
    s_storeHalfWord1 <= i_rs2Data(15 downto 0) & X"0000";

    selectHalfwordToStore : mux2t1_N
        generic map(N => 32)
        port map(
            i_S  => i_addr(1),
            i_D0 => s_storeHalfWord0,
            i_D1 => s_storeHalfWord1,
            o_O  => s_selectedHalfToStore
        );

    -- Select SW, SH, or SB data.
    selectDataToStore : mux4t1_N
        generic map(N => 32)
        port map(
            i_S  => i_dataSize,
            i_D0 => i_rs2Data,
            i_D1 => s_selectedHalfToStore,
            i_D2 => s_selectedByteToStore,
            i_D3 => (others => '0'),
            o_O  => o_storeData
        );

    -- Select the enabled byte lane for SB.
    byteEnableMux : mux4t1_N
        generic map(N => 4)
        port map(
            i_S  => i_addr,
            i_D0 => "0001",
            i_D1 => "0010",
            i_D2 => "0100",
            i_D3 => "1000",
            o_O  => s_byteBE
        );

    -- Select the enabled halfword lanes for aligned SH.
    halfEnableMux : mux2t1_N
        generic map(N => 4)
        port map(
            i_S  => i_addr(1),
            i_D0 => "0011",
            i_D1 => "1100",
            o_O  => s_halfBE
        );

    storeSizeEnableMux : mux4t1_N
        generic map(N => 4)
        port map(
            i_S  => i_dataSize,
            i_D0 => "1111",
            i_D1 => s_halfBE,
            i_D2 => s_byteBE,
            i_D3 => "0000",
            o_O  => o_byteEnable
        );

end structural;