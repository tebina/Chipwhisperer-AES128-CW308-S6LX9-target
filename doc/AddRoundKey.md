# Entity: AddRoundKey 

- **File**: AddRoundKey.vhd
## Diagram

![Diagram](AddRoundKey.svg "Diagram")
## Ports

| Port name | Direction | Type                            | Description |
| --------- | --------- | ------------------------------- | ----------- |
| Data_IN   | in        | STD_LOGIC_VECTOR (127 downto 0) |             |
| Key_IN    | in        | STD_LOGIC_VECTOR (127 downto 0) |             |
| Data_OUT  | out       | STD_LOGIC_VECTOR (127 downto 0) |             |
| SYS_CLK   | in        | STD_LOGIC                       |             |
| RST       | in        | STD_LOGIC                       |             |
## Processes
- XOR_PARTIALKEY_WITH_PLAINTEXT: ( SYS_CLK )
