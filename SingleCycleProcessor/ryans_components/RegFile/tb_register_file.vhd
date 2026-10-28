-------------------------------------------------------------------------
-- Ryan Hoefer
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_register_file.vhd
--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_register_file is
  generic(gCLK_HPER   : time := 50 ns;
  DATA_WIDTH  : integer := 32);

end tb_register_file;

architecture behavior of tb_register_file is
  
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;


  component register_file is
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    Port (  i_r1, i_r2    : in std_logic_vector(4 downto 0);
            i_w           : in std_logic_vector(4 downto 0);
            i_writeData   : in std_logic_vector(31 downto 0);
            i_writeEnable : std_logic;
            CLK           : in std_logic;
            o_data1       : out std_logic_vector(31 downto 0);
            o_data2       : out std_logic_vector(31 downto 0));
    
  end component;

 signal CLK_t          : std_logic := '0';
signal i_writeEnable_t : std_logic := '0';

signal i_r1_t, i_r2_t, i_w_t : std_logic_vector(4 downto 0) := (others => '0');

signal i_writeData_t : std_logic_vector(31 downto 0) := (others => '0');

signal o_data1_t, o_data2_t : std_logic_vector(31 downto 0);

begin

  DUT: register_file 
  port map(i_r1 => i_r1_t, 
           i_r2 => i_r2_t,
           i_w  => i_w_t,
           i_writeData   => i_writeData_t,
           i_writeEnable => i_writeEnable_t,
           CLK => CLK_t,
           o_data1 => o_data1_t,
           o_data2 => o_data2_t);

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
    -- Test 1
    -- read 0 from x 0 on both ports
    i_writeEnable_t <= '0';
    i_r1_t          <= "00000";
    i_r2_t          <= "00000";
    wait for cCLK_PER;
    ------------------------------------------------------------------

    -- Test 2
    -- Store 4 in x1 and read 
    i_w_t           <= "00001";
    i_writeData_t   <= x"00000004";
    i_writeEnable_t <= '1';

    wait for cCLK_PER; 

    i_writeEnable_t <= '0';
    i_r1_t          <= "00001";
    i_r2_t          <= "00000";
    wait for cCLK_PER;  
    ------------------------------------------------------------------

    -- Test 3
    -- write 13 to x2 then read x1 and x2
    i_w_t           <= "00010";
    i_writeData_t   <= x"0000000D";
    i_writeEnable_t <= '1';

    wait for cCLK_PER; 

    i_writeEnable_t <= '0';
    i_r1_t          <= "00001"; -- Read x1
    i_r2_t          <= "00010"; -- Read x2
     wait for cCLK_PER; 
    ------------------------------------------------------------------

    

    -- Test 4
    -- write to x0
    i_w_t           <= "00000";
    i_writeData_t   <= x"FFFFFFFF";
    i_writeEnable_t <= '1';

    wait for cCLK_PER; 

    i_writeEnable_t <= '0';
    i_r1_t          <= "00000";

    wait for cCLK_PER; 
  end process;
  
end behavior;