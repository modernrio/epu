library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.epu_pack.all;

entity vga_640x480 is
	port(
		-- Eingänge
		I_PClk	: in std_logic;						-- Pixeltakt
		I_Reset	: in std_logic;						-- Reset

		-- Ausgänge
		O_VON	: out std_logic;					-- Sichtbarer Bereich
		O_HS	: out std_logic;					-- Horizontale Synchronisation
		O_VS	: out std_logic;					-- Vertikale Syncrhonisation
		O_HC	: out std_logic_vector(9 downto 0);	-- Horizontaler Zähler
		O_VC	: out std_logic_vector(9 downto 0)	-- Vertikaler Zähler
	);
end vga_640x480;

architecture vga_640x480_behav of vga_640x480 is
-- Konstanten
	-- Anzahl an Pixeln in einer Reihe = 800
	constant hpixels	: std_logic_vector(9 downto 0) := "1100100000";
	-- Anzahl an Reihen = 521
	constant vlines		: std_logic_vector(9 downto 0) := "1000001001";
	-- Horizontale Back Porch = 144 = 128 + 16
	constant hbp		: std_logic_vector(9 downto 0) := "0010010000";
	-- Horizontale Front Porch = 784 = 128 + 16 + 640
	constant hfp		: std_logic_vector(9 downto 0) := "1100010000";
	-- Vertikale Back Porch = 31 = 2 + 29
	constant vbp		: std_logic_vector(9 downto 0) := "0000011111";
	-- Vertikale Front Porch = 511 = 2 + 29 + 480
	constant vfp		: std_logic_vector(9 downto 0) := "0111111111";

-- Signale
	-- Horizontaler und vertikaler Zähler
	signal hcs, vcs		: std_logic_vector(9 downto 0);
	-- Aktiviert den vertikalen Zähler
	signal vsenable		: std_logic;
begin
	-- Horizontaler Synchronisationspuls ist '0' wenn hcs zwischen 0 und 127 liegt
	O_HS <= '0' when unsigned(hcs) < 128 else '1';

	-- Zähler für die horizontale Synchronisation
	process(I_PClk, I_Reset)
	begin
		if I_Reset = '1' then
			hcs <= "0000000000";
		elsif rising_edge(I_PClk) then
			-- Wenn das Ende der Reihe erreicht wurde
			if unsigned(hcs) = unsigned(hpixels) - 1 then
				-- Setze den Zähler zurück und aktiviere den vertikalen Zähler
				hcs <= "0000000000";
				vsenable <= '1';
			else
				-- Erhöhe den Zähler um eins und stelle sicher, dass der vertikale Zähler
				-- deaktiviert ist
				hcs <= std_logic_vector(unsigned(hcs) + 1);
				vsenable <= '0';
			end if;
		end if;
	end process;

	-- Vertikaler Synchronisationspuls ist '0' wenn vcs zwischen 0 und 1 liegt
	O_VS <= '0' when unsigned(vcs) < 2 else '1';

	-- Zähler für die vertikale Synchronisation
	process(I_PClk, I_Reset, vsenable)
	begin
		if I_Reset = '1' then
			vcs <= "0000000000";
		elsif (rising_edge(I_PClk) and vsenable = '1') then
			-- Erhöhe den Zähler, wenn aktiviert
			if unsigned(vcs) = unsigned(vlines) - 1 then
				-- Setze den Zähler zurück, wenn das Limit erreicht wurde
				vcs <= "0000000000";
			else
				-- Erhöhe den Zähler um eins
				vcs <= std_logic_vector(unsigned(vcs) + 1);
			end if;
		end if;
	end process;

	-- Schalte VON ein, wenn der zu zeichnende Pixel innerhalb der Porches ist
	O_VON <= '1' when (((hcs < hfp) and (hcs >= hbp)) and ((vcs < vfp) and (vcs >= vbp))) else '0';

	-- Gebe die Zähler aus
	O_HC <= hcs;
	O_VC <= vcs;
end vga_640x480_behav;
