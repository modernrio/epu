----------------------------------------------------------------------------------------------------
-- Beschreibung: Deklaration und Definition verschiedener Hilfsfunktionen und Konstanten
----------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package epu_pack is

function divide (a : unsigned; b : unsigned) return unsigned;
function modulo (a : unsigned; b : unsigned) return unsigned;

-- Adresskonstanten
constant ADDR_RESET            : std_logic_vector(15 downto 0) := X"0000";
constant ADDR_INT			   : std_logic_vector(15 downto 0) := X"0004";

-- Opcodes
constant OPCODE_NOP            : std_logic_vector(4 downto 0) := "00000";
constant OPCODE_ADD            : std_logic_vector(4 downto 0) := "00001";
constant OPCODE_SUB            : std_logic_vector(4 downto 0) := "00010";
constant OPCODE_AND            : std_logic_vector(4 downto 0) := "00011";
constant OPCODE_OR             : std_logic_vector(4 downto 0) := "00100";
constant OPCODE_XOR            : std_logic_vector(4 downto 0) := "00101";
constant OPCODE_NOT            : std_logic_vector(4 downto 0) := "00110";
constant OPCODE_LOAD           : std_logic_vector(4 downto 0) := "00111";
constant OPCODE_MOV            : std_logic_vector(4 downto 0) := "01000";
constant OPCODE_READ           : std_logic_vector(4 downto 0) := "01001";
constant OPCODE_WRITE          : std_logic_vector(4 downto 0) := "01010";
constant OPCODE_SHL            : std_logic_vector(4 downto 0) := "01011";
constant OPCODE_SHR            : std_logic_vector(4 downto 0) := "01100";
constant OPCODE_CMP            : std_logic_vector(4 downto 0) := "01101";
constant OPCODE_JMP            : std_logic_vector(4 downto 0) := "01110";
constant OPCODE_JC             : std_logic_vector(4 downto 0) := "01111";
constant OPCODE_MUL            : std_logic_vector(4 downto 0) := "10000";
constant OPCODE_CALL           : std_logic_vector(4 downto 0) := "10001";
constant OPCODE_RET            : std_logic_vector(4 downto 0) := "10010";
constant OPCODE_PUSH           : std_logic_vector(4 downto 0) := "10011";
constant OPCODE_POP            : std_logic_vector(4 downto 0) := "10100";
constant OPCODE_INT            : std_logic_vector(4 downto 0) := "10111";
constant OPCODE_TEST           : std_logic_vector(4 downto 0) := "11000";
constant OPCODE_DIV            : std_logic_vector(4 downto 0) := "11001";
constant OPCODE_MOD            : std_logic_vector(4 downto 0) := "11010";

-- PC-Operationen
constant PC_OP_NOP             : std_logic_vector(1 downto 0) := "00";
constant PC_OP_INC             : std_logic_vector(1 downto 0) := "01";
constant PC_OP_ASSIGN          : std_logic_vector(1 downto 0) := "10";
constant PC_OP_RESET           : std_logic_vector(1 downto 0) := "11";

-- Flagsregisterbits
	-- Vergleichbits
constant CMP_BIT_EQ            : integer := 15;
constant CMP_BIT_AGB           : integer := 14;
constant CMP_BIT_ALB           : integer := 13;
constant CMP_BIT_AZ            : integer := 12;
constant CMP_BIT_BZ            : integer := 11;

	-- Testbits
constant TEST_BIT_SF           : integer :=  7;
constant TEST_BIT_PF           : integer :=  6;
constant TEST_BIT_ZF           : integer :=  5;

