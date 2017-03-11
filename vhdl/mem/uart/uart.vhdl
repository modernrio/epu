library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.epu_pack.all;

entity uart is
	port(
		-- Physical interface
		I_Clk			: in std_logic;
		TX				: out std_logic;
		RX				: in std_logic;

		-- Client Interface
		I_Reset			: in std_logic;
			-- TX
		I_TX_Data		: in std_logic_vector(7 downto 0);
		I_TX_Enable		: in std_logic;
		O_TX_Ready		: out std_logic;
			-- RX
		I_RX_Cont		: in std_logic;
		O_RX_Data		: out std_logic_vector(7 downto 0);
		O_RX_Sig		: out std_logic;
		O_RX_FrameError	: out std_logic
	);
end uart;

architecture uart_behav of uart is
	type tx_state_t is (idle, active);

	signal rx_clk_count : integer := 0;
	signal rx_clk_reset : std_logic := '0';
	signal rx_clk_baud_tick : std_logic := '0';
	signal rx_state : integer := 0;
	signal rx_sig : std_logic := '0';
	signal rx_sig_count : integer := 0; -- to delay turning rx_sig off
	signal rx_sample_count : integer := 0;
	signal rx_sample_offset : integer := 3;
	signal rx_data : std_logic_vector(7 downto 0) := (others => '0');

	signal tx_clk_count : integer := 0;
	signal tx_count : integer range 0 to 9 := 0;
	signal tx_clk	: std_logic := '0';
	signal tx_state : tx_state_t := idle;
	-- signal baudrate : std_logic_vector(15 downto 0) := X"006C"; -- 921600bps @ 100Mhz
	-- signal baudrate : std_logic_vector(15 downto 0) := X"0365"; -- 115200bps @ 100Mhz
	signal baudrate : std_logic_vector(15 downto 0) := X"28B0"; -- 9600bps @ 100Mhz

	constant OFFSET_START_BIT : integer := 7;
	constant OFFSET_DATA_BITS : integer := 15;
	constant OFFSET_STOP_BIT  : integer := 7;
begin
	clk_gen : process(I_Clk)
	begin
		if rising_edge(I_Clk) then
			-- TX
			if tx_clk_count = 0 then
				tx_clk_count <= to_integer(unsigned(baudrate(15 downto 1)));
				tx_clk <= not tx_clk;
			else
				tx_clk_count <= tx_clk_count - 1;
			end if;

			-- RX
			if rx_clk_count = 0 then
				-- x16-Probe
				rx_clk_count <= to_integer(unsigned(baudrate(15 downto 4)));
				rx_clk_baud_tick <= '1';
			else
				rx_clk_baud_tick <= '0';
				if rx_clk_reset = '1' then
					rx_clk_count <= to_integer(unsigned(baudrate(15 downto 4)));
				else
					rx_clk_count <= rx_clk_count - 1;
				end if;
			end if;
		end if;
	end process;

	O_RX_Sig <= rx_sig;
	rx_proc : process(I_Clk)
	begin
		if rising_edge(I_Clk) then
			if rx_clk_reset = '1' then
				rx_clk_reset <= '0';
			end if;

			if I_Reset = '1' then
				rx_state <= 0;
				rx_sig <= '0';
				rx_sample_count <= 0;
				rx_sample_offset <= OFFSET_START_BIT;
				rx_data <= X"00";
				O_RX_Data <= X"00";
			elsif RX = '0' and rx_state = 0 and I_RX_Cont = '1' then
				rx_state <= 1;
				rx_sample_offset <= OFFSET_START_BIT;
				rx_sample_count <= 0;
				rx_clk_reset <= '1';
			elsif rx_clk_baud_tick = '1' and RX = '0' and rx_state = 1 then
				rx_sample_count <= rx_sample_count + 1;
				if rx_sample_count = rx_sample_offset then
					rx_state <= 2;
					rx_data <= X"00";
					rx_sample_offset <= OFFSET_DATA_BITS;
					rx_sample_count <= 0;
				end if;
			elsif rx_clk_baud_tick = '1' and rx_state >= 2 and rx_state < 10 then
				if rx_sample_count = rx_sample_offset then
					rx_data(6 downto 0) <= rx_data(7 downto 1);
					rx_data(7) <= RX;
					rx_sample_count <= 0;
					rx_state <= rx_state + 1;
				else
					rx_sample_count <= rx_sample_count + 1;
				end if;
			elsif rx_clk_baud_tick = '1' and rx_state = 10 then
				if rx_sample_count = OFFSET_STOP_BIT then
					rx_state <= 0;
					O_RX_Data <= rx_data;

					if RX = '1' then
						-- Stopbit korrekt
						O_RX_FrameError <= '0';
						rx_sig <= '1';
					else
						-- Fehler
						O_RX_FrameError <= '1';
					end if;
				else
					rx_sample_count <= rx_sample_count + 1;
				end if;
			else
				if rx_sig = '1' then
					if rx_sig_count < 3 then
						rx_sig_count <= rx_sig_count + 1;
					else
						rx_sig <= '0';
						rx_sig_count <= 0;
					end if;
				end if;
			end if;
		end if;
	end process;

    tx_proc : process(tx_clk)
    begin
        if rising_edge(tx_clk) then
            case tx_state is
                when idle =>
                    TX <= '1';
					if I_TX_Enable = '1' then
						tx_state <= active;
					end if;
                when active =>
					case tx_count is
						when 0 =>
							-- Startbit
							TX <= '0';
							tx_count <= tx_count + 1;
							O_TX_Ready <= '0';
						when 1 =>
							TX <= I_TX_Data(0);
							tx_count <= tx_count + 1;
						when 2 =>
							TX <= I_TX_Data(1);
							tx_count <= tx_count + 1;
						when 3 =>
							TX <= I_TX_Data(2);
							tx_count <= tx_count + 1;
						when 4 =>
							TX <= I_TX_Data(3);
							tx_count <= tx_count + 1;
						when 5 =>
							TX <= I_TX_Data(4);
							tx_count <= tx_count + 1;
						when 6 =>
							TX <= I_TX_Data(5);
							tx_count <= tx_count + 1;
						when 7 =>
							TX <= I_TX_Data(6);
							tx_count <= tx_count + 1;
						when 8 =>
							TX <= I_TX_Data(7);
							tx_count <= tx_count + 1;
						when 9 =>
							-- Stopbit
							TX <= '1';
							tx_count <= 0;
							O_TX_Ready <= '1';
							if I_TX_Enable = '0' then
								tx_state <= idle;
							end if;
				end case;
            end case;
        end if;
    end process;
end uart_behav;
