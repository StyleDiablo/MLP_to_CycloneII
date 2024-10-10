`timescale 1ns / 1ps
`include "C:/Thesis/rtl/include.v"

module cyMlp (
    input s_axi_aclk, 
    input s_axi_aresetn, 
    input [7:0] switches, 
    output [127:0] lcd_output
);


    wire weightValid;
    wire biasValid;
    wire reset;
    wire [`numNeuronLayer3-1:0] o3_valid;
    wire out_valid;
    wire [3:0] max_data; 

    reg [7:0] num_inputs_to_process;
    reg [7:0] remaining_inputs;
    reg [12:0] rom_address;
    wire [15:0] rom_data;
    reg rom_enable;

    reg [127:0] lcd_buffer;
    reg [4:0] lcd_index;

    assign reset = ~s_axi_aresetn;

    localparam IDLE = 2'b00,
               READ_ROM = 2'b01,
               SEND = 2'b10,
               WAIT = 2'b11;

    reg [1:0] state;
    integer count;
    reg [15:0] in_data_1;
    reg data_out_valid_0;
    reg [7:0] image_count;
    integer skip_count, loadcount;
    integer data_index;
    reg [15:0] holdData_0;
    reg holdData_valid;
    reg input_ready;
    reg output_ready;

    reg start_processing; 
    reg stop_write;  
    reg skip_first_output;  

    input_ROM #(
        .numImages(32),
        .imageSize(64),
        .addressWidth(13),
        .dataWidth(16),
        .imageFile("test_data0-31.mif")
    ) rom_inst (
        .clk(s_axi_aclk),
        .ren(rom_enable),
        .radd(rom_address),
        .data(rom_data)
    );

    always @(posedge s_axi_aclk or posedge reset) begin
        if (reset) begin
            rom_address <= 0;
            rom_enable <= 0;
            state <= IDLE;
            count <= 0;
            data_out_valid_0 <= 0;
            skip_count <= 0;
            image_count <= 0;
            in_data_1 <= 16'b0;
            input_ready <= 0;
            output_ready <= 1;
            start_processing <= 0;
            loadcount <= 0;
            remaining_inputs <= 0;
        end else begin
            if (!start_processing) begin
				num_inputs_to_process <= switches;
                start_processing <= 1;
            end

            if (start_processing) begin 
                case (state)
                    IDLE: begin
                        count <= 0;
                        data_out_valid_0 <= 0;
                        if (image_count < num_inputs_to_process && output_ready) begin
                            rom_address <= image_count * 64;
                            rom_enable <= 1;
                            state <= READ_ROM;
                        end
                    end
                    READ_ROM: begin
                        if (rom_enable) begin
                            if (rom_address == image_count * 64) begin
                                skip_count <= skip_count + 1;
                                rom_address <= rom_address + 1;
                            end else if (count < 63) begin
                                in_data_1 <= rom_data;
                                data_out_valid_0 <= 1;
                                count <= count + 1;
                                rom_address <= rom_address + 1;
                            end else if (count == 63) begin
                                in_data_1 <= rom_data; 
                                data_out_valid_0 <= 1;
                                rom_enable <= 0;
                                input_ready <= 1;
                                state <= WAIT;
                                loadcount <= loadcount + 1;
                                count <= 0;
                                skip_count <= 0;
                            end
                        end
                    end
                    WAIT: begin
                        if (o3_valid[0] == 1'b1) begin
                            image_count <= image_count + 1;
                            state <= IDLE;
                            output_ready <= 1;
                        end
                        data_out_valid_0 <= 0;
                    end
                endcase
            end
        end
    end

    assign lcd_output = lcd_buffer;

    wire [`numNeuronLayer1-1:0] o1_valid;
    wire [`numNeuronLayer1*`dataWidth-1:0] x1_out;
    reg [`numNeuronLayer1*`dataWidth-1:0] holdData_1;
    reg [`dataWidth-1:0] out_data_1;
    reg data_out_valid_1;

    localparam IDLE1 = 1'b0,
               SEND1 = 1'b1;

    reg state_1;
    integer count_1;

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
        .weightValue(32'b0),
        .biasValue(32'b0),
        .config_layer_num(32'b0),
        .config_neuron_num(32'b0),
        .x_valid(data_out_valid_0),
        .x_in(in_data_1),
        .o_valid(o1_valid),
        .x_out(x1_out)
    );

    always @(posedge s_axi_aclk or posedge reset) begin
        if(reset) begin
            state_1 <= IDLE1;
            count_1 <= 0;
            data_out_valid_1 <= 0;
        end else begin
            case(state_1)
                IDLE1: begin
                    count_1 <= 0;
                    data_out_valid_1 <= 0;
                    if (o1_valid[0] == 1'b1) begin
                        holdData_1 <= x1_out;
                        state_1 <= SEND1;
                    end
                end
                SEND1: begin
                    out_data_1 <= holdData_1[`dataWidth-1:0];
                    holdData_1 <= holdData_1 >> `dataWidth;
                    count_1 <= count_1 + 1;
                    data_out_valid_1 <= 1;
                    if (count_1 == `numNeuronLayer1) begin
                        state_1 <= IDLE1;
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

    reg state_2;
    integer count_2;

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
        .weightValue(32'b0),
        .biasValue(32'b0),
        .config_layer_num(32'b0),
        .config_neuron_num(32'b0),
        .x_valid(data_out_valid_1),
        .x_in(out_data_1),
        .o_valid(o2_valid),
        .x_out(x2_out)
    );

    always @(posedge s_axi_aclk or posedge reset) begin
        if(reset) begin
            state_2 <= IDLE1;
            count_2 <= 0;
            data_out_valid_2 <= 0;
        end else begin
            case(state_2)
                IDLE1: begin
                    count_2 <= 0;
                    data_out_valid_2 <= 0;
                    if (o2_valid[0] == 1'b1) begin
                        holdData_2 <= x2_out;
                        state_2 <= SEND1;
                    end
                end
                SEND1: begin
                    out_data_2 <= holdData_2[`dataWidth-1:0];
                    holdData_2 <= holdData_2 >> `dataWidth;
                    count_2 <= count_2 + 1;
                    data_out_valid_2 <= 1;
                    if (count_2 == `numNeuronLayer2) begin
                        state_2 <= IDLE1;
                        data_out_valid_2 <= 0;
                    end
                end
            endcase
        end
    end

    wire [`numNeuronLayer3*`dataWidth-1:0] x3_out;
    reg [`numNeuronLayer3*`dataWidth-1:0] holdData_3;
    reg [`dataWidth-1:0] out_data_3;
    reg data_out_valid_3;

    reg state_3;
    integer count_3;

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
        .weightValue(32'b0),
        .biasValue(32'b0),
        .config_layer_num(32'b0),
        .config_neuron_num(32'b0),
        .x_valid(data_out_valid_2),
        .x_in(out_data_2),
        .o_valid(o3_valid),
        .x_out(x3_out)
    );

    maxFinder #(
        .numInput(`numNeuronLayer3),
        .inputWidth(`dataWidth)
    ) hMax (
        .i_clk(s_axi_aclk),
        .i_data(x3_out),
        .i_valid(o3_valid),
        .o_data(max_data),
        .o_data_valid(out_valid)
    );

    always @(posedge s_axi_aclk or posedge reset) begin
        if (reset) begin
            lcd_index <= 0;
            lcd_buffer <= 0;
            stop_write <= 0;
            skip_first_output <= 0;  
        end else if (o3_valid && !stop_write) begin
            if (!skip_first_output) begin
                skip_first_output <= 1;  
            end else begin
                lcd_buffer[lcd_index*4 +: 4] <= max_data;
                lcd_index <= lcd_index + 1;
                if (lcd_index == 31) begin  
                    stop_write <= 1;
                end
            end
        end
    end

endmodule
