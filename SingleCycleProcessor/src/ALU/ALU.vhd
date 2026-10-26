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
use IEEE.numeric_std.all;

entity ALU is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(
       rs1             : in std_logic_vector(N-1 downto 0);
       rs2             : in std_logic_vector(N-1 downto 0);
       i_imm           : in std_logic_vector(N-1 downto 0);
       i_selectOutput  : in std_logic_vector(2 downto 0);
       i_aluSrc        : in std_logic;
       i_addSub        : in std_logic;
       i_unsigned      : in std_logic;
       i_dir           : in std_logic;
       i_arith         : in std_logic;
       alu_out         : out std_logic_vector(N-1 downto 0));

end ALU;

architecture structural_alu of ALU is
  component addsub_N_for_alu is
       generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
        port(
            i_A           : in std_logic_vector(N-1 downto 0);
            i_B           : in std_logic_vector(N-1 downto 0);
            ctl          : in std_logic;
            s             : out std_logic_vector(N-1 downto 0);
            c_out         : out std_logic);
    end component;



    component barrelShifter is
      Port (  i_A : in std_logic_vector(31 downto 0);
            i_amt : in std_logic_vector(4 downto 0);
            i_dir : in std_logic; --- 0 = right, 1 = left
            i_arith : in std_logic;

            result : out std_logic_vector(31 downto 0));
    end component;


component mux2t1_N is
      generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
            port(i_S     : in std_logic;
            i_D0         : in std_logic_vector(N-1 downto 0);
            i_D1         : in std_logic_vector(N-1 downto 0);
            o_O          : out std_logic_vector(N-1 downto 0));
    end component;

    component and_N is
      generic (N : positive := 32);
    port (
        i_A : in  std_logic_vector(N-1 downto 0);
        i_B : in  std_logic_vector(N-1 downto 0);
        o_F : out std_logic_vector(N-1 downto 0)
    );
    end component;
    component or_N is
      generic (N : positive := 32);
    port (
        i_A : in  std_logic_vector(N-1 downto 0);
        i_B : in  std_logic_vector(N-1 downto 0);
        o_F : out std_logic_vector(N-1 downto 0)
    );
    end component;
    component xor_N is
      generic (N : positive := 32);
    port (
        i_A : in  std_logic_vector(N-1 downto 0);
        i_B : in  std_logic_vector(N-1 downto 0);
        o_F : out std_logic_vector(N-1 downto 0)
    );
    end component;



    signal s_input2        : std_logic_vector(N-1 downto 0);
    signal s_barrelOut, s_addSubOut, s_orOut, s_andOut, s_xorOut, s_sltOut   : std_logic_vector(N-1 downto 0);
    signal PassImmediate     : std_logic;

begin


srcSelect : mux2t1_N
    generic map(N => N)
    port map (i_S => i_aluSrc,
              i_D0 => rs2,
              i_D1 => i_imm,
              o_O => s_input2);
barrelShifterALU : barrelShifter
    port map (i_A => rs1,
              i_amt => s_input2(4 downto 0),
              i_dir => i_dir,
              i_arith => i_arith,
              result => s_barrelOut);
xorGate : xor_N
    generic map(N => N)
    port map (i_A => rs1,
              i_B => s_input2,
              o_F => s_xorOut);
orGate : or_N
    generic map(N => N)
    port map (i_A => rs1,
              i_B => s_input2,
              o_F => s_orOut);
andGate : and_N
    generic map(N => N)
    port map (i_A => rs1,
              i_B => s_input2,
              o_F => s_andOut);
addsub_N_for_alu_inst: addsub_N_for_alu
 generic map(
    N => N
)
 port map(
    i_A => rs1,
    i_B => s_input2,
    ctl => i_addSub,
    s => s_addSubOut,
    c_out => open
);

s_sltOut(N-1 downto 1) <= (others => '0');
s_sltOut(0) <= '1' when (i_unsigned = '0' and signed(rs1) < signed(s_input2)) or (i_unsigned = '1' and unsigned(rs1) < unsigned(s_input2)) else '0';

with i_selectOutput select
    alu_out <= s_addSubOut when "000",
               s_orOut     when "001",
               s_andOut    when "010",
               s_xorOut    when "011",
               s_barrelOut when "100",
               s_sltOut    when "101",
               (others => '0') when others;





  
end structural_alu;