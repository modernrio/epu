--------------------------------------------------------------------------------
-- Beschreibung: RAM-Testmodul
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.VCOMPONENTS.all;

library work;
use work.epu_pack.all;

entity ram_block is
	port(
		-- Eingänge
		I_Clk         : in std_logic;						-- Takteingang
		I_En          : in std_logic;						-- Freigabe
		I_We          : in std_logic;						-- Schreibfreigabe
		I_Data        : in std_logic_vector(7 downto 0);	-- Dateneingang
		I_Addr        : in std_logic_vector(15 downto 0);	-- Adresswahl

		-- Ausgänge
		O_Ready		  : out std_logic;						-- Bereitschaft
		O_Data        : out std_logic_vector(7 downto 0);	-- Datenausgang
		O_LED        : buffer std_logic_vector(7 downto 0)		-- LEDs
	);
end ram_block;

architecture behav_ram_block of ram_block is
	-- Port A Data: 32-bit (each) output: Port A data
	signal DOA		: std_logic_vector(31 downto 0) := (others => '0');       -- 32-bit output: A port data output
	signal DOPA		: std_logic_vector(3 downto 0);          -- 4-bit output: A port parity output
	-- Port A Address/Control Signals: 14-bit (each) input: Port A address and control signals
	signal ADDRA	: std_logic_vector(13 downto 0);    -- 14-bit input: A port address input
	signal CLKA		: std_logic:= '1';                       -- 1-bit input: A port clock input
	signal ENA		: std_logic:= '1';                         -- 1-bit input: A port enable input
	signal REGCEA	: std_logic:= '0';                      -- 1-bit input: A port register clock enable input
	signal RSTA		: std_logic:= '0';                            -- 1-bit input: A port register set/reset input
	signal WEA		: std_logic_vector(3 downto 0) := "0000";        -- 4-bit input: Port A byte-wide write enable input
	-- Port A Data: 32-bit (each) input: Port A data
	signal DIA		: std_logic_vector(31 downto 0);       -- 32-bit input: A port data input
	signal DIPA		: std_logic_vector(3 downto 0);      -- 4-bit input: A port parity input
	
	  -- Port B Data: 32-bit (each) output: Port B data
	signal DOB		: std_logic_vector(31 downto 0);       -- 32-bit output: B port data output
	signal DOPB		: std_logic_vector(3 downto 0);          -- 4-bit output: B port parity output
	-- Port B Address/Control Signals: 14-bit (each) input: Port B address and control signals
	signal ADDRB	: std_logic_vector(13 downto 0);    -- 14-bit input: B port address input
	signal CLKB		: std_logic:= '1';                       -- 1-bit input: B port clock input
	signal ENB		: std_logic:= '1';                         -- 1-bit input: B port enable input
	signal REGCEB	: std_logic:= '0';                      -- 1-bit input: B port register clock enable input
	signal RSTB		: std_logic:= '0';                            -- 1-bit input: B port register set/reset input
	signal WEB		: std_logic_vector(3 downto 0) := "0000";        -- 4-bit input: Port B byte-wide write enable input
	-- Port B Data: 32-bit (each) input: Port B data
	signal DIB		: std_logic_vector(31 downto 0);       -- 32-bit input: B port data input
	signal DIPB		: std_logic_vector(3 downto 0);      -- 4-bit input: B port parity input

	signal count	: integer := 0;
	signal S_LED	: std_logic_vector(7 downto 0) := (others => '0');
	signal w_done	: std_logic := '0';
