----------------------------------------------------------------------------------------------------
-- Beschreibung: Regelt den Datenfluss zwischen dem Speicher und dem Prozessor
----------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.epu_pack.all;

entity memory_control is
	port(
		-- Eingänge
		I_MEM_Clk         : in std_logic;
		I_MEM_Reset       : in std_logic;
		I_MEM_En	      : in std_logic;
		I_MEM_We		  : in std_logic;
		I_MEM_Data		  : in std_logic_vector(7 downto 0);
		I_MEM_Addr		  : in std_logic_vector(15 downto 0);
		I_VID_Clk		  : in std_logic;

		-- Ausgänge
		O_MEM_Ready		  : out std_logic;
		O_MEM_Data        : out std_logic_vector(7 downto 0);
		O_LED			  : out std_logic_vector(7 downto 0);
		O_VID_Red		  : out std_logic;
		O_VID_Green		  : out std_logic;
		O_VID_Blue		  : out std_logic;
		O_VID_HSync		  : out std_logic;
		O_VID_VSync		  : out std_logic;

		UClk			  : in std_logic;
		TX				  : out std_logic;
		RX				  : in std_logic
	);
end memory_control;

architecture behav_memory_control of memory_control is
	-- Komponentendeklaration für das zu testende Gerät (UUT)
	component blk_mem
		port(
			-- Port A
			clka	: in std_logic;
			ena		: in std_logic;
			wea		: in std_logic_vector(0 downto 0);
			addra	: in std_logic_vector(15 downto 0);
			dina	: in std_logic_vector(7 downto 0);
			douta	: out std_logic_vector(7 downto 0);
			-- Port B
			clkb	: in std_logic;
			enb		: in std_logic;
			web		: in std_logic_vector(0 downto 0);
			addrb	: in std_logic_vector(15 downto 0);
			dinb	: in std_logic_vector(7 downto 0);
			doutb	: out std_logic_vector(7 downto 0)
	  );
	end component;
	
	component vga80x40
		port (
			reset		  : in  std_logic;
      		clk25MHz      : in  std_logic;
      		R             : out std_logic;
      		G             : out std_logic;
      		B             : out std_logic;
      		TEXT_A        : out std_logic_vector(11 downto 0);
      		TEXT_D        : in  std_logic_vector(07 downto 0);
			FONT_A        : out std_logic_vector(11 downto 0);
			FONT_D        : in  std_logic_vector(07 downto 0);
			hsync         : out std_logic;
      		vsync         : out std_logic;
      		ocrx		  : in  std_logic_vector(7 downto 0);
      		ocry    	  : in  std_logic_vector(7 downto 0);
      		octl    	  : in  std_logic_vector(7 downto 0)
      );   
	end component;

	component mem_text
		port (
			clka		  : in  std_logic;
			dina  		  : in  std_logic_vector(7 downto 0);
			addra 		  : in  std_logic_vector(11 downto 0);
			wea   		  : in  std_logic_vector(0 downto 0);
			douta 		  : out std_logic_vector(7 downto 0);
			clkb  		  : in  std_logic;
			dinb  		  : in  std_logic_vector(7 downto 0);
			addrb 		  : in  std_logic_vector(11 downto 0);
			web   		  : in  std_logic_vector(0 downto 0);
			doutb 		  : out std_logic_vector(7 downto 0)
		);
	end component;

	component mem_font
		port (
			clka		  : IN std_logic;
			dina  		  : in  std_logic_vector(7 downto 0);
			addra		  : IN std_logic_VECTOR(11 downto 0);
			wea   		  : in  std_logic_vector(0 downto 0);
			douta		  : OUT std_logic_VECTOR(7 downto 0)
		);
	end component;

	
	component uart is
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
	end component;


	-- Signale
	signal S_MEM_Ready    : std_logic := '0';
	signal S_MEM_Data     : std_logic_vector(7 downto 0) := (others => '0');
	signal we					: std_logic_vector(0 downto 0) := (others => '0');

	signal S_RAM_Ready    : std_logic := '0';
	signal S_RAM_Data     : std_logic_vector(7 downto 0) := (others => '0');
	signal LED			  : std_logic_vector(7 downto 0) := (others => '0');
	
	signal tx_ready		  : std_logic := '0';
	signal rx_data		  : std_logic_vector(7 downto 0) := (others => '0');
	signal rx_ready		  : std_logic := '0';
	signal rx_error		  : std_logic := '0';
	signal rx_cont		  : std_logic := '0';

	-- Video signals
	signal clk25MHz    : std_logic;
	signal crx_oreg_ce : std_logic;
	signal cry_oreg_ce : std_logic;
	signal ctl_oreg_ce : std_logic;
	signal crx_oreg    : std_logic_vector(7 downto 0) := (others => '0');
	signal cry_oreg    : std_logic_vector(7 downto 0) := (others => '0');
	signal ctl_oreg    : std_logic_vector(7 downto 0);
	
	-- Text Buffer RAM Memory Signals, Port A (to CPU core)
	signal ram_diA : std_logic_vector(07 downto 0);
	signal ram_doA : std_logic_vector(07 downto 0);
	signal ram_adA : std_logic_vector(11 downto 0);
	signal ram_weA : std_logic_vector(00 downto 0);
	
	-- Text Buffer RAM Memory Signals, Port B (to VGA core)
	signal ram_diB : std_logic_vector(07 downto 0);
	signal ram_doB : std_logic_vector(07 downto 0);
	signal ram_adB : std_logic_vector(11 downto 0);
	signal ram_weB : std_logic_vector(00 downto 0);
	
	-- Font Buffer RAM Memory Signals
	signal rom_adB : std_logic_vector(11 downto 0);
	signal rom_doB : std_logic_vector(07 downto 0);

	-- Block RAM Signals
	signal blk_diA : std_logic_vector(07 downto 0);
	signal blk_doA : std_logic_vector(07 downto 0);
	signal blk_adA : std_logic_vector(15 downto 0);
	signal blk_weA : std_logic_vector(00 downto 0);
	
	signal last_addr : std_logic_vector(15 downto 0);
