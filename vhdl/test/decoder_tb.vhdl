--------------------------------------------------------------------------------
-- Name: Decoder-Testbench
--
-- Projekt: EPU
--
-- Autor: Markus Schneider
--
-- Erstellungsdatum: 08.07.2016
--
-- Version: 1.0
--
-- Beschreibung: Testen des Decoders
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;

entity decoder_tb is
end decoder_tb;

architecture behav_decoder_tb of decoder_tb is
	-- Komponentendeklaration für das zu testende Gerät (UUT)
	component decoder
		port(
			-- Eingänge
			I_Clk   : in std_logic;							-- Takteingang
			I_En    : in std_logic;							-- Freigabesignal
			I_Inst  : in std_logic_vector(7 downto 0);		-- Maschinenbefehl

			-- Ausgänge
			O_We    : out std_logic;						-- Konstantenausgabe
			O_Done  : out std_logic;						-- 1 => Befehl endet nach diesem Byte
			O_SelA  : out std_logic_vector(3 downto 0);		-- Registerwahl für Ausgang A
			O_SelB  : out std_logic_vector(3 downto 0);		-- Registerwahl für Ausgang B
			O_SelD  : out std_logic_vector(3 downto 0);		-- Registerwahl für Ausgang D
			O_AluOp : out std_logic_vector(7 downto 0);		-- ALU-Operation
			O_Imm   : out std_logic_vector(15 downto 0)		-- Konstantenausgabe
		);
	end component;

	-- Eingangssignale
	signal I_Clk    : std_logic := '0';
	signal I_En     : std_logic := '0';
	signal I_Inst   : std_logic_vector(7 downto 0) := (others =>'0');

	-- Ausgangssignale
	signal O_We     : std_logic := '0';
	signal O_Done   : std_logic := '0';
	signal O_SelA   : std_logic_vector(3 downto 0) := (others => '0');
	signal O_SelB   : std_logic_vector(3 downto 0) := (others => '0');
	signal O_SelD   : std_logic_vector(3 downto 0) := (others => '0');
	signal O_AluOp  : std_logic_vector(7 downto 0) := (others => '0');
	signal O_Imm    : std_logic_vector(15 downto 0) := (others => '0');

	-- Konstanten
	constant I_Clk_period : time := 10 ns;
begin
	-- Instanz des UUT erstellen
	uut : decoder port map(
		I_Clk => I_Clk,
		I_En => I_En,
		I_Inst => I_Inst,
		O_We => O_We,
		O_Done => O_Done,
		O_SelA => O_SelA,
		O_SelB => O_SelB,
		O_SelD => O_SelD,
		O_AluOp => O_AluOp,
		O_Imm => O_Imm
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
		I_Inst <= OPCODE_ADD & '0' & "10";
		wait for I_Clk_period;

		I_Inst <= X"32";
		wait for I_Clk_period;

		I_Inst <= X"10";
		wait for I_Clk_period;

		I_Inst <= X"00";
		wait for I_Clk_period;

		wait;
	end process;
end behav_decoder_tb;
