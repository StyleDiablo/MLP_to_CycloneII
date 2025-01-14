`timescale 1ns / 1ps
`include "C:/rtl/include.v"

module cyMlp #(
    parameter integer C_S_AXI_DATA_WIDTH    = 32,
    parameter integer C_S_AXI_ADDR_WIDTH    = 5
)
(

    input                                   s_axi_aclk,
    input                                   s_axi_aresetn,
    input [`dataWidth-1:0]                  axis_in_data,
    input                                   axis_in_data_valid,
    output                                  axis_in_data_ready,
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0]   s_axi_awaddr,
    input wire [2 : 0]                      s_axi_awprot,
    input wire                              s_axi_awvalid,
    output wire                             s_axi_awready,
    input wire [C_S_AXI_DATA_WIDTH-1 : 0]   s_axi_wdata,
    input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] s_axi_wstrb,
    input wire                              s_axi_wvalid,
    output wire                             s_axi_wready,
    output wire [1 : 0]                     s_axi_bresp,
    output wire                             s_axi_bvalid,
    input wire                              s_axi_bready,
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0]   s_axi_araddr,
    input wire [2 : 0]                      s_axi_arprot,
    input wire                              s_axi_arvalid,
    output wire                             s_axi_arready,
    output wire [C_S_AXI_DATA_WIDTH-1 : 0]  s_axi_rdata,
    output wire [1 : 0]                     s_axi_rresp,
    output wire                             s_axi_rvalid,
    input wire                              s_axi_rready,
    output wire                             intr
);


wire [31:0]  config_layer_num;
wire [31:0]  config_neuron_num;
wire [31:0] weightValue;
wire [31:0] biasValue;
wire [31:0] out;
wire out_valid;
wire weightValid;
wire biasValid;
wire axi_rd_en;
wire [31:0] axi_rd_data;
wire softReset;

assign intr = out_valid;
assign axis_in_data_ready = 1'b1;


axi_lite_wrapper # ( 
    .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
    .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH)
) alw (
    .S_AXI_ACLK(s_axi_aclk),
    .S_AXI_ARESETN(s_axi_aresetn),
    .S_AXI_AWADDR(s_axi_awaddr),
    .S_AXI_AWPROT(s_axi_awprot),
    .S_AXI_AWVALID(s_axi_awvalid),
    .S_AXI_AWREADY(s_axi_awready),
    .S_AXI_WDATA(s_axi_wdata),
    .S_AXI_WSTRB(s_axi_wstrb),
    .S_AXI_WVALID(s_axi_wvalid),
    .S_AXI_WREADY(s_axi_wready),
    .S_AXI_BRESP(s_axi_bresp),
    .S_AXI_BVALID(s_axi_bvalid),
    .S_AXI_BREADY(s_axi_bready),
    .S_AXI_ARADDR(s_axi_araddr),
    .S_AXI_ARPROT(s_axi_arprot),
    .S_AXI_ARVALID(s_axi_arvalid),
    .S_AXI_ARREADY(s_axi_arready),
    .S_AXI_RDATA(s_axi_rdata),
    .S_AXI_RRESP(s_axi_rresp),
    .S_AXI_RVALID(s_axi_rvalid),
    .S_AXI_RREADY(s_axi_rready),
    .layerNumber(config_layer_num),
    .neuronNumber(config_neuron_num),
    .weightValue(weightValue),
    .weightValid(weightValid),
    .biasValid(biasValid),
    .biasValue(biasValue),
    .nnOut_valid(out_valid),
    .nnOut(out),
    .axi_rd_en(axi_rd_en),
    .axi_rd_data(axi_rd_data),
    .softReset(softReset)
);

wire reset;

assign reset = ~s_axi_aresetn | softReset;

localparam IDLE = 1'b0,
           SEND = 1'b1;

wire [`numNeuronLayer1-1:0] o1_valid;
wire [`numNeuronLayer1*`dataWidth-1:0] x1_out;
reg [`numNeuronLayer1*`dataWidth-1:0] holdData_1;
reg [`dataWidth-1:0] out_data_1;
reg data_out_valid_1;

Layer_1 #(
    .NN(`numNeuronLayer1),
    .numWeight(`numWeightLayer1),
    .dataWidth(`dataWidth),
    .layerNum(1),
	.sigmoidSize(`sigmoidSize),
    .weightIntWidth(`weightIntWidth)
) l1 (
    .clk(s_axi_aclk),
    .rst(reset),
    .weightValid(weightValid),
    .biasValid(biasValid),
    .weightValue(weightValue),
    .biasValue(biasValue),
    .config_layer_num(config_layer_num),
    .config_neuron_num(config_neuron_num),
    .x_valid(axis_in_data_valid),
    .x_in(axis_in_data),
    .o_valid(o1_valid),
    .x_out(x1_out)
);

