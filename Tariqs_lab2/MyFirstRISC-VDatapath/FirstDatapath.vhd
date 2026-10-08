library IEEE;
use IEEE.std_logic_1164.all;

entity FirstDatapath is
    port(
        i_A       : in  std_logic_vector(31 downto 0);
        i_B       : in  std_logic_vector(31 downto 0);
        i_Imm     : in  std_logic_vector(31 downto 0);

        i_ALUSrc  : in  std_logic;
        i_AddSub  : in  std_logic;

        o_Result  : out std_logic_vector(31 downto 0);
        o_Cout    : out std_logic
    );
end FirstDatapath;

architecture structural of FirstDatapath is

    component mux2t1_N is
        generic(
            N : integer := 32
        );
        port(
            i_S  : in  std_logic;
            i_D0 : in  std_logic_vector(N-1 downto 0);
            i_D1 : in  std_logic_vector(N-1 downto 0);
            o_O  : out std_logic_vector(N-1 downto 0)
        );
    end component;

    component AddSub_N is
        generic(
            N : integer := 32
        );
        port(
            i_A      : in  std_logic_vector(N-1 downto 0);
            i_B      : in  std_logic_vector(N-1 downto 0);
            nAdd_Sub : in  std_logic;
            o_Result : out std_logic_vector(N-1 downto 0);
            o_Cout   : out std_logic
        );
    end component;

    signal s_ALU_B : std_logic_vector(31 downto 0);

begin

    --------------------------------------------------
    -- ALUSrc MUX
    -- 0 = use register B
    -- 1 = use immediate
    --------------------------------------------------

    ALUSRC_MUX : mux2t1_N
        generic map(
            N => 32
        )
        port map(
            i_S  => i_ALUSrc,
            i_D0 => i_B,
            i_D1 => i_Imm,
            o_O  => s_ALU_B
        );

    --------------------------------------------------
    -- Adder / Subtractor
    --------------------------------------------------

    ALU : AddSub_N
        generic map(
            N => 32
        )
        port map(
            i_A      => i_A,
            i_B      => s_ALU_B,
            nAdd_Sub => i_AddSub,
            o_Result => o_Result,
            o_Cout   => o_Cout
        );

end structural;