`timescale 1ns / 1ps

module maxFinder #(
    parameter numInput = 10,
    parameter inputWidth = 16
)(
    input                      i_clk,
    input [(numInput*inputWidth)-1:0] i_data,
    input                      i_valid,
    output reg [31:0]          o_data,
    output reg                 o_data_valid
);

reg [inputWidth-1:0] maxValue;
reg [31:0]           maxIndex;
reg [(numInput*inputWidth)-1:0] inDataBuffer;
integer counter;

always @(posedge i_clk) begin
    if (i_valid) begin
        maxValue <= i_data[inputWidth-1:0];
        maxIndex <= 0;
        counter <= 1;
        inDataBuffer <= i_data;
        o_data_valid <= 1'b0;
    end else if (counter != 0) begin
        if (counter < numInput) begin
            if (inDataBuffer[counter*inputWidth+:inputWidth] > maxValue) begin
                maxValue <= inDataBuffer[counter*inputWidth+:inputWidth];
                maxIndex <= counter;
            end
            counter <= counter + 1;
        end else begin
            o_data <= maxIndex;
            o_data_valid <= 1'b1;
            counter <= 0;
        end
    end
end

endmodule
