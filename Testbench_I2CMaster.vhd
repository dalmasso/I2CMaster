------------------------------------------------------------------------
-- Engineer:    Dalmasso Loic
-- Create Date: 30/10/2024
-- Module Name: I2CMaster
-- Description:
--      I2C Master allowing Write/Read operations on slave devices
--		Features:
--			- Configurable Register Address/Data length
--			- Start Byte
--			- Clock Stretching Detection
--			- Multimaster (arbitration)
--
-- WARNING: /!\ Require Pull-Up on SCL and SDA pins /!\
--
-- Usage:
--      The Ready signal indicates no operation is on going and the I2C Master is waiting Write/Read operation.
--		At any time, if an error occurs, the Error signal is asserted and the I2C Master returns in IDLE state.
--      Reset input can be trigger at any time to reset the I2C Master to the IDLE state.
--		1. Set all necessary inputs
--			* Mode: Write ('0') or Read ('1')
--			* Slave Addresss
--			* Register Address Length in byte & Register Address
--			* Register Value Length in byte & Register Value (Write Mode only)
--			* Read Register Value Length in byte (Read Mode only)
--			* (Optionally) a START BYTE can be sent at the begining of the transmission to wake-up slave(s).
--      2. Asserts Start input. The Ready signal is de-asserted and the Busy signal is asserted.
--		3. I2C Master re-asserts the Ready signal at the end of transmission (Master is ready for a new transmission)
--		4. In Read mode only, the read value is available when its validity signal is asserted
--
-- Generics
--		input_clock: Module Input Clock Frequency
--		i2c_clock: I2C Serial Clock Frequency
--		max_bus_length: Maximum Length of the I2C Bus Address/Data in bits
--
-- Ports
--		Input 	-	i_clock: Module Input Clock
--		Input 	-	i_reset: Reset ('0': No Reset, '1': Reset)
--		Input 	-	i_start: Start I2C Transmission and process Next Phase ('0': No Start, '1': Start)
--		Input 	-	i_start_byte_enable: Enable I2C Start Byte Transmission Phase ('0': Disable, '1': Enable)
--		Input 	-	i_mode: Read or Write Mode ('0': Write, '1': Read)
--		Input 	-	i_slave_addr: Slave Address (7 bits)
--		Input 	-	i_reg_addr_byte: Register Address in bytes
--		Input 	-	i_reg_addr: Register Address to Read/Write
--		Input 	-	i_reg_value_byte: Register Value to Write in bytes
--		Input 	-	i_reg_value: Register Value to Write
--		Input 	-	i_read_value_byte: Register Value to Read in bytes
--		Output 	-	o_read_value_valid: Validity of the Read Register Value ('0': Not Valid, '1': Valid)
--		Output 	-	o_read_value: Read Register Value
--		Output 	-	o_ready: Ready State of I2C Master ('0': Not Ready, '1': Ready)
--		Output 	-	o_error: Error State of I2C Master ('0': No Error, '1': Error)
--		Output 	-	o_busy: Busy State of I2C Master ('0': Not Busy, '1': Busy)
--		In/Out 	-	io_scl: I2C Serial Clock ('0'-'Z'(as '1') values, working with Pull-Up)
--		In/Out 	-	io_sda: I2C Serial Data ('0'-'Z'(as '1') values, working with Pull-Up)
------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Testbench_I2CMaster is
end Testbench_I2CMaster;

architecture Behavioral of Testbench_I2CMaster is

COMPONENT I2CMaster is

GENERIC(
	input_clock: INTEGER := 12_000_000;
	i2c_clock: INTEGER := 100_000;
	max_bus_length: INTEGER := 8
);

