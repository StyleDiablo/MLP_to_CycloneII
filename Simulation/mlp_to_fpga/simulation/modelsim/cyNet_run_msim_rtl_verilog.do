transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/Ohmen/Desktop/Desktop/School/Thesis/rtl {C:/Users/Ohmen/Desktop/Desktop/School/Thesis/rtl/maxFinder.v}
vlog -vlog01compat -work work +incdir+C:/Users/Ohmen/Desktop/Desktop/School/Thesis/rtl {C:/Users/Ohmen/Desktop/Desktop/School/Thesis/rtl/Layer_3.v}
vlog -vlog01compat -work work +incdir+C:/Users/Ohmen/Desktop/Desktop/School/Thesis/rtl {C:/Users/Ohmen/Desktop/Desktop/School/Thesis/rtl/Layer_2.v}
vlog -vlog01compat -work work +incdir+C:/Users/Ohmen/Desktop/Desktop/School/Thesis/rtl {C:/Users/Ohmen/Desktop/Desktop/School/Thesis/rtl/Layer_1.v}
vlog -vlog01compat -work work +incdir+C:/Users/Ohmen/Desktop/Desktop/School/Thesis/rtl {C:/Users/Ohmen/Desktop/Desktop/School/Thesis/rtl/include.v}
vlog -vlog01compat -work work +incdir+C:/Users/Ohmen/Desktop/Desktop/School/Thesis/rtl {C:/Users/Ohmen/Desktop/Desktop/School/Thesis/rtl/axi_lite_wrapper.v}
vlog -vlog01compat -work work +incdir+C:/Users/Ohmen/Desktop/Desktop/School/Thesis/rtl {C:/Users/Ohmen/Desktop/Desktop/School/Thesis/rtl/Weight_Memory.v}
vlog -vlog01compat -work work +incdir+C:/Users/Ohmen/Desktop/Desktop/School/Thesis/rtl {C:/Users/Ohmen/Desktop/Desktop/School/Thesis/rtl/Sig_ROM.v}
vlog -vlog01compat -work work +incdir+C:/Users/Ohmen/Desktop/Desktop/School/Thesis/rtl {C:/Users/Ohmen/Desktop/Desktop/School/Thesis/rtl/neuron.v}
vlog -vlog01compat -work work +incdir+C:/Users/Ohmen/Desktop/Desktop/School/Thesis/rtl {C:/Users/Ohmen/Desktop/Desktop/School/Thesis/rtl/cyMlp.v}

vlog -vlog01compat -work work +incdir+C:/Users/Ohmen/Desktop/Desktop/School/Thesis/mlp_to_fpga/../test-benches {C:/Users/Ohmen/Desktop/Desktop/School/Thesis/mlp_to_fpga/../test-benches/top_sim.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneii_ver -L rtl_work -L work -voptargs="+acc"  top_sim

add wave *
view structure
view signals
run -all
