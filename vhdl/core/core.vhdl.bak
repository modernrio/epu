--------------------------------------------------------------------------------
-- Beschreibung: Zusammenführen der Komponenten des Prozessors
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.epu_pack.all;

entity core is
	port(
		-- Eingänge
		I_CORE_Clk        : in std_logic;						-- Takteingang
		I_CORE_Reset	  : in std_logic;						-- Rücksetzsignal

		I_MEM_Ready	      : in std_logic;						-- Bereitschaft
		I_MEM_Data        : in std_logic_vector(7 downto 0); 	-- Datenausgang

		-- Ausgänge
		O_CORE_HLT		  : out std_logic;						-- Stopsignal

		O_MEM_Reset       : out std_logic;						-- Rücksetzsignal
		O_MEM_En	      : out std_logic;						-- Aktivierung
		O_MEM_We		  : out std_logic;						-- Schreibfreigabe
		O_MEM_Data		  : out std_logic_vector(7 downto 0);	-- Daten
		
		O_LED : out std_logic_vector(7 downto 0);
		
		O_MEM_Addr		  : out std_logic_vector(15 downto 0)	-- Adresswahl
	);
end core;

architecture behav_core of core is
	-- Komponentendeklaration für das zu testende Gerät (UUT)
	component alu
		port(
			-- Eingänge
			I_Clk         : in std_logic;						-- Takteingang
			I_En          : in std_logic;						-- Freigabesignal
			I_AluOp       : in std_logic_vector(7 downto 0);	-- Auszuführende Operation
			I_Imm         : in std_logic_vector(15 downto 0);	-- Konstante aus dem Befehl
			I_DataA       : in std_logic_vector(15 downto 0);	-- Daten von Register A
			I_DataB       : in std_logic_vector(15 downto 0);	-- Daten von Register B
			I_PC          : in std_logic_vector(15 downto 0);	-- Befehlszeiger

			-- Ausgänge
			O_SB          : out std_logic;						-- Sprungbefehl?
			O_Res         : out std_logic_vector(15 downto 0)	-- Ergebnis
		);
	end component;

	component control_unit
		port(
			-- Eingänge
			I_Clk         : in std_logic;						-- Takteingang
			I_Reset       : in std_logic;						-- Rücksetzsignal
			I_Done        : in std_logic;						-- Befehl vollständig dekodiert?
			I_MemReady	  : in std_logic;						-- RAM bereit?
			I_AluOp		  : in std_logic_vector(7 downto 0);	-- ALU-Operation

			-- Ausgänge
			O_State       : out std_logic_vector(6 downto 0)	-- Pipelinestatus
		);
	end component;

	component decoder
		port(
			-- Eingänge
			I_Clk         : in std_logic;						-- Takteingang
			I_En          : in std_logic;						-- Freigabesignal
			I_Inst        : in std_logic_vector(7 downto 0);	-- Maschinenbefehl

			-- Ausgänge
			O_We          : out std_logic;						-- Konstantenausgabe
			O_Done        : out std_logic;						-- 1 => Befehl endet nach dem Byte
			O_SelA        : out std_logic_vector(3 downto 0);	-- Registerwahl für Ausgang A
			O_SelB        : out std_logic_vector(3 downto 0);	-- Registerwahl für Ausgang B
			O_SelD        : out std_logic_vector(3 downto 0);	-- Registerwahl für Ausgang D
			O_AluOp       : out std_logic_vector(7 downto 0);	-- ALU-Operation
			O_Imm         : out std_logic_vector(15 downto 0)	-- Konstantenausgabe
		);
	end component;

	component regfile
		port(
			-- Eingänge
			I_Clk         : in std_logic;						-- Takteingang
			I_En          : in std_logic;						-- Freigabesignal
			I_We          : in std_logic;						-- Schreibfreigabe
			I_Byte        : in std_logic;						-- Schreibbreite
			I_High        : in std_logic;						-- Auswahl High-/Low-Byte
			I_SelA        : in std_logic_vector(3 downto 0);	-- Wählt Register für Ausgang A
			I_SelB        : in std_logic_vector(3 downto 0);	-- Wählt Register für Ausgang B
			I_SelD        : in std_logic_vector(3 downto 0);	-- Wählt Register für Eingang D
			I_DataD       : in std_logic_vector(15 downto 0);	-- Dateneingang für D

			-- Ausgänge
			O_LED : out std_logic_vector(7 downto 0);

			O_DataA       : out std_logic_vector(15 downto 0);	-- Datenausgang für A
			O_DataB       : out std_logic_vector(15 downto 0)	-- Datenausgang für B
		);
	end component;

	component pc_unit
		port(
			-- Eingänge
			I_Clk         : in std_logic;						-- Takteingang
			I_Op          : in std_logic_vector(1 downto 0);	-- PC-Operation
			I_PC          : in std_logic_vector(15 downto 0);	-- Sprungadresse

			-- Ausgänge
			O_PC          : out std_logic_vector(15 downto 0)	-- Befehlszeigerausgabe
		);
	end component;

	component stack
		port(
			-- Eingänge
			I_Clk         : in std_logic;						-- Takteingang
			I_En          : in std_logic;						-- Freigabesignal
			I_We          : in std_logic;						-- Schreibfreigabe
			I_Data        : in std_logic_vector(15 downto 0);	-- Dateneingang

			-- Ausgänge
			O_Data        : out std_logic_vector(15 downto 0)	-- Ergebnis
		);
	end component;

	-- Signale
	signal State          : std_logic_vector(6 downto 0) := (others => '0');

	signal En_Fetch       : std_logic := '0';
	signal En_Decode      : std_logic := '0';
	signal En_RegRead     : std_logic := '0';
	signal En_ALU         : std_logic := '0';
	signal En_MemWrite    : std_logic := '0';
	signal En_Stack       : std_logic := '0';
	signal En_RegWrite    : std_logic := '0';

	signal SB             : std_logic := '0';
	signal AluOp          : std_logic_vector(7 downto 0) := (others => '0');
	signal Imm            : std_logic_vector(15 downto 0) := (others => '0');
	signal DataA          : std_logic_vector(15 downto 0) := (others => '0');
	signal DataB          : std_logic_vector(15 downto 0) := (others => '0');
	signal PC             : std_logic_vector(15 downto 0) := (others => '0');
	signal Res            : std_logic_vector(15 downto 0) := (others => '0');

	signal RegWe          : std_logic := '0';
	signal DecDone        : std_logic := '0';
	signal SelA           : std_logic_vector(3 downto 0) := (others => '0');
	signal SelB           : std_logic_vector(3 downto 0) := (others => '0');
	signal SelD           : std_logic_vector(3 downto 0) := (others => '0');
	signal Inst           : std_logic_vector(7 downto 0) := (others => '0');

	signal Reg_I_En       : std_logic := '0';
	signal Reg_I_We       : std_logic := '0';
	signal Reg_I_Byte     : std_logic := '0';
	signal Reg_I_High     : std_logic := '0';
	signal Reg_I_Data	  : std_logic_vector(15 downto 0) := (others => '0');
	signal regled		  : std_logic_vector(7 downto 0) := (others => '0');

	signal MEM_Reset      : std_logic := '0';
	signal MEM_En		  : std_logic := '0';
	signal MEM_We		  : std_logic := '0';
	signal MEM_Ready	  : std_logic := '0';
	signal MEM_RData	  : std_logic_vector(7 downto 0) := (others => '0');
	signal MEM_WData	  : std_logic_vector(7 downto 0) := (others => '0');
	signal MEM_Addr		  : std_logic_vector(15 downto 0) := (others => '0');

	signal PCOp           : std_logic_vector(1 downto 0) := (others => '0');
	signal PCIn           : std_logic_vector(15 downto 0) := (others => '0');

	signal Stack_I_En     : std_logic := '0';
	signal Stack_I_We     : std_logic := '0';
	signal StackIn        : std_logic_vector(15 downto 0) := (others => '0');
	signal StackData      : std_logic_vector(15 downto 0) := (others => '0');

