------------------------------------------------------------------------
-- Engineer:    Dalmasso Loic
-- Create Date: 30/10/2024
-- Module Name: I2CBusController
-- Description:
--      I2C Bus Controller in charge of applying SCL & SDA signals on the I2C bus, according to operations.
--
-- WARNING: /!\ Require Pull-Up on SCL and SDA pins /!\
--
-- Usage:
--      The Ready signal indicates no operation is on going and the I2C Bus Controller is waiting Write/Read operation.
--		At any time, if an error occurs, the Error signal is asserted and the I2C Bus Controller returns in IDLE state.
--      Reset input can be trigger at any time to reset the I2C Bus Controller to the IDLE state.
--      Write mode:
--          1. Set i_data input with the data to write on the bus.
--          2. Set i_write input to '1' and i_read to '0'. The module will generate a start-then-write or single-write operation, 
--			   depending on the current state of the I2C Bus Controller. The o_busy signal indicates the I2C Bus Controller is
--			   performing the operation.
--          3. While the o_busy signal is asserted:
--              - If new write operation is required, set i_data input with the next data to write, and set i_write input to '1' (i_read to '0').
--              - If read operation is required, set i_read input to '1' and i_write to '0'. The module will generate Read operation.
--              - If Repeated Start operation is required, set i_write and i_read to '1'.
--				- If stop operation is required, set i_write and i_read inputs to '0'.
--      Read mode (always after Write Mode)
--          1. While the o_busy signal is asserted:
--              - If new read operation is required, set i_read input to '1' (i_write to '0').
--				- If Repeated Start operation is required, set i_write and i_read to '1'.
--              - If stop operation is required, set i_read and i_write inputs to '0'.
--          2. When the o_read_value_valid is asserted, the read data is available on the o_read_value output. The value MUST be processed
--			   BEFORE the next read operation.
--
-- Generics
--		input_clock: Module Input Clock Frequency
--		i2c_clock: I2C Serial Clock Frequency
-- Ports
--		Input 	-	i_clock: Module Input Clock
--		Input 	-	i_reset: Reset ('0': No Reset, '1': Reset)
--		Input 	-	i_write: Write Cycle Trigger ('0': No Write, '1': Write)
--		Input 	-	i_read: Read Cycle Trigger ('0': No Read, '1': Read)
--		Input 	-	i_data: Data to write on the bus (8 bits)
--		Output 	-	o_ready: Ready State of I2C Bus ('0': Not Ready, '1': Ready)
--		Output 	-	o_error: Error State of I2C Bus ('0': No Error, '1': Error)
--		Output 	-	o_busy: Busy State of I2C Bus ('0': Not Busy, '1': Busy)
--		Output 	-	o_read_value_valid: I2C Slave Register Value is valid ('0': Not Valid, '1': Valid)
--		Output 	-	o_read_value: I2C Slave Register Value
--		In/Out 	-	io_scl: I2C Serial Clock ('0'-'Z'(as '1') values, working with Pull-Up)
--		In/Out 	-	io_sda: I2C Serial Data ('0'-'Z'(as '1') values, working with Pull-Up)
------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Testbench_I2CBusController is
end Testbench_I2CBusController;

architecture Behavioral of Testbench_I2CBusController is

COMPONENT I2CBusController is

GENERIC(
	input_clock: INTEGER := 12_000_000;
	i2c_clock: INTEGER := 100_000
);

PORT(
	i_clock: IN STD_LOGIC;
	i_reset: IN STD_LOGIC;
	i_write: IN STD_LOGIC;
	i_read: IN STD_LOGIC;
	i_data: IN STD_LOGIC_VECTOR(7 downto 0);
	o_ready: OUT STD_LOGIC;
	o_error: OUT STD_LOGIC;
	o_busy: OUT STD_LOGIC;
	o_read_value_valid: OUT STD_LOGIC;
	o_read_value: OUT STD_LOGIC_VECTOR(7 downto 0);
	io_scl: INOUT STD_LOGIC;
	io_sda: INOUT STD_LOGIC
);

END COMPONENT;

signal clock_12M: STD_LOGIC := '0';
signal reset: STD_LOGIC := '0';
signal new_write: STD_LOGIC := '0';
signal new_read: STD_LOGIC := '0';
signal data: STD_LOGIC_VECTOR(7 downto 0):= (others => '0');

signal ready: STD_LOGIC := '0';
signal error: STD_LOGIC := '0';
signal busy: STD_LOGIC := '0';
signal read_value_valid: STD_LOGIC := '0';
signal read_value: STD_LOGIC_VECTOR(7 downto 0):= (others => '0');
signal scl: STD_LOGIC := '1';
signal sda: STD_LOGIC := '1';

begin

-- Clock 12 MHz
clock_12M <= not(clock_12M) after 41.6667 ns;
reset <= '1', '0' after 50 ns;

-- Read / Write
new_write <= '0', '1' after 110.125881 us, '0' after 259 us, '1' after 400 us, '0' after 420 us, '1' after 510 us, '0' after 600 us;
new_read <= '1' after 400 us, '0' after 600 us;

-- Data Write
data <= "01000010", "01101101" after 181 us;

-- SCL
scl <= '1' when ready = '1' else 'Z';

-- SDA
sda <= 	'Z',
        '0' after 210.126681 us,
        'Z' after 220.126761 us,
        '0' after 300.127401 us,
        'Z' after 310.127481 us,
        '0' after 490.128921 us,
        
        -- Read
    	'1' after 500.129001 us,
		'1' after 510.129081 us,
		'0' after 520.129161 us,
		'0' after 530.129241 us,
		'1' after 540.129321 us,
		'1' after 550.129401 us,
		'1' after 560.129481 us,
		'0' after 570.129561 us,
		'Z' after 580.129641 us;

uut: I2CBusController port map(
	i_clock => clock_12M,
	i_reset => reset,
	i_write => new_write,
	i_read => new_read,
	i_data => data,
	o_ready => ready,
	o_error => error,
	o_busy => busy,
	o_read_value_valid => read_value_valid,
	o_read_value => read_value,
	io_scl => scl,
	io_sda => sda);

end Behavioral;
