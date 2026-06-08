# Test Cases for 2x2 Mesh NoC

## Packet Format

Each packet is 8 bits wide:

| Bits | Field |
|------|-------|
| [7:6] | Destination Router ID |
| [5:4] | Source Router ID |
| [3:0] | Payload |

## Router ID Mapping

| Router | ID | Coordinates |
|--------|----|-------------|
| R0 | 00 | x=0, y=0 |
| R1 | 01 | x=1, y=0 |
| R2 | 10 | x=0, y=1 |
| R3 | 11 | x=1, y=1 |

## Direction Encoding

| Direction | Code |
|----------|------|
| LOCAL | 000 |
| EAST | 001 |
| WEST | 010 |
| SOUTH | 011 |
| NORTH | 100 |

## Mesh-Level Test Cases

| Test No. | Source | Destination | Payload | Expected Path | Verification Status |
|----------|--------|-------------|---------|---------------|---------------------|
| 1 | R0 | R1 | A | R0 → R1 | PASS |
| 2 | R0 | R2 | B | R0 → R2 | PASS |
| 3 | R0 | R3 | C | R0 → R1 → R3 | PASS |
| 4 | R3 | R0 | D | R3 → R2 → R0 | PASS |
| 5 | R2 | R1 | E | R2 → R3 → R1 | PASS |
| 6 | R1 | R2 | F | R1 → R0 → R2 | PASS |
| 7 | R3 | R3 | 5 | R3 | PASS |

## Verified Modules

| Module | Purpose | Status |
|--------|---------|--------|
| fifo.sv | Input buffering | Verified |
| xy_router.sv | XY routing decision | Verified |
| round_robin_arbiter.sv | Fair request handling | Verified |
| router_5port.sv | Router-level packet forwarding | Verified |
| mesh_2x2.sv | Mesh-level packet transfer | Verified |