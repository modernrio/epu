----------------------------------------------------------------------------------------------------
-- Name: Konstanten des Befehlssatzes
--
-- Projekt: EPU
--
-- Autor: Markus Schneider
--
-- Erstellungsdatum: 23.07.2016
--
-- Version: 1.1
--
-- Beschreibung: Konstante Werte mit konstanten Variablen schnell zugänglich machen
----------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;

entity decoder is
	port(
		-- Eingänge
		I_Clk        : in std_logic;						-- Takteingang
		I_En         : in std_logic;						-- Freigabesignal
		I_Inst       : in std_logic_vector(7 downto 0);		-- Maschinenbefehl

		-- Ausgänge
		O_We         : out std_logic;						-- Konstantenausgabe
		O_Done       : out std_logic;						-- 1 => Befehl endet nach diesem Byte
		O_SelA       : out std_logic_vector(3 downto 0);	-- Registerwahl für Ausgang A
		O_SelB       : out std_logic_vector(3 downto 0);	-- Registerwahl für Ausgang B
		O_SelD       : out std_logic_vector(3 downto 0);	-- Registerwahl für Ausgang D
		O_AluOp      : out std_logic_vector(7 downto 0);	-- ALU-Operation
		O_Imm        : out std_logic_vector(15 downto 0)	-- Konstantenausgabe
		);
end decoder;

architecture behav_decoder of decoder is
	signal S_Done  : std_logic := '0';
	signal S_Inst  : std_logic_vector(31 downto 0) := (others => '0');
	signal S_AluOp : std_logic_vector(7 downto 0) := (others => '0');
	signal S_Count : integer := 0;
begin
	process(I_Clk, I_En)
	-- variable S_Count : integer := 0;
	begin
		if rising_edge(I_Clk) and I_En = '1' then
			case S_Count is
				when 0 =>
					S_Inst <= (others => '0');
					S_Inst(31 downto 24) <= I_Inst;
					S_AluOp <= I_Inst;

					-- Hat der Befehl noch mehr Bytes?
					if I_Inst(IFO_REL_LENGTH_BEGIN downto IFO_REL_LENGTH_END) = "00" then
						S_Done <= '1';
						S_Count <= 4;
					else
						S_Done <= '0';
						S_Count <= S_Count + 1;
					end if;

					-- Wird etwas in die Register geschrieben?
					case I_Inst(IFO_REL_OPCODE_BEGIN downto IFO_REL_OPCODE_END) is
						when OPCODE_NOP =>
							O_We <= '0';
						when OPCODE_WRITE =>
							O_We <= '0';
						when OPCODE_JMP =>
							O_We <= '0';
						when OPCODE_JC =>
							O_We <= '0';
						when OPCODE_PUSH =>
							O_We <= '0';
						when OPCODE_CALL =>
							O_We <= '0';
						when OPCODE_RET =>
							O_We <= '0';
						when others =>
							O_We <= '1';
					end case;
				when 1 =>
					S_Inst(23 downto 16) <= I_Inst;
					O_SelA <= I_Inst(IFO_REL_RA_BEGIN downto IFO_REL_RA_END);
					O_SelD <= I_Inst(IFO_REL_RD_BEGIN downto IFO_REL_RD_END);

					-- Hat der Befehl noch mehr Bytes?
					if S_Inst(IFO_LENGTH_BEGIN downto IFO_LENGTH_END) = "01" then
						S_Done <= '1';
						S_Count <= 4;
					else
						S_Done <= '0';
						S_Count <= S_Count + 1;
					end if;
				when 2 =>
					S_Inst(15 downto 8) <= I_Inst;
					O_SelB <= I_Inst(IFO_REL_RB_BEGIN downto IFO_REL_RB_END);

					if S_Inst(IFO_OPCODE_BEGIN downto IFO_OPCODE_END) = OPCODE_JC
					or S_Inst(IFO_OPCODE_BEGIN downto IFO_OPCODE_END) = OPCODE_WRITE then
						-- Spezialfall Form IRR
						O_Imm(15 downto 12) <= S_Inst(IFO_RD_BEGIN downto IFO_RD_END);
						O_Imm(11 downto 8) <= I_Inst(IFO_REL_IMM8_B2_BEGIN - 4 downto IFO_REL_IMM8_B2_END);
					else
						-- Normalfall
						O_Imm(15 downto 8) <= I_Inst(IFO_REL_IMM8_B2_BEGIN downto IFO_REL_IMM8_B2_END);
					end if;

					-- Hat der Befehl noch mehr Bytes?
					if S_Inst(IFO_LENGTH_BEGIN downto IFO_LENGTH_END) = "10" then
						S_Done <= '1';
						S_Count <= 4;
					else
						S_Done <= '0';
						S_Count <= S_Count + 1;
					end if;
				when 3 =>
					S_Inst(7 downto 0) <= I_Inst;
					O_Imm(7 downto 0) <= I_Inst(IFO_REL_IMM8_B3_BEGIN downto IFO_REL_IMM8_B3_END);

					S_Done <= '1';
					S_Count <= 4;
				when 4 =>
					S_Done <= '0';
					S_Count <= 0;
				when others =>
					S_Count <= 0;
			end case;
		end if;
	end process;

	O_Done <= S_Done;
	O_AluOp <= S_AluOp;
end behav_decoder;