reg       state_1;
integer   count_1;
always @(posedge s_axi_aclk) 
begin
    if(reset) 
	begin
        state_1 <= IDLE;
        count_1 <= 0;
        data_out_valid_1 <=0;
    end
    else 
	begin
        case(state_1)
            IDLE: begin
                count_1 <= 0;
                data_out_valid_1 <=0;
                if (o1_valid[0] == 1'b1) 
				begin
                    holdData_1 <= x1_out;
                    state_1 <= SEND;
                end
            end
            SEND: begin
                out_data_1 <= holdData_1[`dataWidth-1:0];
                holdData_1 <= holdData_1>>`dataWidth;
                count_1 <= count_1 +1;
                data_out_valid_1 <= 1;
                if (count_1 == `numNeuronLayer1) 
				begin
                    state_1 <= IDLE;
                    data_out_valid_1 <= 0;
                end
            end
        endcase
    end
end

wire [`numNeuronLayer2-1:0] o2_valid;
wire [`numNeuronLayer2*`dataWidth-1:0] x2_out;
reg [`numNeuronLayer2*`dataWidth-1:0] holdData_2;
reg [`dataWidth-1:0] out_data_2;
reg data_out_valid_2;

Layer_2 #(
    .NN(`numNeuronLayer2),
    .numWeight(`numWeightLayer2),
    .dataWidth(`dataWidth),
    .layerNum(2),
	.sigmoidSize(`sigmoidSize),
    .weightIntWidth(`weightIntWidth)
) l2 (
    .clk(s_axi_aclk),
    .rst(reset),
    .weightValid(weightValid),
    .biasValid(biasValid),
    .weightValue(weightValue),
    .biasValue(biasValue),
    .config_layer_num(config_layer_num),
    .config_neuron_num(config_neuron_num),
    .x_valid(data_out_valid_1),
    .x_in(out_data_1),
    .o_valid(o2_valid),
    .x_out(x2_out)
);

reg       state_2;
integer   count_2;
always @(posedge s_axi_aclk) begin
    if(reset) begin
        state_2 <= IDLE;
        count_2 <= 0;
        data_out_valid_2 <=0;
    end
    else begin
        case(state_2)
            IDLE: begin
                count_2 <= 0;
                data_out_valid_2 <=0;
                if (o2_valid[0] == 1'b1) begin
                    holdData_2 <= x2_out;
                    state_2 <= SEND;
                end
            end
            SEND: begin
                out_data_2 <= holdData_2[`dataWidth-1:0];
                holdData_2 <= holdData_2 >> `dataWidth;
                count_2 <= count_2 +1;
                data_out_valid_2 <= 1;
                if (count_2 == `numNeuronLayer2) begin
                    state_2 <= IDLE;
                    data_out_valid_2 <= 0;
                end
            end
        endcase
    end
end


wire [`numNeuronLayer3-1:0] o3_valid;
wire [`numNeuronLayer3*`dataWidth-1:0] x3_out;
reg [`numNeuronLayer3*`dataWidth-1:0] holdData_3;

Layer_3 #(
    .NN(`numNeuronLayer3),
    .numWeight(`numWeightLayer3),
    .dataWidth(`dataWidth),
    .layerNum(3),
	.sigmoidSize(`sigmoidSize),
    .weightIntWidth(`weightIntWidth)
) l3 (
    .clk(s_axi_aclk),
    .rst(reset),
    .weightValid(weightValid),
    .biasValid(biasValid),
    .weightValue(weightValue),
    .biasValue(biasValue),
    .config_layer_num(config_layer_num),
    .config_neuron_num(config_neuron_num),
    .x_valid(data_out_valid_2),
    .x_in(out_data_2),
    .o_valid(o3_valid),
    .x_out(x3_out)
);


assign axi_rd_data = holdData_3[`dataWidth-1:0];

always @(posedge s_axi_aclk)
    begin
        if (o3_valid[0] == 1'b1)
            holdData_3 <= x3_out;
        else if(axi_rd_en)
        begin
            holdData_3 <= holdData_3>>`dataWidth;
        end
    end

maxFinder #(.numInput(`numNeuronLayer3),.inputWidth(`dataWidth))
    hMax(
        .i_clk(s_axi_aclk),
        .i_data(x3_out),
        .i_valid(o3_valid),
        .o_data(out),
        .o_data_valid(out_valid)
    );
endmodule