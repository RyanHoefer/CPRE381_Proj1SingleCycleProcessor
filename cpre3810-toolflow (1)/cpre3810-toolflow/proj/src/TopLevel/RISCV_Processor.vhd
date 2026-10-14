
-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- RISCV_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a RISCV_Processor
-- implementation.

-- 01/29/2019 by H3::Design created.
-- 04/10/2025 by AP::Coverted to RISC-V.
-- 02/19/2026 by H3::Renamed PC and handled OVFL
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.RISCV_types.all;

entity RISCV_Processor is
  generic(N : integer := DATA_WIDTH);
  port(iCLK            : in std_logic;
       iRST            : in std_logic;
       iInstLd         : in std_logic;
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0);
       oALUOut         : out std_logic_vector(N-1 downto 0)); -- TODO: Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

end RISCV_Processor;


architecture structure of RISCV_Processor is

  -- Required data memory signals
  signal s_DMemWr       : std_logic; -- TODO: use this signal as the final active high data memory write enable signal
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory address input
  signal s_DMemData     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input
  signal s_DMemBE       : std_logic_vector(3 downto 0); -- TODO: enable the addressed byte for SB, halfword for SH, or all bytes for SW
  signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the data memory output

  -- Required register file signals
  signal s_RegWr        : std_logic; -- TODO: use this signal as the final active high write enable input to the register file
  signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- TODO: use this signal as the final destination register address input
  signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input

  -- Required instruction memory signals
  signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_PC instead
  signal s_PC           : std_logic_vector(N-1 downto 0); -- TODO: use this signal as your intended final instruction memory address input.
  signal s_Inst         : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the instruction signal

  -- Required halt signal -- for simulation
  signal s_Halt         : std_logic; -- TODO: this signal indicates to the simulation that intended program execution has completed. (Use WFI with Opcode: 111 0011 func3: 000 and func12: 000100000101 -- func12 is imm field from I-format)

  -- Required overflow signal -- for overflow exception detection
  signal s_Ovfl         : std_logic; -- this signal indicates an overflow exception would have been initiated

  component mem is
    generic(ADDR_WIDTH : integer;
            DATA_WIDTH : integer);
    port(
          clk          : in std_logic;
          addr         : in std_logic_vector((ADDR_WIDTH-1) downto 0);
          data         : in std_logic_vector((DATA_WIDTH-1) downto 0);
          be           : in std_logic_vector(3 downto 0);
          we           : in std_logic := '1';
          q            : out std_logic_vector((DATA_WIDTH-1) downto 0));
  end component;

  component ControlUnit is
    port (
        i_Instruction : in std_logic_vector(31 downto 0);
        o_ALUSrc      : out std_logic;
        o_ALUControl  : out std_logic;
        o_ImmType     : out std_logic_vector(2 downto 0);
        o_ResultSrc   : out std_logic_vector(1 downto 0);
        o_MemWrite    : out std_logic;
        o_RegWrite    : out std_logic
    );
  end component;

  component FetchModule is
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    Port (
        i_rs1_data, i_rs2_data : in std_logic_vector(31 downto 0); -- for branch compares and jal and jalr
        i_instruction          : in std_logic_vector(31 downto 0); -- raw instruction form instruction memory of current instruction
        pc_addr_imm            : in std_logic_vector(31 downto 0); -- immediate offset value for jal and jalr
        CLK, reset             : in std_logic;
        o_pc                   : out std_logic_vector(31 downto 0); -- to the instruciton memory for the next instruction
        o_pc_plus4             : out std_logic_vector(31 downto 0) -- to write back to register for jal and jalr
    );
  end component;

  component register_file is
    generic(N : integer := 32);
    Port (
        i_r1, i_r2     : in std_logic_vector(4 downto 0);
        i_w            : in std_logic_vector(4 downto 0);
        i_writeData    : in std_logic_vector(31 downto 0);
        i_writeEnable  : in std_logic;
        CLK            : in std_logic;
        o_data1        : out std_logic_vector(31 downto 0);
        o_data2        : out std_logic_vector(31 downto 0)
    );
  end component;

  component ImmediateGenerator is
    port (
        i_Instruction : in std_logic_vector(31 downto 0);
        i_ImmType     : in std_logic_vector(2 downto 0);
        o_Immediate   : out std_logic_vector(31 downto 0)
    );
  end component;

  component addsub_N_with_imm is
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    port(
        i_A      : in std_logic_vector(N-1 downto 0);
        i_B      : in std_logic_vector(N-1 downto 0);
        i_imm    : in std_logic_vector(N-1 downto 0);
        ctl      : in std_logic;
        i_aluSrc : in std_logic;
        s        : out std_logic_vector(N-1 downto 0);
        c_out    : out std_logic
    );
  end component;

  signal ALUSrc, ALUControl, MemWrite, RegWrite, writeEnable : std_logic;
  signal ImmType  : std_logic_vector(2 downto 0);
  signal ResultSrc : std_logic_vector(1 downto 0);

  signal rs1_data, rs2_data, pc_addr_imm, PCPlusFour,
         writeData, readData1, readData2, aluResult
         : std_logic_vector(31 downto 0);

  -- TODO: You may add any additional signals or components your implementation
  --       requires below this comment

