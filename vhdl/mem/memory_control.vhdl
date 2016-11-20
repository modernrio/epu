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
		O_LED			  : out std_logic_vector(7 downto 0);	-- LEDs

		UClk			  : in std_logic;
		TX				  : out std_logic;
		RX				  : in std_logic
	);
end memory_control;

architecture behav_memory_control of memory_control is
	-- Komponentendeklaration für das zu testende Gerät (UUT)
	component cram
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
			O_PORTB         : buffer std_logic_vector(7 downto 0)	-- LEDs
		);
	end component;
	component dram
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
			O_PORTB         : buffer std_logic_vector(7 downto 0)	-- LEDs
		);
	end component;
	component fram
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
			O_PORTB         : buffer std_logic_vector(7 downto 0)	-- LEDs
		);
	end component;
	component sram
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
			O_PORTB         : buffer std_logic_vector(7 downto 0)	-- LEDs
		);
	end component;
	component tram
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
			O_PORTB         : buffer std_logic_vector(7 downto 0)	-- LEDs
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

	signal S_RAM_Ready    : std_logic := '0';
	signal S_RAM_Data     : std_logic_vector(7 downto 0) := (others => '0');
	signal LED			  : std_logic_vector(7 downto 0) := (others => '0');
	
	signal tx_ready		  : std_logic := '0';
	signal rx_data		  : std_logic_vector(7 downto 0) := (others => '0');
	signal rx_ready		  : std_logic := '0';
	signal rx_error		  : std_logic := '0';
	
	signal cram_en			: std_logic := '0';
	signal cram_ready		: std_logic := '0';
	signal cram_data		: std_logic_vector(7 downto 0) := (others => '0');
	signal cram_portb		: std_logic_vector(7 downto 0) := (others => '0');
	signal dram_en			: std_logic := '0';
	signal dram_ready		: std_logic := '0';
	signal dram_data		: std_logic_vector(7 downto 0) := (others => '0');
	signal dram_portb		: std_logic_vector(7 downto 0) := (others => '0');
	signal fram_en			: std_logic := '0';
	signal fram_ready		: std_logic := '0';
	signal fram_data		: std_logic_vector(7 downto 0) := (others => '0');
	signal fram_portb		: std_logic_vector(7 downto 0) := (others => '0');
	signal sram_en			: std_logic := '0';
	signal sram_ready		: std_logic := '0';
	signal sram_data		: std_logic_vector(7 downto 0) := (others => '0');
	signal sram_portb		: std_logic_vector(7 downto 0) := (others => '0');
	signal tram_en			: std_logic := '0';
	signal tram_ready		: std_logic := '0';
	signal tram_data		: std_logic_vector(7 downto 0) := (others => '0');
	signal tram_portb		: std_logic_vector(7 downto 0) := (others => '0');
begin
	-- Instanz der UUTs erstellen
	uut_cram : cram port map(
		I_Clk => I_MEM_Clk,
		I_We => I_MEM_We,
		I_En => cram_en,
		I_Data => I_MEM_Data,
		I_Addr => I_MEM_Addr,
		O_Ready => cram_ready,
		O_Data => cram_data,
		O_PORTB => cram_portb
	);
	uut_dram : dram port map(
		I_Clk => I_MEM_Clk,
		I_We => I_MEM_We,
		I_En => dram_en,
		I_Data => I_MEM_Data,
		I_Addr => I_MEM_Addr,
		O_Ready => dram_ready,
		O_Data => dram_data,
		O_PORTB => dram_portb
	);
	uut_fram : fram port map(
		I_Clk => I_MEM_Clk,
		I_We => I_MEM_We,
		I_En => fram_en,
		I_Data => I_MEM_Data,
		I_Addr => I_MEM_Addr,
		O_Ready => fram_ready,
		O_Data => fram_data,
		O_PORTB => fram_portb
	);
	uut_sram : sram port map(
		I_Clk => I_MEM_Clk,
		I_We => I_MEM_We,
		I_En => sram_en,
		I_Data => I_MEM_Data,
		I_Addr => I_MEM_Addr,
		O_Ready => sram_ready,
		O_Data => sram_data,
		O_PORTB => sram_portb
	);
	uut_tram : tram port map(
		I_Clk => I_MEM_Clk,
		I_We => I_MEM_We,
		I_En => tram_en,
		I_Data => I_MEM_Data,
		I_Addr => I_MEM_Addr,
		O_Ready => tram_ready,
		O_Data => tram_data,
		O_PORTB => tram_portb
	);

	uut_uart : uart port map (
		I_Clk => UClk,
		TX => TX,
		RX => RX,
		I_Reset => '0',
		I_TX_Data => sram_portb,
		I_TX_Enable => '1',
		O_TX_Ready => tx_ready,
		I_RX_Cont => '1',
		O_RX_Data => rx_data,
		O_RX_Sig => rx_ready,
		O_RX_FrameError => rx_error
	);
	
	process(I_MEM_Clk)
	begin
		if rising_edge(I_MEM_Clk) then
			if (unsigned(I_MEM_Addr) < 16384) then
				-- Code RAM 0x000 - 0x3FFF
				cram_en <= '1';
				tram_en <= '0';
				fram_en <= '0';
				sram_en <= '0';
				dram_en <= '0';
				S_RAM_Ready <= cram_ready;
				S_RAM_Data <= cram_data;
			elsif (unsigned(I_MEM_Addr) < 20480) then
				-- Text RAM 0x4000 - 0x57FF
				cram_en <= '0';
				tram_en <= '1';
				fram_en <= '0';
				sram_en <= '0';
				dram_en <= '0';
				S_RAM_Ready <= tram_ready;
				S_RAM_Data <= tram_data;
			elsif (unsigned(I_MEM_Addr) < 24576) then
				-- Font RAM 0x5800 - 0x67FF
				cram_en <= '0';
				tram_en <= '0';
				fram_en <= '1';
				sram_en <= '0';
				dram_en <= '0';
				S_RAM_Ready <= fram_ready;
				S_RAM_Data <= fram_data;
			elsif (unsigned(I_MEM_Addr) < 26624) then
				-- Settings RAM 0x6800 - 0x6FFF
				cram_en <= '0';
				tram_en <= '0';
				fram_en <= '0';
				sram_en <= '1';
				dram_en <= '0';
				S_RAM_Ready <= sram_ready;
				S_RAM_Data <= sram_data;
			else
				-- Data RAM 0x7000 - 0xFFFF
				cram_en <= '0';
				tram_en <= '0';
				fram_en <= '0';
				sram_en <= '0';
				dram_en <= '1';
				S_RAM_Ready <= dram_ready;
				S_RAM_Data <= dram_data;
			end if;
		end if;
	end process;

	O_MEM_Ready <= S_RAM_Ready;
	O_MEM_Data  <= S_RAM_Data;
	O_LED <= rx_error & rx_data(6 downto 0);

end behav_memory_control;
