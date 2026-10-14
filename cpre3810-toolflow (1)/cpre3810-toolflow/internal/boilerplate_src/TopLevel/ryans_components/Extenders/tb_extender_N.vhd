-------------------------------------------------------------------------
-- Ryan Hoefer
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_dmem.vhd
--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_extender_N is
  generic(gCLK_HPER   : time := 50 ns;
  DATA_WIDTH  : integer := 32);

end tb_extender_N;

architecture behavior of tb_extender_N is
  constant N : integer := 12;
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;


  component extender_N is
   generic(N : integer := 12);
	port(
		i_A	: in  std_logic_vector(N-1 downto 0);
		i_sign : in std_logic;
		o_F	: out std_logic_vector(31 downto 0)
	);

    
  end component;

 signal i_sign_t          : std_logic := '0';

signal i_A_t : std_logic_vector((N-1) downto 0) := (others => '0');

signal o_F_t: std_logic_vector(31 downto 0) := (others => '0');

begin

extender : extender_N
        generic map(N => N)
		port map(
			i_A		=> i_A_t,
			i_sign	=> i_sign_t,
			o_F  	=> o_F_t
		);


  -- Testbench process  
  P_TB: process
  begin

    --------------------------------------------------
	-- Test 1: zero extend with 1
	--------------------------------------------------
	i_A_t			<= X"800";
	i_sign_t		<= '0';
	wait for cCLK_PER;

    --------------------------------------------------
	-- Test 2: sign extend with 1
	--------------------------------------------------
	i_A_t			<= X"800";
	i_sign_t		<= '1';
	wait for cCLK_PER;

    --------------------------------------------------
    -- Test 3: zero extend with 0
    --------------------------------------------------
    i_A_t		    <= X"7FF";
    i_sign_t	    <= '0';
    wait for cCLK_PER;

    --------------------------------------------------
    -- Test 4: sign extend with 0
    --------------------------------------------------
    i_A_t		    <= X"7FF";
    i_sign_t	    <= '1';
    wait for cCLK_PER;

 

    wait;
  end process;
  
end behavior;