-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/OBUF_HSTL_I_DCI.vhd,v 1.1 2008/06/19 16:59:25 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Output Buffer with HSTL_I_DCI I/O Standard
-- /___/   /\     Filename : OBUF_HSTL_I_DCI.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:10 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL OBUF_HSTL_I_DCI -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity OBUF_HSTL_I_DCI is
  port(
    O : out std_ulogic;

    I : in std_ulogic
    );
end OBUF_HSTL_I_DCI;

architecture OBUF_HSTL_I_DCI_V of OBUF_HSTL_I_DCI is
begin
  O <= TO_X01(I);
end OBUF_HSTL_I_DCI_V;
