-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/IBUF_LVCMOS33.vhd,v 1.1 2008/06/19 16:59:23 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Input Buffer with LVCMOS33 I/O Standard
-- /___/   /\     Filename : IBUF_LVCMOS33.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:29 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL IBUF_LVCMOS33 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity IBUF_LVCMOS33 is
  port(
    O : out std_ulogic;

    I : in std_ulogic
    );
end IBUF_LVCMOS33;

architecture IBUF_LVCMOS33_V of IBUF_LVCMOS33 is
begin
  O <= TO_X01(I);
end IBUF_LVCMOS33_V;
