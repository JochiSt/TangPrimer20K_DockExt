
PROJECT=SimpleBlinking
CONSTRAINT=../../const/sipeed_tang_primer_20k.cst

FPGA_FAMILY=GW2A-18
FPGA_DEVICE=GW2A-LV18PG256C8/I7

TOP_MODULE=SimpleBlinking

OBJECT_FILES=SimpleBlinking.o

#GHDL_OPTIONS+=--latches
GHDL_OPTIONS+=-fsynopsys

###############################################################################

.PHONY: all prog clean total_clean postsim sim

.SECONDARY: $(PROJECT).fs $(PROJECT)_tb $(PROJECT)_tb.vcd

all: $(PROJECT).fs

# Program FPGA
prog: $(PROJECT).fs
	openFPGALoader -b tangprimer20k $<

###############################################################################
# CLEANING
clean:
	rm -f *.o *.cf

total_clean: clean
	rm -f $(PROJECT).{asc,bin,rpt,json}
	rm -f *.vcd *.fst
	rm -f *.svg

###############################################################################
# Synthesis

$(PROJECT)_design.json: $(OBJECT_FILES)
	yosys -m ghdl -p 'ghdl $(GHDL_OPTIONS) $(TOP_MODULE); synth_gowin -json $@'

# Place and Route
$(PROJECT).json: $(PROJECT)_design.json $(CONSTRAINT)
	nextpnr-himbaechel --json $(PROJECT)_design.json\
						--write $@ \
						--device $(FPGA_DEVICE) \
						--vopt family=$(FPGA_FAMILY) \
						--vopt cst=$(CONSTRAINT)

$(PROJECT).fs: $(PROJECT).json
	gowin_pack --device $(FPGA_DEVICE) $< --output $@

###############################################################################

sim: $(PROJECT)_tb.vcd

simview: $(PROJECT)_tb.vcd
	# alternative:
	# gtkwave --optimize $<
	gtkwave -g $<

#%_tb: %_tb.v %.v
#	iverilog -o $@ $^
#
#%_tb.vcd: %_tb
#	vvp -N $< +vcd=$@

%_tb.cpp: $(OBJECT_FILES)
	yosys -m ghdl -p " \
			ghdl $(GHDL_OPTIONS) $(TOP_MODULE); \
			hierarchy -check -top $(TOP_MODULE); \
			write_cxxrtl -header $@"
	sed -i '1s/^/#include <iostream>\n/' $@

%_tb: %_tb.cpp %_tb_main.cpp
	clang++ -g -O3 -I`yosys-config --datdir`/include/backends/cxxrtl/runtime/ -std=c++14 $^ -o $@

%_tb.vcd: %_tb
	./$< $@

# POST synthesis simulation
# inspired and adapted
# 		from https://github.com/YosysHQ/icestorm/blob/master/examples/icestick/
postsim: $(PROJECT)_syntb.vcd

# create VERILOG file from synthesized JSON design file
%_syn.v: %.json
	yosys -p 'read_json $^; write_verilog $@'
# create syntb using iverilog
%_syntb: %_tb.v %_syn.v
	iverilog -g2012 -o $@ $^ `yosys-config --datdir/ice40/cells_sim.v`
# simulate the design
%_syntb.vcd: %_syntb
	vvp -v -n $< +vcd=$@

###############################################################################
# 'compile' VHDL files

%.o: %.vhdl
	ghdl -a $(GHDL_OPTIONS) $<