begin

  s_Ovfl <= '0'; -- RISC-V does not have hardware overflow detection.

  -- Connect ALU output for synthesis
  oALUOut <= aluResult;

  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  with iInstLd select
    s_IMemAddr <= s_PC when '0',
                  iInstAddr when others;

  instructionDecoder: ControlUnit
    port map(
        i_Instruction => s_Inst,
        o_ALUSrc      => ALUSrc,
        o_ALUControl  => ALUControl,
        o_ImmType     => ImmType,
        o_ResultSrc   => ResultSrc,
        o_MemWrite    => s_DMemWr,
        o_RegWrite    => s_RegWr
    );

  RyanFetchModule: FetchModule
    port map(
        i_instruction => s_Inst,
        i_rs1_data    => readData1,
        i_rs2_data    => readData2,
        pc_addr_imm   => pc_addr_imm,
        CLK           => iCLK,
        reset         => iRST,
        o_pc          => s_PC,
        o_pc_plus4    => PCPlusFour
    );

  registerFile: register_file
    generic map(N => N)
    port map(
        i_r1          => s_Inst(19 downto 15),
        i_r2          => s_Inst(24 downto 20),
        i_w           => s_Inst(11 downto 7),
        i_writeData   => writeData,
        i_writeEnable => s_RegWr,
        CLK           => iCLK,
        o_data1       => readData1,
        o_data2       => readData2
    );

  immeGenerator: ImmediateGenerator
    port map(
        i_Instruction => s_Inst,
        i_ImmType     => ImmType,
        o_Immediate   => pc_addr_imm
    );

  addsub: addsub_N_with_imm
    generic map(N => N)
    port map(
        i_A      => readData1,
        i_B      => readData2,
        i_imm    => pc_addr_imm,
        ctl      => ALUControl,
        i_aluSrc => ALUSrc,
        s        => aluResult,
        c_out    => open
    );

  IMem: mem
    generic map(
        ADDR_WIDTH => ADDR_WIDTH,
        DATA_WIDTH => N
    )
    port map(
        clk  => iCLK,
        addr => s_IMemAddr(11 downto 2),
        data => iInstExt,
        be   => "1111",
        we   => iInstLd,
        q    => s_Inst
    );

  s_DMemAddr <= aluResult; -- these are here to keep our names and provided skeleton names the same
  s_DMemData <= readData2;

  -- Enable all four bytes for SW
  s_DMemBE <= "1111";

  DMem: mem
    generic map(
        ADDR_WIDTH => ADDR_WIDTH,
        DATA_WIDTH => N
    )
    port map(
        clk  => iCLK,
        addr => s_DMemAddr(11 downto 2),
        data => s_DMemData,
        be   => s_DMemBE,
        we   => s_DMemWr,
        q    => s_DMemOut
    );

  -- Detect WFI instruction
  s_Halt <= '1' when s_Inst = x"10500073" else '0';

  -- TODO: Implement the rest of your processor below this comment!

  -- Write-back MUX
  with ResultSrc select
    writeData <= aluResult   when "00",
                 s_DMemOut   when "01",
                 pc_addr_imm when "10",
                 (others => '0') when others;

