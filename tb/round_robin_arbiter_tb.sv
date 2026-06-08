`timescale 1ns/1ps

module round_robin_arbiter_tb;

    logic clk;
    logic rst;
    logic [4:0] req;
    logic [4:0] grant;

    round_robin_arbiter #(
        .NUM_PORTS(5)
    ) dut (
        .clk(clk),
        .rst(rst),
        .req(req),
        .grant(grant)
    );

    // 10 ns clock period
    always #5 clk = ~clk;

    initial begin
        $dumpfile("round_robin_arbiter.vcd");
        $dumpvars(0, round_robin_arbiter_tb);

        clk = 0;
        rst = 1;
        req = 5'b00000;

        #12;
        rst = 0;

        $display("Starting Round-Robin Arbiter Test...");
        $display("------------------------------------");

        // Test 1: No request
        apply_request(5'b00000);

        // Test 2: Single request from LOCAL
        apply_request(5'b00001);

        // Test 3: Single request from EAST
        apply_request(5'b01000);

        // Test 4: Multiple requests: LOCAL, NORTH, SOUTH
        apply_request(5'b00111);
        apply_request(5'b00111);
        apply_request(5'b00111);
        apply_request(5'b00111);

        // Test 5: All ports requesting
        apply_request(5'b11111);
        apply_request(5'b11111);
        apply_request(5'b11111);
        apply_request(5'b11111);
        apply_request(5'b11111);

        // Test 6: No request again
        apply_request(5'b00000);

        $display("------------------------------------");
        $display("Round-Robin Arbiter Test Completed.");

        #20;
        $finish;
    end

    task apply_request(input [4:0] request_value);
        begin
            @(posedge clk);
            req = request_value;

            @(posedge clk);

            $display("REQ = %b | GRANT = %b | Granted Port = %s",
                     req, grant, port_name(grant));
        end
    endtask

    function string port_name(input [4:0] grant_value);
        begin
            case (grant_value)
                5'b00001: port_name = "LOCAL";
                5'b00010: port_name = "NORTH";
                5'b00100: port_name = "SOUTH";
                5'b01000: port_name = "EAST";
                5'b10000: port_name = "WEST";
                5'b00000: port_name = "NONE";
                default:  port_name = "INVALID";
            endcase
        end
    endfunction

endmodule