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
		I_M		: in std_logic_vector(0 to 31);
		I_SW	: in std_logic_vector(6 downto 0);
		O_Addr	: out std_logic_vector(3 downto 0);
		O_Red	: out std_logic_vector(2 downto 0);
		O_Green	: out std_logic_vector(2 downto 0);
		O_Blue	: out std_logic_vector(1 downto 0)
	);
end vga_initials;

architecture vga_initials_behav of vga_initials is
	constant hbp	: std_logic_vector(9 downto 0) := "0010010000";
	constant vbp	: std_logic_vector(9 downto 0) := "0000011111";
	constant w		: integer := 32;
	constant h		: integer := 16;

	signal C1, R1	: std_logic_vector(10 downto 0);
	signal rom_addr : std_logic_vector(10 downto 0);
	signal rom_pix	: std_logic_vector(10 downto 0);
	signal spriteon : std_logic;
	signal R, G, B	: std_logic;
begin
	C1 <= "0000" & I_SW(6) & "000001";
	R1 <= "0000" & I_SW(3) & "000001";
	rom_addr <= std_logic_vector(unsigned(I_VC) - unsigned(vbp) - unsigned(R1));
	rom_pix <= std_logic_vector(unsigned(I_HC) - unsigned(hbp) - unsigned(C1));
	O_Addr <= rom_addr(3 downto 0);

	spriteon <= '1' when (((unsigned(I_HC) >= unsigned(C1) + unsigned(hbp))
				and (unsigned(I_HC) < unsigned(C1) + unsigned(hbp) + w))
				and ((unsigned(I_VC) >= unsigned(R1) + unsigned(vbp))
				and (unsigned(I_VC) < unsigned(R1) + unsigned(vbp) + h)))
				else '0';

	process(spriteon, I_VON, rom_pix, I_M)
	begin
		if spriteon = '1' and I_VON = '1' then
			R <= I_M(to_integer(unsigned(rom_pix)));
			G <= I_M(to_integer(unsigned(rom_pix)));
			B <= I_M(to_integer(unsigned(rom_pix)));
			O_Red <= R & R & R;
			O_Green <= G & G & G;
			O_Blue <= B & B;
		else
			O_Red <= "000";
			O_Green <= "000";
			O_Blue <= "00";
		end if;
	end process;
end vga_initials_behav;
