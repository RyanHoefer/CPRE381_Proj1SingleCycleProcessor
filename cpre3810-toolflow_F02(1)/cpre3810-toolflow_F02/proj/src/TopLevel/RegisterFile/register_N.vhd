-- library declaration
library IEEE;
use IEEE.std_logic_1164.all;

-- entity
entity register_N is
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    Port (  REG_IN : in std_logic_vector(N-1 downto 0);
            LD,CLK,RST : in std_logic;
            REG_OUT : out std_logic_vector(N-1 downto 0));
end register_N;
-- architecture
architecture dataflow of register_N is
component dffg is

   port(i_CLK        : in std_logic;     -- Clock input
       i_RST        : in std_logic;     -- Reset input
       i_WE         : in std_logic;     -- Write enable input
       i_D          : in std_logic;     -- Data value input
       o_Q          : out std_logic);   -- Data value output
end component;
begin
    G_reg_N_Bit: for i in 0 to N-1 generate
    Gdff: dffg port map(
              i_D   => REG_IN(i),  
              o_Q  => REG_OUT(i),  
              i_RST      => RST, 
              i_WE   => LD,
              i_CLK      => CLK);  
  end generate G_reg_N_Bit;
end dataflow;