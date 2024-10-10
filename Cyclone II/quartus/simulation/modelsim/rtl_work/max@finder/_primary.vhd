library verilog;
use verilog.vl_types.all;
entity maxFinder is
    generic(
        numInput        : integer := 10;
        inputWidth      : integer := 16
    );
    port(
        i_clk           : in     vl_logic;
        i_data          : in     vl_logic_vector;
        i_valid         : in     vl_logic;
        o_data          : out    vl_logic_vector(3 downto 0);
        o_data_valid    : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of numInput : constant is 1;
    attribute mti_svvh_generic_type of inputWidth : constant is 1;
end maxFinder;
