
-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------

-- RISCV_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a RISCV_Processor
-- implementation.
--
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
  port(
       iCLK      : in std_logic;
       iRST      : in std_logic;
       iInstLd   : in std_logic;
       iInstAddr : in std_logic_vector(N-1 downto 0);
       iInstExt  : in std_logic_vector(N-1 downto 0);
       oALUOut   : out std_logic_vector(N-1 downto 0)
  );
end RISCV_Processor;

architecture structureTopLevel of RISCV_Processor is

  -- Required data memory signals
  signal s_DMemWr   : std_logic;
  signal s_DMemAddr : std_logic_vector(N-1 downto 0);
  signal s_DMemData : std_logic_vector(N-1 downto 0);
  signal s_DMemBE   : std_logic_vector(3 downto 0);
  signal s_DMemOut  : std_logic_vector(N-1 downto 0);

  -- Required register file signals
  signal s_RegWr     : std_logic;
  signal s_RegWrAddr : std_logic_vector(4 downto 0);
  signal s_RegWrData : std_logic_vector(N-1 downto 0);

  -- Required instruction memory signals
  signal s_IMemAddr : std_logic_vector(N-1 downto 0);
  signal s_PC       : std_logic_vector(N-1 downto 0);
  signal s_Inst     : std_logic_vector(N-1 downto 0);

  -- Required halt signal
  signal s_Halt : std_logic;

  -- Required overflow signal
  signal s_Ovfl : std_logic;

  component mem is
    generic(
      ADDR_WIDTH : integer;
      DATA_WIDTH : integer
    );
    port(
      clk  : in std_logic;
      addr : in std_logic_vector((ADDR_WIDTH-1) downto 0);
      data : in std_logic_vector((DATA_WIDTH-1) downto 0);
      be   : in std_logic_vector(3 downto 0);
      we   : in std_logic := '1';
      q    : out std_logic_vector((DATA_WIDTH-1) downto 0)
    );
  end component;

  -- Tariq: Updated the Control Unit interface to include
  -- the new ALU, memory size, and shift control signals.
  component ControlUnit is
    port(
      i_Instruction    : in std_logic_vector(31 downto 0);
      o_ALUSrc         : out std_logic;
      o_ALUControl     : out std_logic;
      o_ImmType        : out std_logic_vector(2 downto 0);
      o_ResultSrc      : out std_logic_vector(2 downto 0);
      o_MemWrite       : out std_logic;
      o_RegWrite       : out std_logic;
      o_sign           : out std_logic;
      o_selectDataSize : out std_logic_vector(1 downto 0);
      o_selectAluOut   : out std_logic_vector(2 downto 0);
      o_dir            : out std_logic;
      o_arith          : out std_logic
    );
  end component;

  component FetchModule is
    generic(N : integer := 32);
    port(
      i_rs1_data    : in std_logic_vector(31 downto 0);
      i_rs2_data    : in std_logic_vector(31 downto 0);
      i_instruction : in std_logic_vector(31 downto 0);
      pc_addr_imm   : in std_logic_vector(31 downto 0);
      CLK           : in std_logic;
      reset         : in std_logic;
      o_pc          : out std_logic_vector(31 downto 0);
      o_pc_plus4    : out std_logic_vector(31 downto 0);
      o_pc_plus_imm : out std_logic_vector(31 downto 0)
    );
  end component;

  component mux2t1_N is
    generic(N : integer := 16);
    port(
      i_S  : in std_logic;
      i_D0 : in std_logic_vector(N-1 downto 0);
      i_D1 : in std_logic_vector(N-1 downto 0);
      o_O  : out std_logic_vector(N-1 downto 0)
    );
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
    port(
      i_r1          : in std_logic_vector(4 downto 0);
      i_r2          : in std_logic_vector(4 downto 0);
      i_w           : in std_logic_vector(4 downto 0);
      i_writeData   : in std_logic_vector(31 downto 0);
      i_writeEnable : in std_logic;
      CLK           : in std_logic;
      o_data1       : out std_logic_vector(31 downto 0);
      o_data2       : out std_logic_vector(31 downto 0)
    );
  end component;

  component ImmediateGenerator is
    port(
      i_Instruction : in std_logic_vector(31 downto 0);
      i_ImmType     : in std_logic_vector(2 downto 0);
      o_Immediate   : out std_logic_vector(31 downto 0)
    );
  end component;

  component ALU is
    generic(N : integer := 32);
    port(
      rs1            : in std_logic_vector(N-1 downto 0);
      rs2            : in std_logic_vector(N-1 downto 0);
      i_imm          : in std_logic_vector(N-1 downto 0);
      i_selectOutput : in std_logic_vector(2 downto 0);
      i_aluSrc       : in std_logic;
      i_addSub       : in std_logic;
      i_unsigned     : in std_logic;
      i_dir          : in std_logic;
      i_arith        : in std_logic;
      alu_out        : out std_logic_vector(N-1 downto 0)
    );
  end component;

  component extender_N is
    generic(N : integer := 12);
    port(
      i_A    : in std_logic_vector(N-1 downto 0);
      i_sign : in std_logic;
      o_F    : out std_logic_vector(31 downto 0)
    );
  end component;

  -- Control signals
  signal ALUSrc, ALUControl, s_memHalfSelect : std_logic;
  signal ImmType, s_selectAluOut : std_logic_vector(2 downto 0);
  signal s_rs1, s_rs2 : std_logic_vector(4 downto 0);

  -- Tariq: ResultSrc is now 3 bits to support five writeback sources.
  signal ResultSrc : std_logic_vector(2 downto 0);

  signal s_selectByte, s_selectDataSize,
         s_selectByteToStore : std_logic_vector(1 downto 0);

  signal s_sign, s_dir, s_arith,
         s_storeHalfWordSelect : std_logic;

  signal s_selectedByte : std_logic_vector(7 downto 0);
  signal s_selectedHalf : std_logic_vector(15 downto 0);

  signal s_memTopHalf, s_memBottomHalf :
         std_logic_vector(15 downto 0);

  signal s_firstByte, s_secondByte,
         s_thirdByte, s_fourthByte :
         std_logic_vector(7 downto 0);

  signal s_halfBE, s_byteBE : std_logic_vector(3 downto 0);

  signal pc_addr_imm, PCPlusFour,
         writeData, readData1, readData2,
         aluResult, s_dataFromMemory,
         s_extendedHalf, s_extendedByte,
         s_PCPlusImm, s_storeByte0,
         s_storeByte1, s_storeByte2,
         s_storeByte3, s_storeHalfWord0,
         s_storeHalfWord1, s_selectedByteToStore,
         s_selectedHalfToStore
         : std_logic_vector(31 downto 0);

