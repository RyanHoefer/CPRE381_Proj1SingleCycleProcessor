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
    -- Test 1: lui x25, 0x10010
    --------------------------------------------------
    i_r1_t			<= "00000";
    i_r2_t			<= "00000";
    i_w_t			<= "11001";
    i_imm12_t		<= X"000";
    i_imm20_t		<= X"10010";
    i_n_addSub_t	<= '1';
    i_aluSrc_t		<= '1';
    i_imm_select_t	<= '1';
    i_regsrc_t		<= '0';
    i_mem_write_t	<= '0';
    i_regwrite_t	<= '1';
    wait for cCLK_PER;
    --------------------------------------------------
    -- Test 2: addi x25, zero, 0
    --------------------------------------------------
    i_r1_t			<= "00000";
    i_r2_t			<= "00000";
    i_w_t			<= "11001";
    i_imm12_t		<= X"000";
    i_imm20_t		<= X"00000";
    i_n_addSub_t	<= '0';
    i_aluSrc_t		<= '1';
    i_imm_select_t	<= '0';
    i_regsrc_t		<= '0';
    i_mem_write_t	<= '0';
    i_regwrite_t	<= '1';
    wait for cCLK_PER;

    --------------------------------------------------
    -- Test 3: addi x26, zero, 256
    --------------------------------------------------
    i_r1_t			<= "00000";
    i_r2_t			<= "00000";
    i_w_t			<= "11010";
    i_imm12_t		<= X"100";
    i_imm20_t		<= X"00000";
    i_n_addSub_t	<= '0';
    i_aluSrc_t		<= '1';
    i_imm_select_t	<= '0';
    i_regsrc_t		<= '0';
    i_mem_write_t	<= '0';
    i_regwrite_t	<= '1';
    wait for cCLK_PER;

    --------------------------------------------------
    -- Test 4: lw x1, 0(x25)
    --------------------------------------------------
    i_r1_t			<= "11001";
    i_r2_t			<= "00000";
    i_w_t			<= "00001";
    i_imm12_t		<= X"000";
    i_imm20_t		<= X"00000";
    i_n_addSub_t	<= '0';
    i_aluSrc_t		<= '1';
    i_imm_select_t	<= '0';
    i_regsrc_t		<= '1';
    i_mem_write_t	<= '0';
    i_regwrite_t	<= '1';
    wait for cCLK_PER;

    --------------------------------------------------
    -- Test 5: lw x2, 4(x25)
    --------------------------------------------------
    i_r1_t			<= "11001";
    i_r2_t			<= "00000";
    i_w_t			<= "00010";
    i_imm12_t		<= X"004";
    i_imm20_t		<= X"00000";
    i_n_addSub_t	<= '0';
    i_aluSrc_t		<= '1';
    i_imm_select_t	<= '0';
    i_regsrc_t		<= '1';
    i_mem_write_t	<= '0';
    i_regwrite_t	<= '1';
    wait for cCLK_PER;
    

    --------------------------------------------------
    -- Test 6: add x1, x1, x2
    --------------------------------------------------
    i_r1_t			<= "00001";
    i_r2_t			<= "00010";
    i_w_t			<= "00001";
    i_imm12_t		<= X"000";
    i_imm20_t		<= X"00000";
    i_n_addSub_t    <= '0';
    i_aluSrc_t		<= '0';
    i_imm_select_t	<= '0';
    i_regsrc_t		<= '0';
    i_mem_write_t	<= '0';
    i_regwrite_t	<= '1';
    wait for cCLK_PER;

    --------------------------------------------------
    -- Test 7: sw x1, 0(x26)
    --------------------------------------------------
    i_r1_t			<= "11010";
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

    --------------------------------------------------
    -- Test 8: lw x2, 8(x25)
    --------------------------------------------------
    i_r1_t			<= "11001";
    i_r2_t			<= "00000";
    i_w_t			<= "00010";
    i_imm12_t		<= X"008";
    i_imm20_t		<= X"00000";
    i_n_addSub_t	<= '0';
    i_aluSrc_t		<= '1';
    i_imm_select_t	<= '0';
    i_regsrc_t		<= '1';
    i_mem_write_t	<= '0';
    i_regwrite_t	<= '1';
    wait for cCLK_PER;

    --------------------------------------------------
    -- Test 9: add x1, x1, x2
    --------------------------------------------------
    i_r1_t			<= "00001";
    i_r2_t			<= "00010";
    i_w_t			<= "00001";
    i_imm12_t		<= X"000";
    i_imm20_t		<= X"00000";
    i_n_addSub_t	<= '0';
    i_aluSrc_t		<= '0';
    i_imm_select_t	<= '0';
    i_regsrc_t		<= '0';
    i_mem_write_t	<= '0';
    i_regwrite_t	<= '1';
    wait for cCLK_PER;

    --------------------------------------------------
    -- Test 10: sw x1, 4(x26)
    --------------------------------------------------
    i_r1_t			<= "11010";
    i_r2_t			<= "00001";
    i_w_t			<= "00000";
    i_imm12_t		<= X"004";
    i_imm20_t		<= X"00000";
    i_n_addSub_t	<= '0';
    i_aluSrc_t		<= '1';
    i_imm_select_t	<= '0';
    i_regsrc_t		<= '0';
    i_mem_write_t	<= '1';
    i_regwrite_t	<= '0';
    wait for cCLK_PER;

    --------------------------------------------------
    -- Test 11: lw x2, 12(x25)
    --------------------------------------------------
    i_r1_t			<= "11001";
    i_r2_t			<= "00000";
    i_w_t			<= "00010";
    i_imm12_t		<= X"00C";
    i_imm20_t		<= X"00000";
    i_n_addSub_t	<= '0';
    i_aluSrc_t		<= '1';
    i_imm_select_t	<= '0';
    i_regsrc_t		<= '1';
    i_mem_write_t	<= '0';
    i_regwrite_t	<= '1';
    wait for cCLK_PER;

    --------------------------------------------------
    -- Test 12: add x1, x1, x2
    --------------------------------------------------
    i_r1_t			<= "00001";
    i_r2_t			<= "00010";
    i_w_t			<= "00001";
    i_imm12_t		<= X"000";
    i_imm20_t		<= X"00000";
    i_n_addSub_t	<= '0';
    i_aluSrc_t		<= '0';
    i_imm_select_t	<= '0';
    i_regsrc_t		<= '0';
    i_mem_write_t	<= '0';
    i_regwrite_t	<= '1';
    wait for cCLK_PER;

    --------------------------------------------------
    -- Test 13: sw x1, 8(x26)
    --------------------------------------------------
    i_r1_t			<= "11010";
    i_r2_t			<= "00001";
    i_w_t			<= "00000";
    i_imm12_t		<= X"008";
    i_imm20_t		<= X"00000";
    i_n_addSub_t	<= '0';
    i_aluSrc_t		<= '1';
    i_imm_select_t	<= '0';
    i_regsrc_t		<= '0';
    i_mem_write_t	<= '1';
    i_regwrite_t	<= '0';
    wait for cCLK_PER;

    --------------------------------------------------
    -- Test 14: lw x2, 16(x25)
    --------------------------------------------------
    i_r1_t			<= "11001";
    i_r2_t			<= "00000";
    i_w_t			<= "00010";
    i_imm12_t		<= X"010";
    i_imm20_t		<= X"00000";
    i_n_addSub_t		<= '0';
    i_aluSrc_t		<= '1';
    i_imm_select_t		<= '0';
    i_regsrc_t		<= '1';
    i_mem_write_t		<= '0';
    i_regwrite_t		<= '1';
    wait for cCLK_PER;

    --------------------------------------------------
    -- Test 15: add x1, x1, x2
    --------------------------------------------------
    i_r1_t			<= "00001";
    i_r2_t			<= "00010";
    i_w_t			<= "00001";
    i_imm12_t		<= X"000";
    i_imm20_t		<= X"00000";
    i_n_addSub_t	<= '0';
    i_aluSrc_t		<= '0';
    i_imm_select_t	<= '0';
    i_regsrc_t		<= '0';
    i_mem_write_t	<= '0';
    i_regwrite_t	<= '1';
    wait for cCLK_PER;

    --------------------------------------------------
    -- Test 16: sw x1, 12(x26)
    --------------------------------------------------
    i_r1_t			<= "11010";
    i_r2_t			<= "00001";
    i_w_t			<= "00000";
    i_imm12_t		<= X"00C";
    i_imm20_t		<= X"00000";
    i_n_addSub_t	<= '0';
    i_aluSrc_t		<= '1';
    i_imm_select_t	<= '0';
    i_regsrc_t		<= '0';
    i_mem_write_t	<= '1';
    i_regwrite_t	<= '0';
    wait for cCLK_PER;

    --------------------------------------------------
    -- Test 17: lw x2, 20(x25)
    --------------------------------------------------
    i_r1_t			<= "11001";
    i_r2_t			<= "00000";
    i_w_t			<= "00010";
    i_imm12_t		<= X"014";
    i_imm20_t		<= X"00000";
    i_n_addSub_t	<= '0';
    i_aluSrc_t		<= '1';
    i_imm_select_t	<= '0';
    i_regsrc_t		<= '1';
    i_mem_write_t	<= '0';
    i_regwrite_t	<= '1';
    wait for cCLK_PER;

    --------------------------------------------------
    -- Test 18: add x1, x1, x2
    --------------------------------------------------
    i_r1_t			<= "00001";
    i_r2_t			<= "00010";
    i_w_t			<= "00001";
    i_imm12_t		<= X"000";
    i_imm20_t		<= X"00000";
    i_n_addSub_t	<= '0';
    i_aluSrc_t		<= '0';
    i_imm_select_t	<= '0';
    i_regsrc_t		<= '0';
    i_mem_write_t	<= '0';
    i_regwrite_t	<= '1';
    wait for cCLK_PER;

    --------------------------------------------------
    -- Test 19: sw x1, 16(x26)
    --------------------------------------------------
    i_r1_t			<= "11010";
    i_r2_t			<= "00001";
    i_w_t			<= "00000";
    i_imm12_t		<= X"010";
    i_imm20_t		<= X"00000";
    i_n_addSub_t	<= '0';
    i_aluSrc_t		<= '1';
    i_imm_select_t	<= '0';
    i_regsrc_t		<= '0';
    i_mem_write_t	<= '1';
    i_regwrite_t	<= '0';
    wait for cCLK_PER;

    --------------------------------------------------
    -- Test 20: lw x2, 24(x25)
    --------------------------------------------------
    i_r1_t			<= "11001";
    i_r2_t			<= "00000";
    i_w_t			<= "00010";
    i_imm12_t		<= X"018";
    i_imm20_t		<= X"00000";
    i_n_addSub_t	<= '0';
    i_aluSrc_t		<= '1';
    i_imm_select_t	<= '0';
    i_regsrc_t		<= '1';
    i_mem_write_t	<= '0';
    i_regwrite_t	<= '1';
    wait for cCLK_PER;

    --------------------------------------------------
    -- Test 21: add x1, x1, x2
    --------------------------------------------------
    i_r1_t			<= "00001";
    i_r2_t			<= "00010";
    i_w_t			<= "00001";
    i_imm12_t		<= X"000";
    i_imm20_t		<= X"00000";
    i_n_addSub_t	<= '0';
    i_aluSrc_t		<= '0';
    i_imm_select_t	<= '0';
    i_regsrc_t		<= '0';
    i_mem_write_t	<= '0';
    i_regwrite_t	<= '1';
    wait for cCLK_PER;

    --------------------------------------------------
    -- Test 22: addi x27, zero, 512
    --------------------------------------------------
    i_r1_t			<= "00000";
    i_r2_t			<= "00000";
    i_w_t			<= "11011";
    i_imm12_t		<= X"200";
    i_imm20_t		<= X"00000";
    i_n_addSub_t	<= '0';
    i_aluSrc_t		<= '1';
    i_imm_select_t	<= '0';
    i_regsrc_t		<= '0';
    i_mem_write_t	<= '0';
    i_regwrite_t	<= '1';
    wait for cCLK_PER;

    --------------------------------------------------
    -- Test 23: sw x1, -4(x27)
    --------------------------------------------------
    i_r1_t			<= "11011";
    i_r2_t			<= "00001";
    i_w_t			<= "00000";
    i_imm12_t		<= X"FFC";
    i_imm20_t		<= X"00000";
    i_n_addSub_t	<= '0';
    i_aluSrc_t		<= '1';
    i_imm_select_t	<= '0';
    i_regsrc_t		<= '0';
    i_mem_write_t	<= '1';
    i_regwrite_t	<= '0';
    wait for cCLK_PER;

    --------------------------------------------------
    -- Test 24: sw x1, -4(x27)
    --------------------------------------------------
    i_r1_t			<= "11011";
    i_r2_t			<= "00001";
    i_w_t			<= "00000";
    i_imm12_t		<= X"FFC";
    i_imm20_t		<= X"00000";
    i_n_addSub_t	<= '0';
    i_aluSrc_t		<= '1';
    i_imm_select_t	<= '0';
    i_regsrc_t		<= '0';
    i_mem_write_t	<= '1';
    i_regwrite_t	<= '0';
    wait for cCLK_PER;

  




    --------------------------------------------------
    -- Test 1: addi x1, x0, 0xFFC
    --------------------------------------------------
    i_r1_t			<= "00000";
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
    -- Test 2: addi x2, x0, 0x148
    --------------------------------------------------
    i_r1_t			<= "00000";
    i_r2_t			<= "00000";
    i_w_t			<= "00010";
    i_imm12_t		<= X"148";
    i_imm20_t		<= X"00000";
    i_n_addSub_t	<= '0';
    i_aluSrc_t		<= '1';
    i_imm_select_t	<= '0';
    i_regsrc_t		<= '0';
    i_mem_write_t	<= '0';
    i_regwrite_t	<= '1';
    wait for cCLK_PER;

    --------------------------------------------------
    -- Test 3: sw x1, 0(x2)
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

    --------------------------------------------------
    -- Test 4: lw x18, 0(x2) 
    --------------------------------------------------
    i_r1_t			<= "00010";
    i_r2_t			<= "00000";
    i_w_t			<= "10010";
    i_imm12_t		<= X"000";
    i_imm20_t		<= X"00000";
    i_n_addSub_t	<= '0';
    i_aluSrc_t		<= '1';
    i_imm_select_t	<= '0';
    i_regsrc_t		<= '1';
    i_mem_write_t	<= '0';
    i_regwrite_t	<= '1';
    wait for cCLK_PER;

    --------------------------------------------------
    -- Test 5: sw x18, 4(x2) 
    --------------------------------------------------
    i_r1_t			<= "00010";
    i_r2_t			<= "10010";
    i_w_t			<= "00000";
    i_imm12_t		<= X"004";
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