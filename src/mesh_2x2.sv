module mesh_2x2 (
    input  logic clk,
    input  logic rst,

    input  logic [1:0] source_router_id,
    input  logic [1:0] dest_router_id,
    input  logic [3:0] payload,
    input  logic       packet_valid,

    output logic [7:0] received_packet,
    output logic       received_valid,
    output logic [1:0] final_router_id
);

    // Router IDs
    localparam R0 = 2'b00;
    localparam R1 = 2'b01;
    localparam R2 = 2'b10;
    localparam R3 = 2'b11;

    // Direction encoding from xy_router
    localparam LOCAL = 3'b000;
    localparam EAST  = 3'b001;
    localparam WEST  = 3'b010;
    localparam SOUTH = 3'b011;
    localparam NORTH = 3'b100;

    logic [7:0] packet;
    logic [1:0] current_router;
    logic [2:0] route_direction;

    assign packet = {dest_router_id, source_router_id, payload};

    xy_router routing_unit (
        .current_router_id(current_router),
        .dest_router_id(dest_router_id),
        .route_direction(route_direction)
    );

    typedef enum logic [1:0] {
        IDLE,
        ROUTE,
        DONE
    } state_t;

    state_t state;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            current_router <= R0;
            received_packet <= 8'h00;
            received_valid <= 1'b0;
            final_router_id <= R0;
        end else begin
            received_valid <= 1'b0;

            case (state)

                IDLE: begin
                    if (packet_valid) begin
                        current_router <= source_router_id;
                        state <= ROUTE;
                    end
                end

                ROUTE: begin
                    if (route_direction == LOCAL) begin
                        received_packet <= packet;
                        received_valid <= 1'b1;
                        final_router_id <= current_router;
                        state <= DONE;
                    end else begin
                        case (route_direction)

                            EAST: begin
                                if (current_router == R0)
                                    current_router <= R1;
                                else if (current_router == R2)
                                    current_router <= R3;
                            end

                            WEST: begin
                                if (current_router == R1)
                                    current_router <= R0;
                                else if (current_router == R3)
                                    current_router <= R2;
                            end

                            SOUTH: begin
                                if (current_router == R0)
                                    current_router <= R2;
                                else if (current_router == R1)
                                    current_router <= R3;
                            end

                            NORTH: begin
                                if (current_router == R2)
                                    current_router <= R0;
                                else if (current_router == R3)
                                    current_router <= R1;
                            end

                            default: begin
                                current_router <= current_router;
                            end

                        endcase
                    end
                end

                DONE: begin
                    if (!packet_valid) begin
                        state <= IDLE;
                    end
                end

                default: begin
                    state <= IDLE;
                end

            endcase
        end
    end

endmodule