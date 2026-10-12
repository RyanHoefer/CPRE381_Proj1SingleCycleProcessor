-- library declaration
library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;
-- entity
entity FetchModule is
generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    Port (  i_rs1_data, i_rs2_data : in std_logic_vector(31 downto 0);
            i_instruction : in std_logic_vector(31 downto 0);

            pc_addr_imm	: in std_logic_vector(31 downto 0);

            CLK, reset : in std_logic;

            o_pc : out std_logic_vector(31 downto 0);
            o_pc_plus4 : out std_logic_vector(31 downto 0));

end FetchModule;


architecture structural of FetchModule is
component register_file is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    Port (  REG_IN : in std_logic_vector(N-1 downto 0);
            LD,CLK,RST : in std_logic;
            REG_OUT : out std_logic_vector(N-1 downto 0));
end component;

component adder_N is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(
       i_A          : in std_logic_vector(N-1 downto 0);
       i_B          : in std_logic_vector(N-1 downto 0);
       c_in          : in std_logic;
       s             : out std_logic_vector(N-1 downto 0);
       c_out         : out std_logic);

end component;

   

signal pc_current, pcPlusFour: std_logic_vector(31 downto 0);

signal equal, less_than_unsigned, less_than_signed, branch_condition, branch_taken : std_logic;

begin

--test equality for beq and bne
equal <= '1' when i_rs1_data = i_rs2_data else '0';

-- test if less than signed for bge and blt

less_than_signed <= '1' when signed(i_rs1_data) < signed(i_rs2_data) else '0';

-- test if less than signed for bgeu and bltu

less_than_unsigned <= '1' when unsigned(i_rs1_data) = unsigned(i_rs2_data) else '0';


-- sets the branch signal to the respective branch logic signal output above
with i_instruction(14 downto 12) select 
    branch_condition <=
        equal                 when "000", -- beq
            not equal         when "001", -- bne
            less_signed       when "100", -- blt
            not less_signed   when "101", -- bge
            less_unsigned     when "110", -- bltu
            not less_unsigned when "111", -- bgeu
            '0'               when others;
-- and with the 
branch_taken <= i_branch and branch_condition;



IncrementPCPlusFour : adder_N
    generic map(N => 32)
        port map (  i_A => pc_current,
                    i_B => X"00000004",
                    c_in => '0',
                    s => pcPlusFour,
                    c_out => open);

result <= reg_src;


   
end structural;