onerror {quit -f}
vlib work
vlog -work work cyNet.vo
vlog -work work mlp_to_fpga.vt
vsim -novopt -c -t 1ps -L cycloneii_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.cyNet_vlg_vec_tst
vcd file -direction mlp_to_fpga.msim.vcd
vcd add -internal cyNet_vlg_vec_tst/*
vcd add -internal cyNet_vlg_vec_tst/i1/*
add wave /*
run -all