begin
	we(0) <= I_MEM_We;

	-- Instanz der UUTs erstellen
	uut_blk_mem : blk_mem port map (
		clka => I_MEM_Clk,
		ena => I_MEM_En,
		wea => blk_weA,
		addra => blk_adA,
		dina => blk_diA,
		douta => blk_doA,
		clkb => I_MEM_Clk,
		enb => '0',
		web => "0",
		addrb => X"0000",
		dinb => X"00"
	  );

	uut_vga80x40 : vga80x40 port map (
		reset => I_MEM_Reset,
		clk25MHz => I_VID_Clk,
		R => O_VID_Red,
		G => O_VID_Green,
		B => O_VID_Blue,
		hsync => O_VID_HSync,
		vsync => O_VID_VSync,
		TEXT_A => ram_adB,
		TEXT_D => ram_doB,
    	FONT_A => rom_adB,
    	FONT_D => rom_doB,
    	ocrx => crx_oreg,
    	ocry => cry_oreg,
    	octl => ctl_oreg
	);

	uut_mem_text : mem_text port map (
		clka => I_MEM_Clk, -- Vid Clk
		dina => ram_diA,
		addra => ram_adA,
    	wea   => ram_weA,
    	douta => ram_doA,
    	clkb  => I_VID_Clk,
    	dinb  => ram_diB,
    	addrb => ram_adB,
    	web   => ram_weB,
    	doutb => ram_doB
	);

	uut_mem_font : mem_font port map (
		clka => I_VID_Clk,
		dina => X"00",
		addra => rom_adB,
		wea => "0",
		douta => rom_doB
	);


	uut_uart : uart port map (
		I_Clk => UClk,
		TX => TX,
		RX => RX,
		I_Reset => '0',
		I_TX_Data => X"7C",
		I_TX_Enable => '0',
		O_TX_Ready => tx_ready,
		I_RX_Cont => rx_cont,
		O_RX_Data => rx_data,
		O_RX_Sig => rx_ready,
		O_RX_FrameError => rx_error
	);

	mem_proc : process(I_MEM_Clk)
	begin
		if I_MEM_Addr(15 downto 12) = X"F" then
			ram_adA <= I_MEM_Addr(11 downto 0);
			ram_weA <= we;
			ram_diA <= I_MEM_Data;
			O_MEM_Data <= ram_doA;
			rx_cont <= '0';
			blk_weA <= "0";
		elsif I_MEM_Addr(15 downto 0) = X"ED00" then
			-- Cursor X pos addr ED00
			crx_oreg <= I_MEM_Data;
			O_MEM_Data <= X"00";
			rx_cont <= '0';
			blk_weA <= "0";
			ram_weA <= "0";
		elsif I_MEM_Addr(15 downto 0) = X"ED01" then
			-- Cursor Y pos addr ED01
			cry_oreg <= I_MEM_Data;
			O_MEM_Data <= X"00";
			rx_cont <= '0';
			blk_weA <= "0";
			ram_weA <= "0";
		elsif I_MEM_Addr(15 downto 0) = X"EF00" then
			O_MEM_Data <= rx_data;
			rx_cont <= '1';
			blk_weA <= "0";
			ram_weA <= "0";
		else
			blk_adA <= I_MEM_Addr;
			blk_weA <= we;
			blk_diA <= I_MEM_Data;
			O_MEM_Data <= blk_doA;
			rx_cont <= '0';
			ram_weA <= "0";
		end if;
	end process;

	ram_weB <= "0";
	ram_diB <= (others => '0');
	
	-- crx_oreg    <= std_logic_vector(TO_UNSIGNED(0, 8));
	-- cry_oreg    <= std_logic_vector(TO_UNSIGNED(39, 8));
	ctl_oreg    <= "11110010";
	crx_oreg_ce <= '1';
	cry_oreg_ce <= '1';
	ctl_oreg_ce <= '1';

	-- This process is only for the READ command
	rdy_proc : process(I_MEM_Clk)
	begin
		if rising_edge(I_MEM_Clk) then
			last_addr <= I_MEM_Addr;
			if I_MEM_Addr(15 downto 0) = X"EF00" then
				O_MEM_Ready <= rx_ready;
			elsif last_addr = I_MEM_Addr then
				O_MEM_Ready <= '0';
			else
				O_MEM_Ready <= '1';
			end if;
		end if;
	end process;

	O_LED <= rx_ready & rx_error & rx_data(5 downto 0);
end behav_memory_control;
