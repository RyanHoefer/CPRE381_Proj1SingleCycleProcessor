-------------------------------------------------------------------------
-- Ryan Hoefer
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- addder_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide Ones Complimentor using structural VHDL, generics, and generate statements.
--
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity adder_N is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(
       i_A          : in std_logic_vector(N-1 downto 0);
       i_B          : in std_logic_vector(N-1 downto 0);
       c_in          : in std_logic;
       s             : out std_logic_vector(N-1 downto 0);
       c_out         : out std_logic);

end adder_N;

architecture structural of adder_N is
  component fulladder is
      port(i_A               : in std_logic;
              i_B            : in std_logic;
              c_in           : in std_logic;
              s              : out std_logic;
              c_out          : out std_logic);
    end component;

    signal carry : std_logic_vector(N downto 0);

begin
-- Instantiate N adder instances.

carry(0) <= c_in;
  G_Adder_N_Bit: for i in 0 to N-1 generate
    GAdder: fulladder port map(
              i_A     => i_A(i),  -- ith instance's data 0 input hooked up to ith data 0 input.
              i_B     => i_B(i),  -- ith instance's data 0 input hooked up to ith data 0 input.
              c_in    => carry(i), 
              c_out   => carry(i+1),
              s      => s(i));  -- ith instance's data output hooked up to ith data output.
  end generate G_Adder_N_Bit;

  c_out <= carry(N);


  
end structural;