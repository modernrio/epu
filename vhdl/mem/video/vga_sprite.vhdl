library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.epu_pack.all;

entity vga_sprite is
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
end vga_sprite;

architecture vga_sprite_behav of vga_sprite is
	constant hbp	: std_logic_vector(9 downto 0) := "0010010000";
	constant vbp	: std_logic_vector(9 downto 0) := "0000011111";
	constant w		: integer := 640;
	constant h		: integer := 480;

	signal xpix		: std_logic_vector(9 downto 0);
	signal ypix		: std_logic_vector(9 downto 0);
	signal C1, R1	: std_logic_vector(9 downto 0);
	signal spriteon : std_logic;
	signal R, G		: std_logic_vector(2 downto 0);
	signal B		: std_logic_vector(1 downto 0);
	signal char_cnt : integer := 0;
begin
	-- C1 <= "0000" & I_SW(6) & "000001";
	-- R1 <= "0000" & I_SW(3) & "000001";
	C1 <= "0000000001";
	R1 <= "0000000001";

	-- Give out the x and y values of the sprite
	xpix <= std_logic_vector(unsigned(I_VC) - unsigned(vbp)  - unsigned(R1));
	ypix <= std_logic_vector(unsigned(I_HC) - unsigned(hbp)  - unsigned(C1));

	-- Enable sprite video out when within the sprite region
	spriteon <= '1' when (((unsigned(I_HC) > unsigned(C1) + unsigned(hbp))
				and (unsigned(I_HC) <= unsigned(C1) + unsigned(hbp) + w))
				and ((unsigned(I_VC) >= unsigned(R1) + unsigned(vbp))
				and (unsigned(I_VC) < unsigned(R1) + unsigned(vbp) + h)))
				else '0';

	process(I_PClk, spriteon, I_VON, I_Data)
	begin
		if rising_edge(I_PClk) then
			if spriteon = '1' and I_VON = '1' then
				R <= I_Data(7 downto 5);
				G <= I_Data(4 downto 2);
				B <= I_Data(1 downto 0);

				if char_cnt >= 80 then
					char_cnt <= 0;
				elsif xpix(2 downto 0) = "100" then
					char_cnt <= char_cnt + 1;
				end if;
			else
				R <= "000";
				G <= "000";
				B <= "00";
			end if;
		end if;
	end process;

	O_X <= xpix;
	O_Y <= ypix;
	O_C <= char_cnt;

	O_Red <= R;
	O_Green <= G;
	O_Blue <= B;
end vga_sprite_behav;
