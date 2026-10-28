-- library declaration
library IEEE;
use IEEE.std_logic_1164.all;
-- entity
entity barrelShifter is
    Port (  i_A : in std_logic_vector(31 downto 0);
            i_amt : in std_logic_vector(4 downto 0);
            i_dir : in std_logic; --- 0 = right, 1 = left
            i_arith : in std_logic;

            result : out std_logic_vector(31 downto 0));

end barrelShifter;
-- architecture
architecture barrelShifterArc of barrelShifter is


    component mux2t1_N is
      generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
            port(i_S     : in std_logic;
            i_D0         : in std_logic_vector(N-1 downto 0);
            i_D1         : in std_logic_vector(N-1 downto 0);
            o_O          : out std_logic_vector(N-1 downto 0));
    end component;

signal firstToSecond, secondToThird, thirdToFourth, fourthToFifth, reversedInput, firstInput, shiftResult, reversedResult : std_logic_vector(31 downto 0);
signal extendBit : std_logic;


begin

reversedBits : for i in 0 to 31 generate 
    reversedInput(i) <= i_A(31 - i);
    reversedResult(i) <= shiftResult(31 - i);
end generate reversedBits;


extendBit <= i_A(31) when i_arith = '1' and i_dir = '0' else '0';

selectInputMux : mux2t1_N
    generic map(N => 32)
    port map (i_S => i_dir,
              i_D0 => i_A,
              i_D1 => reversedInput,
              o_O => firstInput);


firstMux : mux2t1_N
    generic map(N => 32)
    port map (i_S => i_amt(0),
              i_D0 => firstInput,
              i_D1 => extendBit & firstInput(31 downto 1),
              o_O => firstToSecond);

secondMux : mux2t1_N
    generic map(N => 32)
    port map (i_S => i_amt(1),
              i_D0 => firstToSecond,
              i_D1 => extendBit & extendBit & firstToSecond(31 downto 2),
              o_O => secondToThird);

thirdMux : mux2t1_N
    generic map(N => 32)
    port map (i_S => i_amt(2),
              i_D0 => secondToThird,
              i_D1 => extendBit & extendBit & extendBit & extendBit & secondToThird(31 downto 4),
              o_O => thirdToFourth);

fourthMux : mux2t1_N
    generic map(N => 24)
    port map (i_S => i_amt(3),
              i_D0 => thirdToFourth,
              i_D1 => extendBit & extendBit & extendBit & extendBit & extendBit & extendBit & extendBit & extendBit &  thirdToFourth(31 downto 8),
              o_O => fourthToFifth);

fifthMux : mux2t1_N
    generic map(N => 32)
    port map (i_S => i_amt(4),
              i_D0 => fourthToFifth,
              i_D1 => extendBit & extendBit & extendBit & extendBit & extendBit & extendBit & extendBit & extendBit & extendBit & extendBit & extendBit & extendBit & extendBit & extendBit & extendBit & extendBit & fourthToFifth(31 downto 16),
              o_O => shiftResult);

selectOutputMux : mux2t1_N
    generic map(N => 32)
    port map (i_S => i_dir,
              i_D0 => shiftResult,
              i_D1 => reversedResult,
              o_O => result);



   
end barrelShifterArc;