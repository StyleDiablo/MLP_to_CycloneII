`timescale 1ns / 1ps

module input_ROM #(parameter numImages = 1797, imageSize = 65, addressWidth = 17, dataWidth = 16, imageFile="images.mif")
    (
    input clk,
    input ren,
    input [addressWidth-1:0] radd,
    output reg [dataWidth-1:0] data
    );
    
    reg [dataWidth-1:0] mem [0:numImages*imageSize-1];

    initial begin
        $readmemb(imageFile, mem);
    end
    
    always @(posedge clk) begin
        if (ren) begin
            data <= mem[radd];
        end
    end 
endmodule
