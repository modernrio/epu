----------------------------------------------------------------------------------------------------
-- Beschreibung: Regelt den Datenfluss zwischen dem Speicher und dem Prozessor
----------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.epu_pack.all;

entity memory_control is
	port(
		-- Eingänge
		I_MEM_Clk         : in std_logic;						-- Takteingang
		I_MEM_Reset       : in std_logic;						-- Rücksetzsignal
		I_MEM_En	      : in std_logic;						-- Aktivierung
		I_MEM_We		  : in std_logic;						-- Schreibfreigabe
		I_MEM_Data		  : in std_logic_vector(7 downto 0);	-- Daten
		I_MEM_Addr		  : in std_logic_vector(15 downto 0);	-- Adresswahl

		-- Ausgänge
		O_MEM_Ready		  : out std_logic;						-- Bereitschaft
		O_MEM_Data        : out std_logic_vector(7 downto 0);	-- Datenausgang
		O_LED			  : out std_logic_vector(7 downto 0)	-- LEDs
	);
end memory_control;

architecture behav_memory_control of memory_control is
	-- Komponentendeklaration für das zu testende Gerät (UUT)
	component ram_block
		port(
			-- Eingänge
			I_Clk         : in std_logic;						-- Takteingang
			I_En		  : in std_logic;						-- Freigabe
			I_We          : in std_logic;						-- Schreibfreigabe
			I_Data        : in std_logic_vector(7 downto 0);	-- Dateneingang
			I_Addr        : in std_logic_vector(15 downto 0);	-- Adresswahl

			-- Ausgänge
			O_Ready		  : out std_logic;						-- Bereitschaft
			O_Data        : out std_logic_vector(7 downto 0);	-- Datenausgang
			O_LED         : buffer std_logic_vector(7 downto 0)	-- LEDs
		);
	end component;

	-- Signale
	signal S_MEM_Ready    : std_logic := '0';
	signal S_MEM_Data     : std_logic_vector(7 downto 0) := (others => '0');

	signal S_RAM_Ready    : std_logic := '0';
	signal S_RAM_Data     : std_logic_vector(7 downto 0) := (others => '0');
	signal LED			  : std_logic_vector(7 downto 0) := (others => '0');

begin
	-- Instanz der UUTs erstellen
	uut_ram_block : ram_block port map(
		I_Clk => I_MEM_Clk,
		I_We => I_MEM_We,
		I_En => I_MEM_En,
		I_Data => I_MEM_Data,
		I_Addr => I_MEM_Addr,
		O_Ready => S_RAM_Ready,
		O_Data => S_RAM_Data,
		O_LED => LED
	);

	O_MEM_Ready <= S_RAM_Ready;
	O_MEM_Data  <= S_RAM_Data;
	O_LED <= LED;

end behav_memory_control;
