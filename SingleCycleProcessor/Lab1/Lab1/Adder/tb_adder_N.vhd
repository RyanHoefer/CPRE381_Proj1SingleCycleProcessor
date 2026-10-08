library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

entity tb_adder_N is
  generic(gCLK_HPER   : time := 10 ns;
          DATA_WIDTH  : integer := 32);   -- Generic for half of the clock cycle period
end tb_adder_N;


architecture mixed of tb_adder_N is

    -- Define the total clock period time
    constant cCLK_PER  : time := gCLK_HPER * 2;


    component adder_N is
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
        port(
            i_A           : in std_logic_vector(N-1 downto 0);
            i_B           : in std_logic_vector(N-1 downto 0);
            c_in          : in std_logic;
            s             : out std_logic_vector(N-1 downto 0);
            c_out         : out std_logic);
       end component;

    signal CLK, reset : std_logic := '0';
    signal iA      : std_logic_vector(DATA_WIDTH -1 downto 0) := x"00000000";
    signal iB      : std_logic_vector(DATA_WIDTH -1 downto 0) := x"00000000";
    signal cin     : std_logic := '0';
    signal s0      : std_logic_vector(DATA_WIDTH -1 downto 0) := x"00000000";
    signal cout    : std_logic := '0';

    begin
    DUT5: adder_N
    generic map (N => DATA_WIDTH)
    port map(
                i_A     => iA,
                i_B     => iB,
                c_in    => cin,
                s       => s0,
                c_out   => cout);

                
        

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
        iA   <= x"00000005";  
        iB   <= x"00000004";  
        cin   <= '0';  
        wait for gCLK_HPER*2;

        -- Test case 2:
        iA   <= x"00000005";  
        iB   <= x"00000004";  
        cin   <= '1';  

         wait for gCLK_HPER*2;
        

       -- Test case 3:
        iA   <= x"00000060";  
        iB   <= x"00000005";  
        cin   <= '0';   
        wait for gCLK_HPER*2;

        -- Test case 4:
        iA   <= x"FFFFFFFF";  
        iB   <= x"FFFFFFFF";  
        cin   <= '1';  

        wait for gCLK_HPER*2;


        
    

    


        wait;
    end process;

end mixed;