begin
	-- Signale definieren
	MEM_Reset <= I_CORE_Reset;
	-- Ein-/Ausgänge verbinden
	O_CORE_HLT <= '1' when AluOp(IFO_REL_OPCODE_BEGIN downto IFO_REL_OPCODE_END) = OPCODE_HLT
				  else '0';
	O_MEM_Reset <= MEM_Reset;
	O_MEM_En <= MEM_En;
	O_MEM_We <= MEM_We;
	MEM_Ready <= I_MEM_Ready;
	MEM_RData <= I_MEM_Data;
	O_MEM_Data <= MEM_WData;
	O_MEM_Addr <= MEM_Addr;
	
	O_LED <= regled;

	-- Speichercontroller
	MEM_En	  <= En_Fetch or En_MemWrite;
	MEM_We    <= '1' when En_MemWrite = '1'
				 and AluOp(IFO_REL_OPCODE_BEGIN downto IFO_REL_OPCODE_END) = OPCODE_WRITE
				 else '0';
	MEM_WData <= DataB(15 downto 8) when AluOp(IFO_REL_FLAG) = '1' else DataB(7 downto 0);
	MEM_Addr  <= Res when En_MemWrite = '1' else PC;


	-- Instanz der UUTs erstellen
	uut_alu : alu port map (
		I_Clk => I_CORE_Clk,
		I_En => En_ALU,
		I_AluOp => AluOp,
		I_Imm => Imm,
		I_DataA => DataA,
		I_DataB => DataB,
		I_PC => PC,
		O_SB => SB,
		O_Res => Res
	);

	En_Fetch    <= State(0);
	En_Decode   <= State(1);
	En_RegRead  <= State(2);
	En_ALU      <= State(3);
	En_MemWrite <= State(4);
	En_Stack    <= State(5);
	En_RegWrite <= State(6);

	uut_control_unit : control_unit port map (
		I_Clk => I_CORE_Clk,
		I_Reset => I_CORE_Reset,
		I_Done => DecDone,
		I_MemReady => MEM_Ready,
		I_AluOp => AluOp,
		O_State => State
	);

	Inst <= MEM_RData;

	uut_decoder : decoder port map (
		I_Clk => I_CORE_Clk,
		I_En => En_Decode,
		I_Inst => Inst,
		O_We => RegWe,
		O_Done => DecDone,
		O_SelA => SelA,
		O_SelB => SelB,
		O_SelD => SelD,
		O_AluOp => AluOp,
		O_Imm => Imm
	);

	Reg_I_En <= En_RegRead or En_RegWrite;
	Reg_I_We <= En_RegWrite and RegWe;

	Reg_I_Data(15 downto 8) <= I_MEM_Data when
				  AluOp(IFO_REL_OPCODE_BEGIN downto IFO_REL_OPCODE_END) = OPCODE_READ
				  else StackData(15 downto 8) when
				  AluOp(IFO_REL_OPCODE_BEGIN downto IFO_REL_OPCODE_END) = OPCODE_POP
				  else Res(15 downto 8);
	Reg_I_Data(7 downto 0) <= I_MEM_Data when
				  AluOp(IFO_REL_OPCODE_BEGIN downto IFO_REL_OPCODE_END) = OPCODE_READ
				  else StackData(7 downto 0) when
				  AluOp(IFO_REL_OPCODE_BEGIN downto IFO_REL_OPCODE_END) = OPCODE_POP
				  else Res(7 downto 0);

	Reg_I_Byte <= '1' when En_RegWrite = '1'
				  and AluOp(IFO_REL_OPCODE_BEGIN downto IFO_REL_OPCODE_END) = OPCODE_READ
				  else '0';
	
	Reg_I_High <= '1' when En_RegWrite = '1'
				  and AluOp(IFO_REL_OPCODE_BEGIN downto IFO_REL_OPCODE_END) = OPCODE_READ
				  and AluOp(IFO_REL_FLAG) = '0'
				  else '0';

	uut_regfile : regfile port map (
		I_Clk => I_CORE_Clk,
		I_En => Reg_I_En,
		I_We => Reg_I_We,
		I_Byte => Reg_I_Byte,
		I_High => Reg_I_High,
		I_SelA => SelA,
		I_SelB => SelB,
		I_SelD => SelD,
		I_DataD => Reg_I_Data,
		O_LED => regled,
		O_DataA => DataA,
		O_DataB => DataB
	);


	PCOp <= PC_OP_RESET when I_CORE_Reset = '1' else
			PC_OP_ASSIGN when SB = '1' and En_RegWrite = '1' else
			PC_OP_INC when En_Decode = '1' and DecDone = '0' else
			PC_OP_NOP;
		
	PCIn <=	StackData when En_RegWrite = '1'
			and AluOp(IFO_REL_OPCODE_BEGIN downto IFO_REL_OPCODE_END) = OPCODE_RET else
			ADDR_INT when En_RegWrite = '1'
			and AluOp(IFO_REL_OPCODE_BEGIN downto IFO_REL_OPCODE_END) = OPCODE_INT else
			Res;

	uut_pc_unit : pc_unit port map (
		I_Clk => I_CORE_Clk,
		I_Op => PCOp,
		I_PC => PCIn,
		O_PC => PC
	);

	Stack_I_En <= '1' when En_Stack = '1'
				  and (AluOp(IFO_REL_OPCODE_BEGIN downto IFO_REL_OPCODE_END) = OPCODE_PUSH
				  or AluOp(IFO_REL_OPCODE_BEGIN downto IFO_REL_OPCODE_END) = OPCODE_POP
				  or AluOp(IFO_REL_OPCODE_BEGIN downto IFO_REL_OPCODE_END) = OPCODE_CALL
				  or AluOp(IFO_REL_OPCODE_BEGIN downto IFO_REL_OPCODE_END) = OPCODE_RET
				  or AluOp(IFO_REL_OPCODE_BEGIN downto IFO_REL_OPCODE_END) = OPCODE_INT) else
				  '0';
	Stack_I_We <= '1' when En_Stack = '1'
				  and (AluOp(IFO_REL_OPCODE_BEGIN downto IFO_REL_OPCODE_END) = OPCODE_PUSH
				  or AluOp(IFO_REL_OPCODE_BEGIN downto IFO_REL_OPCODE_END) = OPCODE_CALL
				  or AluOp(IFO_REL_OPCODE_BEGIN downto IFO_REL_OPCODE_END) = OPCODE_INT) else
				  '0';
	
	StackIn    <= PC when (AluOp(IFO_REL_OPCODE_BEGIN downto IFO_REL_OPCODE_END) = OPCODE_CALL
				  or AluOp(IFO_REL_OPCODE_BEGIN downto IFO_REL_OPCODE_END) = OPCODE_INT) else
				  DataA;

	uut_stack : stack port map (
		I_Clk => I_CORE_Clk,
		I_En => Stack_I_En,
		I_We => Stack_I_We,
		I_Data => StackIn,
		O_Data => StackData
    );
end behav_core;
