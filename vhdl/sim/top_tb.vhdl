--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:17:57 09/19/2016
-- Design Name:   
-- Module Name:   /home/whoami/Projects/EPU/vhdl/sim/top_tb.vhdl
-- Project Name:  EPU
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: top
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY top_tb IS
END top_tb;
 
ARCHITECTURE behavior OF top_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT top
    PORT(
         MainClk : IN  std_logic;
         RST : IN  std_logic;
         SEGEn : OUT  std_logic_vector(2 downto 0);
         LED : OUT  std_logic_vector(7 downto 0);
         SEG : OUT  std_logic_vector(7 downto 0);
         TXE : IN  std_logic;
         RD : OUT  std_logic;
         WR : OUT  std_logic;
         RXF : IN  std_logic;
         In_Data : INOUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal MainClk : std_logic := '0';
   signal RST : std_logic := '0';
   signal TXE : std_logic := '0';
   signal RXF : std_logic := '0';

	--BiDirs
   signal In_Data : std_logic_vector(7 downto 0);

 	--Outputs
   signal SEGEn : std_logic_vector(2 downto 0);
   signal LED : std_logic_vector(7 downto 0);
   signal SEG : std_logic_vector(7 downto 0);
   signal RD : std_logic;
   signal WR : std_logic;

   -- Clock period definitions
   constant MainClk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: top PORT MAP (
          MainClk => MainClk,
          RST => RST,
          SEGEn => SEGEn,
          LED => LED,
          SEG => SEG,
          TXE => TXE,
          RD => RD,
          WR => WR,
          RXF => RXF,
          In_Data => In_Data
        );

   -- Clock process definitions
   MainClk_process :process
   begin
		MainClk <= '0';
		wait for MainClk_period/2;
		MainClk <= '1';
		wait for MainClk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for MainClk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
