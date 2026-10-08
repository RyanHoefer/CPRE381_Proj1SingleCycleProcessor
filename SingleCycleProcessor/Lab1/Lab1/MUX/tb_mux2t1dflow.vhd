library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

entity tb_mux2t1dflow is
  generic(gCLK_HPER   : time := 10 ns;
          DATA_WIDTH  : integer := 8);   -- Generic for half of the clock cycle period
end tb_mux2t1dflow;


architecture mixed of tb_mux2t1dflow is

    -- Define the total clock period time
    constant cCLK_PER  : time := gCLK_HPER * 2;


    component mux2t1dflow is
    port(i_D0              : in std_logic;
        i_D1              : in std_logic;
        i_S               : in std_logic;
        o_O               : out std_logic);
    end component;

    signal CLK, reset : std_logic := '0';
    signal iA  : std_logic;
    signal iB  : std_logic;
    signal S   : std_logic;
    signal O   : std_logic;

    begin
    DUT1: mux2t1dflow
    
    port map(
                i_D0     => iA,
                i_D1     => iB,
                i_S      => S,
                o_O      => O);

                
        

    --This first process is to setup the clock for the test bench
    P_CLK: process
    begin
        CLK <= '1';         -- clock starts at 1
        wait for gCLK_HPER; -- after half a cycle
        CLK <= '0';         -- clock becomes a 0 (negative edge)
        wait for gCLK_HPER; -- after half a cycle, process begins evaluation again
    end process;

    -- This process resets the sequential components of the design.
    -- It is held to be 1 across both the negative and positive edges of the clock
    -- so it works regardless of whether the design uses synchronous (pos or neg edge)
    -- or asynchronous resets.
    P_RST: process
    begin
        reset <= '0';   
        wait for gCLK_HPER/2;
        reset <= '1';
        wait for gCLK_HPER*2;
        reset <= '0';
        wait;
    end process;  

    P_TEST_CASES: process
    begin
        wait for gCLK_HPER/2; -- for waveform clarity, I prefer not to change inputs on clk edges

        -- Test case 1:
        -- Initialize weight value to 10.
        iA   <= '0';  
        iB   <= '0';  
        s    <= '0';
        -- Not strictly necessary, but this makes the testcases easier to read
        wait for gCLK_HPER*2;
        -- Test case 2:
        -- Initialize weight value to 10.
        iA   <= '1';  
        iB   <= '0';  
        s    <= '0';
        -- Not strictly necessary, but this makes the testcases easier to read
        wait for gCLK_HPER*2;
        -- Test case 3:
        -- Initialize weight value to 10.
        iA   <= '0';  
        iB   <= '1';  
        s    <= '0';
        -- Not strictly necessary, but this makes the testcases easier to read
        wait for gCLK_HPER*2;
        -- Test case 4:
        -- Initialize weight value to 10.
        iA   <= '1';  
        iB   <= '1';  
        s    <= '0';
        -- Not strictly necessary, but this makes the testcases easier to read
        wait for gCLK_HPER*2;
        -- Test case 5:
        -- Initialize weight value to 10.
        iA   <= '0';  
        iB   <= '0';  
        s    <= '1';
        -- Not strictly necessary, but this makes the testcases easier to read
        wait for gCLK_HPER*2;
        -- Test case 6:
        -- Initialize weight value to 10.
        iA   <= '1';  
        iB   <= '0';  
        s    <= '1';
        -- Not strictly necessary, but this makes the testcases easier to read
        wait for gCLK_HPER*2;
        -- Test case 7:
        -- Initialize weight value to 10.
        iA   <= '0';  
        iB   <= '1';  
        s    <= '1';
        -- Not strictly necessary, but this makes the testcases easier to read
        wait for gCLK_HPER*2;
        -- Test case 8:
        -- Initialize weight value to 10.
        iA   <= '1';  
        iB   <= '1';  
        s    <= '1';
        -- Not strictly necessary, but this makes the testcases easier to read
        wait for gCLK_HPER*2;
    

    


        wait;
    end process;

end mixed;