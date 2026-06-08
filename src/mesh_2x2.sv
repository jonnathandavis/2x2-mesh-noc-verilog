module mesh_2x2 (
    input  logic clk,
    input  logic rst,

    input  logic [1:0] source_router_id,
    input  logic [1:0] dest_router_id,
    input  logic [3:0] payload,
    input  logic       packet_valid,

    output logic [7:0] received_packet,
    output logic       received_valid,
    output logic [1:0] final_router_id,

    output logic [1:0] path_0,
    output logic [1:0] path_1,
    output logic [1:0] path_2,
    output logic [1:0] hop_count
);

    localparam R0 = 2'b00;
    localparam R1 = 2'b01;
    localparam R2 = 2'b10;
    localparam R3 = 2'b11;

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

            path_0 <= R0;
            path_1 <= R0;
            path_2 <= R0;
            hop_count <= 2'd0;
        end else begin
            received_valid <= 1'b0;

            case (state)

                IDLE: begin
                    if (packet_valid) begin
                        current_router <= source_router_id;

                        path_0 <= source_router_id;
                        path_1 <= source_router_id;
                        path_2 <= source_router_id;
                        hop_count <= 2'd0;

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
                                if (current_router == R0) begin
                                    current_router <= R1;
                                    if (hop_count == 0) path_1 <= R1;
                                    else path_2 <= R1;
                                end else if (current_router == R2) begin
                                    current_router <= R3;
                                    if (hop_count == 0) path_1 <= R3;
                                    else path_2 <= R3;
                                end
                            end

                            WEST: begin
                                if (current_router == R1) begin
                                    current_router <= R0;
                                    if (hop_count == 0) path_1 <= R0;
                                    else path_2 <= R0;
                                end else if (current_router == R3) begin
                                    current_router <= R2;
                                    if (hop_count == 0) path_1 <= R2;
                                    else path_2 <= R2;
                                end
                            end

                            SOUTH: begin
                                if (current_router == R0) begin
                                    current_router <= R2;
                                    if (hop_count == 0) path_1 <= R2;
                                    else path_2 <= R2;
                                end else if (current_router == R1) begin
                                    current_router <= R3;
                                    if (hop_count == 0) path_1 <= R3;
                                    else path_2 <= R3;
                                end
                            end

                            NORTH: begin
                                if (current_router == R2) begin
                                    current_router <= R0;
                                    if (hop_count == 0) path_1 <= R0;
                                    else path_2 <= R0;
                                end else if (current_router == R3) begin
                                    current_router <= R1;
                                    if (hop_count == 0) path_1 <= R1;
                                    else path_2 <= R1;
                                end
                            end

                            default: begin
                                current_router <= current_router;
                            end

                        endcase

                        hop_count <= hop_count + 1;
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