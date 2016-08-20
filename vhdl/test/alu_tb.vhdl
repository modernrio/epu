--------------------------------------------------------------------------------
-- Name: ALU-Testbench
--
-- Projekt: EPU
--
-- Autor: Markus Schneider
--
-- Erstellungsdatum: 08.07.2016
--
-- Version: 1.0
--
-- Beschreibung: Testen der ALU
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;

entity alu_tb is
end alu_tb;

architecture behav_alu_tb of alu_tb is
	-- Komponentendeklaration für das zu testende Gerät (UUT)
	component alu
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
	end component;

	-- Eingangssignale
	signal I_Clk   : std_logic := '0';
	signal I_En    : std_logic := '0';
	signal I_AluOp : std_logic_vector(7 downto 0) := (others => '0');
	signal I_Imm   : std_logic_vector(15 downto 0) := (others => '0');
	signal I_DataA : std_logic_vector(15 downto 0) := (others => '0');
	signal I_DataB : std_logic_vector(15 downto 0) := (others => '0');
	signal I_PC    : std_logic_vector(15 downto 0) := (others => '0');

	-- Ausgangssingale
	signal O_SB    : std_logic := '0';
	signal O_Res   : std_logic_vector(15 downto 0) := (others => '0');

	-- Konstanten
	constant I_Clk_period : time := 10 ns;
begin
	-- Instanz des UUT erstellen
	uut : alu port map(
		I_Clk => I_Clk,
		I_En => I_En,
		I_AluOp => I_AluOp,
		I_Imm => I_Imm,
		I_DataA => I_DataA,
		I_DataB => I_DataB,
		I_PC => I_PC,
		O_SB => O_SB,
		O_Res => O_Res
	);

	-- Taktprozess
	I_Clk_process : process
	begin
		I_Clk <= '0';
		wait for I_Clk_period/2;
		I_Clk <= '1';
		wait for I_Clk_period/2;
	end process;

	-- Testprozess
	test_proc : process
	begin
		I_En <= '1';
		I_AluOp <= OPCODE_ADD & '0' & "10";
		I_Imm <= X"0000";
		I_DataA <= X"0001";
		I_DataB <= X"0001";
		I_PC <= X"F1FA";
		wait for I_Clk_period;

		I_AluOp <= OPCODE_NOP & '0' & "00";
		wait for I_Clk_period;
		
		I_AluOp <= OPCODE_SUB & '0' & "11";
		I_DataA <= X"000A";
		I_Imm <= X"0005";
		wait for I_Clk_period;

		I_AluOp <= OPCODE_AND & '0' & "10";
		I_DataA <= X"DEAD";
		I_DataB <= X"BEEF";
		wait for I_Clk_period;

		I_AluOp <= OPCODE_OR & '0' & "10";
		I_DataA <= X"DEAD";
		I_DataB <= X"BEEF";
		wait for I_Clk_period;

		I_AluOp <= OPCODE_XOR & '0' & "10";
		I_DataA <= X"DEAD";
		I_DataB <= X"BEEF";
		wait for I_Clk_period;

		I_AluOp <= OPCODE_NOT & '0' & "10";
		I_DataA <= X"AFFE";
		wait for I_Clk_period;

		I_AluOp <= OPCODE_LOAD & '0' & "11";
		I_Imm <= X"1234";
		wait for I_Clk_period;

		I_AluOp <= OPCODE_MOV & '0' & "01";
		I_DataA <= X"5678";
		wait for I_Clk_period;

		I_AluOp <= OPCODE_SHL & '0' & "10";
		I_DataA <= X"5678";
		I_DataB <= X"0002";
		wait for I_Clk_period;

		I_AluOp <= OPCODE_SHL & '1' & "10";
		I_DataA <= X"5678";
		I_Imm <= X"0003";
		wait for I_Clk_period;

		I_AluOp <= OPCODE_SHR & '0' & "10";
		I_DataA <= X"5555";
		I_DataB <= X"00FA";
		wait for I_Clk_period;

		I_AluOp <= OPCODE_SHR & '1' & "10";
		I_DataA <= X"6874";
		I_Imm <= X"0008";
		wait for I_Clk_period;

		I_AluOp <= OPCODE_CMP & '0' & "10";
		I_DataA <= X"6874";
		I_DataB <= X"6874";
		wait for I_Clk_period;

		I_AluOp <= OPCODE_CMP & '0' & "10";
		I_DataA <= X"5432";
		I_DataB <= X"6874";
		wait for I_Clk_period;

		I_AluOp <= OPCODE_CMP & '0' & "10";
		I_DataA <= X"ABCD";
		I_DataB <= X"1111";
		wait for I_Clk_period;

		I_AluOp <= OPCODE_JMP & '1' & "11";
		I_Imm <= X"FEED";
		wait for I_Clk_period;

		I_AluOp <= OPCODE_JC & '1' & "11";
		I_DataA <= X"00" & "0100" & X"0";
		I_Imm <= "1011" & X"ABC";
		wait for I_Clk_period;

		I_AluOp <= OPCODE_JC & '1' & "11";
		I_DataA <= X"00" & "0010" & X"0";
		I_Imm <= "1011" & X"ABC";
		wait for I_Clk_period;

		I_AluOp <= OPCODE_MUL & '0' & "10";
		I_DataA <= X"000A";
		I_DataB <= X"000A";
		wait for I_Clk_period;

		I_AluOp <= OPCODE_TEST & '0' & "01";
		I_DataA <= X"AFFE";
		wait for I_Clk_period;

		I_AluOp <= OPCODE_TEST & '0' & "01";
		I_DataA <= X"AFFF";
		wait for I_Clk_period*16;

		wait;
	end process;
end behav_alu_tb;
