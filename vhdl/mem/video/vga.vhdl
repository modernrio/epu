library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.epu_pack.all;

entity vga is
	port(
		-- Eingänge
		I_PClk	: in std_logic;		-- Pixeltakt
		I_Reset : in std_logic;		-- Reset

		-- Ausgänge
		O_HS	: out std_logic;					-- Horizontale Synchronisation
		O_VS	: out std_logic;					-- Vertikale Syncrhonisation
		O_Red	: out std_logic_vector(2 downto 0);	-- Rotanteil
		O_Green	:out std_logic_vector(2 downto 0);	-- Grünanteil
		O_Blue	: out std_logic_vector(1 downto 0)	-- Blauanteil
	);
end vga;

architecture vga_behav of vga is
	-- Komponenten
	component vga_640x480
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
	end component;

	component vga_stripes
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
	end component;

	-- Signale
	signal von	: std_logic;
	signal hc	: std_logic_vector(9 downto 0);
	signal vc	: std_logic_vector(9 downto 0);
begin
	uut_vga_640x480 : vga_640x480 port map(
		I_PClk => I_PClk,
		I_Reset => I_Reset,
		O_VON => von,
		O_HS => O_HS,
		O_VS => O_VS,
		O_HC => hc,
		O_VC => vc
	);

	uut_vga_stripes : vga_stripes port map(
		I_VON => von,
		I_HC => hc,
		I_VC => vc,
		O_Red => O_Red,
		O_Green => O_Green,
		O_Blue => O_Blue
	);
end vga_behav;
