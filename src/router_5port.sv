module router_5port (
    input  logic clk,
    input  logic rst,

    input  logic [1:0] current_router_id,

    input  logic [7:0] local_in_data,
    input  logic       local_in_valid,

    output logic [7:0] local_out_data,
    output logic       local_out_valid,

    output logic [7:0] north_out_data,
    output logic       north_out_valid,

    output logic [7:0] south_out_data,
    output logic       south_out_valid,

    output logic [7:0] east_out_data,
    output logic       east_out_valid,

    output logic [7:0] west_out_data,
    output logic       west_out_valid
);

    // Direction encoding
    localparam LOCAL = 3'b000;
    localparam EAST  = 3'b001;
    localparam WEST  = 3'b010;
    localparam SOUTH = 3'b011;
    localparam NORTH = 3'b100;

    logic [1:0] dest_router_id;
    logic [2:0] route_direction;

    assign dest_router_id = local_in_data[7:6];

    xy_router routing_unit (
        .current_router_id(current_router_id),
        .dest_router_id(dest_router_id),
        .route_direction(route_direction)
    );

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            local_out_data  <= 8'h00;
            north_out_data  <= 8'h00;
            south_out_data  <= 8'h00;
            east_out_data   <= 8'h00;
            west_out_data   <= 8'h00;

            local_out_valid <= 1'b0;
            north_out_valid <= 1'b0;
            south_out_valid <= 1'b0;
            east_out_valid  <= 1'b0;
            west_out_valid  <= 1'b0;
        end else begin
            local_out_valid <= 1'b0;
            north_out_valid <= 1'b0;
            south_out_valid <= 1'b0;
            east_out_valid  <= 1'b0;
            west_out_valid  <= 1'b0;

            if (local_in_valid) begin
                case (route_direction)
                    LOCAL: begin
                        local_out_data  <= local_in_data;
                        local_out_valid <= 1'b1;
                    end

                    NORTH: begin
                        north_out_data  <= local_in_data;
                        north_out_valid <= 1'b1;
                    end

                    SOUTH: begin
                        south_out_data  <= local_in_data;
                        south_out_valid <= 1'b1;
                    end

                    EAST: begin
                        east_out_data  <= local_in_data;
                        east_out_valid <= 1'b1;
                    end

                    WEST: begin
                        west_out_data  <= local_in_data;
                        west_out_valid <= 1'b1;
                    end

                    default: begin
                        local_out_valid <= 1'b0;
                        north_out_valid <= 1'b0;
                        south_out_valid <= 1'b0;
                        east_out_valid  <= 1'b0;
                        west_out_valid  <= 1'b0;
                    end
                endcase
            end
        end
    end

endmodule