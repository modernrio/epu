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
	component ram_sim
		port(
			-- Eingänge
			I_Clk         : in std_logic;						-- Takteingang
			I_We          : in std_logic;						-- Schreibfreigabe
			I_Data        : in std_logic_vector(7 downto 0);	-- Dateneingang
			I_Addr        : in std_logic_vector(15 downto 0);	-- Adresswahl

			-- Ausgänge
			O_Ready		  : out std_logic;						-- Bereitschaft
			O_Data        : out std_logic_vector(7 downto 0);	-- Datenausgang
			O_LED	      : out std_logic_vector(7 downto 0)	-- LEDs
		);
	end component;

	-- Signale
	signal S_MEM_Ready    : std_logic := '0';
	signal S_MEM_Data     : std_logic_vector(7 downto 0) := (others => '0');

	signal S_RAM_Ready    : std_logic := '0';
	signal S_RAM_Data     : std_logic_vector(7 downto 0) := (others => '0');

begin
	-- Instanz der UUTs erstellen
	uut_ram_sim : ram_sim port map(
		I_Clk => I_MEM_Clk,
		I_We => I_MEM_We,
		I_Data => I_MEM_Data,
		I_Addr => I_MEM_Addr,
		O_Ready => S_RAM_Ready,
		O_Data => S_RAM_Data,
		O_LED => O_LED
	);
	process(I_MEM_Clk, I_MEM_En, I_MEM_Reset, I_MEM_Addr, S_RAM_Ready, S_RAM_Data)
	begin
		if rising_edge(I_MEM_Clk) then
			if I_MEM_Reset = '1' then
				S_MEM_Ready <= '0';
				S_MEM_Data <= X"00";
			elsif I_MEM_En = '1' then
				if I_MEM_Addr(15) = '0' then	-- 0x0000 - 0x7FFF => RAM
					S_MEM_Ready <= S_RAM_Ready;
					S_MEM_Data <= S_RAM_Data;
				else							-- 0x8000 - 0xFFFF => Speichergeräte
					S_MEM_Ready <= '0';
					S_MEM_Data <= X"00";
				end if;
			else
				S_MEM_Ready <= '0';
				S_MEM_Data <= X"00";
			end if;
		end if;
	end process;

	O_MEM_Ready <= S_RAM_Ready;
	O_MEM_Data  <= S_RAM_Data;

end behav_memory_control;