end structure;
-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- RISCV_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a RISCV_Processor
-- implementation.

-- 01/29/2019 by H3::Design created.
-- 04/10/2025 by AP::Coverted to RISC-V.
-- 02/19/2026 by H3::Renamed PC and handled OVFL
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.RISCV_types.all;

entity RISCV_Processor is
  generic(N : integer := DATA_WIDTH);
  port(iCLK            : in std_logic;
       iRST            : in std_logic;
       iInstLd         : in std_logic;
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0);
       oALUOut         : out std_logic_vector(N-1 downto 0)); -- TODO: Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

end RISCV_Processor;


architecture structure of RISCV_Processor is

  -- Required data memory signals
  signal s_DMemWr       : std_logic; -- TODO: use this signal as the final active high data memory write enable signal
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory address input
  signal s_DMemData     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input
  signal s_DMemBE       : std_logic_vector(3 downto 0); -- TODO: enable the addressed byte for SB, halfword for SH, or all bytes for SW
  signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the data memory output

  -- Required register file signals
  signal s_RegWr        : std_logic; -- TODO: use this signal as the final active high write enable input to the register file
  signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- TODO: use this signal as the final destination register address input
  signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input

  -- Required instruction memory signals
  signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_PC instead
  signal s_PC           : std_logic_vector(N-1 downto 0); -- TODO: use this signal as your intended final instruction memory address input.
  signal s_Inst         : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the instruction signal

  -- Required halt signal -- for simulation
  signal s_Halt         : std_logic; -- TODO: this signal indicates to the simulation that intended program execution has completed. (Use WFI with Opcode: 111 0011 func3: 000 and func12: 000100000101 -- func12 is imm field from I-format)

  -- Required overflow signal -- for overflow exception detection
  signal s_Ovfl         : std_logic; -- this signal indicates an overflow exception would have been initiated

  component mem is
    generic(ADDR_WIDTH : integer;
            DATA_WIDTH : integer);
    port(
          clk          : in std_logic;
          addr         : in std_logic_vector((ADDR_WIDTH-1) downto 0);
          data         : in std_logic_vector((DATA_WIDTH-1) downto 0);
          be           : in std_logic_vector(3 downto 0);
          we           : in std_logic := '1';
          q            : out std_logic_vector((DATA_WIDTH-1) downto 0));
  end component;

  component ControlUnit is
    port (
        i_Instruction : in std_logic_vector(31 downto 0);
        o_ALUSrc      : out std_logic;
        o_ALUControl  : out std_logic;
        o_ImmType     : out std_logic_vector(2 downto 0);
        o_ResultSrc   : out std_logic_vector(1 downto 0);
        o_MemWrite    : out std_logic;
        o_RegWrite    : out std_logic
    );
  end component;

  component FetchModule is
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    Port (
        i_rs1_data, i_rs2_data : in std_logic_vector(31 downto 0); -- for branch compares and jal and jalr
        i_instruction          : in std_logic_vector(31 downto 0); -- raw instruction form instruction memory of current instruction
        pc_addr_imm            : in std_logic_vector(31 downto 0); -- immediate offset value for jal and jalr
        CLK, reset             : in std_logic;
        o_pc                   : out std_logic_vector(31 downto 0); -- to the instruciton memory for the next instruction
        o_pc_plus4             : out std_logic_vector(31 downto 0) -- to write back to register for jal and jalr
    );
  end component;

  component register_file is
    generic(N : integer := 32);
    Port (
        i_r1, i_r2     : in std_logic_vector(4 downto 0);
        i_w            : in std_logic_vector(4 downto 0);
        i_writeData    : in std_logic_vector(31 downto 0);
        i_writeEnable  : in std_logic;
        CLK            : in std_logic;
        o_data1        : out std_logic_vector(31 downto 0);
        o_data2        : out std_logic_vector(31 downto 0)
    );
  end component;

  component ImmediateGenerator is
    port (
        i_Instruction : in std_logic_vector(31 downto 0);
        i_ImmType     : in std_logic_vector(2 downto 0);
        o_Immediate   : out std_logic_vector(31 downto 0)
    );
  end component;

  component addsub_N_with_imm is
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    port(
        i_A      : in std_logic_vector(N-1 downto 0);
        i_B      : in std_logic_vector(N-1 downto 0);
        i_imm    : in std_logic_vector(N-1 downto 0);
        ctl      : in std_logic;
        i_aluSrc : in std_logic;
        s        : out std_logic_vector(N-1 downto 0);
        c_out    : out std_logic
    );
  end component;

  signal ALUSrc, ALUControl, MemWrite, RegWrite, writeEnable : std_logic;
  signal ImmType  : std_logic_vector(2 downto 0);
  signal ResultSrc : std_logic_vector(1 downto 0);

  signal rs1_data, rs2_data, pc_addr_imm, PCPlusFour,
         writeData, readData1, readData2, aluResult
         : std_logic_vector(31 downto 0);

  -- TODO: You may add any additional signals or components your implementation
  --       requires below this comment

