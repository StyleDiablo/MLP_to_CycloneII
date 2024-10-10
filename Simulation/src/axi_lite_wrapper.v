`timescale 1 ns / 1 ps

	module axi_lite_wrapper #
	(
		
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		parameter integer C_S_AXI_ADDR_WIDTH	= 5
	)
	(
		
		input wire  S_AXI_ACLK,
		input wire  S_AXI_ARESETN,
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		input wire [2 : 0] S_AXI_AWPROT,

		input wire  S_AXI_AWVALID,
		output wire  S_AXI_AWREADY,
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
   
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,

		input wire  S_AXI_WVALID,

		output wire  S_AXI_WREADY,

		output wire [1 : 0] S_AXI_BRESP,

		output wire  S_AXI_BVALID,

		input wire  S_AXI_BREADY,
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,

		input wire [2 : 0] S_AXI_ARPROT,

		input wire  S_AXI_ARVALID,

		output wire  S_AXI_ARREADY,
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,

		output wire [1 : 0] S_AXI_RRESP,

		output wire  S_AXI_RVALID,

		input wire  S_AXI_RREADY,
        output wire     [31:0]  layerNumber,
        output wire     [31:0]  neuronNumber,
        output reg              weightValid,
        output reg              biasValid,
        output          [31:0]  weightValue,
        output          [31:0]  biasValue,
        input           [31:0]  nnOut,
        input                   nnOut_valid,
        output reg              axi_rd_en,
        input           [31:0]  axi_rd_data,
        output                  softReset
	);

	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awready;
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;
	reg  	axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arready;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rvalid;


	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
	localparam integer OPT_MEM_ADDR_BITS = 2;

	reg [C_S_AXI_DATA_WIDTH-1:0]	weightReg;
	reg [C_S_AXI_DATA_WIDTH-1:0]	biasReg;
	reg [C_S_AXI_DATA_WIDTH-1:0]	outputReg;
	reg [C_S_AXI_DATA_WIDTH-1:0]	layerReg;
	reg [C_S_AXI_DATA_WIDTH-1:0]	neuronReg;
	reg [C_S_AXI_DATA_WIDTH-1:0]	statReg;
	reg [C_S_AXI_DATA_WIDTH-1:0]	controlReg;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg7;
    
	wire	 slv_reg_rden;
	wire	 slv_reg_wren;
	reg [C_S_AXI_DATA_WIDTH-1:0]	 reg_data_out;
	integer	 byte_index;
	reg	 aw_en;


	assign S_AXI_AWREADY	= axi_awready;
	assign S_AXI_WREADY	= axi_wready;
	assign S_AXI_BRESP	= axi_bresp;
	assign S_AXI_BVALID	= axi_bvalid;
	assign S_AXI_ARREADY	= axi_arready;
	assign S_AXI_RDATA	= axi_rdata;
	assign S_AXI_RRESP	= axi_rresp;
	assign S_AXI_RVALID	= axi_rvalid;

    
    assign layerNumber = layerReg;
    assign neuronNumber = neuronReg;
    assign weightValue = weightReg;
    assign biasValue = biasReg;
    assign softReset = controlReg[0];

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awready <= 1'b0;
	      aw_en <= 1'b1;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
	        begin

	          axi_awready <= 1'b1;
	          aw_en <= 1'b0;
	        end
	        else if (S_AXI_BREADY && axi_bvalid)
	            begin
	              aw_en <= 1'b1;
	              axi_awready <= 1'b0;
	            end
	      else           
	        begin
	          axi_awready <= 1'b0;
	        end
	    end 
	end       


	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awaddr <= 0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
	        begin
	          axi_awaddr <= S_AXI_AWADDR;
	        end
	    end 
	end       

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_wready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en )
	        begin
	          axi_wready <= 1'b1;
	        end
	      else
	        begin
	          axi_wready <= 1'b0;
	        end
	    end 
	end       


	assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

	always @( posedge S_AXI_ACLK )
	begin
	if ( S_AXI_ARESETN == 1'b0 )
		begin
		weightReg <= 0;
		biasReg <= 0;
		layerReg <= 0;
		neuronReg <= 0;
		slv_reg7 <= 0;
		weightValid <= 1'b0;
		biasValid <= 1'b0;
		controlReg <= 0;
		end 
	else begin
		weightValid <= 1'b0;
		biasValid <= 1'b0;
		if (slv_reg_wren)
		begin
			case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
			3'h0:begin
					weightReg <= S_AXI_WDATA;
					weightValid <= 1'b1;
			end
			3'h1:begin
					biasReg <= S_AXI_WDATA; 
					biasValid <= 1'b1;
			end
			3'h3:
					layerReg <= S_AXI_WDATA;
			3'h4:
					neuronReg <= S_AXI_WDATA;
			3'h7:
					controlReg <= S_AXI_WDATA;
			endcase
		end
	end
	end    
    
    always @(posedge S_AXI_ACLK)
    begin
        if ( S_AXI_ARESETN == 1'b0 )
            outputReg <= 0;
        else if(nnOut_valid)
            outputReg <= nnOut;
    end

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_bvalid  <= 0;
	      axi_bresp   <= 2'b0;
	    end 
	  else
	    begin    
	      if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
	        begin
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0; 
	        end                   
	      else
	        begin
	          if (S_AXI_BREADY && axi_bvalid)    
	            begin
	              axi_bvalid <= 1'b0; 
	            end  
	        end
	    end
	end   


	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_arready <= 1'b0;
	      axi_araddr  <= 5'b0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID)
	        begin
	          axi_arready <= 1'b1;
	          axi_araddr  <= S_AXI_ARADDR;
	        end
	      else
	        begin
	          axi_arready <= 1'b0;
	        end
	    end 
	end       

 
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	    end 
	  else
	    begin    
	      if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
	        begin
	          axi_rvalid <= 1'b1;
	          axi_rresp  <= 2'b0; 
	        end   
	      else if (axi_rvalid && S_AXI_RREADY)
	        begin
	          axi_rvalid <= 1'b0;
	        end                
	    end
	end    


	assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
	always @(*)
	begin
	      case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	        3'h0   : reg_data_out <= weightReg;
	        3'h1   : reg_data_out <= biasReg;
	        3'h2   : reg_data_out <= outputReg;
	        3'h3   : reg_data_out <= layerReg;
	        3'h4   : reg_data_out <= neuronReg;
	        3'h5   : reg_data_out <= axi_rd_data;
	        3'h6   : reg_data_out <= statReg;
	        3'h7   : reg_data_out <= controlReg;
	        default : reg_data_out <= 0;
	      endcase
	end
	
	
	always @(posedge S_AXI_ACLK)
	begin
	   if ( S_AXI_ARESETN == 1'b0 )
           statReg <= 1'b0;
	   else if(nnOut_valid)
	       statReg <= 1'b1;
	   else if(axi_rvalid & S_AXI_RREADY & axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]==3'h6)//read clear status reg
	       statReg <= 1'b0;
	end
	
	always @(posedge S_AXI_ACLK)
    begin
       if(!axi_rd_en & axi_rvalid & S_AXI_RREADY & axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]==3'h5)
       begin
           axi_rd_en <= 1'b1;
       end
       else
           axi_rd_en <= 1'b0;
    end

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rdata  <= 0;
	    end 
	  else
	    begin    

	      if (slv_reg_rden)
	        begin
	          axi_rdata <= reg_data_out;    
	        end   
	    end
	end    

endmodule
