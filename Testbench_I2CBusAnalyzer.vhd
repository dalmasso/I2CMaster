------------------------------------------------------------------------
-- Engineer:    Dalmasso Loic
-- Create Date: 30/10/2024
-- Module Name: I2CBusAnalyzer
-- Description:
--      I2C Bus Analyzer in charge to detect:
--          - Bus Busy Detection
--          - Bus Arbitration
--          - Clock Stretching
--
-- WARNING: /!\ Require Pull-Up on SCL and SDA pins /!\
--
-- Ports
--		Input 	-	i_clock: Module Input Clock
--		Input 	-	i_scl_master: I2C Serial Clock from Master
--		Input 	-	i_scl_line: I2C Serial Clock bus line
--		Input 	-	i_sda_master: I2C Serial Data from Master
--		Input 	-	i_sda_line: I2C Serial Data bus line
--		Output 	-	o_bus_busy: Bus Busy detection ('0': Not Busy, '1': Busy)
--		Output 	-	o_bus_arbitration: Bus Arbitration detection ('0': Lost Arbitration, '1': Win Arbitration)
--		Output 	-	o_scl_stretching: Serial Clock Stretching detection ('0': Not Stretching, '1': Stretching)
------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Testbench_I2CBusAnalyzer is
end Testbench_I2CBusAnalyzer;

architecture Behavioral of Testbench_I2CBusAnalyzer is

component I2CBusAnalyzer is

PORT(
	i_clock: IN STD_LOGIC;
    i_scl_master: IN STD_LOGIC;
	i_scl_line: IN STD_LOGIC;
	i_sda_master: IN STD_LOGIC;
    i_sda_line: IN STD_LOGIC;
    o_bus_busy: OUT STD_LOGIC;
    o_bus_arbitration: OUT STD_LOGIC;
	o_scl_stretching: OUT STD_LOGIC
);

END component;

signal clock_12M: STD_LOGIC := '0';
signal scl_master: STD_LOGIC := '0';
signal scl_line: STD_LOGIC := '0';
signal sda_master: STD_LOGIC := '0';
signal sda_line: STD_LOGIC := '0';
signal bus_busy: STD_LOGIC;
signal bus_arbitration: STD_LOGIC;
signal scl_stretching: STD_LOGIC;

begin

-- Clock 12 MHz
clock_12M <= not(clock_12M) after 41.6667 ns;

-- SCL
scl_master <= '1', '0' after 625 ns, '1' after 725 ns, '0' after 1200 ns;
scl_line <= '1','0' after 625 ns, '1' after 725 ns, '0' after 950 ns, '1' after 1050 ns, '0' after 1150 ns, '1' after 1200 ns, '0' after 1350 ns;

-- SDA
sda_master <= '1','0' after 500 ns, '1' after 800 ns, '0' after 950 ns, '1' after 1050 ns, '0' after 1150 ns;
sda_line <= '1','0' after 500 ns, '1' after 800 ns, '1' after 950 ns, '0' after 1050 ns, '0' after 1150 ns;

uut: I2CBusAnalyzer port map(
	i_clock => clock_12M,
	i_scl_master => scl_master,
	i_scl_line=> scl_line,
	i_sda_master => sda_master,
	i_sda_line => sda_line,
	o_bus_busy => bus_busy,
	o_bus_arbitration => bus_arbitration,
	o_scl_stretching => scl_stretching);

end Behavioral;
