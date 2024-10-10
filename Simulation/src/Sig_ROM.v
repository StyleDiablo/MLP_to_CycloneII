`timescale 1ns / 1ps

module Sig_ROM #(parameter inWidth = 10, dataWidth = 16) (
    input clk,
    input [inWidth-1:0] x,
    output reg [dataWidth-1:0] out
);

    // Memory array to hold the sigmoid values
    reg [dataWidth-1:0] mem [0:2**inWidth-1];

    // Initialization of the memory from an external file
    initial begin
        $readmemb("sigContent.mif", mem);
    end

    // Index variable
    reg [inWidth-1:0] y;

    always @(posedge clk) begin
        // Handling signed input and adjusting the index
        if ($signed(x) >= 0)
            y <= x + (2**(inWidth-1));
        else
            y <= x - (2**(inWidth-1));

        // Output assignment
        out <= mem[y];
    end

endmodule

