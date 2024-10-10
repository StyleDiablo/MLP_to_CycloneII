library verilog;
use verilog.vl_types.all;
entity cyMlp is
    generic(
        C_S_AXI_DATA_WIDTH: integer := 32;
        C_S_AXI_ADDR_WIDTH: integer := 5
    );
    port(
        s_axi_aclk      : in     vl_logic;
        s_axi_aresetn   : in     vl_logic;
        axis_in_data    : in     vl_logic_vector(15 downto 0);
        axis_in_data_valid: in     vl_logic;
        axis_in_data_ready: out    vl_logic;
        s_axi_awaddr    : in     vl_logic_vector;
        s_axi_awprot    : in     vl_logic_vector(2 downto 0);
        s_axi_awvalid   : in     vl_logic;
        s_axi_awready   : out    vl_logic;
        s_axi_wdata     : in     vl_logic_vector;
        s_axi_wstrb     : in     vl_logic_vector;
        s_axi_wvalid    : in     vl_logic;
        s_axi_wready    : out    vl_logic;
        s_axi_bresp     : out    vl_logic_vector(1 downto 0);
        s_axi_bvalid    : out    vl_logic;
        s_axi_bready    : in     vl_logic;
        s_axi_araddr    : in     vl_logic_vector;
        s_axi_arprot    : in     vl_logic_vector(2 downto 0);
        s_axi_arvalid   : in     vl_logic;
        s_axi_arready   : out    vl_logic;
        s_axi_rdata     : out    vl_logic_vector;
        s_axi_rresp     : out    vl_logic_vector(1 downto 0);
        s_axi_rvalid    : out    vl_logic;
        s_axi_rready    : in     vl_logic;
        intr            : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of C_S_AXI_DATA_WIDTH : constant is 2;
    attribute mti_svvh_generic_type of C_S_AXI_ADDR_WIDTH : constant is 2;
end cyMlp;
