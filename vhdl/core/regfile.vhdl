----------------------------------------------------------------------------------------------------
-- Beschreibung: Registerdatei für das Auswählen der Register
----------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.epu_pack.all;

entity regfile is
	port(
			-- Eingänge
			I_Clk   : in std_logic;							-- Takteingang
			I_En    : in std_logic;							-- Freigabesignal
			I_We    : in std_logic;							-- Schreibfreigabe
			I_Byte  : in std_logic;							-- Schreibbreite
			I_High  : in std_logic;							-- Auswahl High-/Low-Byte
			I_SelA  : in std_logic_vector(3 downto 0);		-- Wählt Register für Ausgang A
			I_SelB  : in std_logic_vector(3 downto 0);		-- Wählt Register für Ausgang B
			I_SelD  : in std_logic_vector(3 downto 0);		-- Wählt Register für Eingang D
			I_DataD : in std_logic_vector(15 downto 0);		-- Dateneingang für D

			-- Ausgänge
			O_LED : out std_logic_vector(7 downto 0);

			O_DataA : out std_logic_vector(15 downto 0);	-- Datenausgang für A
			O_DataB : out std_logic_vector(15 downto 0)		-- Datenausgang für B
		);
end regfile;

architecture behav_regfile of regfile is
	type store_t is array(0 to 15) of std_logic_vector(15 downto 0);

	signal regs : store_t := (others => X"0000");

	signal S_DataA : std_logic_vector(15 downto 0) := (others => '0');
	signal S_DataB : std_logic_vector(15 downto 0) := (others => '0');
begin
	process(I_Clk, I_En)
	begin
		if rising_edge(I_Clk) and I_En = '1' then
			-- Registerinhalt ausgeben (unabhängig von I_We)
			S_DataA <= regs(to_integer(unsigned(I_SelA)));
			S_DataB <= regs(to_integer(unsigned(I_SelB)));

			if I_We = '1' then
				-- Daten in Register schreiben
				if I_Byte = '0' then
					-- 2 Byte
					regs(to_integer(unsigned(I_SelD))) <= I_DataD;
				else
					-- 1 Byte
					if I_High = '0' then
						-- Schreibe in MSB
						regs(to_integer(unsigned(I_SelD)))(15 downto 8) <= I_DataD(15 downto 8);
					else
						-- Schreibe in LSB
						regs(to_integer(unsigned(I_SelD)))(7 downto 0) <= I_DataD(7 downto 0);
					end if;
				end if;
			end if;
		end if;
	end process;

	O_DataA <= S_DataA;
	O_DataB <= S_DataB;
	O_LED <= regs(3)(7 downto 0);
end behav_regfile;
