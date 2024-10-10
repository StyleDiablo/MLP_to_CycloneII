library verilog;
use verilog.vl_types.all;
entity input_ROM is
    generic(
        numImages       : integer := 1797;
        imageSize       : integer := 65;
        addressWidth    : integer := 17;
        dataWidth       : integer := 16;
        imageFile       : string  := "images.mif"
    );
    port(
        clk             : in     vl_logic;
        ren             : in     vl_logic;
        radd            : in     vl_logic_vector;
        data            : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of numImages : constant is 1;
    attribute mti_svvh_generic_type of imageSize : constant is 1;
    attribute mti_svvh_generic_type of addressWidth : constant is 1;
    attribute mti_svvh_generic_type of dataWidth : constant is 1;
    attribute mti_svvh_generic_type of imageFile : constant is 1;
end input_ROM;
