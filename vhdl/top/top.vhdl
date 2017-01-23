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
		MainClk	: in std_logic;
		RST		: in std_logic;
		SEGEn	: out std_logic_vector(2 downto 0);
		LED		: out std_logic_vector(7 downto 0);
		SEG		: out std_logic_vector(7 downto 0);
		SW		: in std_logic_vector(6 downto 0);

		TX		: out std_logic;
		RX		: in std_logic;
		
		hs 		: out std_logic;
		vs		: out std_logic;
		red		: out std_logic_vector(2 downto 0);
		green	: out std_logic_vector(2 downto 0);
		blue	: out std_logic_vector(1 downto 0)
	);
end top;

architecture behav_top of top is
	-- Komponentendeklaration für das zu testende Gerät (UUT)
	component freq_divider
		port(
			I_Clk		  : in std_logic;
			O_Clk		  : out std_logic;
			Uart_Clk	  : out std_logic;
			Seg_Clk		  : out std_logic;
			Text_Clk : out std_logic;
			Video_Clk  : out std_logic
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
			
			O_LED		  : out std_logic_vector(7 downto 0);
			
			O_MEM_Addr	  : out std_logic_vector(15 downto 0)	-- Adresswahl
		);
	end component;

	component memory_control
		port(
			-- Eingänge
			I_MEM_Clk         : in std_logic;						-- Takteingang
			I_MEM_Reset       : in std_logic;						-- Rücksetzsignal
			I_MEM_En	      : in std_logic;						-- Aktivierung
			I_MEM_We		  : in std_logic;						-- Schreibfreigabe
			I_MEM_Data		  : in std_logic_vector(7 downto 0);	-- Daten
			I_MEM_Addr		  : in std_logic_vector(15 downto 0);	-- Adresswahl
			I_VID_Clk		  : in std_logic;						-- Videotakt

			-- Ausgänge
			O_MEM_Ready		  : out std_logic;						-- Bereitschaft
			O_MEM_Data        : out std_logic_vector(7 downto 0);	-- Datenausgang
			O_LED			  : out std_logic_vector(7 downto 0);	-- LEDs
			O_VID_Red		  : out std_logic;						-- Rot
			O_VID_Green		  : out std_logic;						-- Grün
			O_VID_Blue		  : out std_logic;						-- Blau
			O_VID_HSync		  : out std_logic;						-- HSync
			O_VID_VSync		  : out std_logic;						-- HSync

			UClk			  : in std_logic;
			TX				  : out std_logic;
			RX				  : in std_logic
		);
	end component;

	-- Signale
		-- Top
	signal Clk 	 	 	  : std_logic := '0';
	signal SegClk		  : std_logic := '0';
	signal TxtClk		  : std_logic := '0';
	signal VidClk		  : std_logic := '0';
	signal leds			  : std_logic_vector(7 downto 0) := (others => '0');
	signal core_leds	  : std_logic_vector(7 downto 0) := (others => '0');
	signal seg_count	  : integer := 0;
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
	signal UARTClk			: std_logic := '0';

	signal VidAddr		  : std_logic_vector(15 downto 0) := (others => '0');
	signal VidData		  : std_logic_vector(7 downto 0) := (others => '0');

	signal VidRed		  : std_logic;
	signal VidGreen		  : std_logic;
	signal VidBlue		  : std_logic;
begin
	-- Instanz der UUTs erstellen
	uut_freq_divider : freq_divider port map (
		I_Clk => MainClk,
		O_Clk => Clk,
		Uart_Clk => UARTClk,
		Seg_Clk => SegClk,
		Text_Clk => TxtClk,
		Video_Clk => VidClk
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
		O_LED => core_leds,
		O_MEM_Addr => MemAddr
	);


	uut_memory_control : memory_control port map (
		I_MEM_Clk => Clk,
		I_MEM_Reset => MemReset,
		I_MEM_En => MemEn,
		I_MEM_We => MemWe,
		I_MEM_Data => MemWData,
		I_MEM_Addr => MemAddr,
		I_VID_Clk => VidClk,
		O_MEM_Ready => MemReady,
		O_MEM_Data => MemRData,
		O_LED => leds,
		O_VID_Red => VidRed,
		O_VID_Green => VidGreen,
		O_VID_Blue => VidBlue,
		O_VID_HSync => hs,
		O_VID_VSync => vs,
		UClk => UARTClk,
		TX => TX,
		RX => RX
	);

	red <= VidRed & VidRed & VidRed;
	green <= VidGreen & VidGreen & VidGreen;
	blue <= VidBlue & VidBlue;

	CoreReset <= RST;
	LED <= leds;
	SEG(0) <= '1';
	
	seg_proc : process(SegClk)
	begin
		if rising_edge(SegClk) then
			if seg_count = 0 then
				SEG(7 downto 1) <= bcd2seg(MemAddr(3 downto 0));
				SEGEn <= "011";
				seg_count <= seg_count + 1;
			elsif seg_Count = 1 then
				SEG(7 downto 1) <= bcd2seg(MemAddr(7 downto 4));
				SEGEn <= "101";
				seg_count <= seg_count + 1;
			else
				SEG(7 downto 1) <= bcd2seg(MemAddr(11 downto 8));
				SegEn <= "110";
				seg_count <= 0;
			end if;
		end if;
	end process;
end behav_top;
