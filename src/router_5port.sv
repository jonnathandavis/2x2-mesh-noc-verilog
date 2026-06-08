module router_5port (
    input  logic clk,
    input  logic rst,

    input  logic [1:0] current_router_id,

    input  logic [7:0] local_in_data,
    input  logic       local_in_valid,

    output logic       local_fifo_full,
    output logic       local_fifo_empty,

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

    logic fifo_wr_en;
    logic fifo_rd_en;

    logic [7:0] fifo_data_out;
    logic [7:0] packet_reg;

    logic [1:0] dest_router_id;
    logic [2:0] route_direction;

    assign fifo_wr_en = local_in_valid && !local_fifo_full;
    assign dest_router_id = packet_reg[7:6];

    fifo #(
        .DATA_WIDTH(8),
        .FIFO_DEPTH(8)
    ) local_input_fifo (
        .clk(clk),
        .rst(rst),
        .wr_en(fifo_wr_en),
        .rd_en(fifo_rd_en),
        .data_in(local_in_data),
        .data_out(fifo_data_out),
        .full(local_fifo_full),
        .empty(local_fifo_empty)
    );

    xy_router routing_unit (
        .current_router_id(current_router_id),
        .dest_router_id(dest_router_id),
        .route_direction(route_direction)
    );

    typedef enum logic [1:0] {
        IDLE,
        READ_FIFO,
        CAPTURE_FIFO,
        ROUTE_PACKET
    } state_t;

    state_t state;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;

            fifo_rd_en <= 1'b0;
            packet_reg <= 8'h00;

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
            fifo_rd_en <= 1'b0;

            local_out_valid <= 1'b0;
            north_out_valid <= 1'b0;
            south_out_valid <= 1'b0;
            east_out_valid  <= 1'b0;
            west_out_valid  <= 1'b0;

            case (state)

                IDLE: begin
                    if (!local_fifo_empty) begin
                        fifo_rd_en <= 1'b1;
                        state <= READ_FIFO;
                    end
                end

                // FIFO reads data on this clock edge
                READ_FIFO: begin
                    state <= CAPTURE_FIFO;
                end

                // Now fifo_data_out contains correct packet
                CAPTURE_FIFO: begin
                    packet_reg <= fifo_data_out;
                    state <= ROUTE_PACKET;
                end

                ROUTE_PACKET: begin
                    case (route_direction)

                        LOCAL: begin
                            local_out_data  <= packet_reg;
                            local_out_valid <= 1'b1;
                        end

                        NORTH: begin
                            north_out_data  <= packet_reg;
                            north_out_valid <= 1'b1;
                        end

                        SOUTH: begin
                            south_out_data  <= packet_reg;
                            south_out_valid <= 1'b1;
                        end

                        EAST: begin
                            east_out_data  <= packet_reg;
                            east_out_valid <= 1'b1;
                        end

                        WEST: begin
                            west_out_data  <= packet_reg;
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

                    state <= IDLE;
                end

                default: begin
                    state <= IDLE;
                end

            endcase
        end
    end

endmodule