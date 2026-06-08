`timescale 1ns/1ps

module mesh_2x2_tb;

    logic clk;
    logic rst;

    logic [1:0] source_router_id;
    logic [1:0] dest_router_id;
    logic [3:0] payload;
    logic       packet_valid;

    logic [7:0] received_packet;
    logic       received_valid;
    logic [1:0] final_router_id;

    logic [1:0] path_0;
    logic [1:0] path_1;
    logic [1:0] path_2;
    logic [1:0] hop_count;

    mesh_2x2 dut (
        .clk(clk),
        .rst(rst),

        .source_router_id(source_router_id),
        .dest_router_id(dest_router_id),
        .payload(payload),
        .packet_valid(packet_valid),

        .received_packet(received_packet),
        .received_valid(received_valid),
        .final_router_id(final_router_id),

        .path_0(path_0),
        .path_1(path_1),
        .path_2(path_2),
        .hop_count(hop_count)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("mesh_2x2_path.vcd");
        $dumpvars(0, mesh_2x2_tb);

        clk = 0;
        rst = 1;
        source_router_id = 2'b00;
        dest_router_id = 2'b00;
        payload = 4'h0;
        packet_valid = 1'b0;

        #20;
        rst = 0;

        $display("Starting 2x2 Mesh NoC Path Verification...");
        $display("-------------------------------------------");

        send_and_check(2'b00, 2'b01, 4'hA, "R0 to R1");
        send_and_check(2'b00, 2'b10, 4'hB, "R0 to R2");
        send_and_check(2'b00, 2'b11, 4'hC, "R0 to R3");
        send_and_check(2'b11, 2'b00, 4'hD, "R3 to R0");
        send_and_check(2'b10, 2'b01, 4'hE, "R2 to R1");
        send_and_check(2'b01, 2'b10, 4'hF, "R1 to R2");
        send_and_check(2'b11, 2'b11, 4'h5, "R3 to R3");

        $display("-------------------------------------------");
        $display("2x2 Mesh NoC Path Verification Completed.");

        #20;
        $finish;
    end

    task send_and_check(
        input [1:0] src,
        input [1:0] dest,
        input [3:0] data,
        input string test_name
    );
        logic [7:0] expected_packet;
        integer timeout;
        logic found;

        begin
            expected_packet = {dest, src, data};
            timeout = 0;
            found = 1'b0;

            @(negedge clk);
            source_router_id = src;
            dest_router_id = dest;
            payload = data;
            packet_valid = 1'b1;

            @(negedge clk);
            packet_valid = 1'b0;

            while (timeout < 10 && !found) begin
                @(posedge clk);
                #1;

                if (received_valid) begin
                    found = 1'b1;

                    if (received_packet == expected_packet && final_router_id == dest) begin
                        print_pass(test_name, received_packet);
                    end else begin
                        $display("FAIL: %s | Expected Packet = %b | Got Packet = %b | Expected Router = R%0d | Got Router = R%0d",
                                 test_name, expected_packet, received_packet, dest, final_router_id);
                    end
                end

                timeout = timeout + 1;
            end

            if (!found) begin
                $display("FAIL: %s | No received packet detected", test_name);
            end

            #10;
        end
    endtask

    task print_pass(
        input string test_name,
        input [7:0] packet
    );
        begin
            if (hop_count == 0) begin
                $display("PASS: %s | Path = R%0d | Packet = %b",
                         test_name, path_0, packet);
            end
            else if (hop_count == 1) begin
                $display("PASS: %s | Path = R%0d -> R%0d | Packet = %b",
                         test_name, path_0, path_1, packet);
            end
            else begin
                $display("PASS: %s | Path = R%0d -> R%0d -> R%0d | Packet = %b",
                         test_name, path_0, path_1, path_2, packet);
            end
        end
    endtask

endmodule