PORT(
	i_clock: IN STD_LOGIC;
    i_reset: IN STD_LOGIC;
	i_start: IN STD_LOGIC;
	i_start_byte_enable: IN STD_LOGIC;
	i_mode: IN STD_LOGIC;
	i_slave_addr: IN STD_LOGIC_VECTOR(6 downto 0);
	i_reg_addr_byte: IN INTEGER range 0 to max_bus_length/8;
	i_reg_addr: IN STD_LOGIC_VECTOR(max_bus_length-1 downto 0);
	i_reg_value_byte: IN INTEGER range 0 to max_bus_length/8;
	i_reg_value: IN STD_LOGIC_VECTOR(max_bus_length-1 downto 0);
	i_read_value_byte: IN INTEGER range 0 to max_bus_length/8;
	o_read_value_valid: OUT STD_LOGIC;
	o_read_value: OUT STD_LOGIC_VECTOR(max_bus_length-1 downto 0);
	o_ready: OUT STD_LOGIC;
	o_error: OUT STD_LOGIC;
	o_busy: OUT STD_LOGIC;
	io_scl: INOUT STD_LOGIC;
	io_sda: INOUT STD_LOGIC
);

END COMPONENT;

signal clock_12M: STD_LOGIC := '0';
signal reset: STD_LOGIC := '0';
signal start: STD_LOGIC := '0';
signal start_byte_enable: STD_LOGIC := '0';
signal mode: STD_LOGIC := '0';

signal ready: STD_LOGIC := '0';
signal error: STD_LOGIC := '0';
signal busy: STD_LOGIC := '0';
signal read_value_valid: STD_LOGIC := '0';
signal read_value: STD_LOGIC_VECTOR(15 downto 0):= (others => '0');
signal scl: STD_LOGIC := '1';
signal sda: STD_LOGIC := '1';

begin

-- Clock 12 MHz
clock_12M <= not(clock_12M) after 41.6667 ns;
reset <= '1', '0' after 50 ns;

-- Start
start <= '0', '1' after 110.125881 us, '0' after 259 us, '1' after 600 us, '0' after 620 us;

-- Start Byte
start_byte_enable <= '1', '0' after 130 us;

-- Mode
mode <= '0', '1' after 590 us;

-- SCL
scl <= '1' when ready = '1' else 'Z';

-- SDA
sda <= 	'Z',
        -- First Cycle (Write)
        '0' after 210.126681 us,
        'Z' after 220.126761 us,
        '0' after 320.127561 us,
        'Z' after 330.127641 us,
        '0' after 410.128281 us,
        'Z' after 420.128361 us,
        '0' after 500.129001 us,
        'Z' after 510.129081 us,
        
        -- Second Cycle (Read)
        '0' after 590.129721 us,
        'Z' after 600.129801 us,
        '0' after 710.130681 us,
        'Z' after 720.130761 us,
        '0' after 800.131401 us,
        'Z' after 810.131481 us,
        '0' after 890.132121 us,
        'Z' after 900.132201 us,
        '0' after 1000.133001 us,
        -- Read 1
    	'1' after 1010.133081 us,
		'1' after 1020.133161 us,
		'0' after 1030.133241 us,
		'0' after 1040.133321 us,
		'1' after 1050.133401 us,
		'1' after 1060.133481 us,
		'1' after 1070.133561 us,
		'0' after 1080.133641 us,
		'Z' after 1090.133721 us,
		-- Read 2
    	'0' after 1100.133801 us,
		'0' after 1110.133881 us,
		'1' after 1120.133961 us,
		'1' after 1130.134041 us,
		'0' after 1140.134121 us,
		'0' after 1150.134201 us,
		'1' after 1160.134281 us,
		'1' after 1170.134361 us,
		'Z' after 1180.134441 us;

uut: I2CMaster
    generic map(
        input_clock => 12_000_000,
        i2c_clock => 100_000,
        max_bus_length => 16)
        
    port map(
        i_clock => clock_12M,
        i_reset => reset,
        i_start => start,
        i_start_byte_enable => start_byte_enable,
        i_mode => mode,
        i_slave_addr => "1001101",
        i_reg_addr_byte => 2,
        i_reg_addr => "1111000001010101",
        i_reg_value_byte => 1,
        i_reg_value => "1110001100000000",
        i_read_value_byte => 2,
        o_read_value_valid => read_value_valid,
        o_read_value => read_value,
        o_ready => ready,
        o_error => error,
        o_busy => busy,
        io_scl => scl,
        io_sda => sda);

end Behavioral;
