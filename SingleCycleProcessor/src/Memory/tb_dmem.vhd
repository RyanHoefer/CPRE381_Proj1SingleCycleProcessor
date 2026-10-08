-------------------------------------------------------------------------
-- Ryan Hoefer
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_dmem.vhd
--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_dmem is
  generic(gCLK_HPER   : time := 50 ns;
  DATA_WIDTH  : integer := 32);

end tb_dmem;

architecture behavior of tb_dmem is
  
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;


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

 signal CLK_t          : std_logic := '0';

signal addr_t : std_logic_vector((10-1) downto 0) := (others => '0');

signal data_t, q_t: std_logic_vector((32-1) downto 0) := (others => '0');

signal be_t : std_logic_vector (3 downto 0) := (others => '0');

signal we_t : std_logic := '1';
begin

dmem : mem
		port map(
			clk		=> CLK_t,
			addr	=> addr_t,
			data	=> data_t,
			be		=> be_t,
			we		=> we_t,
			q		=> q_t
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
	-- Test 1: read address 0x000
	--------------------------------------------------
	addr_t		<= "0000000000";
	data_t		<= X"00000000";
	be_t		<= "0000";
	we_t		<= '0';
	wait for cCLK_PER;

	--------------------------------------------------
	-- Test 2: read address 0x001
	--------------------------------------------------
	addr_t		<= "0000000001";
	data_t		<= X"00000000";
	be_t		<= "0000";
	we_t		<= '0';
	wait for cCLK_PER;

	--------------------------------------------------
	-- Test 3: read address 0x002
	--------------------------------------------------
	addr_t		<= "0000000010";
	data_t		<= X"00000000";
	be_t		<= "0000";
	we_t		<= '0';
	wait for cCLK_PER;

	--------------------------------------------------
	-- Test 4: read address 0x003
	--------------------------------------------------
	addr_t		<= "0000000011";
	data_t		<= X"00000000";
	be_t		<= "0000";
	we_t		<= '0';
	wait for cCLK_PER;

	--------------------------------------------------
	-- Test 5: read address 0x004
	--------------------------------------------------
	addr_t		<= "0000000100";
	data_t		<= X"00000000";
	be_t		<= "0000";
	we_t		<= '0';
	wait for cCLK_PER;

	--------------------------------------------------
	-- Test 6: read address 0x005
	--------------------------------------------------
	addr_t		<= "0000000101";
	data_t		<= X"00000000";
	be_t		<= "0000";
	we_t		<= '0';
	wait for cCLK_PER;

	--------------------------------------------------
	-- Test 7: read address 0x006
	--------------------------------------------------
	addr_t		<= "0000000110";
	data_t		<= X"00000000";
	be_t		<= "0000";
	we_t		<= '0';
	wait for cCLK_PER;

	--------------------------------------------------
	-- Test 8: read address 0x007
	--------------------------------------------------
	addr_t		<= "0000000111";
	data_t		<= X"00000000";
	be_t		<= "0000";
	we_t		<= '0';
	wait for cCLK_PER;

	--------------------------------------------------
	-- Test 9: read address 0x008
	--------------------------------------------------
	addr_t		<= "0000001000";
	data_t		<= X"00000000";
	be_t		<= "0000";
	we_t		<= '0';
	wait for cCLK_PER;

	--------------------------------------------------
	-- Test 10: read address 0x009
	--------------------------------------------------
	addr_t		<= "0000001001";
	data_t		<= X"00000000";
	be_t		<= "0000";
	we_t		<= '0';
	wait for cCLK_PER;

  --------------------------------------------------
	-- Test 11: write -1 to address 0x00A
	--------------------------------------------------
	addr_t		<= "0100000000";
	data_t		<= X"FFFFFFFF";
	be_t		<= "1111";
	we_t		<= '1';
	wait for cCLK_PER;

  --------------------------------------------------
  -- Test 12: write 2 to address 0x101
  --------------------------------------------------
  addr_t		<= "0100000001";
  data_t		<= X"00000002";
  be_t		<= "1111";
  we_t		<= '1';
  wait for cCLK_PER;

  --------------------------------------------------
  -- Test 13: write -3 to address 0x102
  --------------------------------------------------
  addr_t		<= "0100000010";
  data_t		<= X"FFFFFFFD";
  be_t		<= "1111";
  we_t		<= '1';
  wait for cCLK_PER;

  --------------------------------------------------
  -- Test 14: write 4 to address 0x103
  --------------------------------------------------
  addr_t		<= "0100000011";
  data_t		<= X"00000004";
  be_t		<= "1111";
  we_t		<= '1';
  wait for cCLK_PER;

  --------------------------------------------------
  -- Test 15: write 5 to address 0x104
  --------------------------------------------------
  addr_t		<= "0100000100";
  data_t		<= X"00000005";
  be_t		<= "1111";
  we_t		<= '1';
  wait for cCLK_PER;

  --------------------------------------------------
  -- Test 16: write 6 to address 0x105
  --------------------------------------------------
  addr_t		<= "0100000101";
  data_t		<= X"00000006";
  be_t		<= "1111";
  we_t		<= '1';
  wait for cCLK_PER;

  --------------------------------------------------
  -- Test 17: write -7 to address 0x106
  --------------------------------------------------
  addr_t		<= "0100000110";
  data_t		<= X"FFFFFFF9";
  be_t		<= "1111";
  we_t		<= '1';
  wait for cCLK_PER;

  --------------------------------------------------
  -- Test 18: write -8 to address 0x107
  --------------------------------------------------
  addr_t		<= "0100000111";
  data_t		<= X"FFFFFFF8";
  be_t		<= "1111";
  we_t		<= '1';
  wait for cCLK_PER;

  --------------------------------------------------
  -- Test 19: write 9 to address 0x108
  --------------------------------------------------
  addr_t		<= "0100001000";
  data_t		<= X"00000009";
  be_t		<= "1111";
  we_t		<= '1';
  wait for cCLK_PER;

  --------------------------------------------------
  -- Test 20: write -10 to address 0x109
  --------------------------------------------------
  addr_t		<= "0100001001";
  data_t		<= X"FFFFFFF6";
  be_t		<= "1111";
  we_t		<= '1';
  wait for cCLK_PER;

  --------------------------------------------------
  -- Test 21: read -1 from address 0x100
  --------------------------------------------------
  addr_t		<= "0100000000";
  data_t		<= X"00000000";
  be_t		<= "0000";
  we_t		<= '0';
  wait for cCLK_PER;
  --------------------------------------------------
  -- Test 22: read 2 from address 0x101
  --------------------------------------------------
  addr_t		<= "0100000001";
  data_t		<= X"00000000";
  be_t		<= "0000";
  we_t		<= '0';
  wait for cCLK_PER;

  --------------------------------------------------
  -- Test 23: read -3 from address 0x102
  --------------------------------------------------
  addr_t		<= "0100000010";
  data_t		<= X"00000000";
  be_t		<= "0000";
  we_t		<= '0';
  wait for cCLK_PER;

  --------------------------------------------------
  -- Test 24: read 4 from address 0x103
  --------------------------------------------------
  addr_t		<= "0100000011";
  data_t		<= X"00000000";
  be_t		<= "0000";
  we_t		<= '0';
  wait for cCLK_PER;

  --------------------------------------------------
  -- Test 25: read 5 from address 0x104
  --------------------------------------------------
  addr_t		<= "0100000100";
  data_t		<= X"00000000";
  be_t		<= "0000";
  we_t		<= '0';
  wait for cCLK_PER;

  --------------------------------------------------
  -- Test 26: read 6 from address 0x105
  --------------------------------------------------
  addr_t		<= "0100000101";
  data_t		<= X"00000000";
  be_t		<= "0000";
  we_t		<= '0';
  wait for cCLK_PER;

  --------------------------------------------------
  -- Test 27: read -7 from address 0x106
  --------------------------------------------------
  addr_t		<= "0100000110";
  data_t		<= X"00000000";
  be_t		<= "0000";
  we_t		<= '0';
  wait for cCLK_PER;

  --------------------------------------------------
  -- Test 28: read -8 from address 0x107
  --------------------------------------------------
  addr_t		<= "0100000111";
  data_t		<= X"00000000";
  be_t		<= "0000";
  we_t		<= '0';
  wait for cCLK_PER;

  --------------------------------------------------
  -- Test 29: read 9 from address 0x108
  --------------------------------------------------
  addr_t		<= "0100001000";
  data_t		<= X"00000000";
  be_t		<= "0000";
  we_t		<= '0';
  wait for cCLK_PER;

  --------------------------------------------------
  -- Test 30: read -10 from address 0x109
  --------------------------------------------------
  addr_t		<= "0100001001";
  data_t		<= X"00000000";
  be_t		<= "0000";
  we_t		<= '0';
  wait for cCLK_PER;

    wait;
  end process;
  
end behavior;