library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_FetchModule is
end tb_FetchModule;

architecture Behavioral of tb_FetchModule is

    signal s_CLK          : std_logic := '0';
    signal s_reset        : std_logic := '1';
    signal s_rs1_data     : std_logic_vector(31 downto 0) := (others => '0');
    signal s_rs2_data     : std_logic_vector(31 downto 0) := (others => '0');
    signal s_instruction  : std_logic_vector(31 downto 0) := x"00000013";
    signal s_pc_addr_imm  : std_logic_vector(31 downto 0) := (others => '0');
    signal s_pc           : std_logic_vector(31 downto 0);
    signal s_pc_plus4     : std_logic_vector(31 downto 0);

begin

    DUT: entity work.FetchModule
        port map (
            i_rs1_data   => s_rs1_data,
            i_rs2_data   => s_rs2_data,
            i_instruction => s_instruction,
            pc_addr_imm  => s_pc_addr_imm,
            CLK          => s_CLK,
            reset        => s_reset,
            o_pc         => s_pc,
            o_pc_plus4   => s_pc_plus4
        );

    -- Clock period: 10 ns
    s_CLK <= not s_CLK after 5 ns;

    process
    begin
        -- Hold reset through the first rising clock edge
        wait for 12 ns;
        assert s_pc = x"00000000"
            report "Reset PC failed"
            severity error;

        s_reset <= '0';

        wait for 5 ns;
        assert s_pc = x"00000004"
            report "PC should be 4"
            severity error;

        wait for 10 ns;
        assert s_pc = x"00000008"
            report "PC should be 8"
            severity error;

        wait for 10 ns;
        assert s_pc = x"0000000C"
            report "PC should be 12"
            severity error;

        wait for 10 ns;
        assert s_pc = x"00000010"
            report "PC should be 16"
            severity error;

        assert s_pc_plus4 = x"00000014"
            report "PC+4 output incorrect"
            severity error;

        report "FetchModule sequential PC tests passed!"
            severity note;

        wait;
    end process;

end Behavioral;
