----------------------------------------------------------------------------------------------------
-- Beschreibung: Stack zum Speichern von Variablen und Rückkehraddressen von Funktionen
----------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.epu_pack.all;

entity stack is
	port(
		-- Eingänge
		I_Clk   : in std_logic;							-- Takteingang
		I_En    : in std_logic;							-- Freigabesignal
		I_We    : in std_logic;							-- Schreibfreigabe
		I_Data  : in std_logic_vector(15 downto 0);		-- Dateneingang

		-- Ausgänge
		O_Data   : out std_logic_vector(15 downto 0)	-- Ergebnis
	);
end stack;

architecture behav_stack of stack is
	constant STACK_MAX : integer := 255;
	type store_t is array(STACK_MAX downto 0) of std_logic_vector(15 downto 0);

	signal S_Stack   : store_t := (others => X"0000");
	signal S_Pointer : integer range 0 to STACK_MAX := STACK_MAX;
	signal S_Full    : std_logic := '0';
	signal S_Empty   : std_logic := '0';
begin
	process(I_Clk, I_En)
	begin
		if rising_edge(I_Clk) and I_En = '1' then
			if I_We = '1' and S_Full = '0' then
				-- PUSH
				S_Stack(S_Pointer) <= I_Data;
				if S_Pointer /= 0 then
					S_Pointer <= S_Pointer - 1;
				end if;
				-- Flags setzen
				if S_Pointer - 1 = 0 then
					S_Full <= '1';
					S_Empty <= '0';
				else
					S_Full <= '0';
					S_Empty <= '0';
				end if;
			elsif I_We = '0' and S_Empty = '0' then
				-- POP
				if S_Pointer /= STACK_MAX then
					O_Data <= S_Stack(S_Pointer + 1);
					S_Pointer <= S_Pointer + 1;
				end if;
				-- Flags setzen
				if S_Pointer + 1 = STACK_MAX then
					S_Full <= '0';
					S_Empty <= '1';
				else
					S_Full <= '0';
					S_Empty <= '0';
				end if;
			end if;
		end if;
	end process;
end behav_stack;
