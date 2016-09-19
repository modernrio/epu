----------------------------------------------------------------------------------------------------
-- Beschreibung: Ausführen von arithmetischen und logischen Befehlen
----------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.epu_pack.all;

entity alu is
	port(
		-- Eingänge
		I_Clk   : in std_logic;							-- Takteingang
		I_En    : in std_logic;							-- Freigabesignal
		I_AluOp : in std_logic_vector(7 downto 0);		-- Auszuführende Operation
		I_Imm   : in std_logic_vector(15 downto 0);		-- Konstante aus dem Befehl
		I_DataA : in std_logic_vector(15 downto 0);		-- Daten von Register A
		I_DataB : in std_logic_vector(15 downto 0);		-- Daten von Register B
		I_PC    : in std_logic_vector(15 downto 0);		-- Befehlszeiger

		-- Ausgänge
		O_SB    : out std_logic;						-- Soll ein Sprungbefehl ausgeführt werden?
		O_Res   : out std_logic_vector(15 downto 0)		-- Ergebnis
	);
end alu;

architecture behav_alu of alu is
	component adder16 is
	port (
		-- Eingänge
		I_A		: in std_logic_vector(15 downto 0);
		I_B		: in std_logic_vector(15 downto 0);
		I_Carry : in std_logic;

		-- Ausgänge
		O_Sum	: in std_logic_vector(15 downto 0);
		O_Carry : in std_logic
	);
	end component;
	
	component fulladder is
		port(
		-- Eingänge
		I_A		: in std_logic;
		I_B		: in std_logic;
		I_Carry	: in std_logic;

		-- Ausgänge
		O_Sum	: out std_logic;
		O_Carry : out std_logic
	);
	end component;

	signal S_SB  : std_logic := '0';
	signal S_Res : std_logic_vector(17 downto 0) := (others => '0');
