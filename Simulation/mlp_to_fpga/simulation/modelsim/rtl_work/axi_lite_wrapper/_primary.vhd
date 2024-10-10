library verilog;
use verilog.vl_types.all;
entity axi_lite_wrapper is
    generic(
        C_S_AXI_DATA_WIDTH: integer := 32;
        C_S_AXI_ADDR_WIDTH: integer := 5
    );
    port(
        S_AXI_ACLK      : in     vl_logic;
        S_AXI_ARESETN   : in     vl_logic;
        S_AXI_AWADDR    : in     vl_logic_vector;
        S_AXI_AWPROT    : in     vl_logic_vector(2 downto 0);
        S_AXI_AWVALID   : in     vl_logic;
        S_AXI_AWREADY   : out    vl_logic;
        S_AXI_WDATA     : in     vl_logic_vector;
        S_AXI_WSTRB     : in     vl_logic_vector;
        S_AXI_WVALID    : in     vl_logic;
        S_AXI_WREADY    : out    vl_logic;
        S_AXI_BRESP     : out    vl_logic_vector(1 downto 0);
        S_AXI_BVALID    : out    vl_logic;
        S_AXI_BREADY    : in     vl_logic;
        S_AXI_ARADDR    : in     vl_logic_vector;
        S_AXI_ARPROT    : in     vl_logic_vector(2 downto 0);
        S_AXI_ARVALID   : in     vl_logic;
        S_AXI_ARREADY   : out    vl_logic;
        S_AXI_RDATA     : out    vl_logic_vector;
        S_AXI_RRESP     : out    vl_logic_vector(1 downto 0);
        S_AXI_RVALID    : out    vl_logic;
        S_AXI_RREADY    : in     vl_logic;
        layerNumber     : out    vl_logic_vector(31 downto 0);
        neuronNumber    : out    vl_logic_vector(31 downto 0);
        weightValid     : out    vl_logic;
        biasValid       : out    vl_logic;
        weightValue     : out    vl_logic_vector(31 downto 0);
        biasValue       : out    vl_logic_vector(31 downto 0);
        nnOut           : in     vl_logic_vector(31 downto 0);
        nnOut_valid     : in     vl_logic;
        axi_rd_en       : out    vl_logic;
        axi_rd_data     : in     vl_logic_vector(31 downto 0);
        softReset       : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of C_S_AXI_DATA_WIDTH : constant is 2;
    attribute mti_svvh_generic_type of C_S_AXI_ADDR_WIDTH : constant is 2;
end axi_lite_wrapper;
