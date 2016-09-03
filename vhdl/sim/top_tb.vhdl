library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.epu_pack.all;

entity top_tb is
end top_tb;
 
architecture behav_top_tb of top_tb is 
	-- Komponentendeklaration für das zu testende Gerät (UUT)
	component top
		port(
			MainClk	: in  std_logic;
			RST		: in  std_logic;
			SEGEn	: out std_logic_vector(2 downto 0);
			LED		: out  std_logic_vector(7 downto 0);
			SEG		: out std_logic_vector(7 downto 0)
        );
	end component;
    

	-- Signale
		-- Eingänge
	signal MainClk : std_logic := '0';
	signal RST : std_logic := '0';
		-- Ausgänge
	signal SEGEn : std_logic_vector(2 downto 0);
	signal LED 	 : std_logic_vector(7 downto 0);
	signal SEG 	 : std_logic_vector(7 downto 0);
	   -- Taktperiode
	constant MainClk_period : time := 10 ns;
 
begin
	-- Instanz der UUTs erstellen
	uut: top port map (
		MainClk => MainClk,
		RST => RST,
		LED => LED,
		SEG => SEG,
		SEGEn => SEGEn
	);

   -- Taktprozess
   MainClk_process :process
   begin
		MainClk <= '0';
		wait for MainClk_period/2;
		MainClk <= '1';
		wait for MainClk_period/2;
   end process;
end behav_top_tb;
