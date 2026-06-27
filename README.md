# 2×2 Mesh Network-on-Chip with XY Routing and Automated Verification Using Verilog HDL

## Project Overview

This project implements a simplified **2×2 Mesh Network-on-Chip (NoC)** architecture using Verilog/SystemVerilog HDL. The design focuses on packet-based communication between four routers using deterministic **XY routing**. The project also includes automated testbenches to verify FIFO operation, routing correctness, arbitration, router forwarding, and mesh-level packet transfer.

The project is designed to be simple, modular, and suitable for academic implementation and verification.

---

## Abstract Summary

Network-on-Chip (NoC) is an efficient communication architecture used in modern System-on-Chip (SoC) designs. This project presents a 2×2 Mesh NoC with four routers connected in a mesh topology. Packets are routed using deterministic XY routing, where the packet first moves along the X direction and then along the Y direction. Verilog testbenches are used to generate test cases, monitor outputs, and verify correct packet delivery.

---

## Mesh Topology

The 2×2 mesh contains four routers:

```text
R0 ---- R1
|       |
R2 ---- R3
```

## Router ID Mapping

| Router | ID | Coordinates |
| ------ | -- | ----------- |
| R0     | 00 | x=0, y=0    |
| R1     | 01 | x=1, y=0    |
| R2     | 10 | x=0, y=1    |
| R3     | 11 | x=1, y=1    |

---

## Packet Format

Each packet is 8 bits wide.

| Bits  | Field          | Description        |
| ----- | -------------- | ------------------ |
| [7:6] | Destination ID | Destination router |
| [5:4] | Source ID      | Source router      |
| [3:0] | Payload        | 4-bit data         |

Example:

```text
Packet = 8'b11_00_1010
Destination = R3
Source = R0
Payload = A
```

This packet travels from R0 to R3.

---

## XY Routing Algorithm

The XY routing algorithm works as follows:

1. Compare the current router position with the destination router position.
2. First route along the X direction.
3. Then route along the Y direction.
4. If the current router is the destination, send the packet to the LOCAL output.

Example:

```text
R0 to R3

R0 = (0,0)
R3 = (1,1)

Path:
R0 -> R1 -> R3
```

---

## Direction Encoding

| Direction | Code |
| --------- | ---- |
| LOCAL     | 000  |
| EAST      | 001  |
| WEST      | 010  |
| SOUTH     | 011  |
| NORTH     | 100  |

---

## Project Structure

```text
2x2-mesh-noc-verilog/
│
├── src/
│   ├── fifo.sv
│   ├── xy_router.sv
│   ├── round_robin_arbiter.sv
│   ├── router_5port.sv
│   └── mesh_2x2.sv
│
├── tb/
│   ├── fifo_tb.sv
│   ├── xy_router_tb.sv
│   ├── round_robin_arbiter_tb.sv
│   ├── router_5port_tb.sv
│   └── mesh_2x2_tb.sv
│
├── docs/
│   ├── packet_format.md
│   ├── test_cases.md
│   ├── results.md
│   ├── waveform_explanation.md
│   └── report_notes.md
│
├── screenshots/
│   ├── fifo_waveform.png
│   ├── xy_router_waveform.png
│   ├── arbiter_waveform.png
│   ├── router_5port_fifo_waveform.png
│   └── mesh_2x2_path_waveform.png
│
├── sim/
├── .gitignore
└── README.md
```

---

## Modules Implemented

### 1. FIFO Buffer

File:

```text
src/fifo.sv
```

The FIFO module stores input data temporarily. It supports write enable, read enable, full flag, empty flag, data input, and data output.

Verified using:

```text
tb/fifo_tb.sv
```

---

### 2. XY Router

File:

```text
src/xy_router.sv
```

The XY router decides the next direction of packet movement based on the current router ID and destination router ID.

Verified using:

```text
tb/xy_router_tb.sv
```

---

### 3. Round-Robin Arbiter

File:

```text
src/round_robin_arbiter.sv
```

The round-robin arbiter handles multiple requests fairly by rotating priority among requesting ports.

Verified using:

```text
tb/round_robin_arbiter_tb.sv
```

---

### 4. FIFO-Buffered 5-Port Router

File:

```text
src/router_5port.sv
```

