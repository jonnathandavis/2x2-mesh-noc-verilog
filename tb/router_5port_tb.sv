`timescale 1ns/1ps

module router_5port_tb;

    logic clk;
    logic rst;

    logic [1:0] current_router_id;

    logic [7:0] local_in_data;
    logic       local_in_valid;

    logic [7:0] local_out_data;
    logic       local_out_valid;

    logic [7:0] north_out_data;
    logic       north_out_valid;

    logic [7:0] south_out_data;
    logic       south_out_valid;

    logic [7:0] east_out_data;
    logic       east_out_valid;

    logic [7:0] west_out_data;
    logic       west_out_valid;

    router_5port dut (
        .clk(clk),
        .rst(rst),
        .current_router_id(current_router_id),

        .local_in_data(local_in_data),
        .local_in_valid(local_in_valid),

        .local_out_data(local_out_data),
        .local_out_valid(local_out_valid),

        .north_out_data(north_out_data),
        .north_out_valid(north_out_valid),

        .south_out_data(south_out_data),
        .south_out_valid(south_out_valid),

        .east_out_data(east_out_data),
        .east_out_valid(east_out_valid),

        .west_out_data(west_out_data),
        .west_out_valid(west_out_valid)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("router_5port.vcd");
        $dumpvars(0, router_5port_tb);

        clk = 0;
        rst = 1;
        current_router_id = 2'b00;
        local_in_data = 8'h00;
        local_in_valid = 1'b0;

        #20;
        rst = 0;

        $display("Starting 5-Port Router Test...");
        $display("--------------------------------");

        // Router R0 tests
        current_router_id = 2'b00;

        send_and_check(8'b01_00_1010, "EAST",  "R0 to R1, expected EAST");
        send_and_check(8'b10_00_1011, "SOUTH", "R0 to R2, expected SOUTH");
        send_and_check(8'b11_00_1100, "EAST",  "R0 to R3, expected EAST first");
        send_and_check(8'b00_00_1111, "LOCAL", "R0 to R0, expected LOCAL");

        // Router R3 tests
        current_router_id = 2'b11;

        send_and_check(8'b00_11_0001, "WEST",  "R3 to R0, expected WEST first");
        send_and_check(8'b01_11_0010, "NORTH", "R3 to R1, expected NORTH");
        send_and_check(8'b10_11_0011, "WEST",  "R3 to R2, expected WEST");
        send_and_check(8'b11_11_0100, "LOCAL", "R3 to R3, expected LOCAL");

        $display("--------------------------------");
        $display("5-Port Router Test Completed.");

        #20;
        $finish;
    end

    task send_and_check(
        input [7:0] packet,
        input string expected_port,
        input string test_name
    );
        begin
            // Apply input before active clock edge
            @(negedge clk);
            local_in_data = packet;
            local_in_valid = 1'b1;

            // Router captures packet here
            @(posedge clk);
            #1;

            $display("TEST: %s | Packet = %b", test_name, packet);

            if (expected_port == "LOCAL") begin
                check_output(expected_port, local_out_valid, local_out_data, packet);
            end
            else if (expected_port == "NORTH") begin
                check_output(expected_port, north_out_valid, north_out_data, packet);
            end
            else if (expected_port == "SOUTH") begin
                check_output(expected_port, south_out_valid, south_out_data, packet);
            end
            else if (expected_port == "EAST") begin
                check_output(expected_port, east_out_valid, east_out_data, packet);
            end
            else if (expected_port == "WEST") begin
                check_output(expected_port, west_out_valid, west_out_data, packet);
            end

            // Deassert input valid
            @(negedge clk);
            local_in_valid = 1'b0;
            local_in_data = 8'h00;

            @(posedge clk);
            #1;
        end
    endtask

    task check_output(
        input string expected_port,
        input logic actual_valid,
        input logic [7:0] actual_data,
        input logic [7:0] expected_data
    );
        begin
            if (actual_valid && actual_data == expected_data) begin
                $display("PASS: Output Port = %s | Data = %b", expected_port, actual_data);
            end else begin
                $display("FAIL: Expected Port = %s | Expected Data = %b | Actual Valid = %b | Actual Data = %b",
                         expected_port, expected_data, actual_valid, actual_data);
            end
        end
    endtask

endmodule