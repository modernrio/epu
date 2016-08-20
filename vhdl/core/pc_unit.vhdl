----------------------------------------------------------------------------------------------------
-- Name: Befehlszähler
--
-- Projekt: EPU
--
-- Autor: Markus Schneider
--
-- Erstellungsdatum: 23.07.2016
--
-- Version: 1.1
--
-- Beschreibung: Zeiger auf den nächsten auszuführenden Befehl
----------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;

entity pc_unit is
	port(
		-- Eingänge
		I_Clk      : in std_logic;							-- Takteingang
		I_Op       : in std_logic_vector(1 downto 0);		-- PC-Operation
		I_PC       : in std_logic_vector(15 downto 0);		-- Sprungadresse

		-- Ausgänge
		O_PC    : out std_logic_vector(15 downto 0)		-- Befehlszeigerausgabe
	);
end pc_unit;

architecture behav_pc_unit of pc_unit is
	signal S_CurPC : std_logic_vector(15 downto 0) := ADDR_RESET;
begin
	process(I_Clk)
	begin
		if rising_edge(I_Clk) then
			case I_Op is
				when PC_OP_NOP =>
					-- NOP - Verändere nichts
				when PC_OP_INC =>
					-- Inkrementiere den Befehlszähler
					S_CurPC <= std_logic_vector(unsigned(S_CurPC) + 1);
				when PC_OP_ASSIGN =>
					-- Setze den Befehlszähler auf die Sprungadresse
					S_CurPC <= I_PC;
				when PC_OP_RESET =>
					-- Setze den Befehlszähler auf null
					S_CurPC <= ADDR_RESET;
				when others =>
			end case;
		end if;
	end process;

	O_PC <= S_CurPC;
end behav_pc_unit;
