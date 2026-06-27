# Waveform Explanation

## FIFO Waveform

The FIFO waveform verifies correct write and read operation. During write cycles, `wr_en` is asserted and input data values such as 11, 22, 33, and 44 are stored. During read cycles, `rd_en` is asserted and the same values appear at `data_out` in the same order, confirming First-In First-Out behavior. The `full` and `empty` signals indicate buffer status correctly.

## XY Router Waveform

The XY router waveform shows routing decisions based on `current_router_id` and `dest_router_id`. The `route_direction` output changes according to the destination. For example, packets from R0 to R1 are routed EAST, packets from R0 to R2 are routed SOUTH, and packets from R3 to R0 are routed WEST first.

## Round-Robin Arbiter Waveform

The arbiter waveform verifies fair request handling. The `req` signal represents input port requests and the `grant` signal shows the selected port. For multiple active requests, the grant rotates among requesting ports, demonstrating round-robin arbitration.

## FIFO-Buffered Router Waveform

The router waveform shows packets entering through the local input port, being buffered, and then forwarded to the correct output port. The output valid signals such as `east_out_valid`, `south_out_valid`, `west_out_valid`, `north_out_valid`, and `local_out_valid` confirm destination-based packet forwarding.

## 2x2 Mesh NoC Waveform

The mesh waveform verifies packet transfer between four routers. The signals `source_router_id`, `dest_router_id`, `received_packet`, and `final_router_id` confirm successful delivery. The path tracking signals `path_0`, `path_1`, and `path_2` show the route followed by the packet, validating deterministic XY routing in the 2x2 mesh topology.