library verilog;
use verilog.vl_types.all;
entity Weight_Memory is
    generic(
        numWeight       : integer := 3;
        neuronNo        : integer := 5;
        layerNo         : integer := 1;
        addressWidth    : integer := 10;
        dataWidth       : integer := 16;
        weightFile      : string  := "w_1_15.mif"
    );
    port(
        clk             : in     vl_logic;
        wen             : in     vl_logic;
        ren             : in     vl_logic;
        wadd            : in     vl_logic_vector;
        radd            : in     vl_logic_vector;
        win             : in     vl_logic_vector;
        wout            : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of numWeight : constant is 1;
    attribute mti_svvh_generic_type of neuronNo : constant is 1;
    attribute mti_svvh_generic_type of layerNo : constant is 1;
    attribute mti_svvh_generic_type of addressWidth : constant is 1;
    attribute mti_svvh_generic_type of dataWidth : constant is 1;
    attribute mti_svvh_generic_type of weightFile : constant is 1;
end Weight_Memory;
