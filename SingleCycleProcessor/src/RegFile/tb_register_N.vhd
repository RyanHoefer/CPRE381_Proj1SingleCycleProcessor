-------------------------------------------------------------------------
-- Joseph Zambreno
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_dffg.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- edge-triggered flip-flop with parallel access and reset.
--
--
-- NOTES:
-- 8/19/16 by JAZ::Design created.
-- 11/25/19 by H3:Changed name to avoid name conflict with Quartus
--          primitives.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_register_N is
  generic(gCLK_HPER   : time := 50 ns;
  DATA_WIDTH  : integer := 32);

end tb_register_N;

architecture behavior of tb_register_N is
  
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;


  component register_N is
    generic(N : integer := 32); 
    Port (  REG_IN : in std_logic_vector(N-1 downto 0);
            LD,CLK,RST : in std_logic;
            REG_OUT : out std_logic_vector(N-1 downto 0));
    
  end component;

  -- Temporary signals to connect to the dff component.
  signal s_CLK, s_RST, s_WE  : std_logic;
  signal s_D, s_Q : std_logic_vector(DATA_WIDTH - 1 downto 0);

begin

  DUT: register_N 
  port map(CLK => s_CLK, 
           RST => s_RST,
           LD  => s_WE,
           REG_IN   => s_D,
           REG_OUT   => s_Q);

  -- This process sets the clock value (low for gCLK_HPER, then high
  -- for gCLK_HPER). Absent a "wait" command, processes restart 
  -- at the beginning once they have reached the final statement.
  P_CLK: process
  begin
    s_CLK <= '0';
    wait for gCLK_HPER;
    s_CLK <= '1';
    wait for gCLK_HPER;
  end process;
  
  -- Testbench process  
  P_TB: process
  begin
    -- reset
    s_RST <= '1';
    s_WE  <= '0';
    s_D   <= x"00000000";
    wait for cCLK_PER;

    -- Store 4
    s_RST <= '0';
    s_WE  <= '1';
    s_D   <= x"00000004";
    wait for cCLK_PER;  

    -- keep 4
    s_RST <= '0';
    s_WE  <= '0';
    s_D   <= x"00000013";
    wait for cCLK_PER;  

    -- Store 567   
    s_RST <= '0';
    s_WE  <= '1';
    s_D   <= x"00000567";
    wait for cCLK_PER;  

    --  dont store FFFFF
    s_RST <= '0';
    s_WE  <= '0';
    s_D   <= x"000FFFFF";
    wait for cCLK_PER;  

    wait;
  end process;
  
end behavior;