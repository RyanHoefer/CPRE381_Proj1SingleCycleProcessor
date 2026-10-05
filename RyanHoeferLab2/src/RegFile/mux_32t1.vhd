-------------------------------------------------------------------------
-- Ryan Hoefer
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- mux_32t1.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide Ones Complimentor using structural VHDL, generics, and generate statements.
--
-------------------------------------------------------------------------




library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.mux_types.all;


entity mux_32t1 is
    port (D_IN  : in input_array;
          SEL   : in std_logic_vector(4 downto 0);
          MUX_OUT : out std_logic_vector(31 downto 0));
    end mux_32t1;

architecture dataflow of mux_32t1 is
    begin
    MUX_OUT <= D_IN(to_integer(unsigned(sel)));
end dataflow;