all:
	vlib work
	vlog uvm_colors.sv
	vlog example.sv
	vsim -c top -do "run 1; quit -f"

clean:
	rm -rf work vsim.wlf transcript

debug:
	vsim -novopt top