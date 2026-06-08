`timescale 1ns/1ps

module xy_router_tb;

    logic [1:0] current_router_id;
    logic [1:0] dest_router_id;
    logic [2:0] route_direction;

    // Instantiate DUT
    xy_router dut (
        .current_router_id(current_router_id),
        .dest_router_id(dest_router_id),
        .route_direction(route_direction)
    );

    // Direction encoding
    localparam LOCAL = 3'b000;
    localparam EAST  = 3'b001;
    localparam WEST  = 3'b010;
    localparam SOUTH = 3'b011;
    localparam NORTH = 3'b100;

    initial begin
        $dumpfile("xy_router.vcd");
        $dumpvars(0, xy_router_tb);

        $display("Starting XY Routing Test...");
        $display("---------------------------");

        test_route(2'b00, 2'b01, EAST);   // R0 to R1
        test_route(2'b00, 2'b10, SOUTH);  // R0 to R2
        test_route(2'b00, 2'b11, EAST);   // R0 to R3, first move EAST

        test_route(2'b01, 2'b00, WEST);   // R1 to R0
        test_route(2'b01, 2'b11, SOUTH);  // R1 to R3

        test_route(2'b10, 2'b00, NORTH);  // R2 to R0
        test_route(2'b10, 2'b11, EAST);   // R2 to R3

        test_route(2'b11, 2'b01, NORTH);  // R3 to R1
        test_route(2'b11, 2'b10, WEST);   // R3 to R2
        test_route(2'b11, 2'b00, WEST);   // R3 to R0, first move WEST

        test_route(2'b00, 2'b00, LOCAL);  // R0 to R0
        test_route(2'b01, 2'b01, LOCAL);  // R1 to R1
        test_route(2'b10, 2'b10, LOCAL);  // R2 to R2
        test_route(2'b11, 2'b11, LOCAL);  // R3 to R3

        $display("---------------------------");
        $display("XY Routing Test Completed.");

        #10;
        $finish;
    end

    task test_route(
        input [1:0] current_id,
        input [1:0] dest_id,
        input [2:0] expected_direction
    );
        begin
            current_router_id = current_id;
            dest_router_id = dest_id;

            #10;

            if (route_direction == expected_direction) begin
                $display("PASS: Current=R%0d Dest=R%0d Route=%s",
                         current_id, dest_id, direction_name(route_direction));
            end else begin
                $display("FAIL: Current=R%0d Dest=R%0d Expected=%s Got=%s",
                         current_id, dest_id,
                         direction_name(expected_direction),
                         direction_name(route_direction));
            end
        end
    endtask

    function string direction_name(input [2:0] direction);
        begin
            case (direction)
                LOCAL: direction_name = "LOCAL";
                EAST : direction_name = "EAST";
                WEST : direction_name = "WEST";
                SOUTH: direction_name = "SOUTH";
                NORTH: direction_name = "NORTH";
                default: direction_name = "UNKNOWN";
            endcase
        end
    endfunction

endmodule