library verilog;
use verilog.vl_types.all;
entity neuron is
    generic(
        layerNo         : integer := 0;
        neuronNo        : integer := 0;
        numWeight       : integer := 64;
        dataWidth       : integer := 8;
        sigmoidSize     : integer := 5;
        weightIntWidth  : integer := 1;
        biasFile        : string  := "";
        weightFile      : string  := ""
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        myinput         : in     vl_logic_vector;
        myinputValid    : in     vl_logic;
        weightValid     : in     vl_logic;
        biasValid       : in     vl_logic;
        weightValue     : in     vl_logic_vector(15 downto 0);
        biasValue       : in     vl_logic_vector(31 downto 0);
        config_layer_num: in     vl_logic_vector(31 downto 0);
        config_neuron_num: in     vl_logic_vector(31 downto 0);
        \out\           : out    vl_logic_vector;
        outvalid        : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of layerNo : constant is 1;
    attribute mti_svvh_generic_type of neuronNo : constant is 1;
    attribute mti_svvh_generic_type of numWeight : constant is 1;
    attribute mti_svvh_generic_type of dataWidth : constant is 1;
    attribute mti_svvh_generic_type of sigmoidSize : constant is 1;
    attribute mti_svvh_generic_type of weightIntWidth : constant is 1;
    attribute mti_svvh_generic_type of biasFile : constant is 1;
    attribute mti_svvh_generic_type of weightFile : constant is 1;
end neuron;
