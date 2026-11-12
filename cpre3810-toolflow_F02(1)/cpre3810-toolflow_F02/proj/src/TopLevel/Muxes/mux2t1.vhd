library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mux2t1 is

  port(i_D0             : in std_logic;
       i_D1               : in std_logic;
       i_S               : in std_logic;
       o_O               : out std_logic);

end mux2t1;

architecture structure of mux2t1 is

    component andg2 
        port (i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
    end component;

    component invg
    port (i_A          : in std_logic;
       o_F          : out std_logic);
    end component;

    component org2
    port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
    end component;

    component xorg2
    port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
       end component;
       signal sN, a1, a2: std_logic;
begin
    t1 : invg 
    port map (i_A => i_S,
              o_F => sN);
    t2 : andg2 
    port map (i_A => i_D1,
              i_B => i_S,
              o_F => a1);

    t3 : andg2
    port map (i_A => i_D0,
              i_B => sN,
              o_F => a2);
    t4 : org2
    port map (i_A => a1,
              i_B => a2,
              o_F => o_O);
  
end structure;
