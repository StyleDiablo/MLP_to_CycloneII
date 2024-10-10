library verilog;
use verilog.vl_types.all;
entity cyNet_vlg_check_tst is
    port(
        axis_in_data_ready: in     vl_logic;
        intr            : in     vl_logic;
        s_axi_arready   : in     vl_logic;
        s_axi_awready   : in     vl_logic;
        s_axi_bresp     : in     vl_logic_vector(1 downto 0);
        s_axi_bvalid    : in     vl_logic;
        s_axi_rdata     : in     vl_logic_vector(31 downto 0);
        s_axi_rresp     : in     vl_logic_vector(1 downto 0);
        s_axi_rvalid    : in     vl_logic;
        s_axi_wready    : in     vl_logic;
        sampler_rx      : in     vl_logic
    );
end cyNet_vlg_check_tst;
