module round_robin_arbiter #(
    parameter NUM_PORTS = 5
)(
    input  logic clk,
    input  logic rst,

    input  logic [NUM_PORTS-1:0] req,
    output logic [NUM_PORTS-1:0] grant
);

    logic [$clog2(NUM_PORTS)-1:0] priority_ptr;
    logic [$clog2(NUM_PORTS)-1:0] grant_index;
    logic grant_valid;

    integer i;
    integer check_index;

    always_comb begin
        grant = '0;
        grant_valid = 1'b0;
        grant_index = priority_ptr;

        for (i = 0; i < NUM_PORTS; i = i + 1) begin
            check_index = priority_ptr + i;

            if (check_index >= NUM_PORTS)
                check_index = check_index - NUM_PORTS;

            if (!grant_valid && req[check_index]) begin
                grant[check_index] = 1'b1;
                grant_index = check_index[$clog2(NUM_PORTS)-1:0];
                grant_valid = 1'b1;
            end
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            priority_ptr <= 0;
        end else begin
            if (grant_valid) begin
                if (grant_index == NUM_PORTS - 1)
                    priority_ptr <= 0;
                else
                    priority_ptr <= grant_index + 1;
            end
        end
    end

endmodule