begin
	-- RAMB16BWER: 16k-bit Data and 2k-bit Parity Configurable Synchronous Dual Port Block RAM with Optional Output Registers
	--             Spartan-6
	-- Xilinx HDL Language Template, version 14.7

   RAMB16BWER_inst : RAMB16BWER
   generic map (
		-- DATA_WIDTH_A/DATA_WIDTH_B: 0, 1, 2, 4, 9, 18, or 36
		DATA_WIDTH_A => 9,
		DATA_WIDTH_B => 9,
		-- DOA_REG/DOB_REG: Optional output register (0 or 1)
		DOA_REG => 0,
		DOB_REG => 0,
		-- EN_RSTRAM_A/EN_RSTRAM_B: Enable/disable RST
		EN_RSTRAM_A => TRUE,
		EN_RSTRAM_B => TRUE,
		-- INITP_00 to INITP_07: Initial memory contents.
		INITP_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INITP_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INITP_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
      	-- INIT_00 to INIT_3F: Initial memory contents.
		INIT_00 => X"00503B004002535500403B001002535000103B003002534500303B0000203B00",
		INIT_01 => X"00903B008002532E00803B007002533000703B006002537600603B0050025320",
		INIT_02 => X"0000000000000000000000000000000500007700A002530A00A03B0090025331",
		INIT_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_0F => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_10 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_11 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_12 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_13 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_14 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_15 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_16 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_17 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_18 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_19 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_1A => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_1B => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_1C => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_1D => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_1E => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_1F => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_20 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_21 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_22 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_23 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_24 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_25 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_26 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_27 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_28 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_29 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_2A => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_2B => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_2C => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_2D => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_2E => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_2F => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_30 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_33 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
		INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
		-- INIT_A/INIT_B: Initial values on output port
		INIT_A => X"000000000",
		INIT_B => X"000000000",
		-- INIT_FILE: Optional file used to specify initial RAM contents
		INIT_FILE => "NONE",
		-- RSTTYPE: "SYNC" or "ASYNC" 
		RSTTYPE => "SYNC",
		-- RST_PRIORITY_A/RST_PRIORITY_B: "CE" or "SR" 
		RST_PRIORITY_A => "CE",
		RST_PRIORITY_B => "CE",
		-- SIM_COLLISION_CHECK: Collision check enable "ALL", "WARNING_ONLY", "GENERATE_X_ONLY" or "NONE" 
		SIM_COLLISION_CHECK => "ALL",
		-- SIM_DEVICE: Must be set to "SPARTAN6" for proper simulation behavior
		SIM_DEVICE => "SPARTAN6",
		-- SRVAL_A/SRVAL_B: Set/Reset value for RAM output
		SRVAL_A => X"000000000",
		SRVAL_B => X"000000000",
		-- WRITE_MODE_A/WRITE_MODE_B: "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE" 
		WRITE_MODE_A => "NO_CHANGE",
		WRITE_MODE_B => "NO_CHANGE" 
   )
   port map (
		-- Port A Data: 32-bit (each) output: Port A data
		DOA => DOA,       -- 32-bit output: A port data output
		DOPA => DOPA,     -- 4-bit output: A port parity output
		-- Port B Data: 32-bit (each) output: Port B data
		DOB => DOB,       -- 32-bit output: B port data output
		DOPB => DOPB,     -- 4-bit output: B port parity output
		-- Port A Address/Control Signals: 14-bit (each) input: Port A address and control signals
		ADDRA => ADDRA,   -- 14-bit input: A port address input
		CLKA => CLKA,     -- 1-bit input: A port clock input
		ENA => ENA,       -- 1-bit input: A port enable input
		REGCEA => REGCEA, -- 1-bit input: A port register clock enable input
		RSTA => RSTA,     -- 1-bit input: A port register set/reset input
		WEA => WEA,       -- 4-bit input: Port A byte-wide write enable input
		-- Port A Data: 32-bit (each) input: Port A data
		DIA => DIA,       -- 32-bit input: A port data input
		DIPA => DIPA,     -- 4-bit input: A port parity input
		-- Port B Address/Control Signals: 14-bit (each) input: Port B address and control signals
		ADDRB => ADDRB,   -- 14-bit input: B port address input
		CLKB => CLKB,     -- 1-bit input: B port clock input
		ENB => ENB,       -- 1-bit input: B port enable input
		REGCEB => REGCEB, -- 1-bit input: B port register clock enable input
		RSTB => RSTB,     -- 1-bit input: B port register set/reset input
		WEB => WEB,       -- 4-bit input: Port B byte-wide write enable input
		-- Port B Data: 32-bit (each) input: Port B data
		DIB => DIB,       -- 32-bit input: B port data input
		DIPB => DIPB      -- 4-bit input: B port parity input
   );
	
	CLKA <= I_Clk;
	CLKB <= I_Clk;
	
	ENA <= I_En;
	
	-- Port B used for LEDs
	ENB <= '1';
	WEB <= "0000";
	ADDRB <= "000" & X"00" & "000";
	
	ADDRA <= I_Addr(10 downto 0) & "000";

	ram_proc : process(I_Clk, I_En)
	begin
		if rising_edge(I_Clk) and I_En = '1' then
			if (I_We = '1') then
				if w_done = '0' then
					WEA <= "0001";
					DIA <= X"000000" & I_Data;
					w_done <= '1';
				else
					WEA <= "0000";
					w_done <= '0';
				end if;
			else
				WEA <= "0000";
				O_Data <= DOA(7 downto 0);
			end if;

			-- Ready after two cycles
			if count = 0 then
				count <= 1;
				O_Ready <= '0';
			elsif count = 1 then
				count <= 0;
				O_Ready <= '1';
			end if;
			S_LED <= O_LED;
		end if;
	end process;

	led_proc : process(I_En)
	begin
		if rising_edge(I_En) then
			O_LED <= DOB(7 downto 0);
		end if;
	end process;
end behav_ram_block;
