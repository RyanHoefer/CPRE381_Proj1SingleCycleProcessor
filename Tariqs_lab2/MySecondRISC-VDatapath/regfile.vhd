library IEEE;
use IEEE.std_logic_1164.all;

entity regfile is
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
end regfile;

architecture structural of regfile is

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

    component decoder5to32 is
        port(
            i_D : in  std_logic_vector(4 downto 0);
            o_Q : out std_logic_vector(31 downto 0)
        );
    end component;

    component mux32to1 is
        port(
            i_S : in std_logic_vector(4 downto 0);

            i_D0  : in std_logic_vector(31 downto 0);
            i_D1  : in std_logic_vector(31 downto 0);
            i_D2  : in std_logic_vector(31 downto 0);
            i_D3  : in std_logic_vector(31 downto 0);
            i_D4  : in std_logic_vector(31 downto 0);
            i_D5  : in std_logic_vector(31 downto 0);
            i_D6  : in std_logic_vector(31 downto 0);
            i_D7  : in std_logic_vector(31 downto 0);
            i_D8  : in std_logic_vector(31 downto 0);
            i_D9  : in std_logic_vector(31 downto 0);
            i_D10 : in std_logic_vector(31 downto 0);
            i_D11 : in std_logic_vector(31 downto 0);
            i_D12 : in std_logic_vector(31 downto 0);
            i_D13 : in std_logic_vector(31 downto 0);
            i_D14 : in std_logic_vector(31 downto 0);
            i_D15 : in std_logic_vector(31 downto 0);
            i_D16 : in std_logic_vector(31 downto 0);
            i_D17 : in std_logic_vector(31 downto 0);
            i_D18 : in std_logic_vector(31 downto 0);
            i_D19 : in std_logic_vector(31 downto 0);
            i_D20 : in std_logic_vector(31 downto 0);
            i_D21 : in std_logic_vector(31 downto 0);
            i_D22 : in std_logic_vector(31 downto 0);
            i_D23 : in std_logic_vector(31 downto 0);
            i_D24 : in std_logic_vector(31 downto 0);
            i_D25 : in std_logic_vector(31 downto 0);
            i_D26 : in std_logic_vector(31 downto 0);
            i_D27 : in std_logic_vector(31 downto 0);
            i_D28 : in std_logic_vector(31 downto 0);
            i_D29 : in std_logic_vector(31 downto 0);
            i_D30 : in std_logic_vector(31 downto 0);
            i_D31 : in std_logic_vector(31 downto 0);

            o_Q : out std_logic_vector(31 downto 0)
        );
    end component;

    -- One-hot decoder output
    signal s_Decoded : std_logic_vector(31 downto 0);

    -- Individual register write enables
    signal s_WE : std_logic_vector(31 downto 0);

    -- Outputs of registers x0-x31
    type reg_array is array (0 to 31)
        of std_logic_vector(31 downto 0);

    signal s_Reg : reg_array;

begin

    --------------------------------------------------
    -- Decode destination register
    --------------------------------------------------

    DECODER : decoder5to32
        port map(
            i_D => i_WAddr,
            o_Q => s_Decoded
        );

    --------------------------------------------------
    -- Combine decoder with global write enable
    --------------------------------------------------

    GEN_WE : for i in 0 to 31 generate
        s_WE(i) <= s_Decoded(i) and i_WE;
    end generate;

    --------------------------------------------------
    -- x0 must always contain zero
    --------------------------------------------------

    s_Reg(0) <= (others => '0');

    --------------------------------------------------
    -- Registers x1 through x31
    --------------------------------------------------

    GEN_REGS : for i in 1 to 31 generate

        REG_I : register_N
            generic map(
                N => 32
            )
            port map(
                i_CLK => i_CLK,
                i_RST => i_RST,
                i_WE  => s_WE(i),
                i_D   => i_WData,
                o_Q   => s_Reg(i)
            );

    end generate GEN_REGS;

    --------------------------------------------------
    -- Read Port 1
    --------------------------------------------------

    READ_MUX1 : mux32to1
        port map(
            i_S => i_RAddr1,

            i_D0  => s_Reg(0),
            i_D1  => s_Reg(1),
            i_D2  => s_Reg(2),
            i_D3  => s_Reg(3),
            i_D4  => s_Reg(4),
            i_D5  => s_Reg(5),
            i_D6  => s_Reg(6),
            i_D7  => s_Reg(7),
            i_D8  => s_Reg(8),
            i_D9  => s_Reg(9),
            i_D10 => s_Reg(10),
            i_D11 => s_Reg(11),
            i_D12 => s_Reg(12),
            i_D13 => s_Reg(13),
            i_D14 => s_Reg(14),
            i_D15 => s_Reg(15),
            i_D16 => s_Reg(16),
            i_D17 => s_Reg(17),
            i_D18 => s_Reg(18),
            i_D19 => s_Reg(19),
            i_D20 => s_Reg(20),
            i_D21 => s_Reg(21),
            i_D22 => s_Reg(22),
            i_D23 => s_Reg(23),
            i_D24 => s_Reg(24),
            i_D25 => s_Reg(25),
            i_D26 => s_Reg(26),
            i_D27 => s_Reg(27),
            i_D28 => s_Reg(28),
            i_D29 => s_Reg(29),
            i_D30 => s_Reg(30),
            i_D31 => s_Reg(31),

            o_Q => o_RData1
        );

    --------------------------------------------------
    -- Read Port 2
    --------------------------------------------------

    READ_MUX2 : mux32to1
        port map(
            i_S => i_RAddr2,

            i_D0  => s_Reg(0),
            i_D1  => s_Reg(1),
            i_D2  => s_Reg(2),
            i_D3  => s_Reg(3),
            i_D4  => s_Reg(4),
            i_D5  => s_Reg(5),
            i_D6  => s_Reg(6),
            i_D7  => s_Reg(7),
            i_D8  => s_Reg(8),
            i_D9  => s_Reg(9),
            i_D10 => s_Reg(10),
            i_D11 => s_Reg(11),
            i_D12 => s_Reg(12),
            i_D13 => s_Reg(13),
            i_D14 => s_Reg(14),
            i_D15 => s_Reg(15),
            i_D16 => s_Reg(16),
            i_D17 => s_Reg(17),
            i_D18 => s_Reg(18),
            i_D19 => s_Reg(19),
            i_D20 => s_Reg(20),
            i_D21 => s_Reg(21),
            i_D22 => s_Reg(22),
            i_D23 => s_Reg(23),
            i_D24 => s_Reg(24),
            i_D25 => s_Reg(25),
            i_D26 => s_Reg(26),
            i_D27 => s_Reg(27),
            i_D28 => s_Reg(28),
            i_D29 => s_Reg(29),
            i_D30 => s_Reg(30),
            i_D31 => s_Reg(31),

            o_Q => o_RData2
        );

end structural;