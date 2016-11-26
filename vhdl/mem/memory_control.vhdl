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
		I_VID_Addr		  : in std_logic_vector(15 downto 0);	-- Videoadresswahl

		-- Ausgänge
		O_MEM_Ready		  : out std_logic;						-- Bereitschaft
		O_MEM_Data        : out std_logic_vector(7 downto 0);	-- Datenausgang
		O_VID_Data        : out std_logic_vector(7 downto 0);	-- Videodatenausgang
		O_LED			  : out std_logic_vector(7 downto 0);	-- LEDs

		UClk			  : in std_logic;
		TX				  : out std_logic;
		RX				  : in std_logic
	);
end memory_control;

architecture behav_memory_control of memory_control is
	-- Komponentendeklaration für das zu testende Gerät (UUT)
	component blk_mem
		port(
			-- Port A
			clka	: in std_logic;
			ena		: in std_logic;
			wea		: in std_logic_vector(0 downto 0);
			addra	: in std_logic_vector(15 downto 0);
			dina	: in std_logic_vector(7 downto 0);
			douta	: out std_logic_vector(7 downto 0);
			-- Port B
			clkb	: in std_logic;
			enb		: in std_logic;
			web		: in std_logic_vector(0 downto 0);
			addrb	: in std_logic_vector(15 downto 0);
			dinb	: in std_logic_vector(7 downto 0);
			doutb	: out std_logic_vector(7 downto 0)
	  );
	end component;
	
	component uart is
    port(
		-- Physical interface
		I_Clk			: in std_logic;
		TX				: out std_logic;
		RX				: in std_logic;

		-- Client Interface
		I_Reset			: in std_logic;
			-- TX
		I_TX_Data		: in std_logic_vector(7 downto 0);
		I_TX_Enable		: in std_logic;
		O_TX_Ready		: out std_logic;
			-- RX
		I_RX_Cont		: in std_logic;
		O_RX_Data		: out std_logic_vector(7 downto 0);
		O_RX_Sig		: out std_logic;
		O_RX_FrameError	: out std_logic
    );
	end component;


	-- Signale
	signal S_MEM_Ready    : std_logic := '0';
	signal S_MEM_Data     : std_logic_vector(7 downto 0) := (others => '0');
	signal we					: std_logic_vector(0 downto 0) := (others => '0');

	signal S_RAM_Ready    : std_logic := '0';
	signal S_RAM_Data     : std_logic_vector(7 downto 0) := (others => '0');
	signal LED			  : std_logic_vector(7 downto 0) := (others => '0');
	
	signal tx_ready		  : std_logic := '0';
	signal rx_data		  : std_logic_vector(7 downto 0) := (others => '0');
	signal rx_ready		  : std_logic := '0';
	signal rx_error		  : std_logic := '0';

begin
	we(0) <= I_MEM_We;

	-- Instanz der UUTs erstellen
	uut_blk_mem : blk_mem port map (
		clka => I_MEM_Clk,
		ena => I_MEM_En,
		wea => we,
		addra => I_MEM_Addr,
		dina => I_MEM_Data,
		douta => O_MEM_Data,
		clkb => I_MEM_Clk,
		enb => '1',
		web => "0",
		addrb => I_VID_Addr,
		dinb => X"00",
		doutb => O_VID_Data
	  );

	uut_uart : uart port map (
		I_Clk => UClk,
		TX => TX,
		RX => RX,
		I_Reset => '0',
		I_TX_Data => X"7C",
		I_TX_Enable => '1',
		O_TX_Ready => tx_ready,
		I_RX_Cont => '1',
		O_RX_Data => rx_data,
		O_RX_Sig => rx_ready,
		O_RX_FrameError => rx_error
	);

	O_MEM_Ready <= '1';
	--O_MEM_Data  <= S_RAM_Data;
	--O_LED <= rx_error & rx_data(6 downto 0);

end behav_memory_control;
