--------------------------------------------------------------------------------
-- Beschreibung: RAM-Testmodul
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.epu_pack.all;

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
	constant RAM_MAX  : integer := 128;
	type store_t is array(0 to RAM_MAX - 1) of std_logic_vector(7 downto 0);

	signal ram : store_t := (
		X"77", -- 0x0000: jmp.i 0x5
		X"00",
		X"00",
		X"05",
		X"90", -- 0x0004: ret
		X"3b", -- 0x0005: load r0, 0x0
		X"00",
		X"00",
		X"00",
		X"3b", -- 0x0009: load r1, 0x1
		X"10",
		X"00",
		X"01",
		X"d8", -- 0x000d: hlt
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
				ram(to_integer(unsigned(I_Addr(6 downto 0)))) <= I_Data;
			else
				O_Data <= ram(to_integer(unsigned(I_Addr(6 downto 0))));
			end if;
		end if;
	end process;

	O_Ready <= '1'; -- for now not implemented
end behav_ram_sim;
