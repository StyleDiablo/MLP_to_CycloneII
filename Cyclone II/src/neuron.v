`timescale 1ns / 1ps
`include "C:/Thesis/rtl/include.v"

module neuron #(
    parameter layerNo = 0,
    parameter neuronNo = 0,
    parameter numWeight = 64,
    parameter dataWidth = 16,
	 parameter sigmoidSize=5,
    parameter weightIntWidth = 1,
    parameter biasFile = "",
    parameter weightFile = ""
)(
    input clk,
    input rst,
    input [dataWidth-1:0] myinput,
    input myinputValid,
    input weightValid,
    input biasValid,
    input [15:0] weightValue,
    input [31:0] biasValue,
    input [31:0] config_layer_num,
    input [31:0] config_neuron_num,
    output [dataWidth-1:0] out,
    output reg outvalid   
);

    localparam addressWidth = $clog2(numWeight);
    reg [addressWidth-1:0] w_addr;
    reg [addressWidth:0] r_addr; 
    reg [dataWidth-1:0] w_in;
    wire [dataWidth-1:0] w_out;
    reg [2*dataWidth-1:0] mul, sum, bias;
    reg [31:0] biasReg[0:0];
	reg         weight_valid;
    reg         mult_valid;
    wire        mux_valid;
    reg         sigValid; 
    wire 		ren;
    wire [2*dataWidth-1:0] comboAdd, BiasAdd;
    reg [dataWidth-1:0] myinputd;
    reg muxValid_d, muxValid_f;
    
    // Memory write enable logic
    always @(posedge clk) begin
        if (rst) begin
            w_addr <= {addressWidth{1'b1}};
        end else if (weightValid && (config_layer_num == layerNo) && (config_neuron_num == neuronNo)) begin
            w_addr <= w_addr + 1'b1;
            w_in <= weightValue;
        end
    end
	
		
    assign mux_valid = mult_valid;
    assign comboAdd = mul + sum;
    assign BiasAdd = bias + sum;
    assign ren = myinputValid;
    
	initial begin
            $readmemb(biasFile, biasReg);
        end
        always @(posedge clk) begin
            bias <= {biasReg[0][dataWidth-1:0], {dataWidth{1'b0}}}; // Using depth 1 biasReg
        end
	
    always @(posedge clk)
    begin
        if(rst|outvalid)
            r_addr <= 0;
        else if(myinputValid)
            r_addr <= r_addr + 1'b1;
    end
    
    always @(posedge clk)
    begin
        mul  <= $signed(myinputd) * $signed(w_out);
    end
    
    
    always @(posedge clk)
    begin
        if(rst|outvalid)
            sum <= 0;
        else if((r_addr == numWeight) & muxValid_f)
        begin
            if(!bias[2*dataWidth-1] &!sum[2*dataWidth-1] & BiasAdd[2*dataWidth-1]) //If bias and sum are positive and after adding bias to sum, if sign bit becomes 1, saturate
            begin
                sum[2*dataWidth-1] <= 1'b0;
                sum[2*dataWidth-2:0] <= {2*dataWidth-1{1'b1}};
            end
            else if(bias[2*dataWidth-1] & sum[2*dataWidth-1] &  !BiasAdd[2*dataWidth-1]) //If bias and sum are negative and after addition if sign bit is 0, saturate
            begin
                sum[2*dataWidth-1] <= 1'b1;
                sum[2*dataWidth-2:0] <= {2*dataWidth-1{1'b0}};
            end
            else
                sum <= BiasAdd; 
        end
        else if(mux_valid)
        begin
            if(!mul[2*dataWidth-1] & !sum[2*dataWidth-1] & comboAdd[2*dataWidth-1])
            begin
                sum[2*dataWidth-1] <= 1'b0;
                sum[2*dataWidth-2:0] <= {2*dataWidth-1{1'b1}};
            end
            else if(mul[2*dataWidth-1] & sum[2*dataWidth-1] & !comboAdd[2*dataWidth-1])
            begin
                sum[2*dataWidth-1] <= 1'b1;
                sum[2*dataWidth-2:0] <= {2*dataWidth-1{1'b0}};
            end
            else
                sum <= comboAdd; 
        end
    end
    
    always @(posedge clk)
    begin
        myinputd <= myinput;
        weight_valid <= myinputValid;
        mult_valid <= weight_valid;
        sigValid <= ((r_addr == numWeight) & muxValid_f) ? 1'b1 : 1'b0;
        outvalid <= sigValid;
        muxValid_d <= mux_valid;
        muxValid_f <= !mux_valid & muxValid_d;
    end

    // Instantiate memory for weights
    Weight_Memory #(
        .numWeight(numWeight),
        .neuronNo(neuronNo),
        .layerNo(layerNo),
        .addressWidth(addressWidth),
        .dataWidth(dataWidth),
        .weightFile(weightFile)
    ) weight_memory (
        .clk(clk),
        .wen(weightValid),
        .ren(ren),
        .wadd(w_addr),
        .radd(r_addr),
        .win(w_in),
        .wout(w_out)
    );
	
    // Instantiate ReLU activation function
   	Sig_ROM #(
		.inWidth(sigmoidSize),
		.dataWidth(dataWidth)) 
	s1(
		.clk(clk),
		.x(sum[2*dataWidth-1-:sigmoidSize]),
		.out(out)
	);
endmodule
