-------------------------------------------------------------------------
-- Ryan Hoefer
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_datapath.vhd
--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_datapath2 is
  generic(gCLK_HPER   : time := 50 ns;
  DATA_WIDTH  : integer := 32);

end tb_datapath2;

architecture behavior of tb_datapath2 is
  
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;


    component datapath2 is
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

    
  end component;

   signal CLK_t : std_logic := '0';

    signal i_r1_t, i_r2_t, i_w_t : std_logic_vector(4 downto 0) := (others => '0');

    signal i_imm12_t : std_logic_vector(11 downto 0) := (others => '0');

    signal i_imm20_t : std_logic_vector(19 downto 0) := (others => '0');

    signal result_t : std_logic_vector(31 downto 0) := (others => '0');

    signal i_n_addSub_t, i_aluSrc_t, i_imm_select_t, i_regsrc_t, i_mem_write_t, i_regwrite_t : std_logic := '0';

begin

    DUT : datapath2
        generic map(
            N => 32
        )
        port map(
            i_rs1 => i_r1_t,
            i_rs2 => i_r2_t,
            i_w	 => i_w_t,
            i_imm12	=> i_imm12_t,
            i_imm20	=> i_imm20_t,
            i_n_addSub => i_n_addSub_t,
            i_aluSrc => i_aluSrc_t,
            i_imm_select => i_imm_select_t,
            i_regsrc => i_regsrc_t,
            i_mem_write	=> i_mem_write_t,
            i_regwrite => i_regwrite_t,
            CLK	 => CLK_t,
            result => result_t
        );
  -- This process sets the clock value (low for gCLK_HPER, then high
  -- for gCLK_HPER). Absent a "wait" command, processes restart 
  -- at the beginning once they have reached the final statement.
  P_CLK: process
  begin
    CLK_t <= '0';
    wait for gCLK_HPER;
    CLK_t <= '1';
    wait for gCLK_HPER;
  end process;
  
  -- Testbench process  
  P_TB: process
  begin
  
    --------------------------------------------------
    -- Test 1: addi x1, x1, 0xFFC
    --------------------------------------------------
    i_r1_t			<= "00001";
    i_r2_t			<= "00000";
    i_w_t			<= "00001";
    i_imm12_t		<= X"FFC";
    i_imm20_t		<= X"00000";
    i_n_addSub_t	<= '0';
    i_aluSrc_t		<= '1';
    i_imm_select_t	<= '0';
    i_regsrc_t		<= '0';
    i_mem_write_t	<= '0';
    i_regwrite_t	<= '1';
    wait for cCLK_PER;

    --------------------------------------------------
    -- Test 3: addi x2, x2, 0x052
    --------------------------------------------------
    i_r1_t			<= "00010";
    i_r2_t			<= "00000";
    i_w_t			<= "00010";
    i_imm12_t		<= X"052";
    i_imm20_t		<= X"00000";
    i_n_addSub_t	<= '0';
    i_aluSrc_t		<= '1';
    i_imm_select_t	<= '0';
    i_regsrc_t		<= '0';
    i_mem_write_t	<= '0';
    i_regwrite_t	<= '1';
    wait for cCLK_PER;

    --------------------------------------------------
    -- Test 4: sw x1, 0(x2)
    --------------------------------------------------
    i_r1_t			<= "00010";
    i_r2_t			<= "00001";
    i_w_t			<= "00000";
    i_imm12_t		<= X"000";
    i_imm20_t		<= X"00000";
    i_n_addSub_t	<= '0';
    i_aluSrc_t		<= '1';
    i_imm_select_t	<= '0';
    i_regsrc_t		<= '0';
    i_mem_write_t	<= '1';
    i_regwrite_t	<= '0';
    wait for cCLK_PER;
	
	


	wait for cCLK_PER;
  end process;
  
end behavior;