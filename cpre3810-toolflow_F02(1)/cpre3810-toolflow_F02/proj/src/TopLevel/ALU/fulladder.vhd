-------------------------------------------------------------------------
-- Ryan Hoefer
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- fulladder.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide Ones Complimentor using structural VHDL, generics, and generate statements.
--
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity fulladder is
       port(i_A            : in std_logic;
            i_B            : in std_logic;
            c_in           : in std_logic;
            s              : out std_logic;
            c_out          : out std_logic);

end fulladder;

architecture structural of fulladder is

  component xorg2 is
    port(i_A        : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
  end component;
  component andg2 is
    port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
  end component;
  component org2 is
    port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
  end component;
  signal a1, a2, a3: std_logic;

begin
t1 : xorg2 
    port map (i_A => i_A,
              i_B => i_B,
              o_F => a1);
t2 : xorg2 
    port map (i_A => a1,
              i_B => c_in,
              o_F => s);
t3 : andg2 
    port map (i_A => i_A,
              i_B => i_B,
              o_F => a2);
t4 : andg2 
    port map (i_A => a1,
              i_B => c_in,
              o_F => a3);
t5 : org2
    port map (i_A => a2,
              i_B => a3,
              o_F => c_out);


  
  
end structural;