-- Bedingungssprungflags
constant CJF_EQ                : std_logic_vector(3 downto 0) := "0000";
constant CJF_NEQ               : std_logic_vector(3 downto 0) := "0001";
constant CJF_AGB               : std_logic_vector(3 downto 0) := "0010";
constant CJF_ALB               : std_logic_vector(3 downto 0) := "0011";
constant CJF_AGEB              : std_logic_vector(3 downto 0) := "0100";
constant CJF_ALEB              : std_logic_vector(3 downto 0) := "0101";
constant CJF_PARITY            : std_logic_vector(3 downto 0) := "0110";
constant CJF_NOPARITY          : std_logic_vector(3 downto 0) := "0111";
constant CJF_CARRY             : std_logic_vector(3 downto 0) := "1000";
constant CJF_NOCARRY           : std_logic_vector(3 downto 0) := "1001";
constant CJF_OVERFLOW          : std_logic_vector(3 downto 0) := "1010";
constant CJF_NOOVERFLOW        : std_logic_vector(3 downto 0) := "1011";
constant CJF_ZERO              : std_logic_vector(3 downto 0) := "1100";
constant CJF_NOTZERO           : std_logic_vector(3 downto 0) := "1101";

-- Befehlsformoffsets
	-- Byte 0
		-- Absolute Konstanten
constant IFO_OPCODE_BEGIN      : integer := 31;
constant IFO_OPCODE_END        : integer := 27;
constant IFO_FLAG              : integer := 26;
constant IFO_LENGTH_BEGIN      : integer := 25;
constant IFO_LENGTH_END        : integer := 24;

		-- Relative Konstanten
constant IFO_REL_OPCODE_BEGIN  : integer := 7;
constant IFO_REL_OPCODE_END    : integer := 3;
constant IFO_REL_FLAG          : integer := 2;
constant IFO_REL_LENGTH_BEGIN  : integer := 1;
constant IFO_REL_LENGTH_END    : integer := 0;

	-- Byte 1
		-- Absoulute Konstanten
constant IFO_RD_BEGIN          : integer := 23;
constant IFO_RD_END            : integer := 20;
constant IFO_RA_BEGIN          : integer := 19;
constant IFO_RA_END            : integer := 16;

		-- Relative Konstanten
constant IFO_REL_RD_BEGIN      : integer := 7;
constant IFO_REL_RD_END        : integer := 4;
constant IFO_REL_RA_BEGIN      : integer := 3;
constant IFO_REL_RA_END        : integer := 0;

	-- Byte 2
		-- Absolute Konstanten
constant IFO_RB_BEGIN          : integer := 15;
constant IFO_RB_END            : integer := 12;
constant IFO_IMM8_B2_BEGIN     : integer := 15;
constant IFO_IMM8_B2_END       : integer := 8;

		-- Relative Konstanten
constant IFO_REL_RB_BEGIN      : integer := 7;
constant IFO_REL_RB_END        : integer := 4;
constant IFO_REL_IMM8_B2_BEGIN : integer := 7;
constant IFO_REL_IMM8_B2_END   : integer := 0;

	-- Byte 3
		-- Relative Konstanten
constant IFO_REL_IMM8_B3_BEGIN : integer := 7;
constant IFO_REL_IMM8_B3_END   : integer := 0;

	-- Byte 2 & 3
		-- Absolute Konstanten
constant IFO_IMM16_BEGIN       : integer := 15;
constant IFO_IMM16_END         : integer := 0;

end epu_pack;

package body epu_pack is
	function divide (a : unsigned; b : unsigned) return unsigned is
		variable a1 : unsigned(a'length-1 downto 0) := a;
		variable b1 : unsigned(b'length-1 downto 0) := b;
		variable p1 : unsigned(b'length downto 0) := (others => '0');
		variable i  : integer := 0;

	begin
		for i in 0 to b'length-1 loop
			p1(b'length-1 downto 1) := p1(b'length-2 downto 0);
			p1(0) := a1(a'length-1);
			a1(a'length-1 downto 1) := a1(a'length-2 downto 0);
			p1 := p1-b1;
			if(p1(b'length-1) ='1') then
				a1(0) :='0';
				p1 := p1+b1;
			else
				a1(0) :='1';
			end if;
		end loop;
		return a1;

	end divide;

	function modulo (a : unsigned; b : unsigned) return unsigned is
		variable x : unsigned(a'length-1 downto 0) := a;
		variable y : unsigned(b'length-1 downto 0) := b;
		variable r : unsigned(a'length-1 + b'length downto 0) := (others => '0');
	begin
		r := x - (divide(x, y) * y);
		return r(b'length-1 downto 0);
	end modulo;
end epu_pack;
