-- library declaration
library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;
-- entity
entity FetchModule is
generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    Port (  i_rs1_data, i_rs2_data : in std_logic_vector(31 downto 0); -- for branch compares and jal and jalr
            i_instruction : in std_logic_vector(31 downto 0); -- raw instruction form instruction memory of current instruction

            pc_addr_imm	: in std_logic_vector(31 downto 0); -- immediate offset value for jal and jalr

            CLK, reset : in std_logic;

            o_pc : out std_logic_vector(31 downto 0); -- to the instruciton memory for the next instruction
            o_pc_plus4 : out std_logic_vector(31 downto 0);
            o_pc_plus_imm : out std_logic_vector(31 downto 0)); -- to write back to register for jal and jalr

end FetchModule;


architecture structural of FetchModule is
component register_N is
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

   

signal pc_current, pc_next, base_pc, pcPlusFour, base_plus_imm, jalr_clear_zero: std_logic_vector(31 downto 0);

signal equal, less_than_unsigned, less_than_signed, branch_condition, branch_taken : std_logic;

signal branch, jal, jalr : std_logic;

begin

--test equality for beq and bne
equal <= '1' when i_rs1_data = i_rs2_data else '0';

-- test if less than signed for bge and blt

less_than_signed <= '1' when signed(i_rs1_data) < signed(i_rs2_data) else '0';

-- test if less than signed for bgeu and bltu

less_than_unsigned <= '1' when unsigned(i_rs1_data) < unsigned(i_rs2_data) else '0';


branch <= '1'
when i_instruction(6 downto 0) = "1100011"
else '0';

jal <= '1'
when i_instruction(6 downto 0) = "1101111"
else '0';

jalr <= '1'
when i_instruction(6 downto 0) = "1100111"
else '0';




-- sets the branch signal to the respective branch logic signal output above
with i_instruction(14 downto 12) select 
    branch_condition <=
            equal                   when "000", -- beq
            not equal               when "001", -- bne
            less_than_signed             when "100", -- blt
            not less_than_signed         when "101", -- bge
            less_than_unsigned      when "110", -- bltu
            not less_than_unsigned when "111", -- bgeu
            '0'               when others;
-- and gate with the instruction bit that specifies whether the instruction is branch or not 
branch_taken <= branch and branch_condition;


PC : register_N
    generic map(N => 32)
        port map (  REG_IN => pc_next,
                    LD => '1',
                    CLK => CLK,
                    RST => reset,
                    REG_OUT => pc_current);


IncrementPCPlusFour : adder_N
    generic map(N => 32)
        port map (  i_A => pc_current,
                    i_B => X"00000004",
                    c_in => '0',
                    s => pcPlusFour,
                    c_out => open);

base_pc <= i_rs1_data when jalr = '1' else pc_current; -- use rs1 for jalr as a base or keeps the current pc

base_plus_imm <= std_logic_vector(unsigned(base_pc) + unsigned(pc_addr_imm)); -- add the base to the offset imm

jalr_clear_zero <= base_plus_imm(31 downto 1) & '0' when jalr = '1' else base_plus_imm; -- clear bit zero if instruction is jalr 

pc_next <= jalr_clear_zero when jal = '1' or jalr = '1' or branch_taken = '1' else pcPlusFour; -- 

o_pc <= pc_current;
o_pc_plus4 <= pcPlusFour;
o_pc_plus_imm <= base_plus_imm;
   
end structural;