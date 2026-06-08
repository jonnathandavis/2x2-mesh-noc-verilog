# Rough Report Notes

## Project Title

2×2 Mesh Network-on-Chip with XY Routing and Automated Verification Using Verilog HDL

## Objective

To design and verify a 2×2 Mesh Network-on-Chip architecture using Verilog HDL. The project focuses on packet-based communication between four routers using deterministic XY routing and automated Verilog testbenches.

## Existing System

Traditional bus-based communication systems are simple but become inefficient when many processing elements communicate at the same time. They suffer from limited scalability, higher congestion, and reduced performance in complex System-on-Chip designs.

## Proposed System

The proposed system uses a 2×2 Mesh Network-on-Chip architecture. Four routers are connected in mesh topology. Packets are routed based on destination ID using XY routing. Verilog testbenches are used to automatically verify packet delivery and routing correctness.

## Main Modules

### FIFO

The FIFO module provides input buffering. It stores incoming packets temporarily and supports full and empty status signals.

### XY Router

The XY routing module decides the next direction for packet movement. It first routes packets along the X direction and then along the Y direction.

### Round-Robin Arbiter

The round-robin arbiter provides fair request handling when multiple ports request access. It was designed and verified as a router control mechanism.

### 5-Port Router

The 5-port router performs destination-based packet forwarding. It supports Local, North, South, East, and West output directions.

### 2×2 Mesh NoC

The mesh connects four router nodes: R0, R1, R2, and R3. The mesh-level testbench verifies packet transfer between different source and destination routers.

## Packet Format

Each packet is 8 bits wide.

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

## Verified Test Cases

| Source | Destination | Expected Path | Status |
|--------|-------------|---------------|--------|
| R0 | R1 | R0 → R1 | PASS |
| R0 | R2 | R0 → R2 | PASS |
| R0 | R3 | R0 → R1 → R3 | PASS |
| R3 | R0 | R3 → R2 → R0 | PASS |
| R2 | R1 | R2 → R3 → R1 | PASS |
| R1 | R2 | R1 → R0 → R2 | PASS |
| R3 | R3 | R3 | PASS |

## Tools Used

- Verilog/SystemVerilog HDL
- Icarus Verilog
- GTKWave
- Git/GitHub
- VS Code

## Results

All major modules were verified using automated testbenches. The simulation results confirmed FIFO operation, XY routing correctness, arbiter functionality, router forwarding, and mesh-level packet delivery.

## Conclusion

The project successfully demonstrates a 2×2 Mesh NoC architecture using Verilog HDL. Deterministic XY routing enables correct packet movement between router nodes. Automated verification confirms reliable operation of the designed modules.

## Future Scope

- FPGA synthesis and implementation
- Full hardware router-to-router interconnection
- Multiple simultaneous packet transfers
- Virtual channel support
- Larger 4×4 mesh NoC
- Fault-tolerant routing