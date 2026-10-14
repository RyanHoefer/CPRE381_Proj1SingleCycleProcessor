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

entity zero_appender_N is
	generic(
		N : integer := 20
	);
	port(
		i_A	: in  std_logic_vector(N-1 downto 0);
		o_F	: out std_logic_vector(31 downto 0)
	);
end zero_appender_N;

architecture dataflow of zero_appender_N is
begin

	o_F(31 downto 32-N) <= i_A;

	G_Append : for i in 0 to 31-N generate
		o_F(i) <= '0';
	end generate G_Append;

end dataflow;