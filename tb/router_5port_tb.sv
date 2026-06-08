`timescale 1ns/1ps

module router_5port_tb;

    logic clk;
    logic rst;

    logic [1:0] current_router_id;

    logic [7:0] local_in_data;
    logic       local_in_valid;

    logic       local_fifo_full;
    logic       local_fifo_empty;

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

        .local_fifo_full(local_fifo_full),
        .local_fifo_empty(local_fifo_empty),

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
        $dumpfile("router_5port_fifo.vcd");
        $dumpvars(0, router_5port_tb);

        clk = 0;
        rst = 1;
        current_router_id = 2'b00;
        local_in_data = 8'h00;
        local_in_valid = 1'b0;

        #20;
        rst = 0;

        $display("Starting FIFO-Based 5-Port Router Test...");
        $display("------------------------------------------");

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

        $display("------------------------------------------");
        $display("FIFO-Based 5-Port Router Test Completed.");

        #20;
        $finish;
    end

    task send_and_check(
        input [7:0] packet,
        input string expected_port,
        input string test_name
    );
        begin
            @(negedge clk);
            local_in_data = packet;
            local_in_valid = 1'b1;

            @(negedge clk);
            local_in_valid = 1'b0;
            local_in_data = 8'h00;

            wait_for_output(expected_port, packet, test_name);
        end
    endtask

    task wait_for_output(
        input string expected_port,
        input [7:0] expected_data,
        input string test_name
    );
        integer timeout;
        logic found;
        begin
            timeout = 0;
            found = 1'b0;

            while (timeout < 10 && !found) begin
                @(posedge clk);
                #1;

                if (expected_port == "LOCAL" && local_out_valid) begin
                    found = 1'b1;
                    check_output(expected_port, local_out_data, expected_data, test_name);
                end
                else if (expected_port == "NORTH" && north_out_valid) begin
                    found = 1'b1;
                    check_output(expected_port, north_out_data, expected_data, test_name);
                end
                else if (expected_port == "SOUTH" && south_out_valid) begin
                    found = 1'b1;
                    check_output(expected_port, south_out_data, expected_data, test_name);
                end
                else if (expected_port == "EAST" && east_out_valid) begin
                    found = 1'b1;
                    check_output(expected_port, east_out_data, expected_data, test_name);
                end
                else if (expected_port == "WEST" && west_out_valid) begin
                    found = 1'b1;
                    check_output(expected_port, west_out_data, expected_data, test_name);
                end

                timeout = timeout + 1;
            end

            if (!found) begin
                $display("FAIL: %s | No output detected on expected port %s",
                         test_name, expected_port);
            end
        end
    endtask

    task check_output(
        input string expected_port,
        input [7:0] actual_data,
        input [7:0] expected_data,
        input string test_name
    );
        begin
            if (actual_data == expected_data) begin
                $display("PASS: %s | Output Port = %s | Data = %b",
                         test_name, expected_port, actual_data);
            end else begin
                $display("FAIL: %s | Expected Port = %s | Expected Data = %b | Actual Data = %b",
                         test_name, expected_port, expected_data, actual_data);
            end
        end
    endtask

endmodule