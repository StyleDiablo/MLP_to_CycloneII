library verilog;
use verilog.vl_types.all;
entity Layer_3 is
    generic(
        NN              : integer := 30;
        numWeight       : integer := 784;
        dataWidth       : integer := 16;
        layerNum        : integer := 1;
        sigmoidSize     : integer := 10;
        weightIntWidth  : integer := 4
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        weightValid     : in     vl_logic;
        biasValid       : in     vl_logic;
        weightValue     : in     vl_logic_vector(31 downto 0);
        biasValue       : in     vl_logic_vector(31 downto 0);
        config_layer_num: in     vl_logic_vector(31 downto 0);
        config_neuron_num: in     vl_logic_vector(31 downto 0);
        x_valid         : in     vl_logic;
        x_in            : in     vl_logic_vector;
        o_valid         : out    vl_logic_vector;
        x_out           : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of NN : constant is 1;
    attribute mti_svvh_generic_type of numWeight : constant is 1;
    attribute mti_svvh_generic_type of dataWidth : constant is 1;
    attribute mti_svvh_generic_type of layerNum : constant is 1;
    attribute mti_svvh_generic_type of sigmoidSize : constant is 1;
    attribute mti_svvh_generic_type of weightIntWidth : constant is 1;
end Layer_3;
