--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:13:01 10/24/2016
-- Design Name:   
-- Module Name:   /home/whoami/Projects/epu/vhdl/sim/top_tb.vhd
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
		SW	 : IN std_logic_vector(6 downto 0);
		TX : OUT  std_logic;
		RX : IN  std_logic;
		hs 				  : out std_logic;
		vs			   	  : out std_logic;
		red				  : out std_logic_vector(2 downto 0);
		green		   	  : out std_logic_vector(2 downto 0);
		blue		   	  : out std_logic_vector(1 downto 0)
	);
    END COMPONENT;
    

   --Inputs
   signal MainClk : std_logic := '0';
   signal RST : std_logic := '0';
   signal RX : std_logic := '0';
   signal SW : std_logic_vector(6 downto 0) := "0000000";

 	--Outputs
   signal SEGEn : std_logic_vector(2 downto 0);
   signal LED : std_logic_vector(7 downto 0);
   signal SEG : std_logic_vector(7 downto 0);
   signal TX : std_logic;
   signal hs, vs : std_logic;
   signal red, green : std_logic_vector(2 downto 0);
   signal blue : std_logic_vector(1 downto 0);

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
		  SW => SW,
          TX => TX,
          RX => RX,
		  hs => hs,
		  vs => vs,
		  red => red,
		  green => green,
		  blue => blue
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
