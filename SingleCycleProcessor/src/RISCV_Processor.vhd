
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


architecture structureTopLevel of RISCV_Processor is

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
        o_pc_plus4             : out std_logic_vector(31 downto 0);
        o_pc_plus_imm          : out std_logic_vector(31 downto 0) -- to write back to register for jal and jalr
    );
  end component;

  component mux2t1_N is
  generic(N : integer := 16); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_S          : in std_logic;
       i_D0         : in std_logic_vector(N-1 downto 0);
       i_D1         : in std_logic_vector(N-1 downto 0);
       o_O          : out std_logic_vector(N-1 downto 0));

  end component;

  component mux4t1_N is
    generic(N : integer := 16);
    port(
        i_S  : in std_logic_vector(1 downto 0);
        i_D0 : in std_logic_vector(N-1 downto 0);
        i_D1 : in std_logic_vector(N-1 downto 0);
        i_D2 : in std_logic_vector(N-1 downto 0);
        i_D3 : in std_logic_vector(N-1 downto 0);
        o_O  : out std_logic_vector(N-1 downto 0)
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

  component ALU is
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

  end component;

  component extender_N is
    generic(N : integer := 12);
    port(
      i_A	: in  std_logic_vector(N-1 downto 0);
      i_sign : in std_logic;
      o_F	: out std_logic_vector(31 downto 0)
    );
  end component;

  signal ALUSrc, ALUControl, s_memHalfSelect : std_logic;
  signal ImmType,  s_selectAluOut  : std_logic_vector(2 downto 0);
  signal s_rs1, s_rs2  : std_logic_vector(4 downto 0);
  signal ResultSrc, s_selectByte, s_selectDataSize, s_selectByteToStore : std_logic_vector(1 downto 0);
  signal s_sign, s_dir, s_arith, s_storeHalfWordSelect : std_logic;
  signal s_selectedByte : std_logic_vector(7 downto 0);
  signal s_selectedHalf  : std_logic_vector(15 downto 0);
  signal s_memTopHalf, s_memBottomHalf  : std_logic_vector(15 downto 0);
  signal s_firstByte, s_secondByte, s_thirdByte, s_fourthByte : std_logic_vector(7 downto 0);

  signal s_halfBE, s_byteBE : std_logic_vector(3 downto 0);

  signal pc_addr_imm, PCPlusFour,
         writeData, readData1, readData2, aluResult, s_dataFromMemory, s_extendedHalf, s_extendedByte, s_PCPlusImm, s_storeByte0, s_storeByte1, s_storeByte2, s_storeByte3, s_storeHalfWord0, s_storeHalfWord1, s_selectedByteToStore, s_selectedHalfToStore
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
        -- o_RegWrite    => s_RegWr -- needs to be changed according to the new qrite back mux at the bottom
        -- o_sign => s_sign --- sign of extension for lb, lbu,  lh, lhu -- width is (1), for slt it is 1 and sltu it is 0
        -- o_selectDataSize => s_selectDataSize -- width is (2) -- selects between 00 - full word, 01 - half word, 10 - byte. for lw, lh and lb instructions, also used for sw, sh, and sb respectively
        -- o_selectAluOut => s_selectAluOut -- width is (3)  -- selects the output of the alu, based on the mux inside of the alu
        -- o_dir => s_dir -- width is 1  -- selects direction of shifts
        -- o_arith => s_arith  -- width is (1)  -- selects whether shifts are logical or arithmetic
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
        o_pc_plus4    => PCPlusFour,
        o_pc_plus_imm => s_PCPlusImm
    );

    s_RegWrAddr <= s_Inst(11 downto 7);
    s_rs1 <= s_Inst(19 downto 15);
    s_rs2 <= s_Inst(24 downto 20);
  registerFile: register_file
    generic map(N => N)
    port map(
        i_r1          => s_rs1,
        i_r2          => s_rs2,
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

    ALU_inst: ALU
     generic map(N => N)
     port map(
        rs1 => readData1,
        rs2 => readData2,
        i_imm => pc_addr_imm,
        i_selectOutput =>  s_selectAluOut,
        i_aluSrc => ALUSrc,
        i_addSub => ALUControl,
        i_unsigned => not s_sign,
        i_dir => s_dir,
        i_arith => s_arith,
        alu_out => aluResult
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
  

  -- Enable all four bytes for SW
  

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


    byteExtender : extender_N
    generic map(N => 8)
    port map(
        i_A    => s_selectedByte,
        i_sign => s_sign,
        o_F    => s_extendedByte
    );

  halfExtender : extender_N
    generic map(N => 16)
    port map(
        i_A    => s_selectedHalf,
        i_sign => s_sign,
        o_F    => s_extendedHalf
    );

    s_memBottomHalf <= s_DMemOut(15 downto 0);
    s_memTopHalf <= s_DMemOut(31 downto 16);

    s_memHalfSelect <= s_DMemAddr(1);

    halfwordMux : mux2t1_N
    generic map(N => 16)
    port map(
        i_S  => s_memHalfSelect,
        i_D0 => s_memBottomHalf,
        i_D1 => s_memTopHalf,
        o_O  => s_selectedHalf
    );
    s_firstByte  <= s_DMemOut(7 downto 0);
    s_secondByte <= s_DMemOut(15 downto 8);
    s_thirdByte  <= s_DMemOut(23 downto 16);
    s_fourthByte <= s_DMemOut(31 downto 24);

    s_selectByte <= s_DMemAddr(1 downto 0);

    byteMux : mux4t1_N
     generic map(N => 8)
     port map(
        i_S => s_selectByte,
        i_D0 => s_firstByte,
        i_D1 => s_secondByte,
        i_D2 => s_thirdByte,
        i_D3 => s_fourthByte,
        o_O => s_selectedByte
    );

    selectDataFromMemory : mux4t1_N
     generic map(N => 32)
     port map(
        i_S => s_selectDataSize,
        i_D0 => s_DMemOut,
        i_D1 => s_extendedHalf,
        i_D2 => s_extendedByte,
        i_D3 => (others => '0'),
        o_O => s_dataFromMemory
    );

     s_storeByte0  <= X"000000" & readData2(7 downto 0);
    s_storeByte1 <= X"0000" & readData2(7 downto 0) & X"00";
    s_storeByte2  <= X"00" & readData2(7 downto 0) & X"0000";
    s_storeByte3 <= readData2(7 downto 0) & X"000000";
    s_selectByteToStore <= s_DMemAddr(1 downto 0);

    selectByteToStore : mux4t1_N
     generic map(N => 32)
     port map(
        i_S => s_selectByteToStore,
        i_D0 => s_storeByte0,
        i_D1 => s_storeByte1,
        i_D2 => s_storeByte2,
        i_D3 => s_storeByte3,
        o_O => s_selectedByteToStore
    );

    s_storeHalfWord0  <= X"0000" & readData2(15 downto 0);
    s_storeHalfWord1 <= readData2(15 downto 0) & X"0000";
    s_storeHalfWordSelect <= s_DMemAddr(1);

    SelecthalfwordToStore : mux2t1_N
    generic map(N => 32)
    port map(
        i_S  => s_storeHalfWordSelect,
        i_D0 => s_storeHalfWord0,
        i_D1 => s_storeHalfWord1,
        o_O  => s_selectedHalfToStore
    );

    selectByteHalfOrWordToStore : mux4t1_N
     generic map(N => 32)
     port map(
        i_S => s_selectDataSize,
        i_D0 => readData2,
        i_D1 => s_selectedHalfToStore,
        i_D2 => s_selectedByteToStore,
        i_D3 => (others => '0'),
        o_O => s_DMemData
    );

    -- Select what byte to enable for SB
byteEnableMux : mux4t1_N
    generic map(N => 4)
    port map(
        i_S  => s_DMemAddr(1 downto 0),
        i_D0 => "0001",
        i_D1 => "0010",
        i_D2 => "0100",
        i_D3 => "1000",
        o_O  => s_byteBE
    );

-- Select what Half Word to enable for SH
halfEnableMux : mux2t1_N
    generic map(N => 4)
    port map(
        i_S  => s_DMemAddr(1),
        i_D0 => "0011",
        i_D1 => "1100",
        o_O  => s_halfBE
    );

-- Choose what bytes to enable for Dmem
storeSizeEnableMux : mux4t1_N
    generic map(N => 4)
    port map(
        i_S  => s_selectDataSize,
        i_D0 => "1111",   -- 00: SW
        i_D1 => s_halfBE, -- 01: SH
        i_D2 => s_byteBE, -- 10: SB
        i_D3 => "0000",   -- 11: unused
        o_O  => s_DMemBE
    );



  -- Detect WFI instruction
  s_Halt <= '1' when s_Inst = x"10500073" else '0';


  -- Write-back MUX
  with ResultSrc select
    writeData <= aluResult   when "00",
                 s_dataFromMemory   when "01",
                 pc_addr_imm when "10",
                 (others => '0') when others;
--- CHANGE TO THIS:
  -- with ResultSrc select
  --   writeData <= aluResult   when "000",
  --                  s_dataFromMemory   when "001",
  --                  pc_addr_imm when "010", -- LUI
  --                  PCPlusFour  when "011", -- JAL/JALR
  --                  s_PCPlusImm when "100", -- AUIPC
  --                  (others => '0') when others;



end structureTopLevel;
