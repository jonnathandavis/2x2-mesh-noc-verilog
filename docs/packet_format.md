# Packet Format for 2x2 Mesh NoC

Each packet/flit is 8 bits wide.

## Packet Structure

| Bits  | Field       | Description |
|------|-------------|-------------|
| [7:6] | Destination ID | Router where packet should reach |
| [5:4] | Source ID | Router where packet started |
| [3:0] | Payload | 4-bit data |

## Router ID Mapping

| Router | ID | Coordinates |
|--------|----|-------------|
| R0 | 00 | x=0, y=0 |
| R1 | 01 | x=1, y=0 |
| R2 | 10 | x=0, y=1 |
| R3 | 11 | x=1, y=1 |

## Mesh Layout

```text
R0 ---- R1
|       |
R2 ---- R3