begin

  s_Ovfl <= '0'; -- RISC-V does not have hardware overflow detection.

  -- Connect ALU output for synthesis
  oALUOut <= aluResult;
  s_RegWrData <= writeData;

  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  with iInstLd select
    s_IMemAddr <= s_PC when '0',
                  iInstAddr when others;

  instructionDecoder: ControlUnit
    port map(
        i_Instruction => s_Inst,
        o_ALUSrc      => ALUSrc,
        o_ALUControl  => ALUControl,
        o_ImmType     => ImmType,
        o_ResultSrc   => ResultSrc,
        o_MemWrite    => s_DMemWr,
        o_RegWrite    => s_RegWr
    );

  RyanFetchModule: FetchModule
    port map(
        i_instruction => s_Inst,
        i_rs1_data    => readData1,
        i_rs2_data    => readData2,
        pc_addr_imm   => pc_addr_imm,
        CLK           => iCLK,
        reset         => iRST,
        o_pc          => s_PC,
        o_pc_plus4    => PCPlusFour
    );

    s_RegWrAddr <= s_Inst(11 downto 7);
  registerFile: register_file
    generic map(N => N)
    port map(
        i_r1          => s_Inst(19 downto 15),
        i_r2          => s_Inst(24 downto 20),
        i_w           => s_RegWrAddr,
        i_writeData   => s_RegWrData,
        i_writeEnable => s_RegWr,
        CLK           => iCLK,
        o_data1       => readData1,
        o_data2       => readData2
    );

  immeGenerator: ImmediateGenerator
    port map(
        i_Instruction => s_Inst,
        i_ImmType     => ImmType,
        o_Immediate   => pc_addr_imm
    );

  addsub: addsub_N_with_imm
    generic map(N => N)
    port map(
        i_A      => readData1,
        i_B      => readData2,
        i_imm    => pc_addr_imm,
        ctl      => ALUControl,
        i_aluSrc => ALUSrc,
        s        => aluResult,
        c_out    => open
    );

  IMem: mem
    generic map(
        ADDR_WIDTH => ADDR_WIDTH,
        DATA_WIDTH => N
    )
    port map(
        clk  => iCLK,
        addr => s_IMemAddr(11 downto 2),
        data => iInstExt,
        be   => "1111",
        we   => iInstLd,
        q    => s_Inst
    );

  s_DMemAddr <= aluResult; -- these are here to keep our names and provided skeleton names the same
  s_DMemData <= readData2;

  -- Enable all four bytes for SW
  s_DMemBE <= "1111";

  DMem: mem
    generic map(
        ADDR_WIDTH => ADDR_WIDTH,
        DATA_WIDTH => N
    )
    port map(
        clk  => iCLK,
        addr => s_DMemAddr(11 downto 2),
        data => s_DMemData,
        be   => s_DMemBE,
        we   => s_DMemWr,
        q    => s_DMemOut
    );

  -- Detect WFI instruction
  s_Halt <= '1' when s_Inst = x"10500073" else '0';

  -- TODO: Implement the rest of your processor below this comment!

  -- Write-back MUX
  with ResultSrc select
    writeData <= aluResult   when "00",
                 s_DMemOut   when "01",
                 pc_addr_imm when "10",
                 (others => '0') when others;

