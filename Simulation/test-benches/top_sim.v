`timescale 1ns / 1ps

`include "C:/Users/Ohmen/Desktop/Desktop/School/Thesis/rtl/include.v"

`define MaxTestSamples 100

module top_sim(

    );
    
    reg reset;
    reg clock;
    reg [`dataWidth-1:0] in;
    reg in_valid;
    reg [`dataWidth-1:0] in_mem [64:0];
    reg [7:0] fileName[17:0];
    reg s_axi_awvalid;
    reg [31:0] s_axi_awaddr;
    wire s_axi_awready;
    reg [31:0] s_axi_wdata;
    reg s_axi_wvalid;
    wire s_axi_wready;
    wire s_axi_bvalid;
    reg s_axi_bready;
    wire intr;
    reg [31:0] axiRdData;
    reg [31:0] s_axi_araddr;
    wire [31:0] s_axi_rdata;
    reg s_axi_arvalid;
    wire s_axi_arready;
    wire s_axi_rvalid;
    reg s_axi_rready;
    reg [`dataWidth-1:0] expected;
    
    integer right=0;
    integer wrong=0;
    
    cyMlp dut(
    .s_axi_aclk(clock),
    .s_axi_aresetn(reset),
    .s_axi_awaddr(s_axi_awaddr),
    .s_axi_awprot(0),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_awready(s_axi_awready),
    .s_axi_wdata(s_axi_wdata),
    .s_axi_wstrb(4'hF),
    .s_axi_wvalid(s_axi_wvalid),
    .s_axi_wready(s_axi_wready),
    .s_axi_bresp(),
    .s_axi_bvalid(s_axi_bvalid),
    .s_axi_bready(s_axi_bready),
    .s_axi_araddr(s_axi_araddr),
    .s_axi_arprot(0),
    .s_axi_arvalid(s_axi_arvalid),
    .s_axi_arready(s_axi_arready),
    .s_axi_rdata(s_axi_rdata),
    .s_axi_rresp(),
    .s_axi_rvalid(s_axi_rvalid),
    .s_axi_rready(s_axi_rready),
    .axis_in_data(in),
    .axis_in_data_valid(in_valid),
    .axis_in_data_ready(),
    .intr(intr)
    );
    
            
    initial
    begin
        clock = 1'b0;
        s_axi_awvalid = 1'b0;
        s_axi_bready = 1'b0;
        s_axi_wvalid = 1'b0;
        s_axi_arvalid = 1'b0;
    end
        
    always
        #5 clock = ~clock;
    
    always @(posedge clock)
    begin
        s_axi_bready <= s_axi_bvalid;
        s_axi_rready <= s_axi_rvalid;
    end
    
    task writeAxi(
    input [31:0] address,
    input [31:0] data
    );
    begin
        @(posedge clock);
        s_axi_awvalid <= 1'b1;
        s_axi_awaddr <= address;
        s_axi_wdata <= data;
        s_axi_wvalid <= 1'b1;
        wait(s_axi_wready);
        @(posedge clock);
        s_axi_awvalid <= 1'b0;
        s_axi_wvalid <= 1'b0;
        @(posedge clock);
    end
    endtask
    
    task readAxi(
    input [31:0] address
    );
    begin
        @(posedge clock);
        s_axi_arvalid <= 1'b1;
        s_axi_araddr <= address;
        wait(s_axi_arready);
        @(posedge clock);
        s_axi_arvalid <= 1'b0;
        wait(s_axi_rvalid);
        @(posedge clock);
        axiRdData <= s_axi_rdata;
        @(posedge clock);
    end
    endtask
    
 task sendData(input integer fileIndex);
    integer i;
    reg [8*100:1] filePath; 
    begin
        $sformat(filePath, "C:/Users/Ohmen/Desktop/Desktop/School/Thesis/test_data/test_data/test_data_%04d.txt", fileIndex);
        $display("Reading file: %s", filePath);
        $readmemb(filePath, in_mem); 
            
        for (i = 0; i < 64; i = i + 1) begin 
            in <= in_mem[i];
            in_valid <= 1'b1;
        end
        @(posedge clock);
		in_valid <= 0;
		expected = in_mem[64]; 
    end
endtask

   
    integer i,j,layerNo=1,k;
    integer start;
    integer testDataCount;
    integer testDataCount_int;
    initial
    begin
        reset = 0;
        in_valid = 0;
        #100;
        reset = 1;
        #100
        writeAxi(28,0);
        start = $time;
        $display("Configuration completed",,,,$time-start,,"ns");
        start = $time;
        for(testDataCount=0;testDataCount<`MaxTestSamples;testDataCount=testDataCount+1)
        begin
            sendData(testDataCount);
            @(posedge intr);
            $display("Status: %0x",axiRdData);
            readAxi(8);
            if(axiRdData==expected)
                right = right+1;
            $display("%0d. Accuracy: %f, Detected number: %0x, Expected: %x",testDataCount+1,right*100.0/(testDataCount+1),axiRdData,expected);
            $display("Total execution time",,,,$time-start,,"ns");
        end
        $display("Accuracy: %f",right*100.0/testDataCount);
        $stop;
    end


endmodule
