`timescale 1ns/1ps

module fifo_tb;

    logic clk;
    logic rst;

    logic wr_en;
    logic rd_en;

    logic [7:0] data_in;
    logic [7:0] data_out;

    logic full;
    logic empty;

    // Instantiate FIFO
    fifo #(
        .DATA_WIDTH(8),
        .FIFO_DEPTH(8)
    ) dut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty)
    );

    // Clock generation: 10 ns clock period
    always #5 clk = ~clk;

    initial begin
        $dumpfile("fifo.vcd");
        $dumpvars(0, fifo_tb);

        clk = 0;
        rst = 1;
        wr_en = 0;
        rd_en = 0;
        data_in = 8'h00;

        // Reset FIFO
        #10;
        rst = 0;

        $display("Starting FIFO Test...");
        $display("---------------------");

        // Write data into FIFO
        write_fifo(8'h11);
        write_fifo(8'h22);
        write_fifo(8'h33);
        write_fifo(8'h44);

        // Read data from FIFO
        read_fifo();
        read_fifo();
        read_fifo();
        read_fifo();

        // Try reading when FIFO is empty
        read_fifo();

        // Fill FIFO completely
        write_fifo(8'hA1);
        write_fifo(8'hA2);
        write_fifo(8'hA3);
        write_fifo(8'hA4);
        write_fifo(8'hA5);
        write_fifo(8'hA6);
        write_fifo(8'hA7);
        write_fifo(8'hA8);

        // Try writing when FIFO is full
        write_fifo(8'hFF);

        // Read all data
        read_fifo();
        read_fifo();
        read_fifo();
        read_fifo();
        read_fifo();
        read_fifo();
        read_fifo();
        read_fifo();

        $display("---------------------");
        $display("FIFO Test Completed.");

        #20;
        $finish;
    end

    task write_fifo(input [7:0] value);
        begin
            @(posedge clk);
            wr_en = 1;
            rd_en = 0;
            data_in = value;

            @(posedge clk);
            wr_en = 0;

            $display("WRITE: data_in = %h | data_out = %h | full = %b | empty = %b",
                     value, data_out, full, empty);
        end
    endtask

    task read_fifo();
        begin
            @(posedge clk);
            wr_en = 0;
            rd_en = 1;

            @(posedge clk);
            rd_en = 0;

            $display("READ : data_out = %h | full = %b | empty = %b",
                     data_out, full, empty);
        end
    endtask

endmodule