library verilog;
use verilog.vl_types.all;
entity cyMlp is
    port(
        s_axi_aclk      : in     vl_logic;
        s_axi_aresetn   : in     vl_logic;
        switches        : in     vl_logic_vector(7 downto 0);
        lcd_output      : out    vl_logic_vector(127 downto 0)
    );
end cyMlp;
