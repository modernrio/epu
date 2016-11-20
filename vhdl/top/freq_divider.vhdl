--------------------------------------------------------------------------------
-- Beschreibung: Senkt die Taktfrequenz (für Testzwecke)
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.epu_pack.all;

entity freq_divider is
	port(
		I_Clk	: in std_logic;
		O_Clk	: out std_logic;
		Uart_Clk : out std_logic;
		Seg_Clk : out std_logic;
		Video_Clk : out std_logic
	);

end freq_divider;

architecture behav_freq_divider of freq_divider is
	signal scaler : std_logic_vector(22 downto 0) := (others => '0');
begin
	freq_div_proc : process(I_Clk)
	begin
		if rising_edge(I_Clk) then
			scaler <= std_logic_vector(unsigned(scaler) + 1);
		end if;
	end process;

	Uart_Clk <= I_Clk;
	-- O_Clk <= scaler(0); -- 21-22 for synthesis
	O_Clk <= scaler(21);
	Seg_Clk <= scaler(18); -- 18 for synthesis
	Video_Clk <= scaler(1); -- 25Mhz Pixel clock
end behav_freq_divider;
