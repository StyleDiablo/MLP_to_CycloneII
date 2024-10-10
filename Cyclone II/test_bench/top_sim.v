`timescale 1ns / 1ps
`include "C:/Thesis/rtl/include.v"

`define MaxTestSamples 32

module top_sim;

    // Testbench signals
    reg reset;
    reg clock;
    reg [7:0] switches;
    wire [127:0] lcd_output;

    // Expected output data from file (adjust size as needed)
    reg [3:0] expected_output [0:`MaxTestSamples - 1]; 
    integer testDataCount, file, r;
    reg [3:0] actual_value, expected_value;
    integer right = 0; 

    // Instantiate the DUT (Device Under Test)
    cyMlp dut (
        .s_axi_aclk(clock),
        .s_axi_aresetn(reset),
        .switches(switches),
        .lcd_output(lcd_output)
    );

    // Test logic
    initial begin
        // Initialize
        clock = 0;
        reset = 0;
        switches = `MaxTestSamples; // Process all 128 images
        // Reset the DUT
        #20;
        reset = 1;
        $display("Reset deasserted at time %t", $time);
        #10; 

        // Read expected output values from file
        $readmemb("C:/Thesis/tensorflow/65th_values.txt", expected_output); 


        // Wait for processing to complete after each key press
        for (testDataCount = 0; testDataCount < `MaxTestSamples; testDataCount = testDataCount + 32) begin
            #300000; // Adjust the delay based on your processing time

            // Compare the LCD output with the expected values
            for (r = 0; r < 32; r = r + 1) begin
                actual_value = lcd_output[r*4 +: 4];
                expected_value = expected_output[testDataCount + r];
                if (actual_value == expected_value) begin
                    right = right + 1;
                end
                $display("%0d. Accuracy: %f, Detected number: %0x, Expected: %x", testDataCount + r + 1, (right*100.0)/(testDataCount + r + 1), actual_value, expected_value);
            end
            $display("Accuracy after %0d samples: %f", testDataCount + 32, (right*100.0)/(testDataCount + 32));
            $display(" ");

        end

        $display("Final Accuracy: %f", (right*100.0)/`MaxTestSamples);
        $finish;
    end

    // Clock generation
    always #5 clock = ~clock;

endmodule
