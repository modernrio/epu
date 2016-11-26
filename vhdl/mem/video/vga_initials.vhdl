library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.epu_pack.all;

entity vga_initials is
	port(
		I_VON	: in std_logic;
		I_HC	: in std_logic_vector(9 downto 0);
		I_VC	: in std_logic_vector(9 downto 0);
		I_Data	: in std_logic_vector(7 downto 0);
		I_SW	: in std_logic_vector(6 downto 0);
		O_Addr	: out std_logic_vector(15 downto 0);
		O_Red	: out std_logic_vector(2 downto 0);
		O_Green	: out std_logic_vector(2 downto 0);
		O_Blue	: out std_logic_vector(1 downto 0)
	);
end vga_initials;

architecture vga_initials_behav of vga_initials is
	constant hbp	: std_logic_vector(9 downto 0) := "0010010000";
	constant vbp	: std_logic_vector(9 downto 0) := "0000011111";
	constant w		: integer := 240;
	constant h		: integer := 160;

	signal xpix		: std_logic_vector(9 downto 0);
	signal ypix		: std_logic_vector(9 downto 0);
	signal C1, R1	: std_logic_vector(9 downto 0);
	signal spriteon : std_logic;
	signal R, G, B	: std_logic;
begin
	-- C1 <= "0000" & I_SW(6) & "000001";
	-- R1 <= "0000" & I_SW(3) & "000001";
	C1 <= "0000000001";
	R1 <= "0000000001";

	ypix <= std_logic_vector(unsigned(I_VC) - unsigned(vbp)  - unsigned(R1));
	xpix <= std_logic_vector(unsigned(I_HC) - unsigned(hbp)  - unsigned(C1));

	-- Enable sprite video out when within the sprite region
	spriteon <= '1' when (((unsigned(I_HC) > unsigned(C1) + unsigned(hbp))
				and (unsigned(I_HC) <= unsigned(C1) + unsigned(hbp) + w))
				and ((unsigned(I_VC) >= unsigned(R1) + unsigned(vbp))
				and (unsigned(I_VC) < unsigned(R1) + unsigned(vbp) + h)))
				else '0';

	process(xpix, ypix)
		variable addr : std_logic_vector(19 downto 0);
	begin
		-- rom_addr = w*y + x
		addr := std_logic_vector((w * unsigned(ypix)) + unsigned(xpix));
		O_Addr <= addr(15 downto 0);
	end process;

	process(spriteon, I_VON, I_Data)
	begin
		if spriteon = '1' and I_VON = '1' then
			O_Red <= I_Data(7 downto 5);
			O_Green <= I_Data(4 downto 2);
			O_Blue <= I_Data(1 downto 0);
		else
			O_Red <= "000";
			O_Green <= "000";
			O_Blue <= "00";
		end if;
	end process;
end vga_initials_behav;
