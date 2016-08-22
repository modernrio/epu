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
	X"3b", -- 0x0005: load r0, 0d20
	X"00",
	X"00",
	X"14",
	X"3b", -- 0x0009: load r1, 0d5
	X"10",
	X"00",
	X"05",
	X"3b", -- 0x000d: load r2, 0d48
	X"20",
	X"00",
	X"30",
	X"3b", -- 0x0011: load r3, 0d6
	X"30",
	X"00",
	X"06",
	X"3b", -- 0x0015: load r4, 0d24
	X"40",
	X"00",
	X"18",
	X"3b", -- 0x0019: load r5, 0d7
	X"50",
	X"00",
	X"07",
	X"3b", -- 0x001d: load r6, 0d6497
	X"60",
	X"19",
	X"61",
	X"3b", -- 0x0021: load r7, 0d67
	X"70",
	X"00",
	X"43",
	X"ca", -- 0x0025: div r15, r0, r1
	X"f0",
	X"10",
	X"d2", -- 0x0028: mod r15, r0, r1
	X"f0",
	X"10",
	X"ca", -- 0x002b: div r15, r2, r3
	X"f2",
	X"30",
	X"d2", -- 0x002e: mod r15, r2, r3
	X"f2",
	X"30",
	X"ca", -- 0x0031: div r15, r4, r5
	X"f4",
	X"50",
	X"d2", -- 0x0034: mod r15, r4, r5
	X"f4",
	X"50",
	X"ca", -- 0x0037: div r15, r6, r7
	X"f6",
	X"70",
	X"d2", -- 0x003a: mod r15, r6, r7
	X"f6",
	X"70",
	X"77", -- 0x003d: jmp.i 0x5
	X"00",
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
