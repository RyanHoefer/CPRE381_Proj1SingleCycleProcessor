library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mux2t1dflow is

  port(i_D0              : in std_logic;
       i_D1              : in std_logic;
       i_S               : in std_logic;
       o_O               : out std_logic);

end mux2t1dflow;

architecture dataflow of mux2t1dflow is
begin
    o_O <=    i_D0 when (i_S = '0') else
              i_D1 when (i_S = '1') else
              '0';

end dataflow;