end structure;
-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- RISCV_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a RISCV_Processor
-- implementation.

-- 01/29/2019 by H3::Design created.
-- 04/10/2025 by AP::Coverted to RISC-V.
-- 02/19/2026 by H3::Renamed PC and handled OVFL
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.RISCV_types.all;

entity RISCV_Processor is
  generic(N : integer := DATA_WIDTH);
  port(iCLK            : in std_logic;
       iRST            : in std_logic;
       iInstLd         : in std_logic;
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0);
       oALUOut         : out std_logic_vector(N-1 downto 0)); -- TODO: Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

end RISCV_Processor;


architecture structure of RISCV_Processor is

  -- Required data memory signals
  signal s_DMemWr       : std_logic; -- TODO: use this signal as the final active high data memory write enable signal
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory address input
  signal s_DMemData     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input
  signal s_DMemBE       : std_logic_vector(3 downto 0); -- TODO: enable the addressed byte for SB, halfword for SH, or all bytes for SW
  signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the data memory output

  -- Required register file signals
  signal s_RegWr        : std_logic; -- TODO: use this signal as the final active high write enable input to the register file
  signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- TODO: use this signal as the final destination register address input
  signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input

  -- Required instruction memory signals
  signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_PC instead
  signal s_PC           : std_logic_vector(N-1 downto 0); -- TODO: use this signal as your intended final instruction memory address input.
  signal s_Inst         : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the instruction signal

  -- Required halt signal -- for simulation
  signal s_Halt         : std_logic; -- TODO: this signal indicates to the simulation that intended program execution has completed. (Use WFI with Opcode: 111 0011 func3: 000 and func12: 000100000101 -- func12 is imm field from I-format)

  -- Required overflow signal -- for overflow exception detection
  signal s_Ovfl         : std_logic; -- this signal indicates an overflow exception would have been initiated

  component mem is
    generic(ADDR_WIDTH : integer;
            DATA_WIDTH : integer);
    port(
          clk          : in std_logic;
          addr         : in std_logic_vector((ADDR_WIDTH-1) downto 0);
          data         : in std_logic_vector((DATA_WIDTH-1) downto 0);
          be           : in std_logic_vector(3 downto 0);
          we           : in std_logic := '1';
          q            : out std_logic_vector((DATA_WIDTH-1) downto 0));
  end component;

  component ControlUnit is
    port (
        i_Instruction : in std_logic_vector(31 downto 0);
        o_ALUSrc      : out std_logic;
        o_ALUControl  : out std_logic;
        o_ImmType     : out std_logic_vector(2 downto 0);
        o_ResultSrc   : out std_logic_vector(1 downto 0);
        o_MemWrite    : out std_logic;
        o_RegWrite    : out std_logic
    );
  end component;

  component FetchModule is
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    Port (
        i_rs1_data, i_rs2_data : in std_logic_vector(31 downto 0); -- for branch compares and jal and jalr
        i_instruction          : in std_logic_vector(31 downto 0); -- raw instruction form instruction memory of current instruction
        pc_addr_imm            : in std_logic_vector(31 downto 0); -- immediate offset value for jal and jalr
        CLK, reset             : in std_logic;
        o_pc                   : out std_logic_vector(31 downto 0); -- to the instruciton memory for the next instruction
        o_pc_plus4             : out std_logic_vector(31 downto 0) -- to write back to register for jal and jalr
    );
  end component;

  component register_file is
    generic(N : integer := 32);
    Port (
        i_r1, i_r2     : in std_logic_vector(4 downto 0);
        i_w            : in std_logic_vector(4 downto 0);
        i_writeData    : in std_logic_vector(31 downto 0);
        i_writeEnable  : in std_logic;
        CLK            : in std_logic;
        o_data1        : out std_logic_vector(31 downto 0);
        o_data2        : out std_logic_vector(31 downto 0)
    );
  end component;

  component ImmediateGenerator is
    port (
        i_Instruction : in std_logic_vector(31 downto 0);
        i_ImmType     : in std_logic_vector(2 downto 0);
        o_Immediate   : out std_logic_vector(31 downto 0)
    );
  end component;

  component addsub_N_with_imm is
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    port(
        i_A      : in std_logic_vector(N-1 downto 0);
        i_B      : in std_logic_vector(N-1 downto 0);
        i_imm    : in std_logic_vector(N-1 downto 0);
        ctl      : in std_logic;
        i_aluSrc : in std_logic;
        s        : out std_logic_vector(N-1 downto 0);
        c_out    : out std_logic
    );
  end component;

  signal ALUSrc, ALUControl, MemWrite, RegWrite, writeEnable : std_logic;
  signal ImmType  : std_logic_vector(2 downto 0);
  signal ResultSrc : std_logic_vector(1 downto 0);

  signal rs1_data, rs2_data, pc_addr_imm, PCPlusFour,
         writeData, readData1, readData2, aluResult
         : std_logic_vector(31 downto 0);

  -- TODO: You may add any additional signals or components your implementation
  --       requires below this comment

