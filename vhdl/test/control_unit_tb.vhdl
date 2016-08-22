--------------------------------------------------------------------------------
-- Beschreibung: Testen des Steuerwerks
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.epu_pack.all;

entity control_unit_tb is
end control_unit_tb;

architecture behav_control_unit_tb of control_unit_tb is
	-- Komponentendeklaration für das zu testende Gerät (UUT)
	component control_unit
		port(
			-- Eingänge
			I_Clk   : in std_logic;							-- Takteingang
			I_Reset : in std_logic;							-- Rücksetzsignal
			I_Done : in std_logic;							-- Befehl vollständig dekodiert?

			-- Ausgänge
			O_State : out std_logic_vector(3 downto 0)		-- Pipelinestatus
		);
	end component;

	-- Eingangssignale
	signal I_Clk   : std_logic := '0';
	signal I_Reset : std_logic := '0';
	signal I_Done  : std_logic := '0';

	-- Ausgangssignale
	signal O_State : std_logic_vector(3 downto 0) := (others => '0');

	-- Konstanten
	constant I_Clk_period : time := 10 ns;
begin
	-- Instanz des UUT erstellen
	uut : control_unit port map (
		I_Clk => I_Clk,
		I_Reset => I_Reset,
		I_Done => I_Done,
		O_State => O_State
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
		I_Reset <= '1';
		I_Done <= '0';
		wait for I_Clk_period*2;

		I_Reset <= '0';
		I_Done <= '0';
		wait for I_Clk_period;

		I_Done <= '0';
		wait for I_Clk_period;
		
		I_Done <= '1';
		wait for I_Clk_period;

		I_Done <= '0';
		wait for I_Clk_period;

		I_Done <= '0';
		wait for I_Clk_period;

		I_Done <= '1';
		wait for I_Clk_period;

		I_Done <= '0';
		wait for I_Clk_period;

		wait;
	end process;
end behav_control_unit_tb;
