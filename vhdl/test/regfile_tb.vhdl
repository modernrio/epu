----------------------------------------------------------------------------------------------------
-- Beschreibung: Testen der Registerdatei
----------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regfile_tb is
end regfile_tb;

architecture behav_regfile_tb of regfile_tb is
	-- Komponentendeklaration für das zu testende Gerät (UUT)
	component regfile
		port(
			-- Eingänge
			I_Clk   : in std_logic;							-- Takteingang
			I_En    : in std_logic;							-- Freigabesignal
			I_We    : in std_logic;							-- Schreibfreigabe
			I_SelA  : in std_logic_vector(3 downto 0);		-- Wählt Register für Ausgang A
			I_SelB  : in std_logic_vector(3 downto 0);		-- Wählt Register für Ausgang B
			I_SelD  : in std_logic_vector(3 downto 0);		-- Wählt Register für Eingang D
			I_DataD : in std_logic_vector(15 downto 0);		-- Dateneingang für D

			-- Ausgänge
			O_DataA : out std_logic_vector(15 downto 0);	-- Datenausgang für A
			O_DataB : out std_logic_vector(15 downto 0)		-- Datenausgang für B
			);
	end component;

	-- Eingangssignale
	signal I_Clk   : std_logic := '0';
	signal I_En    : std_logic := '0';
	signal I_We    : std_logic := '0';
	signal I_SelA  : std_logic_vector(3 downto 0) := (others => '0');
	signal I_SelB  : std_logic_vector(3 downto 0) := (others => '0');
	signal I_SelD  : std_logic_vector(3 downto 0) := (others => '0');
	signal I_DataD : std_logic_vector(15 downto 0) := (others => '0');

	-- Ausgangssignale
	signal O_DataA : std_logic_vector(15 downto 0) := (others => '0');
	signal O_DataB : std_logic_vector(15 downto 0) := (others => '0');

	-- Konstanten
	constant I_Clk_period : time := 10 ns;
begin
	-- Instanz des UUT erstellen
	uut : regfile port map(
		I_Clk => I_Clk,
		I_En => I_En,
		I_We => I_We,
		I_SelA => I_SelA,
		I_SelB => I_SelB,
		I_SelD => I_SelD,
		I_DataD => I_DataD,
		O_DataA => O_DataA,
		O_DataB => O_DataB
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
		-- Reset-State für 20ns
		wait for I_Clk_period*2;

		-- Registerdatei aktivieren
		I_En <= '1';

		-- Schreibtest r0 = 0xFEFE
		I_We <= '1';
		I_SelA <= "0000";
		I_SelB <= "0111";
		I_SelD <= "0000";
		I_DataD <= X"FEFE";
		wait for I_Clk_period;
	
		-- Schreibtest r1 = 0xAFFE
		I_We <= '1';
		I_SelA <= "0000";
		I_SelB <= "0111";
		I_SelD <= "0001";
		I_DataD <= X"AFFE";
		wait for I_Clk_period;

		-- Schreibtest r10 = 0xAAAA
		I_We <= '1';
		I_SelA <= "0000";
		I_SelB <= "0111";
		I_SelD <= "1010";
		I_DataD <= X"AAAA";
		wait for I_Clk_period;
	
		-- Schreibtest r15 = 0xDEAD
		I_We <= '1';
		I_SelA <= "1000";
		I_SelB <= "1111";
		I_SelD <= "1111";
		I_DataD <= X"DEAD";
		wait for I_Clk_period;

		-- Schreibtest r4 = 0x1234
		I_We <= '1';
		I_SelA <= "0000";
		I_SelB <= "0111";
		I_SelD <= "0100";
		I_DataD <= X"1234";
		wait for I_Clk_period;
	
		-- Schreibtest r5 = 0x5555
		I_We <= '1';
		I_SelA <= "0000";
		I_SelB <= "0111";
		I_SelD <= "0101";
		I_DataD <= X"5555";
		wait for I_Clk_period;

		-- Schreibtest r14 = 0xBEEF
		I_We <= '1';
		I_SelA <= "1000";
		I_SelB <= "1111";
		I_SelD <= "1110";
		I_DataD <= X"BEEF";
		wait for I_Clk_period;
	
		-- Schreibtest r7 = 0x1111
		I_We <= '1';
		I_SelA <= "0000";
		I_SelB <= "0111";
		I_SelD <= "0111";
		I_DataD <= X"1111";
		wait for I_Clk_period;
	
		-- Lesetest r15(0xDEAD), r14(0xBEEF)
		I_We <= '0';
		I_SelA <= "1111";
		I_SelB <= "1110";
		I_SelD <= "0000";
		I_DataD <= X"0000";
		wait for I_Clk_period;

		-- Lesetest r0(0xFEFE), r7(0x1111)
		I_We <= '0';
		I_SelA <= "0000";
		I_SelB <= "0111";
		I_SelD <= "0000";
		I_DataD <= X"0000";
		wait for I_Clk_period;

		-- Deaktivierungstest
		I_En <= '0';

		-- Lesetest r10(0xAAAA), r5(0x5555) [DEAKTIVIERT]
		I_We <= '0';
		I_SelA <= "1010";
		I_SelB <= "0101";
		I_SelD <= "0000";
		I_DataD <= X"0000";
		wait for I_Clk_period;

		-- Schreibtest r5=0x0000 [DEAKTIVIERT]
		I_We <= '1';
		I_SelA <= "0000";
		I_SelB <= "0000";
		I_SelD <= "0101";
		I_DataD <= X"0000";
		wait for I_Clk_period;

		-- Aktivierungstest
		I_En <= '1';

		-- Lesetest r10(0xAAAA), r5(0x5555) [AKTIVIERT]
		I_We <= '0';
		I_SelA <= "1010";
		I_SelB <= "0101";
		I_SelD <= "0110";
		I_DataD <= X"0000";
		wait for I_Clk_period;

		wait;
	end process;
end behav_regfile_tb;
