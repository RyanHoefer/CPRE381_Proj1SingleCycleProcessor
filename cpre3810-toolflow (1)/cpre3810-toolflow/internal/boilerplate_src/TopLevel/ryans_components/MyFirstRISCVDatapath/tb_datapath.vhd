-------------------------------------------------------------------------
-- Ryan Hoefer
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_datapath.vhd
--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_datapath is
  generic(gCLK_HPER   : time := 50 ns;
  DATA_WIDTH  : integer := 32);

end tb_datapath;

architecture behavior of tb_datapath is
  
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;


  component datapath is
   generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    Port (  i_r1, i_r2 : in std_logic_vector(4 downto 0);
            i_w : in std_logic_vector(4 downto 0);
            i_imm : in std_logic_vector(31 downto 0);
            i_n_addSub : std_logic;
            i_aluSrc : std_logic;
            CLK : in std_logic;
            i_regwrite : in std_logic;
            result : out std_logic_vector(31 downto 0));

    
  end component;

 signal CLK_t          : std_logic := '0';
signal i_writeEnable_t : std_logic := '0';

signal i_r1_t, i_r2_t, i_w_t : std_logic_vector(4 downto 0) := (others => '0');

signal i_imm_t, result_t : std_logic_vector(31 downto 0) := (others => '0');

signal i_n_addSub_t, i_aluSrc_t, i_regwrite_t : std_logic;