The router receives a packet, stores it in FIFO, reads the destination field, applies XY routing, and sends the packet to the correct output direction.

Verified using:

```text
tb/router_5port_tb.sv
```

---

### 5. 2×2 Mesh NoC

File:

```text
src/mesh_2x2.sv
```

The mesh-level model verifies packet movement between routers R0, R1, R2, and R3 using XY routing.

Verified using:

```text
tb/mesh_2x2_tb.sv
```

---

## Simulation Commands

Run from the project root folder.

### FIFO Test

```powershell
iverilog -g2012 -o sim/fifo_tb.vvp src/fifo.sv tb/fifo_tb.sv
vvp sim/fifo_tb.vvp
```

### XY Router Test

```powershell
iverilog -g2012 -o sim/xy_router_tb.vvp src/xy_router.sv tb/xy_router_tb.sv
vvp sim/xy_router_tb.vvp
```

### Round-Robin Arbiter Test

```powershell
iverilog -g2012 -o sim/arbiter_tb.vvp src/round_robin_arbiter.sv tb/round_robin_arbiter_tb.sv
vvp sim/arbiter_tb.vvp
```

### FIFO-Buffered Router Test

```powershell
iverilog -g2012 -o sim/router_5port_fifo_tb.vvp src/fifo.sv src/xy_router.sv src/router_5port.sv tb/router_5port_tb.sv
vvp sim/router_5port_fifo_tb.vvp
```

### 2×2 Mesh Path Verification

```powershell
iverilog -g2012 -o sim/mesh_2x2_path_tb.vvp src/xy_router.sv src/mesh_2x2.sv tb/mesh_2x2_tb.sv
vvp sim/mesh_2x2_path_tb.vvp
```

---

## Verified Test Cases

| Test No. | Source | Destination | Payload | Expected Path | Status |
| -------- | ------ | ----------- | ------- | ------------- | ------ |
| 1        | R0     | R1          | A       | R0 → R1       | PASS   |
| 2        | R0     | R2          | B       | R0 → R2       | PASS   |
| 3        | R0     | R3          | C       | R0 → R1 → R3  | PASS   |
| 4        | R3     | R0          | D       | R3 → R2 → R0  | PASS   |
| 5        | R2     | R1          | E       | R2 → R3 → R1  | PASS   |
| 6        | R1     | R2          | F       | R1 → R0 → R2  | PASS   |
| 7        | R3     | R3          | 5       | R3            | PASS   |

---

## Tools Used

* Verilog/SystemVerilog HDL
* Icarus Verilog
* GTKWave
* Git and GitHub
* VS Code
* Windows PowerShell

---

## Waveform Results

Waveform screenshots are available in the `screenshots/` folder.

Important waveform files:

```text
fifo_waveform.png
xy_router_waveform.png
arbiter_waveform.png
router_5port_fifo_waveform.png
mesh_2x2_path_waveform.png
```

---

## Current Project Status

Completed:

* FIFO design and verification
* XY routing design and verification
* Round-robin arbiter design and verification
* FIFO-buffered 5-port router verification
* 2×2 mesh path verification
* Waveform screenshots
* Test case documentation
* Simulation results documentation

---

## Implementation Note

The current implementation verifies the 2×2 Mesh NoC architecture using modular RTL blocks and a mesh-level packet transfer model. The FIFO, XY routing logic, round-robin arbiter, FIFO-buffered router, and mesh-level packet path verification are implemented and tested separately using automated Verilog testbenches.

In the present version, the mesh-level model validates packet movement between four router nodes using deterministic XY routing. A fully structural implementation, where four complete 5-port router modules are directly interconnected through North, South, East, and West ports with simultaneous packet traffic support, can be added as a future enhancement.

This approach keeps the design simple, modular, and suitable for academic simulation-based verification while still demonstrating the main concepts of NoC communication, destination-based routing, and automated verification.

---

## Future Scope

- Full structural interconnection of four 5-port routers
- Support for simultaneous packet transfers
- FIFO buffering on all five router input ports
- Integration of round-robin arbitration inside the full router
- FPGA synthesis and implementation
- Virtual channel support
- Larger 4×4 Mesh NoC
- Fault-tolerant routing
- Low-power NoC design

---


