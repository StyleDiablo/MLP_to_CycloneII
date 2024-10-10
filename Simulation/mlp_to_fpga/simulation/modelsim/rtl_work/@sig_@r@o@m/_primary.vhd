library verilog;
use verilog.vl_types.all;
entity Sig_ROM is
    generic(
        inWidth         : integer := 10;
        dataWidth       : integer := 16
    );
    port(
        clk             : in     vl_logic;
        x               : in     vl_logic_vector;
        \out\           : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of inWidth : constant is 1;
    attribute mti_svvh_generic_type of dataWidth : constant is 1;
end Sig_ROM;
