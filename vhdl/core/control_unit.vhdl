----------------------------------------------------------------------------------------------------
-- Beschreibung: Steuert den Status der Pipeline
----------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.epu_pack.all;

entity control_unit is
	port(
		-- Eingänge
		I_Clk   : in std_logic;							-- Takteingang
		I_Reset : in std_logic;							-- Rücksetzsignal
		I_Done  : in std_logic;							-- Befehl vollständig dekodiert?
		I_AluOp : in std_logic_vector(7 downto 0);		-- ALU-Operation

		-- Ausgänge
		O_State : out std_logic_vector(6 downto 0)		-- Pipelinestatus
	);
end control_unit;

architecture behav_control_unit of control_unit is
	signal S_State : std_logic_vector(6 downto 0) := "0000001";
begin
	process(I_Clk)
	begin
		if rising_edge(I_Clk) then
			if I_Reset = '1' then
				S_State <= "0000000";
			else
				case S_State is
					when "0000001" => -- Fetch
						S_State <= "0000010";
					when "0000010" => -- Decode
						if I_Done = '1' then
							S_State <= "0000100"; 
						else
							S_State <= "0000001";
						end if;
					when "0000100" => -- Read
						S_State <= "0001000";
					when "0001000" => -- Execute
						if I_AluOp(IFO_REL_OPCODE_BEGIN downto IFO_REL_OPCODE_END) = OPCODE_READ
						or I_AluOp(IFO_REL_OPCODE_BEGIN downto IFO_REL_OPCODE_END) = OPCODE_WRITE then
							S_State <= "0010000"; -- Memory Write
						elsif I_AluOp(IFO_REL_OPCODE_BEGIN downto IFO_REL_OPCODE_END) = OPCODE_PUSH
						or I_AluOp(IFO_REL_OPCODE_BEGIN downto IFO_REL_OPCODE_END) = OPCODE_POP
						or I_AluOp(IFO_REL_OPCODE_BEGIN downto IFO_REL_OPCODE_END) = OPCODE_CALL
						or I_AluOp(IFO_REL_OPCODE_BEGIN downto IFO_REL_OPCODE_END) = OPCODE_RET
						or I_AluOp(IFO_REL_OPCODE_BEGIN downto IFO_REL_OPCODE_END) = OPCODE_INT then
							S_State <= "0100000"; -- Stack Read/Write
						else
							S_State <= "1000000"; -- Reg Write
						end if;
					when "0010000" => -- Memory Write
						S_State <= "1000000";
					when "0100000" => -- Stack Read/Write
						S_State <= "1000000";
					when "1000000" => -- Reg Write
						S_State <= "0000001";
					when others =>
						S_State <= "0000001";
				end case;
			end if;
		end if;
	end process;

	O_State <= S_State;
end behav_control_unit;
