-- library declaration
library IEEE;
use IEEE.std_logic_1164.all;
use work.mux_types.all;
-- entity
entity register_file is
generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    Port (  i_r1, i_r2 : in std_logic_vector(4 downto 0);
            i_w : in std_logic_vector(4 downto 0);
            i_writeData : in std_logic_vector(31 downto 0);
            i_writeEnable : std_logic;
            CLK : in std_logic;
            o_data1 : out std_logic_vector(31 downto 0);
            o_data2 : out std_logic_vector(31 downto 0));
end register_file;
-- architecture
architecture mixed of register_file is
component mux_32t1 is

  port (D_IN  : in input_array;
          SEL   : in std_logic_vector(4 downto 0);
          MUX_OUT : out std_logic_vector(31 downto 0));
end component;

component decoder_5t32 is

  port (D_IN  : in std_logic_vector(4 downto 0);
          F_OUT : out std_logic_vector(31 downto 0));
end component;

component register_N is

  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    Port (  REG_IN : in std_logic_vector(N-1 downto 0);
            LD,CLK,RST : in std_logic;
            REG_OUT : out std_logic_vector(N-1 downto 0));
end component;

signal writeAddrDecode, writeEnable: std_logic_vector(31 downto 0);
signal registerArray : input_array;

begin
registerArray(0) <= (others => '0');
writeDecoder : decoder_5t32 
    port map (D_in => i_w,
              F_OUT => writeAddrDecode);

writeEnable <= writeAddrDecode when i_writeEnable = '1' else (others => '0');

--generate all registers except for 0
G_32_reg: for i in 1 to 31 generate
    reg32: register_N port map(
              REG_IN     => i_writeData,  
              LD         => writeEnable(i),  
              CLK        => CLK, 
              RST        => '0',
              REG_OUT    => registerArray(i));  
  end generate G_32_reg;

readmux1 : mux_32t1 
port map (  D_in => registerArray,
            SEL => i_r1, 
            MUX_OUT => o_data1);

readmux2 : mux_32t1 
port map (  D_in => registerArray,
            SEL => i_r2, 
            MUX_OUT => o_data2);
   
end mixed;