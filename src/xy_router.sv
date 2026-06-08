module xy_router (
    input  logic [1:0] current_router_id,
    input  logic [1:0] dest_router_id,
    output logic [2:0] route_direction
);

    // Direction encoding
    localparam LOCAL = 3'b000;
    localparam EAST  = 3'b001;
    localparam WEST  = 3'b010;
    localparam SOUTH = 3'b011;
    localparam NORTH = 3'b100;

    logic current_x;
    logic current_y;
    logic dest_x;
    logic dest_y;

    always_comb begin
        // Router ID mapping:
        // R0 = 00 = x=0, y=0
        // R1 = 01 = x=1, y=0
        // R2 = 10 = x=0, y=1
        // R3 = 11 = x=1, y=1

        current_x = current_router_id[0];
        current_y = current_router_id[1];

        dest_x = dest_router_id[0];
        dest_y = dest_router_id[1];

        // XY routing:
        // First move in X direction, then move in Y direction.
        if (current_router_id == dest_router_id) begin
            route_direction = LOCAL;
        end
        else if (dest_x > current_x) begin
            route_direction = EAST;
        end
        else if (dest_x < current_x) begin
            route_direction = WEST;
        end
        else if (dest_y > current_y) begin
            route_direction = SOUTH;
        end
        else begin
            route_direction = NORTH;
        end
    end

endmodule