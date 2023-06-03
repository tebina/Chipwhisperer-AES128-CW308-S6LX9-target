# Entity: SubBytes 

- **File**: SubBytes.vhd
## Diagram

![Diagram](SubBytes.svg "Diagram")
## Ports

| Port name    | Direction | Type                            | Description |
| ------------ | --------- | ------------------------------- | ----------- |
| SubBytes_IN  | in        | STD_LOGIC_VECTOR (127 downto 0) |             |
| SubBytes_OUT | out       | STD_LOGIC_VECTOR (127 downto 0) |             |
| SYS_CLK      | in        | STD_LOGIC                       |             |
| RST          | in        | STD_LOGIC                       |             |
## Signals

| Name          | Type                            | Description |
| ------------- | ------------------------------- | ----------- |
| SUB_BYTES_BUF | STD_LOGIC_VECTOR (127 downto 0) |             |
## Processes
- SBOX_BYTE_SUBSTITUTION: ( SYS_CLK )
