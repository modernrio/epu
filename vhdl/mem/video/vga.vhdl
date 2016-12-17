library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.epu_pack.all;

entity vga is
	port(
		-- Eingänge
		I_TClk	: in std_logic;							-- Speichertakt
		I_PClk	: in std_logic;							-- Pixeltakt
		I_SW	: in std_logic_vector(6 downto 0);		-- Buttons (SW1-SW7)
		I_Reset : in std_logic;							-- Reset
		I_Data	: in std_logic_vector(7 downto 0);		-- Videospeichereingang

		-- Ausgänge
		O_Addr	: out std_logic_vector(15 downto 0);	-- Videospeicheradresse
		O_HS	: out std_logic;						-- Horizontale Synchronisation
		O_VS	: out std_logic;						-- Vertikale Syncrhonisation
		O_Red	: out std_logic_vector(2 downto 0);		-- Rotanteil
		O_Green	:out std_logic_vector(2 downto 0);		-- Grünanteil
		O_Blue	: out std_logic_vector(1 downto 0)		-- Blauanteil
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

	component vga_sprite
	port(
		I_PClk	: in std_logic;
		I_VON	: in std_logic;
		I_HC	: in std_logic_vector(9 downto 0);
		I_VC	: in std_logic_vector(9 downto 0);
		I_Data	: in std_logic_vector(7 downto 0);
		I_SW	: in std_logic_vector(6 downto 0);
		O_X		: out std_logic_vector(9 downto 0);
		O_Y		: out std_logic_vector(9 downto 0);
		O_C		: out integer;
		O_Red	: out std_logic_vector(2 downto 0);
		O_Green	: out std_logic_vector(2 downto 0);
		O_Blue	: out std_logic_vector(1 downto 0)
	);
	end component;

	component text_conv
		port(
			I_Clk	: in std_logic;
			I_MData : in std_logic_vector(7 downto 0);
			I_X		: in std_logic_vector(9 downto 0);
			I_Y		: in std_logic_vector(9 downto 0);
			I_C		: in integer;
			O_MAddr : out std_logic_vector(15 downto 0);
			O_Data	: out std_logic_vector(7 downto 0)
		);
	end component;

	-- Signale
	signal von	: std_logic;
	signal hc	: std_logic_vector(9 downto 0);
	signal vc	: std_logic_vector(9 downto 0);
	signal m	: std_logic_vector(0 to 31);
	signal addr : std_logic_vector(3 downto 0);
	signal xpix : std_logic_vector(9 downto 0);
	signal ypix : std_logic_vector(9 downto 0);
	signal char : integer;
	signal data : std_logic_vector(7 downto 0);
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

	uut_vga_sprite : vga_sprite port map(
		I_PClk => I_PClk,
		I_VON => von,
		I_HC => hc,
		I_VC => vc,
		I_Data => data,
		I_SW => I_SW,
		O_X => xpix,
		O_Y => ypix,
		O_C => char,
		O_Red => O_Red,
		O_Green => O_Green,
		O_Blue => O_Blue
	);

	uut_text_conv : text_conv port map(
		I_Clk => I_TClk,
		I_MData => I_Data,
		I_X => xpix,
		I_Y => ypix,
		I_C => char,
		O_MAddr => O_Addr,
		O_Data => data
	);
end vga_behav;
