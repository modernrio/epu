--------------------------------------------------------------------------------
-- Name: Ram-Testbench
--
-- Projekt: EPU
--
-- Autor: Markus Schneider
--
-- Erstellungsdatum: 18.07.2016
--
-- Version: 1.0
-- Beschreibung: RAM-Testmodul mit fest eingetragenen Instruktionen
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;

entity ram_sim is
	port(
		-- Eingänge
		I_Clk         : in std_logic;						-- Takteingang
		I_We          : in std_logic;						-- Schreibfreigabe
		I_Data        : in std_logic_vector(7 downto 0);	-- Dateneingang
		I_Addr        : in std_logic_vector(15 downto 0);	-- Adresswahl

		-- Ausgänge
		O_Ready		  : out std_logic;						-- Bereitschaft
		O_Data        : out std_logic_vector(7 downto 0)	-- Datenausgang
	);
end ram_sim;

architecture behav_ram_sim of ram_sim is
	type store_t is array(0 to RAM_MAX) of std_logic_vector(7 downto 0);

	signal ram : store_t := (
	X"77", -- 0x0000: jmp.i 0x5
	X"00",
	X"00",
	X"05",
	X"90", -- 0x0004: ret
	X"3b", -- 0x0005: load r4, 0xBEEF
	X"40",
	X"be",
	X"ef",
	X"3b", -- 0x0009: load r5, 0xDEAD
	X"50",
	X"de",
	X"ad",
	X"99", -- 0x000d: push r4
	X"04",
	X"99", -- 0x000f: push r5
	X"05",
	X"a1", -- 0x0011: pop r4
	X"40",
	X"a1", -- 0x0013: pop r5
	X"50",
	X"0a", -- 0x0015: add r0, r4, r5
	X"04",
	X"50",
	X"7f", -- 0x0018: jnz.i 0x5
	X"de",
	X"00",
	X"05",
	X"00",
	X"00",
	X"00",
	X"00",
	X"00",
	X"00",
	X"00",
	X"00",
	X"00",
	X"00",
	X"00",
	X"00",
	X"00",
	X"00",
	X"00",
	X"00",
	X"00",
	X"00",
	X"00",
	X"00",
	X"00",
	X"00",
	X"00",
	X"00",
	X"00",
	X"00",
	X"00",
	X"00",
	X"00",
	X"00",
	X"00",
	X"00",
	X"00",
	X"00",
	X"00",
	X"00" 
	);
begin
	process(I_Clk)
	begin
		if rising_edge(I_Clk) then
			if (I_We = '1') then
				ram(to_integer(unsigned(I_Addr(5 downto 0)))) <= I_Data;
			else
				O_Data <= ram(to_integer(unsigned(I_Addr(5 downto 0))));
			end if;
		end if;
	end process;

	O_Ready <= '1'; -- for now not implemented
end behav_ram_sim;