begin

  DUT: datapath
  port map(i_r1 => i_r1_t, 
           i_r2 => i_r2_t,
           i_w  => i_w_t,
           i_imm => i_imm_t,
           i_n_addSub => i_n_addSub_t,
           i_aluSrc => i_aluSrc_t,
           CLK => CLK_t,
           i_regwrite => i_regwrite_t,
           result => result_t);

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
	-- Test 1: addi x1, zero, 1
	--------------------------------------------------
	i_r1_t			<= "00000";
	i_r2_t			<= "00000";
	i_w_t			<= "00001";
	i_imm_t			<= X"00000001";
	i_n_addSub_t	<= '0';
	i_aluSrc_t		<= '1';
	i_regwrite_t	<= '1';
	wait for cCLK_PER;

	--------------------------------------------------
	-- Test 2: addi x2, zero, 2
	--------------------------------------------------
	i_r1_t			<= "00000";
	i_r2_t			<= "00000";
	i_w_t			<= "00010";
	i_imm_t			<= X"00000002";
	i_n_addSub_t	<= '0';
	i_aluSrc_t		<= '1';
	i_regwrite_t	<= '1';
	wait for cCLK_PER;

	--------------------------------------------------
	-- Test 3: addi x3, zero, 3
	--------------------------------------------------
	i_r1_t			<= "00000";
	i_r2_t			<= "00000";
	i_w_t			<= "00011";
	i_imm_t			<= X"00000003";
	i_n_addSub_t	<= '0';
	i_aluSrc_t		<= '1';
	i_regwrite_t	<= '1';
	wait for cCLK_PER;

	--------------------------------------------------
	-- Test 4: addi x4, zero, 4
	--------------------------------------------------
	i_r1_t			<= "00000";
	i_r2_t			<= "00000";
	i_w_t			<= "00100";
	i_imm_t			<= X"00000004";
	i_n_addSub_t	<= '0';
	i_aluSrc_t		<= '1';
	i_regwrite_t	<= '1';
	wait for cCLK_PER;

	--------------------------------------------------
	-- Test 5: addi x5, zero, 5
	--------------------------------------------------
	i_r1_t			<= "00000";
	i_r2_t			<= "00000";
	i_w_t			<= "00101";
	i_imm_t			<= X"00000005";
	i_n_addSub_t	<= '0';
	i_aluSrc_t		<= '1';
	i_regwrite_t	<= '1';
	wait for cCLK_PER;

	--------------------------------------------------
	-- Test 6: addi x6, zero, 6
	--------------------------------------------------
	i_r1_t			<= "00000";
	i_r2_t			<= "00000";
	i_w_t			<= "00110";
	i_imm_t			<= X"00000006";
	i_n_addSub_t	<= '0';
	i_aluSrc_t		<= '1';
	i_regwrite_t	<= '1';
	wait for cCLK_PER;

	--------------------------------------------------
	-- Test 7: addi x7, zero, 7
	--------------------------------------------------
	i_r1_t			<= "00000";
	i_r2_t			<= "00000";
	i_w_t			<= "00111";
	i_imm_t			<= X"00000007";
	i_n_addSub_t	<= '0';
	i_aluSrc_t		<= '1';
	i_regwrite_t	<= '1';
	wait for cCLK_PER;

	--------------------------------------------------
	-- Test 8: addi x8, zero, 8
	--------------------------------------------------
	i_r1_t			<= "00000";
	i_r2_t			<= "00000";
	i_w_t			<= "01000";
	i_imm_t			<= X"00000008";
	i_n_addSub_t	<= '0';
	i_aluSrc_t		<= '1';
	i_regwrite_t	<= '1';
	wait for cCLK_PER;

	--------------------------------------------------
	-- Test 9: addi x9, zero, 9
	--------------------------------------------------
	i_r1_t			<= "00000";
	i_r2_t			<= "00000";
	i_w_t			<= "01001";
	i_imm_t			<= X"00000009";
	i_n_addSub_t	<= '0';
	i_aluSrc_t		<= '1';
	i_regwrite_t	<= '1';
	wait for cCLK_PER;

	--------------------------------------------------
	-- Test 10: addi x10, zero, 10
	--------------------------------------------------
	i_r1_t			<= "00000";
	i_r2_t			<= "00000";
	i_w_t			<= "01010";
	i_imm_t			<= X"0000000A";
	i_n_addSub_t	<= '0';
	i_aluSrc_t		<= '1';
	i_regwrite_t	<= '1';
	wait for cCLK_PER;

	--------------------------------------------------
	-- Test 11: add x11, x1, x2
	-- x11 = x1 + x2
	--------------------------------------------------
	i_r1_t			<= "00001";
	i_r2_t			<= "00010";
	i_w_t			<= "01011";
	i_imm_t			<= X"00000000";
	i_n_addSub_t	<= '0';
	i_aluSrc_t		<= '0';
	i_regwrite_t	<= '1';
	wait for cCLK_PER;

	--------------------------------------------------
	-- Test 12: sub x12, x11, x3
	-- x12 = x11 - x3
	--------------------------------------------------
	i_r1_t			<= "01011";
	i_r2_t			<= "00011";
	i_w_t			<= "01100";
	i_imm_t			<= X"00000000";
	i_n_addSub_t	<= '1';
	i_aluSrc_t		<= '0';
	i_regwrite_t	<= '1';
	wait for cCLK_PER;

	--------------------------------------------------
	-- Test 13: add x13, x12, x4
	-- x13 = x12 + x4
	--------------------------------------------------
	i_r1_t			<= "01100";
	i_r2_t			<= "00100";
	i_w_t			<= "01101";
	i_imm_t			<= X"00000000";
	i_n_addSub_t	<= '0';
	i_aluSrc_t		<= '0';
	i_regwrite_t	<= '1';
	wait for cCLK_PER;

	--------------------------------------------------
	-- Test 14: sub x14, x13, x5
	-- x14 = x13 - x5
	--------------------------------------------------
	i_r1_t			<= "01101";
	i_r2_t			<= "00101";
	i_w_t			<= "01110";
	i_imm_t			<= X"00000000";
	i_n_addSub_t	<= '1';
	i_aluSrc_t		<= '0';
	i_regwrite_t	<= '1';
	wait for cCLK_PER;

	--------------------------------------------------
	-- Test 15: add x15, x14, x6
	-- x15 = x14 + x6
	--------------------------------------------------
	i_r1_t			<= "01110";
	i_r2_t			<= "00110";
	i_w_t			<= "01111";
	i_imm_t			<= X"00000000";
	i_n_addSub_t	<= '0';
	i_aluSrc_t		<= '0';
	i_regwrite_t	<= '1';
	wait for cCLK_PER;

	--------------------------------------------------
	-- Test 16: sub x16, x15, x7
	-- x16 = x15 - x7
	--------------------------------------------------
	i_r1_t			<= "01111";
	i_r2_t			<= "00111";
	i_w_t			<= "10000";
	i_imm_t			<= X"00000000";
	i_n_addSub_t	<= '1';
	i_aluSrc_t		<= '0';
	i_regwrite_t	<= '1';
	wait for cCLK_PER;

	--------------------------------------------------
	-- Test 17: add x17, x16, x8
	-- x17 = x16 + x8
	--------------------------------------------------
	i_r1_t			<= "10000";
	i_r2_t			<= "01000";
	i_w_t			<= "10001";
	i_imm_t			<= X"00000000";
	i_n_addSub_t	<= '0';
	i_aluSrc_t		<= '0';
	i_regwrite_t	<= '1';
	wait for cCLK_PER;

	--------------------------------------------------
	-- Test 18: sub x18, x17, x9
	-- x18 = x17 - x9
	--------------------------------------------------
	i_r1_t			<= "10001";
	i_r2_t			<= "01001";
	i_w_t			<= "10010";
	i_imm_t			<= X"00000000";
	i_n_addSub_t	<= '1';
	i_aluSrc_t		<= '0';
	i_regwrite_t	<= '1';
	wait for cCLK_PER;

	--------------------------------------------------
	-- Test 19: add x19, x18, x10
	-- x19 = x18 + x10
	--------------------------------------------------
	i_r1_t			<= "10010";
	i_r2_t			<= "01010";
	i_w_t			<= "10011";
	i_imm_t			<= X"00000000";
	i_n_addSub_t	<= '0';
	i_aluSrc_t		<= '0';
	i_regwrite_t	<= '1';
	wait for cCLK_PER;
	--------------------------------------------------
	-- Test 20: addi x20, zero, -35
	-- Place -35 in x20
	--------------------------------------------------
	i_r1_t			<= "00000";
	i_r2_t			<= "00000";
	i_w_t			<= "10100";
	i_imm_t			<= X"FFFFFFDD";
	i_n_addSub_t	<= '0';
	i_aluSrc_t		<= '1';
	i_regwrite_t	<= '1';
	wait for cCLK_PER;

	--------------------------------------------------
	-- Test 21: add x21, x19, x20
	-- x21 = x19 + x20
	--------------------------------------------------
	i_r1_t			<= "10011";
	i_r2_t			<= "10100";
	i_w_t			<= "10101";
	i_imm_t			<= X"00000000";
	i_n_addSub_t	<= '0';
	i_aluSrc_t		<= '0';
	i_regwrite_t	<= '1';
	wait for cCLK_PER;

	--------------------------------------------------
	-- Test 22: lui x22, 0xFEED2
	-- Place 0xFEED2000 in x22
	--------------------------------------------------
	i_r1_t			<= "00000";
	i_r2_t			<= "00000";
	i_w_t			<= "10110";
	i_imm_t			<= X"FEED2000";
	i_n_addSub_t	<= '1';
	i_aluSrc_t		<= '1';
	i_regwrite_t	<= '1';
	wait for cCLK_PER;

	--------------------------------------------------
	-- Test 23: addi x22, x22, 0x050
	-- Complete loading x22 with a large immediate
	--------------------------------------------------
	i_r1_t			<= "10110";
	i_r2_t			<= "00000";
	i_w_t			<= "10110";
	i_imm_t			<= X"00000050";
	i_n_addSub_t	<= '0';
	i_aluSrc_t		<= '1';
	i_regwrite_t	<= '1';
	wait for cCLK_PER;
  end process;
  
end behavior;