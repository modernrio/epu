-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/RAM128X1S_1.vhd,v 1.1 2008/06/19 16:59:25 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Static Synchronous RAM 128-Deep by 1-Wide
-- /___/   /\     Filename : RAM128X1S_1.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:47 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL RAM128X1S_1 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VPKG.all;

entity RAM128X1S_1 is

  generic (
    INIT : bit_vector(127 downto 0) := X"00000000000000000000000000000000"
    );

  port (
    O : out std_ulogic;

    A0   : in std_ulogic;
    A1   : in std_ulogic;
    A2   : in std_ulogic;
    A3   : in std_ulogic;
    A4   : in std_ulogic;
    A5   : in std_ulogic;
    A6   : in std_ulogic;
    D    : in std_ulogic;
    WCLK : in std_ulogic;
    WE   : in std_ulogic
    );
end RAM128X1S_1;

architecture RAM128X1S_1_V of RAM128X1S_1 is
  signal MEM : std_logic_vector( 128 downto 0 ) := ('X' & To_StdLogicVector(INIT) );

begin
  VITALReadBehavior  : process(A0, A1, A2, A3, A4, A5, A6, MEM)
    Variable Index   : integer    := 128;
    variable Address : std_logic_vector( 6 downto 0);

  begin
    Address := (A6, A5, A4, A3, A2, A1, A0);
    Index   := SLV_TO_INT(SLV => Address);
    O <= MEM(Index);      
  end process VITALReadBehavior;

  VITALWriteBehavior : process(WCLK)
    Variable Index   : integer := 128;
    variable Address : std_logic_vector (6 downto 0);

  begin
    if (falling_edge(WCLK)) then
      if (WE = '1') then
        Address := (A6, A5, A4, A3, A2, A1, A0);
        Index   := SLV_TO_INT(SLV => Address);
        MEM(Index) <= D after 100 ps;
      end if;
    end if;
  end process VITALWriteBehavior;
end RAM128X1S_1_V;


