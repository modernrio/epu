-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/fuji/VITAL/BUFHCE.vhd,v 1.1 2009/11/12 20:50:51 yanx Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  H Clock Buffer with Active High Enable
-- /___/   /\     Filename : BUFHCE.vhd
-- \   \  /  \    Timestamp :
--  \___\/\___\
--
-- Revision:
--    04/08/08 - Initial version.
--    10/19/08 - Recoding to same as BUFGCE according to hardware.
--    11/13/09 - Add CE_TYPE attribute.
-- End Revision

----- CELL BUFHCE -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
library UNISIM;
use UNISIM.VCOMPONENTS.all;

entity BUFHCE is
  generic(
    CE_TYPE : string := "SYNC";
    INIT_OUT : integer := 0
    );
  port(
    O : out std_ulogic;

    CE : in std_ulogic;
    I : in std_ulogic
    );
end BUFHCE;

architecture BUFHCE_V of BUFHCE is
                                                                                  
    signal NCE : STD_ULOGIC := 'X';
    signal GND : STD_ULOGIC := '0';
    signal Z1 : STD_ULOGIC := '1';
    signal O_out1 : STD_ULOGIC := '0';
    signal O_out2 : STD_ULOGIC := '0';
    signal CE_TYPE_BINARY : std_ulogic;
    signal INIT_OUT_BINARY : std_ulogic;
                                                                                  
begin
    INIPROC : process
    begin
    -- case CE_TYPE is
      if((CE_TYPE = "SYNC") or (CE_TYPE = "sync")) then
        CE_TYPE_BINARY <= '0';
      elsif((CE_TYPE = "ASYNC") or (CE_TYPE= "async")) then
        CE_TYPE_BINARY <= '1';
      else
        assert FALSE report "Error : CE_TYPE = is not SYNC, ASYNC." severity error;
      end if;
    -- end case;
    case INIT_OUT is
      when  0   =>  INIT_OUT_BINARY <= '0';
      when  1   =>  INIT_OUT_BINARY <= '1';
      when others  =>  assert FALSE report "Error : INIT_OUT is not in range 0 .. 1." severity error;
    end case;
    wait;
    end process INIPROC;

    B1 : BUFGMUX
        port map (
        I0 => I,
        I1 => GND,
        O =>O_out1,
        s =>NCE);

    B2 : BUFGMUX_1
        port map (
        I0 => I,
        I1 => Z1,
        O =>O_out2,
        s =>NCE);

    I1 : INV
        port map (
        I => CE,
        O => NCE);

    O <= O_out2 when INIT_OUT = 1 else O_out1;

end BUFHCE_V;

