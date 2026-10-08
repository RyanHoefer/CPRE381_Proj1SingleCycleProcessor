-- library declaration
library IEEE;
use IEEE.std_logic_1164.all;
-- entity
entity datapath2 is
generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    Port (  i_rs1, i_rs2 : in std_logic_vector(4 downto 0);
            i_w : in std_logic_vector(4 downto 0);

            i_imm12	: in std_logic_vector(11 downto 0);
            i_imm20	: in std_logic_vector(19 downto 0);

            i_n_addSub : std_logic;
            i_aluSrc : std_logic;
            i_imm_select : std_logic;
            i_regsrc : std_logic;
            i_mem_write : std_logic;
            i_regwrite : in std_logic;

            CLK : in std_logic;

            result : out std_logic_vector(31 downto 0));

end datapath2;
-- architecture
architecture structural of datapath2 is
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

component mem is
   generic 
    (
        DATA_WIDTH : natural := 32;
        ADDR_WIDTH : natural := 10;
        BYTE_WIDTH : natural := 8
    );
    port 
    (
        clk        : in std_logic;
        addr            : in std_logic_vector((ADDR_WIDTH-1) downto 0);
        data            : in std_logic_vector((DATA_WIDTH-1) downto 0);
        be              : in std_logic_vector (3 downto 0);   -- 4 bytes per word
        we        : in std_logic := '1';
        q        : out std_logic_vector((DATA_WIDTH -1) downto 0)
    );

    
  end component;

component mux2t1_N is
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_S          : in std_logic;
       i_D0         : in std_logic_vector(N-1 downto 0);
       i_D1         : in std_logic_vector(N-1 downto 0);
       o_O          : out std_logic_vector(N-1 downto 0));
end component;

component extender_N is
  generic(N : integer := 12);
	port(
		i_A	: in  std_logic_vector(N-1 downto 0);
		i_sign : in std_logic;
		o_F	: out std_logic_vector(31 downto 0)
	);
end component;

component zero_appender_N is
  generic(
		N : integer := 20
	);
	port(
		i_A	: in  std_logic_vector(N-1 downto 0);
		o_F	: out std_logic_vector(31 downto 0)
	);
end component;

signal reg_src, rd1, rd2, z_app, s_ext, dmem_o, alu, imm: std_logic_vector(31 downto 0);

begin


registerFile : register_file
    generic map(N => N)
    port map (i_r1 => i_rs1,
            i_r2 => i_rs2,
            i_w => i_w,
            i_writeData => reg_src,
            i_writeEnable => i_regwrite,
            CLK => CLK,
            o_data1 => rd1,
            o_data2 => rd2);

addsub : addsub_N_with_imm
    generic map(N => N)
        port map (  i_A => rd1,
                    i_B => rd2,
                    i_imm => imm,
                    ctl => i_n_addSub,
                    i_aluSrc => i_aluSrc,
                    s => alu,
                    c_out => open);

dmem : mem
    generic map(
		DATA_WIDTH => N,
		ADDR_WIDTH => 10,
		BYTE_WIDTH => 8
	)
        port map (  addr => alu(11 downto 2),
                    data => rd2,
                    be => "1111",
                    we => i_mem_write,
                    q => dmem_o,
                    clk => clk);

dataMux : mux2t1_N 
    generic map(N => N)
        port map (  i_D0 => alu,
                    i_D1 => dmem_o,
                    i_S => i_regsrc,
                    o_O => reg_src);

immMux : mux2t1_N 
    generic map(N => N)
        port map (  i_D0 => s_ext,
                    i_D1 => z_app,
                    i_S => i_imm_select,
                    o_O => imm);

extender : extender_N
    generic map(N => 12)
        port map (  i_A => i_imm12,
                    i_sign => '1',
                    O_F => s_ext);

zAppender : zero_appender_N
    generic map(N => 20)
        port map (  i_A => i_imm20,
                    o_F => z_app);

result <= reg_src;


   
end structural;