module fifo #(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 8
)(
    input  logic clk,
    input  logic rst,

    input  logic wr_en,
    input  logic rd_en,

    input  logic [DATA_WIDTH-1:0] data_in,
    output logic [DATA_WIDTH-1:0] data_out,

    output logic full,
    output logic empty
);

    localparam ADDR_WIDTH = $clog2(FIFO_DEPTH);

    logic [DATA_WIDTH-1:0] mem [0:FIFO_DEPTH-1];

    logic [ADDR_WIDTH-1:0] wr_ptr;
    logic [ADDR_WIDTH-1:0] rd_ptr;

    logic [ADDR_WIDTH:0] count;

    assign full  = (count == FIFO_DEPTH);
    assign empty = (count == 0);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr   <= 0;
            rd_ptr   <= 0;
            count    <= 0;
            data_out <= 0;
        end else begin

            // Write into FIFO when write enable is high and FIFO is not full
            if (wr_en && !full) begin
                mem[wr_ptr] <= data_in;
                wr_ptr <= wr_ptr + 1;
            end

            // Read from FIFO when read enable is high and FIFO is not empty
            if (rd_en && !empty) begin
                data_out <= mem[rd_ptr];
                rd_ptr <= rd_ptr + 1;
            end

            // Update number of stored elements
            case ({wr_en && !full, rd_en && !empty})
                2'b10: count <= count + 1;   // only write
                2'b01: count <= count - 1;   // only read
                2'b11: count <= count;       // simultaneous read and write
                default: count <= count;
            endcase

        end
    end

endmodule