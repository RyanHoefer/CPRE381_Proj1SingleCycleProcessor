-------------------------------------------------------------------------
-- Ryan Hoefer
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- mux2t1_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide Ones Complimentor using structural VHDL, generics, and generate statements.
--
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity onescomp_N is
  generic(N : integer := 16); -- Generic of type integer for input/output data width. Default value is 32.
  port(
       i_A         : in std_logic_vector(N-1 downto 0);
       o_F          : out std_logic_vector(N-1 downto 0));

end onescomp_N;

architecture structural of onescomp_N is

  component invg is
    port(i_A          : in std_logic;
       o_F          : out std_logic);
  end component;

begin

  -- Instantiate N not gate instances.
  G_OnesComp_N_Bit: for i in 0 to N-1 generate
    OnesC: invg port map(
              i_A     => i_A(i),  -- ith instance's data 0 input hooked up to ith data 0 input.
              o_F      => o_F(i));  -- ith instance's data output hooked up to ith data output.
  end generate G_OnesComp_N_Bit;
  
end structural;