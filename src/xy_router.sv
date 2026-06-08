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

    wire current_x;
    wire current_y;
    wire dest_x;
    wire dest_y;

    assign current_x = current_router_id[0];
    assign current_y = current_router_id[1];

    assign dest_x = dest_router_id[0];
    assign dest_y = dest_router_id[1];

    always @(*) begin
        // XY routing:
        // First move in X direction.
        // Then move in Y direction.
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