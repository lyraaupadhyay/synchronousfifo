module fifo_sync # (
    parameter depth = 16 ,
    parameter data_width = 8,
    parameter address_width = 4

    )(  input   wire clk,
        input wire reset,
        input wire wr_ena,
        input wire rd_ena,
        input wire [data_width-1:0] d_in,
        output reg [data_width-1:0] d_out,
        output wire empty,
        output wire full
    );
    // memory array for fifo
    reg [data_width-1:0]memory[0:depth-1];

    //write pointer declaration
    reg [address_width:0] wr_ptr;

    //read pointer declaration
    reg[address_width:0]rd_ptr;

    //count logic
    reg[address_width:0] count;

    //write logic
    always@(posedge clk or negedge reset) begin
        if(~reset)begin
            wr_ptr <= 0;
        end
        else begin
            if(wr_ena && !full)begin
                memory[wr_ptr[address_width-1:0]] <= d_in;
                wr_ptr <= wr_ptr +1;
            end
        end
    end

    //read logic
    always@(posedge clk or negedge reset)begin
        if(~reset)begin
            rd_ptr <= 0;
        end
        else begin
            if(rd_ena && !empty)begin
                d_out <= memory[rd_ptr[address_width-1:0]];
                rd_ptr <= rd_ptr +1;
            end
        end
    end

    // count logic
    always@(posedge clk or negedge reset)begin
        if(~reset)begin
            count <= 0;
        end

        else begin 
            case({wr_ena && !full , rd_ena && !empty}) 
                2'b10: count <= count+1;
                2'b01: count <= count-1;
                default: count <= count;
        
            endcase
        end
    end

    assign empty = (count ==0);
    assign full = (count == depth);

endmodule
