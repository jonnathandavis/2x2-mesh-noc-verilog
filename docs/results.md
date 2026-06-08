# Simulation Results

## FIFO Verification

The FIFO module was verified by writing and reading multiple 8-bit data values. The output sequence matched the input sequence, confirming First-In First-Out operation. Full and empty conditions were also tested successfully.

## XY Routing Verification

The XY routing module was tested for all major source-destination combinations in the 2x2 mesh. The router first moves packets in the X direction and then in the Y direction. All routing decisions matched the expected output directions.

## Round-Robin Arbiter Verification

The round-robin arbiter was tested using single and multiple request scenarios. The grant output rotated among requesting ports, confirming fair request handling.

## 5-Port Router Verification

The router was verified using packets with different destination IDs. The router extracted the destination field from the packet and forwarded it to the correct output port using XY routing.

## FIFO-Buffered Router Verification

The router was upgraded with FIFO input buffering. Packets were first stored in the FIFO and then routed to the correct output port. Simulation confirmed correct packet forwarding after FIFO read timing was handled.

## 2x2 Mesh NoC Verification

The 2x2 mesh was verified using multiple source-destination packet transfers. The simulation confirmed successful packet delivery and correct XY routing paths.

Example verified paths:

| Source | Destination | Verified Path |
|--------|-------------|---------------|
| R0 | R1 | R0 → R1 |
| R0 | R2 | R0 → R2 |
| R0 | R3 | R0 → R1 → R3 |
| R3 | R0 | R3 → R2 → R0 |
| R2 | R1 | R2 → R3 → R1 |
| R1 | R2 | R1 → R0 → R2 |
| R3 | R3 | R3 |

## Conclusion

The simulation results confirm that the proposed 2x2 Mesh NoC architecture performs correct packet routing using the deterministic XY routing algorithm. The automated Verilog testbenches successfully validate FIFO operation, routing correctness, arbitration behavior, router forwarding, and mesh-level packet delivery.