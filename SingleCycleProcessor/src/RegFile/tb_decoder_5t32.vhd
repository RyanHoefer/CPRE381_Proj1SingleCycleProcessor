
library IEEE;
use IEEE.std_logic_1164.all;

entity tb_decoder_5t32 is
  generic(gCLK_HPER   : time := 50 ns;
  DATA_WIDTH  : integer := 32);

end tb_decoder_5t32;

architecture behavior of tb_decoder_5t32 is
-- Define the total clock period time
    constant cCLK_PER  : time := gCLK_HPER * 2;


  component decoder_5t32 is
    port (D_IN  : in std_logic_vector(4 downto 0);
          F_OUT : out std_logic_vector(31 downto 0));
    end component;

  -- Temporary signals to connect to the dff component.
  signal D_IN  : std_logic_vector(4 downto 0);
  signal F_OUT : std_logic_vector(31 downto 0);
  signal CLK : std_logic := '0';

    begin

    DUT: decoder_5t32 
    port map(D_IN => D_IN, 
            F_OUT => F_OUT);

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
    -- expected: x"00000002"
    D_IN <= "00001";
    wait for gCLK_HPER;

    -- expected: x"80000000"
    D_IN <= "11111";
    wait for gCLK_HPER;

    -- expected: x"00000400"
    D_IN <= "01010";
    wait for gCLK_HPER;

    -- expected: x"00000001"
    D_IN <= "00000";
    wait for gCLK_HPER;

    wait;
  end process;
  
end behavior;