begin

  s_Ovfl <= '0'; -- RISC-V does not have hardware overflow detection.

  -- Connect ALU output for synthesis
  oALUOut <= aluResult;
  s_RegWrData <= writeData;

  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  with iInstLd select
    s_IMemAddr <= s_PC when '0',
                  iInstAddr when others;

  instructionDecoder: ControlUnit
    port map(
        i_Instruction => s_Inst,
        o_ALUSrc      => ALUSrc,
        o_ALUControl  => ALUControl,
        o_ImmType     => ImmType,
        o_ResultSrc   => ResultSrc,
        o_MemWrite    => s_DMemWr,
        o_RegWrite    => s_RegWr
    );

  RyanFetchModule: FetchModule
    port map(
        i_instruction => s_Inst,
        i_rs1_data    => readData1,
        i_rs2_data    => readData2,
        pc_addr_imm   => pc_addr_imm,
        CLK           => iCLK,
        reset         => iRST,
        o_pc          => s_PC,
        o_pc_plus4    => PCPlusFour
    );

    s_RegWrAddr <= s_Inst(11 downto 7);
  registerFile: register_file
    generic map(N => N)
    port map(
        i_r1          => s_Inst(19 downto 15),
        i_r2          => s_Inst(24 downto 20),
        i_w           => s_RegWrAddr,
        i_writeData   => s_RegWrData,
        i_writeEnable => s_RegWr,
        CLK           => iCLK,
        o_data1       => readData1,
        o_data2       => readData2
    );

  immeGenerator: ImmediateGenerator
    port map(
        i_Instruction => s_Inst,
        i_ImmType     => ImmType,
        o_Immediate   => pc_addr_imm
    );

  addsub: addsub_N_with_imm
    generic map(N => N)
    port map(
        i_A      => readData1,
        i_B      => readData2,
        i_imm    => pc_addr_imm,
        ctl      => ALUControl,
        i_aluSrc => ALUSrc,
        s        => aluResult,
        c_out    => open
    );

  IMem: mem
    generic map(
        ADDR_WIDTH => ADDR_WIDTH,
        DATA_WIDTH => N
    )
    port map(
        clk  => iCLK,
        addr => s_IMemAddr(11 downto 2),
        data => iInstExt,
        be   => "1111",
        we   => iInstLd,
        q    => s_Inst
    );

  s_DMemAddr <= aluResult; -- these are here to keep our names and provided skeleton names the same
  s_DMemData <= readData2;

  -- Enable all four bytes for SW
  s_DMemBE <= "1111";

  DMem: mem
    generic map(
        ADDR_WIDTH => ADDR_WIDTH,
        DATA_WIDTH => N
    )
    port map(
        clk  => iCLK,
        addr => s_DMemAddr(11 downto 2),
        data => s_DMemData,
        be   => s_DMemBE,
        we   => s_DMemWr,
        q    => s_DMemOut
    );

  -- Detect WFI instruction
  s_Halt <= '1' when s_Inst = x"10500073" else '0';

  -- TODO: Implement the rest of your processor below this comment!

  -- Write-back MUX
  with ResultSrc select
    writeData <= aluResult   when "00",
                 s_DMemOut   when "01",
                 pc_addr_imm when "10",
                 (others => '0') when others;

end structure;