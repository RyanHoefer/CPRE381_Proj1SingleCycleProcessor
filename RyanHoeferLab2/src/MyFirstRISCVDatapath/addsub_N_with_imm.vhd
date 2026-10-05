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

entity addsub_N_with_imm is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(
       i_A           : in std_logic_vector(N-1 downto 0);
       i_B           : in std_logic_vector(N-1 downto 0);
       i_imm         : in std_logic_vector(N-1 downto 0);
       ctl           : in std_logic;
       i_aluSrc      : in std_logic;
       s             : out std_logic_vector(N-1 downto 0);
       c_out         : out std_logic);

end addsub_N_with_imm;

architecture structural of addsub_N_with_imm is
  component adder_N is
      generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
        port(
            i_A          : in std_logic_vector(N-1 downto 0);
            i_B          : in std_logic_vector(N-1 downto 0);
            c_in         : in std_logic;
            s            : out std_logic_vector(N-1 downto 0);
            c_out        : out std_logic);
    end component;

    component onescomp_N is
      generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
            port(
            i_A          : in std_logic_vector(N-1 downto 0);
            o_F          : out std_logic_vector(N-1 downto 0));
    end component;


component mux2t1_N is
      generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
            port(i_S     : in std_logic;
            i_D0         : in std_logic_vector(N-1 downto 0);
            i_D1         : in std_logic_vector(N-1 downto 0);
            o_O          : out std_logic_vector(N-1 downto 0));
    end component;


    signal BN, MuxB, muxImm: std_logic_vector(N-1 downto 0);
    signal AddResult         : std_logic_vector(N-1 downto 0);
    signal PassImmediate     : std_logic;

begin

t1 : entity work.onescomp_N
    generic map(N => N)
    port map (i_A => i_B,
              o_F => BN);
t2 : entity work.mux2t1_N
    generic map(N => N)
    port map (i_S => ctl,
              i_D0 => i_B,
              i_D1 => BN,
              o_O => MuxB);

t3 : entity work.mux2t1_N
	generic map(N => N)
	port map (i_s => i_aluSrc,
			  i_D0 => MuxB,
			  i_D1 => i_imm,
			  o_O => MuxImm);

t4 : entity work.adder_N
    generic map(N => N)
    port map (i_A => i_A,
              i_B => MuxImm,
              c_in => ctl,
              s => AddResult,
              c_out => c_out);

PassImmediate <= ctl and i_aluSrc;

t5 : entity work.mux2t1_N
  generic map (N => N)
            port map (
                i_s  => PassImmediate,
                i_D0 => AddResult,
                i_D1 => i_imm,
                o_O  => s);



  
end structural;