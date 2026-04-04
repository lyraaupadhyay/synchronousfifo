module fifo_sync_tb;
    parameter depth =16;
    parameter data_width = 8;
    parameter address_width = 4;

    reg clk;
    reg reset;
    reg wr_ena;
    reg rd_ena;
    reg [data_width-1:0]d_in;
    wire [data_width-1:0]d_out;
    wire full;
    wire empty;

    fifo_sync #(
        .depth(depth),
        .data_width(data_width),
        .address_width(address_width)
    ) dut (
        .clk(clk),
        .reset(reset),
        .wr_ena(wr_ena),
        .rd_ena(rd_ena),
        .d_in(d_in),
        .d_out(d_out),
        .empty(empty),
        .full(full)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Reset task
    task apply_reset;
    begin
        reset = 0;
        wr_ena = 0;
        rd_ena = 0;
        d_in   = 0;
        #20;
        reset = 1;
        $display("RESET APPLIED");
    end
    endtask

    // Write task
    task fifo_write(input [data_width-1:0] data);
    begin
        @(posedge clk);
        if (!full) begin
            wr_ena = 1;
            rd_ena = 0;
            d_in   = data;
            $display("WRITE: %h", data);
        end else begin
            $display("WRITE BLOCKED (FIFO FULL)");
        end
    end
    endtask

    // Read task
    task fifo_read;
    begin
        @(posedge clk);
        if (!empty) begin
            rd_ena = 1;
            wr_ena = 0;
            $display("READ issued");
        end else begin
            $display("READ BLOCKED (FIFO EMPTY)");
        end
    end
    endtask

// Simultaneous read/write task
    task fifo_read_write(input [data_width-1:0] data);
    begin
        @(posedge clk);
        if (!full && !empty) begin
            wr_ena = 1;
            rd_ena = 1;
            d_in   = data;
            $display("SIMULTANEOUS R/W: write=%h", data);
        end
    end
    endtask

 // Idle task
    task fifo_idle;
    begin
        @(posedge clk);
        wr_ena = 0;
        rd_ena = 0;
    end
    endtask

    initial begin
        $dumpfile("fifo.vcd");
        $dumpvars(0, fifo_sync_tb);

        apply_reset;

        // Condition 1: Write only
        fifo_write(8'h11);
        fifo_write(8'h22);
        fifo_write(8'h33);
        fifo_idle;

        // Condition 2: Read only
        fifo_read;
        fifo_read;
        fifo_idle;

        // Condition 3: Simultaneous read & write
        fifo_read_write(8'h44);
        fifo_read_write(8'h55);
        fifo_idle;

        // Condition 4: Read until empty
        repeat (5) fifo_read;
        fifo_idle;

        // Condition 5: Write until full
        repeat (depth + 2) fifo_write(d_in + 8'h11);
        fifo_idle;

        #20;
        $finish;
    end

endmodule