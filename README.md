# I2C Master

This module implements I2C master protocol, supporting:
- Write/Read modes (with Repeated Start)
- Configurable Register Address/Data length
- Start Byte
- Clock Stretching Detection
- Multimaster (arbitration)

I2C Master module is composed of 2 sub-modules:
- I2C Bus Controller: in charge of applying SCL & SDA signals on the I2C bus, according to operations
- I2C Bus Analyzer: in charge to detect busy status, arbitration and clock stretching

**/!\ Require Pull-Up on SCL and SDA pins /!\ **

<img width="1163" alt="Overview" src="https://github.com/user-attachments/assets/d52974eb-6c6a-4930-bab6-96c7f1ac8038">

## Architecture Overview

<img width="1295" alt="Architecture" src="https://github.com/user-attachments/assets/d48ea24a-88f4-4504-b399-dad2f8457861">

## Usage

The Ready signal indicates no operation is on going and the I2C Master is waiting Write/Read operation.
At any time, if an error occurs, the Error signal is asserted and the I2C Master returns in IDLE state.
Reset input can be trigger at any time to reset the I2C Master to the IDLE state.

1. Set all necessary inputs
    - Mode: Write ('0') or Read ('1')
    - Slave Addresss
    - Register Address Length in byte & Register Address
    - Register Value Length in byte & Register Value (Write Mode only)
    - Read Register Value Length in byte (Read Mode only)
    - (Optionally) a START BYTE can be sent at the begining of the transmission to wake-up slave(s).
2. Asserts Start input. The Ready signal is de-asserted and the Busy signal is asserted.
3. I2C Master re-asserts the Ready signal at the end of transmission (Master is ready for a new transmission)
4. In Read mode only, the read value is available when its validity signal is asserted

## I2C Master Pin Description

### Generics

| Name | Description |
| ---- | ----------- |
| input_clock | Module Input Clock Frequency |
| i2c_clock | I2C Serial Clock Frequency |
| max_bus_length | Maximum Length of the I2C Bus Address/Data in bits |

### Ports

| Name | Type | Description |
| ---- | ---- | ----------- |
| i_clock | Input | Module Input Clock |
| i_reset | Input | Reset ('0': No Reset, '1': Reset) |
| i_start | Input | Start I2C Transmission and process Next Phase ('0': No Start, '1': Start) |
| i_start_byte_enable | Input | Enable I2C Start Byte Transmission Phase ('0': Disable, '1': Enable) |
| i_mode | Input | Read or Write Mode ('0': Write, '1': Read) |
| i_slave_addr | Input | Slave Address (7 bits) |
| i_reg_addr_byte | Input | Register Address in bytes |
| i_reg_addr | Input | Register Address to Read/Write |
| i_reg_value_byte | Input | Register Value to Write in bytes |
| i_reg_value | Input | Register Value to Write |
| i_read_value_byte | Input | Register Value to Read in bytes |
| o_read_value_valid | Output | Validity of the Read Register Value ('0': Not Valid, '1': Valid) |
| o_read_value | Output | Read Register Value |
| o_ready | Output | Ready State of I2C Master ('0': Not Ready, '1': Ready) |
| o_error | Output | Error State of I2C Master ('0': No Error, '1': Error) |
| o_busy | Output | Busy State of I2C Master ('0': Not Busy, '1': Busy) |
| io_scl | In/Out | I2C Serial Clock ('0'-'Z'(as '1') values, working with Pull-Up) |
| io_sda | In/Out | I2C Serial Data ('0'-'Z'(as '1') values, working with Pull-Up) |

### I2C Bus Controller Pin Description

#### Generics

| Name | Description |
| ---- | ----------- |
| input_clock | Module Input Clock Frequency |
| i2c_clock | I2C Serial Clock Frequency |

#### Ports

| Name | Type | Description |
| ---- | ---- | ----------- |
| i_clock | Input | Module Input Clock |
| i_reset | Input | Reset ('0': No Reset, '1': Reset) |
| i_write | Input | Write Cycle Trigger ('0': No Write, '1': Write) |
| i_read | Input | Read Cycle Trigger ('0': No Read, '1': Read) |
| i_data | Input | Data to write on the bus (8 bits) |
| o_ready | Output | Ready State of I2C Bus ('0': Not Ready, '1': Ready) |
| o_error | Output | Error State of I2C Bus ('0': No Error, '1': Error) |
| o_busy | Output | Busy State of I2C Bus ('0': Not Busy, '1': Busy) |
| o_read_value_valid | Output | I2C Slave Register Value is valid ('0': Not Valid, '1': Valid) |
| o_read_value | Output | I2C Slave Register Value |
| io_scl | In/Out | I2C Serial Clock ('0'-'Z'(as '1') values, working with Pull-Up) |
| io_sda | In/Out | I2C Serial Data ('0'-'Z'(as '1') values, working with Pull-Up) |

### I2C Bus Analyzer Pin Description

#### Ports

| Name | Type | Description |
| ---- | ---- | ----------- |
| i_clock | Input | Module Input Clock |
| i_scl_master | Input | I2C Serial Clock from Master |
| i_scl_line | Input | I2C Serial Clock bus line |
| i_sda_master | Input | I2C Serial Data from Master |
| i_sda_line | Input | I2C Serial Data bus line |
| o_bus_busy | Output | Bus Busy detection ('0': Not Busy, '1': Busy) |
| o_bus_arbitration | Output | Bus Arbitration detection ('0': Lost Arbitration, '1': Win Arbitration) |
| o_scl_stretching | Output | Serial Clock Stretching detection ('0': Not Stretching, '1': Stretching) |
