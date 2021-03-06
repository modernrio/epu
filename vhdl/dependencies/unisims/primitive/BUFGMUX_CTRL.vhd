-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/rainier/VITAL/BUFGMUX_CTRL.vhd,v 1.1 2008/06/19 16:59:21 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Global Clock Mux Buffer
-- /___/   /\     Filename : BUFGMUX_CTRL.vhd
-- \   \  /  \    Timestamp : Fri Mar 26 08:17:58 PST 2004
--  \___\/\___\
--
-- Revision:
--    03/10/06 - Initial version.
-- end Revision

----- CELL BUFGMUX_CTRL -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;

library unisim;
use unisim.vpkg.all;
use unisim.vcomponents.all;

entity BUFGMUX_CTRL is

  port(
      O			: out std_ulogic;

      I0		: in std_ulogic;
      I1		: in std_ulogic;
      S			: in std_ulogic
    );

end BUFGMUX_CTRL;


architecture BUFGMUX_CTRL_V OF BUFGMUX_CTRL is


  signal SigPullUp		: std_ulogic := '1';
  signal SigPullDown		: std_ulogic := '0';
  signal NOT_S			: std_ulogic := 'X';

begin

  NOT_S <= NOT S;

----------------------------------------------------------------------
-----------    Instant BUFGCTRL  -------------------------------------
----------------------------------------------------------------------
  INST_BUFGCTRL : BUFGCTRL
  generic map (
      INIT_OUT => 0,
      PRESELECT_I0 => true,
      PRESELECT_I1 => false
     )
  port map (
      O		=> O,

      CE0	=> SigPullUp,
      CE1	=> SigPullUp,
      I0	=> I0,
      I1	=> I1,
      IGNORE0	=> SigPullDown,
      IGNORE1	=> SigPullDown,
      S0	=> NOT_S,
      S1	=> S
      );
end BUFGMUX_CTRL_V;