begin

  -- RISC-V does not have hardware overflow detection.
  s_Ovfl <= '0';

  -- Connect ALU output for synthesis
  oALUOut <= aluResult;
  s_RegWrData <= writeData;

  -- Instruction memory address selection
  with iInstLd select
    s_IMemAddr <= s_PC when '0',
                  iInstAddr when others;

  -- Tariq: Connected all new Control Unit signals
  -- to the existing processor datapath.
  instructionDecoder: ControlUnit
    port map(
      i_Instruction    => s_Inst,
      o_ALUSrc         => ALUSrc,
      o_ALUControl     => ALUControl,
      o_ImmType        => ImmType,
      o_ResultSrc      => ResultSrc,
      o_MemWrite       => s_DMemWr,
      o_RegWrite       => s_RegWr,
      o_sign           => s_sign,
      o_selectDataSize => s_selectDataSize,
      o_selectAluOut   => s_selectAluOut,
      o_dir            => s_dir,
      o_arith          => s_arith
    );

  -- Fetch Module
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

  -- Register addresses
  s_RegWrAddr <= s_Inst(11 downto 7);
  s_rs1 <= s_Inst(19 downto 15);
  s_rs2 <= s_Inst(24 downto 20);

  -- Register file
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

  -- Immediate Generator
  immeGenerator: ImmediateGenerator
    port map(
      i_Instruction => s_Inst,
      i_ImmType     => ImmType,
      o_Immediate   => pc_addr_imm
    );

  -- ALU
  ALU_inst: ALU
    generic map(N => N)
    port map(
      rs1            => readData1,
      rs2            => readData2,
      i_imm          => pc_addr_imm,
      i_selectOutput => s_selectAluOut,
      i_aluSrc       => ALUSrc,
      i_addSub       => ALUControl,
      i_unsigned     => not s_sign,
      i_dir          => s_dir,
      i_arith        => s_arith,
      alu_out        => aluResult
    );

  -- Instruction memory
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

  -- Data memory address
  s_DMemAddr <= aluResult;

  -- Data memory
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

  -- Byte extender
  byteExtender: extender_N
    generic map(N => 8)
    port map(
      i_A    => s_selectedByte,
      i_sign => s_sign,
      o_F    => s_extendedByte
    );

  -- Halfword extender
  halfExtender: extender_N
    generic map(N => 16)
    port map(
      i_A    => s_selectedHalf,
      i_sign => s_sign,
      o_F    => s_extendedHalf
    );

  -- Select halfword from memory
  s_memBottomHalf <= s_DMemOut(15 downto 0);
  s_memTopHalf <= s_DMemOut(31 downto 16);

  s_memHalfSelect <= s_DMemAddr(1);

  halfwordMux: mux2t1_N
    generic map(N => 16)
    port map(
      i_S  => s_memHalfSelect,
      i_D0 => s_memBottomHalf,
      i_D1 => s_memTopHalf,
      o_O  => s_selectedHalf
    );

  -- Select byte from memory
  s_firstByte  <= s_DMemOut(7 downto 0);
  s_secondByte <= s_DMemOut(15 downto 8);
  s_thirdByte  <= s_DMemOut(23 downto 16);
  s_fourthByte <= s_DMemOut(31 downto 24);

  s_selectByte <= s_DMemAddr(1 downto 0);

  byteMux: mux4t1_N
    generic map(N => 8)
    port map(
      i_S  => s_selectByte,
      i_D0 => s_firstByte,
      i_D1 => s_secondByte,
      i_D2 => s_thirdByte,
      i_D3 => s_fourthByte,
      o_O  => s_selectedByte
    );

  -- Select loaded word, halfword, or byte
  selectDataFromMemory: mux4t1_N
    generic map(N => 32)
    port map(
      i_S  => s_selectDataSize,
      i_D0 => s_DMemOut,
      i_D1 => s_extendedHalf,
      i_D2 => s_extendedByte,
      i_D3 => (others => '0'),
      o_O  => s_dataFromMemory
    );

  -- Position byte for store
  s_storeByte0 <= X"000000" & readData2(7 downto 0);
  s_storeByte1 <= X"0000" & readData2(7 downto 0) & X"00";
  s_storeByte2 <= X"00" & readData2(7 downto 0) & X"0000";
  s_storeByte3 <= readData2(7 downto 0) & X"000000";

  s_selectByteToStore <= s_DMemAddr(1 downto 0);

  selectByteToStore: mux4t1_N
    generic map(N => 32)
    port map(
      i_S  => s_selectByteToStore,
      i_D0 => s_storeByte0,
      i_D1 => s_storeByte1,
      i_D2 => s_storeByte2,
      i_D3 => s_storeByte3,
      o_O  => s_selectedByteToStore
    );

  -- Position halfword for store
  s_storeHalfWord0 <= X"0000" & readData2(15 downto 0);
  s_storeHalfWord1 <= readData2(15 downto 0) & X"0000";

  s_storeHalfWordSelect <= s_DMemAddr(1);

  SelecthalfwordToStore: mux2t1_N
    generic map(N => 32)
    port map(
      i_S  => s_storeHalfWordSelect,
      i_D0 => s_storeHalfWord0,
      i_D1 => s_storeHalfWord1,
      o_O  => s_selectedHalfToStore
    );

  -- Select store data size
  selectByteHalfOrWordToStore: mux4t1_N
    generic map(N => 32)
    port map(
      i_S  => s_selectDataSize,
      i_D0 => readData2,
      i_D1 => s_selectedHalfToStore,
      i_D2 => s_selectedByteToStore,
      i_D3 => (others => '0'),
      o_O  => s_DMemData
    );

  -- Byte enables
  byteEnableMux: mux4t1_N
    generic map(N => 4)
    port map(
      i_S  => s_DMemAddr(1 downto 0),
      i_D0 => "0001",
      i_D1 => "0010",
      i_D2 => "0100",
      i_D3 => "1000",
      o_O  => s_byteBE
    );

  -- Halfword enables
  halfEnableMux: mux2t1_N
    generic map(N => 4)
    port map(
      i_S  => s_DMemAddr(1),
      i_D0 => "0011",
      i_D1 => "1100",
      o_O  => s_halfBE
    );

  -- Select memory byte enables
  storeSizeEnableMux: mux4t1_N
    generic map(N => 4)
    port map(
      i_S  => s_selectDataSize,
      i_D0 => "1111",
      i_D1 => s_halfBE,
      i_D2 => s_byteBE,
      i_D3 => "0000",
      o_O  => s_DMemBE
    );

  -- Detect WFI instruction
  s_Halt <= '1' when s_Inst = x"10500073" else '0';

  -- Tariq: Expanded writeback to five sources
  -- for LUI, jumps, and AUIPC.
  with ResultSrc select
    writeData <= aluResult        when "000",
                 s_dataFromMemory when "001",
                 pc_addr_imm      when "010",
                 PCPlusFour       when "011",
                 s_PCPlusImm      when "100",
                 (others => '0')  when others;

end structureTopLevel;
