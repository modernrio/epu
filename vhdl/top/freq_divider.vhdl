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
		I_Clk : in std_logic;
		O_Clk : out std_logic
	);

end freq_divider;

architecture behav_freq_divider of freq_divider is
	signal scaler : std_logic_vector(20 downto 0) := (others => '0');
begin
	freq_div_proc : process(I_Clk)
	begin
		if rising_edge(I_Clk) then
			scaler <= std_logic_vector(unsigned(scaler) + 1);
		end if;
	end process;

	O_Clk <= scaler(20);
end behav_freq_divider;
