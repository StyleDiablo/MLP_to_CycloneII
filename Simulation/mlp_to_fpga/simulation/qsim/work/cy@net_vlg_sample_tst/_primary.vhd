library verilog;
use verilog.vl_types.all;
entity cyNet_vlg_sample_tst is
    port(
        axis_in_data    : in     vl_logic_vector(31 downto 0);
        axis_in_data_valid: in     vl_logic;
        s_axi_aclk      : in     vl_logic;
        s_axi_araddr    : in     vl_logic_vector(4 downto 0);
        s_axi_aresetn   : in     vl_logic;
        s_axi_arprot    : in     vl_logic_vector(2 downto 0);
        s_axi_arvalid   : in     vl_logic;
        s_axi_awaddr    : in     vl_logic_vector(4 downto 0);
        s_axi_awprot    : in     vl_logic_vector(2 downto 0);
        s_axi_awvalid   : in     vl_logic;
        s_axi_bready    : in     vl_logic;
        s_axi_rready    : in     vl_logic;
        s_axi_wdata     : in     vl_logic_vector(31 downto 0);
        s_axi_wstrb     : in     vl_logic_vector(3 downto 0);
        s_axi_wvalid    : in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end cyNet_vlg_sample_tst;
