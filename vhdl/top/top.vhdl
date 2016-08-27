--------------------------------------------------------------------------------
-- Beschreibung: Verbinden aller Module zu einem Topmodul
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.epu_pack.all;

entity top is
	port(
		MainClk			  : in std_logic;
		RST				  : in std_logic;
		LED				  : out std_logic_vector(7 downto 0)
	);
end top;

architecture behav_top of top is
	-- Komponentendeklaration für das zu testende Gerät (UUT)
	component freq_divider
		port(
			I_Clk : in std_logic;
			O_Clk : out std_logic
		);
	end component;
	
	component core
		port(
			-- Eingänge
			I_CORE_Clk    : in std_logic;						-- Takteingang
			I_CORE_Reset  : in std_logic;						-- Rücksetzsignal

			I_MEM_Ready	  : in std_logic;						-- Bereitschaft
			I_MEM_Data    : in std_logic_vector(7 downto 0); 	-- Datenausgang

			-- Ausgänge
			O_CORE_HLT	  : out std_logic;						-- Stopsignal

			O_MEM_Reset   : out std_logic;						-- Rücksetzsignal
			O_MEM_En	  : out std_logic;						-- Aktivierung
			O_MEM_We	  : out std_logic;						-- Schreibfreigabe
			O_MEM_Data	  : out std_logic_vector(7 downto 0);	-- Daten
			O_MEM_Addr	  : out std_logic_vector(15 downto 0)	-- Adresswahl
		);
	end component;

	component memory_control
		port(
			-- Eingänge
			I_MEM_Clk     : in std_logic;						-- Takteingang
			I_MEM_Reset   : in std_logic;						-- Rücksetzsignal
			I_MEM_En	  : in std_logic;						-- Aktivierung
			I_MEM_We	  : in std_logic;						-- Schreibfreigabe
			I_MEM_Data	  : in std_logic_vector(7 downto 0);	-- Daten
			I_MEM_Addr	  : in std_logic_vector(15 downto 0);	-- Adresswahl

			-- Ausgänge
			O_MEM_Ready	  : out std_logic;						-- Bereitschaft
			O_MEM_Data    : out std_logic_vector(7 downto 0);	-- Datenausgang
			O_LED		  : out std_logic_vector(7 downto 0)	-- LEDs
		);
	end component;

	-- Signale
		-- Top
	signal Clk 	 	 	  : std_logic := '0';
	signal leds			  : std_logic_vector(7 downto 0) := (others => '0');
		-- Core
	signal CoreReset	  : std_logic := '0';
	signal CoreHLT		  : std_logic := '0';
		-- Speichercontroller
	signal MemReady		  : std_logic := '0';
	signal MemReset		  : std_logic := '0';
	signal MemEn		  : std_logic := '0';
	signal MemWe		  : std_logic := '0';
	signal MemWData		  : std_logic_vector(7 downto 0) := (others => '0');
	signal MemRData		  : std_logic_vector(7 downto 0) := (others => '0');
	signal MemAddr		  : std_logic_vector(15 downto 0) := (others => '0');

	-- Konstanten
	constant CLK_PERIOD   : time := 10 ns;
begin
	-- Instanz der UUTs erstellen
	uut_freq_divider : freq_divider port map (
		I_Clk => MainClk,
		O_Clk => Clk
	);
	
	uut_core : core port map (
		I_CORE_Clk => Clk,
		I_CORE_Reset => CoreReset,
		I_MEM_Ready => MemReady,
		I_MEM_Data => MemRData,
		O_CORE_HLT => CoreHLT,
		O_MEM_Reset => MemReset,
		O_MEM_En => MemEn,
		O_MEM_We => MemWe,
		O_MEM_Data => MemWData,
		O_MEM_Addr => MemAddr
	);


	uut_memory_control : memory_control port map (
		I_MEM_Clk => Clk,
		I_MEM_Reset => MemReset,
		I_MEM_En => MemEn,
		I_MEM_We => MemWe,
		I_MEM_Data => MemWData,
		I_MEM_Addr => MemAddr,
		O_MEM_Ready => MemReady,
		O_MEM_Data => MemRData,
		O_LED => leds
	);
	
	CoreReset <= RST;
	LED <= leds;
	
end behav_top;
