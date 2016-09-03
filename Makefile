# Version: GHDL 0.34dev (20151126) [Dunoon edition] - GCC back-end code generator

SIMFILE=vhdl/sim/sim_top_tb.vcd
GHDL=ghdl
GHDLFLAGS= --workdir=vhdl/work --work=unisim --ieee=synopsys -fexplicit
GHDLRUNFLAGS= --stop-time=20000ns --vcd=$(SIMFILE)
GTKWAVE=gtkwave

# Default target
all: build

# Preparation target
vhdl/work:
	mkdir -p vhdl/work

# Unisim target
unisim:
	$(GHDL) -i --workdir=vhdl/work --work=unisim vhdl/dependencies/unisims/*.vhd
	$(GHDL) -i --workdir=vhdl/work --work=unisim vhdl/dependencies/unisims/primitive/*.vhd

# Elaboration target
build: vhdl/work/epu_pack.o vhdl/work/top.o vhdl/work/freq_divider.o vhdl/work/core.o vhdl/work/memory_control.o vhdl/work/alu.o vhdl/work/control_unit.o vhdl/work/decoder.o vhdl/work/regfile.o vhdl/work/pc_unit.o vhdl/work/stack.o vhdl/work/ram_block.o vhdl/work/top_tb.o
	$(GHDL) -m $(GHDLFLAGS) top_tb
	rm -f e~*
	mv top_tb vhdl/sim/top_tb 2> /dev/null || true

# Run target
run: build
	./vhdl/sim/top_tb $(GHDLRUNFLAGS)

# Simulate target
sim: run
	$(GTKWAVE) $(SIMFILE) &

# Targets to analyze files
vhdl/work/epu_pack.o: vhdl/core/epu_pack.vhdl vhdl/work
	$(GHDL) -a $(GHDLFLAGS) $<
vhdl/work/top.o: vhdl/top/top.vhdl vhdl/work
	$(GHDL) -a $(GHDLFLAGS) $<
vhdl/work/freq_divider.o: vhdl/top/freq_divider.vhdl vhdl/work
	$(GHDL) -a $(GHDLFLAGS) $<
vhdl/work/core.o: vhdl/core/core.vhdl vhdl/work
	$(GHDL) -a $(GHDLFLAGS) $<
vhdl/work/memory_control.o: vhdl/mem/memory_control.vhdl vhdl/work
	$(GHDL) -a $(GHDLFLAGS) $<
vhdl/work/alu.o: vhdl/core/alu.vhdl vhdl/work
	$(GHDL) -a $(GHDLFLAGS) $<
vhdl/work/control_unit.o: vhdl/core/control_unit.vhdl vhdl/work
	$(GHDL) -a $(GHDLFLAGS) $<
vhdl/work/decoder.o: vhdl/core/decoder.vhdl vhdl/work
	$(GHDL) -a $(GHDLFLAGS) $<
vhdl/work/regfile.o: vhdl/core/regfile.vhdl vhdl/work
	$(GHDL) -a $(GHDLFLAGS) $<
vhdl/work/pc_unit.o: vhdl/core/pc_unit.vhdl vhdl/work
	$(GHDL) -a $(GHDLFLAGS) $<
vhdl/work/stack.o: vhdl/core/stack.vhdl vhdl/work
	$(GHDL) -a $(GHDLFLAGS) $<
vhdl/work/ram_block.o: vhdl/mem/ram_block.vhdl vhdl/work unisim
	$(GHDL) -a $(GHDLFLAGS) $<
vhdl/work/top_tb.o: vhdl/sim/top_tb.vhdl vhdl/work
	$(GHDL) -a $(GHDLFLAGS) $<

# Files dependences
vhdl/work/top.o: vhdl/work/epu_pack.o
vhdl/work/top.o: vhdl/work/epu_pack.o
vhdl/work/core.o: vhdl/work/epu_pack.o
vhdl/work/memory_control.o: vhdl/work/epu_pack.o
vhdl/work/alu.o: vhdl/work/epu_pack.o
vhdl/work/control_unit.o: vhdl/work/epu_pack.o
vhdl/work/decoder.o: vhdl/work/epu_pack.o
vhdl/work/regfile.o: vhdl/work/epu_pack.o
vhdl/work/pc_unit.o: vhdl/work/epu_pack.o
vhdl/work/stack.o: vhdl/work/epu_pack.o
vhdl/work/ram_block.o: vhdl/work/epu_pack.o
vhdl/work/top_tb.o: vhdl/work/epu_pack.o
