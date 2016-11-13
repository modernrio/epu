library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.epu_pack.all;

entity vga_stripes is
	port(
		-- Eingänge
		I_VON	: in std_logic;						-- Sichtbarer Bereich?
		I_HC	: in std_logic_vector(9 downto 0);	-- Horizontale Syncrhonisation
		I_VC	: in std_logic_vector(9 downto 0);	-- Vertikale Synchronisation

		-- Ausgänge
		O_Red	: out std_logic_vector(2 downto 0);	-- Rotanteil
		O_Green	: out std_logic_vector(2 downto 0);	-- Grünanteil
		O_Blue	: out std_logic_vector(1 downto 0)	-- Blauanteil
	);
end vga_stripes;

architecture vga_stripes_behav of vga_stripes is
begin
	-- Erstelle rote + grüne horizontale Streifen
	process(I_VON, I_VC)
	begin
		-- Blau wird nicht benötigt
		O_Blue <= "00";

		-- Wenn Pixel im sichtbaren Bereich sind
		if I_VON = '1' then
			O_Red <= I_VC(4) & I_VC(4) & I_VC(4);
			O_Green <= not(I_VC(4) & I_VC(4) & I_VC(4));
		else
			O_Red <= "000";
			O_Green <= "000";
		end if;
	end process;
end vga_stripes_behav;
