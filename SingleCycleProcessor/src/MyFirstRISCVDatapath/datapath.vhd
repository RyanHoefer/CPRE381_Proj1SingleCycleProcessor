-- library declaration
library IEEE;
use IEEE.std_logic_1164.all;
-- entity
entity datapath is
generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    Port (  i_r1, i_r2 : in std_logic_vector(4 downto 0);
            i_w : in std_logic_vector(4 downto 0);
            i_imm : in std_logic_vector(31 downto 0);
            i_n_addSub : std_logic;
            i_aluSrc : std_logic;
            CLK : in std_logic;
            i_regwrite : in std_logic;
            result : out std_logic_vector(31 downto 0));

end datapath;
-- architecture
architecture structural of datapath is
component register_file is
generic(N : integer := 32);

  Port (  i_r1, i_r2 : in std_logic_vector(4 downto 0);
            i_w : in std_logic_vector(4 downto 0);
            i_writeData : in std_logic_vector(31 downto 0);
            i_writeEnable : std_logic;
            CLK : in std_logic;
            o_data1 : out std_logic_vector(31 downto 0);
            o_data2 : out std_logic_vector(31 downto 0));
end component;

component addsub_N_with_imm is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(
       i_A           : in std_logic_vector(N-1 downto 0);
       i_B           : in std_logic_vector(N-1 downto 0);
       i_imm         : in std_logic_vector(N-1 downto 0);
       ctl           : in std_logic;
       i_aluSrc      : in std_logic;
       s             : out std_logic_vector(N-1 downto 0);
       c_out         : out std_logic);
end component;

signal writeToRegister_D, read_data1, read_data2: std_logic_vector(31 downto 0);

begin


registerFile : register_file
    generic map(N => N)
    port map (i_r1 => i_r1,
            i_r2 => i_r2,
            i_w => i_w,
            i_writeData => writeToRegister_D,
            i_writeEnable => i_regwrite,
            CLK => CLK,
            o_data1 => read_data1,
            o_data2 => read_data2);

addsub : addsub_N_with_imm
    generic map(N => N)
        port map (  i_A => read_data1,
                    i_B => read_data2,
                    i_imm => i_imm,
                    ctl => i_n_addSub,
                    i_aluSrc => i_aluSrc,
                    s => writeToRegister_D,
                    c_out => open);

result <= writeToRegister_D;

   
end structural;