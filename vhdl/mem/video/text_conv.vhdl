library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.epu_pack.all;

entity text_conv is
	port(
		I_Clk	: in std_logic;
		I_MData : in std_logic_vector(7 downto 0);
		I_X		: in std_logic_vector(9 downto 0);
		I_Y		: in std_logic_vector(9 downto 0);
		I_C		: in integer;
		O_MAddr : out std_logic_vector(15 downto 0);
		O_Data	: out std_logic_vector(7 downto 0)
	);
end text_conv;

architecture text_conv_behav of text_conv is
	component font_rom
		port(
		  clk: in std_logic;
		  addr: in std_logic_vector(10 downto 0);
		  data: out std_logic_vector(7 downto 0)
		);
	end component;

	signal byte			: std_logic_vector(0 downto 0) := "1";
	signal font_addr	: std_logic_vector(10 downto 0);
	signal font_data	: std_logic_vector(7 downto 0);
	signal color_data	: std_logic_vector(7 downto 0);

	type colors_t is array(0 to 15) of std_logic_vector(7 downto 0);
	constant colors : colors_t:=(  
		X"00", -- 0 Black
		X"E0", -- 1 Red
		X"1C", -- 2 Green
		X"03", -- 3 Blue
		X"00", -- 4 Unknown
		X"00", -- 5 Unknown
		X"00", -- 6 Unknown
		X"00", -- 7 Unknown
		X"00", -- 8 Unknown
		X"00", -- 9 Unknown
		X"00", -- a Unknown
		X"00", -- b Unknown
		X"00", -- c Unknown
		X"00", -- d Unknown
		X"00", -- e Unknown
		X"00"  -- f Unknown
	);

	constant CHAR_WIDTH		: std_logic_vector(3 downto 0) := X"8";
	constant CHAR_HEIGHT	: std_logic_vector(7 downto 0) := X"10";
begin
	uut_font_rom : font_rom port map(
		clk => I_Clk,
		addr => font_addr,
		data => font_data
	);

	process(I_Clk)
	begin
		if falling_edge(I_Clk) then
			byte(0) <= not byte(0);
			
			O_MAddr <= std_logic_vector(unsigned(ADDR_TEXT_BEGIN) + I_C);
		end if;
	end process;

	process(I_Clk)
		variable font_bit : std_logic_vector(3 downto 0);
		variable font_color : std_logic_vector(3 downto 0);
	begin
		if falling_edge(I_Clk) then
			if byte(0) = '0' then
				-- ASCII byte
				-- TODO: Font address is not correct.
				--		 The formula is correct, but is not executed as planned.
				font_addr <= "000" & std_logic_vector(unsigned(I_MData) +
									 modulo(unsigned(I_Y), unsigned(CHAR_HEIGHT)));
			else
				-- Color byte
				color_data <= I_MData;
			end if;

			font_bit := std_logic_vector(modulo(unsigned(I_X), unsigned(CHAR_WIDTH)));
			if font_data(to_integer(unsigned(font_bit(2 downto 0)))) = '1' then
				font_color := color_data(3 downto 0);
				O_Data <= colors(to_integer(unsigned(font_color)));
			else
				font_color := '0' & color_data(6 downto 4);
				O_Data <= colors(to_integer(unsigned(font_color)));
			end if;
		end if;
	end process;

end text_conv_behav;
