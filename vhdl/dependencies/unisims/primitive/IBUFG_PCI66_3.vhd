-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/IBUFG_PCI66_3.vhd,v 1.1 2008/06/19 16:59:23 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Input Clock Buffer with PCI66_3 I/O Standard
-- /___/   /\     Filename : IBUFG_PCI66_3.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:39 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL IBUFG_PCI66_3 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity IBUFG_PCI66_3 is
  port(
    O : out std_ulogic;

    I : in std_ulogic
    );
end IBUFG_PCI66_3;

architecture IBUFG_PCI66_3_V of IBUFG_PCI66_3 is
begin
  O <= TO_X01(I);
end IBUFG_PCI66_3_V;


