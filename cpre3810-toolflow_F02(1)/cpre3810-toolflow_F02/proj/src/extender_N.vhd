-------------------------------------------------------------------------
-- Ryan Hoefer
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- extender_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide Ones Complimentor using structural VHDL, generics, and generate statements.
--
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity extender_N is
	generic(N : integer := 12);
	port(
		i_A	: in  std_logic_vector(N-1 downto 0);
		i_sign : in std_logic;
		o_F	: out std_logic_vector(31 downto 0)
	);
end extender_N;

architecture dataflow of extender_N is
begin

    o_F(N-1 downto 0) <= i_A;

	G_Extend : for i in N to 31 generate
		o_F(i) <= i_A(N-1) when i_sign = '1' else '0';
	end generate;
end dataflow;