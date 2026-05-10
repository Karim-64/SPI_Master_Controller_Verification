vlib work
vlog -f src_files.list 
vsim -voptargs=+acc work.top

add wave /top/apbif/*
run -all

#quit -f