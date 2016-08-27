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
		O_Data        : out std_logic_vector(7 downto 0);	-- Datenausgang
		O_LED	      : out std_logic_vector(7 downto 0)	-- LEDs
	);
end ram_sim;

architecture behav_ram_sim of ram_sim is
	constant RAM_MAX  : integer := 26;
	type store_t is array(0 to RAM_MAX - 1) of std_logic_vector(7 downto 0);

	signal ram : store_t := (
		X"77", -- 0x0000: jmp.i 0x5
		X"00",
		X"00",
		X"05",
		X"90", -- 0x0004: ret
		X"3b", -- 0x0005: load r0, 0xAA55
		X"00",
		X"aa",
		X"55",
		X"3b", -- 0x0009: load r1, 0x19
		X"10",
		X"00",
		X"19",
		X"53", -- 0x000d: write.l r1, r0, 0x0
		X"01",
		X"00",
		X"00",
		X"57", -- 0x0011: write.h r1, r0, 0x0
		X"01",
		X"00",
		X"00",
		X"77", -- 0x0015: jmp.i 0xd
		X"00",
		X"00",
		X"0d",
		X"00"  -- .data 0x00
	);
begin
	ram_proc : process(I_Clk)
	begin
		if rising_edge(I_Clk) then
			if (I_We = '1') then
				ram(to_integer(unsigned(I_Addr(6 downto 0)))) <= I_Data;
			else
				O_Data <= ram(to_integer(unsigned(I_Addr(6 downto 0))));
			end if;
		end if;
	end process;
	
	O_LED <= ram(25);
	O_Ready <= '1'; -- for now not implemented
end behav_ram_sim;
