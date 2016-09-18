library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.epu_pack.all;

entity uart is
	port(
		I_Clk	: in std_logic;
		TXE : in std_logic;
		RD : out std_logic;
		WR : out std_logic;
		RXF : in std_logic;
		In_Data	: inout std_logic_vector(7 downto 0);
		TX_Ready : out std_logic;
		TX : in std_logic;
		TX_Data : in std_logic_vector(7 downto 0);
		T_Clk : out std_logic
	);
end uart;

architecture Behavioral of uart is
	signal count : integer := 4;
	signal tx_clk : std_logic := '0';
	signal tx_count : integer := 0;
	signal baudrate : std_logic_vector(15 downto 0) := X"28B0";
begin
	tx_clk_gen : process(I_Clk)
	begin
		if rising_edge(I_Clk) then
			if tx_count = 0 then
				-- Chop off LSB to get a clock
				tx_count <= to_integer(unsigned(baudrate(15 downto 1)));
				tx_clk <= not tx_clk;
			else
				tx_count <= tx_count - 1;
			end if;
		end if;
	end process;

	hello_proc : process(tx_clk)
	begin
		if rising_edge(tx_clk) then
			case count is
				when 0 =>
					if TXE = '0' then
						count <= count + 1;
					end if;
					WR <= '1';
					RD <= '0';
					TX_Ready <= '0';
				when 1 =>
					In_Data <= TX_Data;
					count <= count + 1;
				when 2 =>
					WR <= '0';
					count <= count + 1;
				when 3 =>
					WR <= '1';
					count <= count + 1;
				when others =>
					TX_Ready <= '1';
					if TX = '1' then
						count <= 0;
					end if;
			end case;
		end if;
	end process;
end Behavioral;

