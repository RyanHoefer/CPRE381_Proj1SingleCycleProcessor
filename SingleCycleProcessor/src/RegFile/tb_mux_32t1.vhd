library IEEE;
use IEEE.std_logic_1164.all;
use work.mux_types.all;

entity tb_mux_32t1 is
  generic(gCLK_HPER   : time := 50 ns;
  DATA_WIDTH  : integer := 32);

end tb_mux_32t1;

architecture behavior of tb_mux_32t1 is
-- Define the total clock period time
    constant cCLK_PER  : time := gCLK_HPER * 2;


  component mux_32t1 is
    port (D_IN  : in input_array;
          SEL   : in std_logic_vector(4 downto 0);
          MUX_OUT : out std_logic_vector(31 downto 0));
    end component;

  -- Temporary signals to connect to the dff component.
    signal D_IN    : input_array;
    signal MUX_OUT : std_logic_vector(31 downto 0);
    signal SEL     : std_logic_vector(4 downto 0);
    signal CLK : std_logic := '0';

    begin

    DUT: mux_32t1 
    port map(D_IN => D_IN, 
             SEL  => SEL,
             MUX_OUT => MUX_OUT);

    --This first process is to setup the clock for the test bench
    P_CLK: process
    begin
        CLK <= '1';         -- clock starts at 1
        wait for gCLK_HPER; -- after half a cycle
        CLK <= '0';         -- clock becomes a 0 (negative edge)
        wait for gCLK_HPER; -- after half a cycle, process begins evaluation again
    end process;
  -- Testbench process  
  P_TB: process
  begin
    -- expected: x"0000000A"
    D_IN(0) <= x"0000000A";
    D_IN(1) <= x"0000000A";
    SEL  <= "00000";
    wait for gCLK_HPER;

     -- expected: x"00000001"
    D_IN(0) <= x"00000001";
    D_IN(1) <= x"0000000A";
    SEL  <= "00000";
    wait for gCLK_HPER;

     -- expected: x"00000001"
    D_IN(0) <= x"0000000A";
    D_IN(1) <= x"00000001";
    SEL  <= "00001";
    wait for gCLK_HPER;

     -- expected: x"0000000A"
    D_IN(0) <= x"0000000A";
    D_IN(31) <= x"0000000A";
    SEL  <= "11111";
    wait for gCLK_HPER;

  

    wait;
  end process;
  
end behavior;