begin
	process(I_Clk, I_En)
	begin
		if rising_edge(I_Clk) and I_En = '1' then
			case I_AluOp(IFO_REL_OPCODE_BEGIN downto IFO_REL_OPCODE_END) is
				when OPCODE_NOP =>
					S_Res(15 downto 0) <= X"0000";
					S_SB <= '0';
				when OPCODE_ADD =>
					if I_AluOp(IFO_REL_FLAG) = '0' then
						if I_AluOp(IFO_REL_LENGTH_END) = '0' then
							-- Nicht vorzeichenbehaftet + Form RRR
							S_Res(16 downto 0) <= std_logic_vector(unsigned('0' & I_DataA)
												+ unsigned('0' & I_DataB));
						else
							-- Nicht vorzeichenbehaftet + Form RRI
							S_Res(16 downto 0) <= std_logic_vector(unsigned('0' & I_DataA)
												+ unsigned('0' & I_Imm));
						end if;
					else
						if I_AluOp(IFO_REL_LENGTH_END) = '0' then
							-- Vorzeichenbehaftet + Form RRR
							S_Res(15 downto 0) <= std_logic_vector(signed(I_DataA) + signed(I_DataB));
							S_Res(17) <= (I_DataA(15) and I_DataB(15) and not S_Res(15)) or
										 (not I_DataA(15) and not I_DataB(15) and S_Res(15));
						else
							-- Vorzeichenbehaftet + Form RRI
							S_Res(15 downto 0) <= std_logic_vector(signed(I_DataA) + signed(I_Imm));
							S_Res(17) <= (I_DataA(15) and I_Imm(15) and not S_Res(15)) or
										 (not I_DataA(15) and not I_Imm(15) and S_Res(15));
						end if;
					end if;
					S_SB <= '0';
				when OPCODE_SUB =>
					if I_AluOp(IFO_REL_FLAG) = '0' then
						if I_AluOp(IFO_REL_LENGTH_END) = '0' then
							-- Nicht vorzeichenbehaftet + Form RRR
							S_Res(16 downto 0) <= std_logic_vector(unsigned('0' & I_DataA)
												- unsigned('0' & I_DataB));
						else
							-- Nicht vorzeichenbehaftet + Form RRI
							S_Res(16 downto 0) <= std_logic_vector(unsigned('0' & I_DataA)
												- unsigned('0' & I_Imm));
						end if;
					else
						if I_AluOp(IFO_REL_LENGTH_END) = '0' then
							-- Vorzeichenbehaftet + Form RRR
							S_Res(15 downto 0) <= std_logic_vector(signed(I_DataA) - signed(I_DataB));
							S_Res(17) <= (not I_DataA(15) and I_DataB(15) and S_Res(15)) or
										 (I_DataA(15) and not I_DataB(15) and not S_Res(15));
						else
							-- Vorzeichenbehaftet + Form RRI
							S_Res(15 downto 0) <= std_logic_vector(signed(I_DataA) - signed(I_Imm));
							S_Res(17) <= (not I_DataA(15) and I_Imm(15) and S_Res(15)) or
										 (I_DataA(15) and not I_Imm(15) and not S_Res(15));
						end if;
					end if;
					S_SB <= '0';
				when OPCODE_AND =>
					S_Res(15 downto 0) <= I_DataA and I_DataB;
					S_SB <= '0';
				when OPCODE_OR =>
					S_Res(15 downto 0) <= I_DataA or I_DataB;
					S_SB <= '0';
				when OPCODE_XOR =>
					S_Res(15 downto 0) <= I_DataA xor I_DataB;
					S_SB <= '0';
				when OPCODE_NOT =>
					S_Res(15 downto 0) <= not I_DataA;
					S_SB <= '0';
				when OPCODE_LOAD =>
					S_Res(15 downto 0) <= I_Imm;
					S_SB <= '0';
				when OPCODE_READ =>
					S_Res(16 downto 0) <= std_logic_vector(signed(I_DataA(15) & I_DataA)
										+ signed('0' & I_Imm));
					S_SB <= '0';
				when OPCODE_WRITE =>
					S_Res(16 downto 0) <= std_logic_vector(signed(I_DataA(15) & I_DataA)
										+ signed('0' & I_Imm));
					S_SB <= '0';
				when OPCODE_SHL =>
					if I_AluOp(IFO_REL_LENGTH_END) = '0' then
						-- Form RRR
						-- S_Res(15 downto 0) <= std_logic_vector(shift_left(unsigned(I_DataA),
						-- 						to_integer(unsigned(I_DataB(3 downto 0)))));
					else
						-- Form RRI
						-- S_Res(15 downto 0) <= std_logic_vector(shift_left(unsigned(I_DataA),
						-- 						to_integer(unsigned(I_Imm(3 downto 0)))));
					end if;
					S_SB <= '0';
				when OPCODE_SHR =>
					if I_AluOp(IFO_REL_LENGTH_END) = '0' then
						-- Form RRR
						-- S_Res(15 downto 0) <= std_logic_vector(shift_right(unsigned(I_DataA),
						-- 						to_integer(unsigned(I_DataB(3 downto 0)))));
					else
						-- Form RRI
						-- S_Res(15 downto 0) <= std_logic_vector(shift_right(unsigned(I_DataA),
						-- 						to_integer(unsigned(I_Imm(3 downto 0)))));
					end if;
					S_SB <= '0';
				when OPCODE_CMP =>
					if I_DataA = I_DataB then
						S_Res(CMP_BIT_EQ) <= '1';
					else
						S_Res(CMP_BIT_EQ) <= '0';
					end if;

					if I_DataA = X"0000" then
						S_Res(CMP_BIT_AZ) <= '1';
					else
						S_Res(CMP_BIT_AZ) <= '0';
					end if;

					if I_DataB = X"0000" then
						S_Res(CMP_BIT_BZ) <= '1';
					else
						S_Res(CMP_BIT_BZ) <= '0';
					end if;

					if I_AluOp(IFO_REL_FLAG) = '0' then
						if unsigned(I_DataA) > unsigned(I_DataB) then
							S_Res(CMP_BIT_AGB) <= '1';
						else
							S_Res(CMP_BIT_AGB) <= '0';
						end if;

						if unsigned(I_DataA) < unsigned(I_DataB) then
							S_Res(CMP_BIT_ALB) <= '1';
						else
							S_Res(CMP_BIT_ALB) <= '0';
						end if;
					else
						if signed(I_DataA) > signed(I_DataB) then
							S_Res(CMP_BIT_AGB) <= '1';
						else
							S_Res(CMP_BIT_AGB) <= '0';
						end if;

						if signed(I_DataA) < signed(I_DataB) then
							S_Res(CMP_BIT_ALB) <= '1';
						else
							S_Res(CMP_BIT_ALB) <= '0';
						end if;
					end if;
					S_SB <= '0';
				when OPCODE_JMP =>
					if I_AluOp(IFO_REL_LENGTH_BEGIN) = '0' then
						-- PC = Ra
						S_Res(15 downto 0) <= I_DataA;
					else
						if I_AluOp(IFO_REL_FLAG) = '0' then
							-- PC = PC + Konstante
							S_Res(15 downto 0) <= std_logic_vector(signed(I_PC) + signed(I_Imm));
						else
							-- PC = Konstante
							S_Res(15 downto 0) <= I_Imm;
						end if;
					end if;
					S_SB <= '1';
				when OPCODE_JC =>
					if I_AluOp(IFO_REL_LENGTH_END) = '0' then
						-- PC = Rb
						S_Res(15 downto 0) <= I_DataB;
					else
						if I_AluOp(IFO_REL_FLAG) = '0' then
							-- PC = PC + Konstante
							S_Res(15 downto 0) <= std_logic_vector(signed(I_PC)
												+ signed(I_Imm(11 downto 0)));
						else
							-- PC = Konstante
							S_Res(15 downto 0) <= X"0" & I_Imm(11 downto 0);
						end if;
					end if;

					case I_Imm(15 downto 12) is
						when CJF_EQ =>
							S_SB <= I_DataA(CMP_BIT_EQ);
						when CJF_NEQ =>
							S_SB <= not I_DataA(CMP_BIT_EQ);
						when CJF_AGB =>
							S_SB <= I_DataA(CMP_BIT_AGB);
						when CJF_ALB =>
							S_SB <= I_DataA(CMP_BIT_ALB);
						when CJF_AGEB =>
							S_SB <= I_DataA(CMP_BIT_AGB) or I_DataA(CMP_BIT_EQ);
						when CJF_ALEB =>
							S_SB <= I_DataA(CMP_BIT_ALB) or I_DataA(CMP_BIT_EQ);
						when CJF_PARITY =>
							S_SB <= I_DataA(TEST_BIT_PF);
						when CJF_NOPARITY =>
							S_SB <= not I_DataA(TEST_BIT_PF);
						when CJF_CARRY =>
							S_SB <= S_Res(16);
						when CJF_NOCARRY =>
							S_SB <= not S_Res(16);
						when CJF_OVERFLOW =>
							S_SB <= S_Res(17);
						when CJF_NOOVERFLOW =>
							S_SB <= not S_Res(17);
						when CJF_ZERO =>
							S_SB <= I_DataA(TEST_BIT_ZF);
						when CJF_NOTZERO =>
							S_SB <= not I_DataA(TEST_BIT_ZF);
						when CJF_BITHIGH =>
							S_SB <= I_DataA(TEST_BIT_BF);
						when CJF_BITLOW =>
							S_SB <= not I_DataA(TEST_BIT_BF);
						when others =>
							S_SB <= '0';
					end case;
				when OPCODE_MUL =>
					S_Res(15 downto 0) <= std_logic_vector(unsigned(I_DataA(7 downto 0))
										* unsigned(I_DataB(7 downto 0)));
					S_SB <= '0';
				when OPCODE_PUSH =>
					S_SB <= '0';
				when OPCODE_POP =>
					S_SB <= '0';
				when OPCODE_CALL =>
					-- JMP
					if I_AluOp(IFO_REL_LENGTH_BEGIN) = '0' then
						-- PC = Ra
						S_Res(15 downto 0) <= I_DataA;
					else
						if I_AluOp(IFO_REL_FLAG) = '0' then
							-- PC = PC + Konstante
							S_Res(15 downto 0) <= std_logic_vector(signed(I_PC) + signed(I_Imm));
						else
							-- PC = Konstante
							S_Res(15 downto 0) <= I_Imm;
						end if;
					end if;
					S_SB <= '1';
				when OPCODE_RET =>
					S_SB <= '1';
				when OPCODE_INT =>
					S_Res(15 downto 0) <= I_Imm;
					S_SB <= '1';
				when OPCODE_TEST =>
					-- Parity Flag
					S_Res(TEST_BIT_PF) <= I_DataA(0)
										xor I_DataA(1)
										xor I_DataA(2)
										xor I_DataA(3)
										xor I_DataA(4)
										xor I_DataA(5)
										xor I_DataA(6)
										xor I_DataA(7)
										xor I_DataA(8)
										xor I_DataA(9)
										xor I_DataA(10)
										xor I_DataA(11)
										xor I_DataA(12)
										xor I_DataA(13)
										xor I_DataA(14)
										xor I_DataA(15);

					-- Zero Flag
					if I_DataA = X"0000" then
						S_Res(TEST_BIT_ZF) <= '1';
					else 
						S_Res(TEST_BIT_ZF) <= '0';
					end if;

					-- Bit Flag
					if I_DataA(to_integer(unsigned(I_Imm(IFO_IMM4_B2_BEGIN downto IFO_IMM4_B2_END)))) = '1' then
						S_Res(TEST_BIT_BF) <= '1';
					else
						S_Res(TEST_BIT_BF) <= '0';
					end if;

					S_SB <= '0';
				when OPCODE_DIV =>
					S_Res(15 downto 0) <= std_logic_vector(divide(unsigned(I_DataA), unsigned(I_DataB)));

					S_SB <= '0';
				when OPCODE_MOD =>
					S_Res(15 downto 0) <= std_logic_vector(modulo(unsigned(I_DataA), unsigned(I_DataB)));

					S_SB <= '0';
				when OPCODE_SET =>
					S_Res(15 downto 0) <= I_DataA;
					S_Res(to_integer(unsigned(I_Imm(IFO_IMM4_B2_BEGIN downto IFO_IMM4_B2_END)))) <= '1';

					S_SB <= '0';
				when OPCODE_CLR =>
					S_Res(15 downto 0) <= I_DataA;
					S_Res(to_integer(unsigned(I_Imm(IFO_IMM4_B2_BEGIN downto IFO_IMM4_B2_END)))) <= '0';

					S_SB <= '0';
				when others =>
					S_Res <= "00" & X"EEEE";
			end case;
		end if;
	end process;

	O_SB <= S_SB;
	O_Res <= S_Res(15 downto 0);
end behav_alu;
