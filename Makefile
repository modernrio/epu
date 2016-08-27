# Version: GHDL 0.34dev (20151126) [Dunoon edition] - GCC back-end code generator

SIMFILE=vhdl/sim/top/sim_top.vcd
GHDL=ghdl
GHDLFLAGS= --workdir=vhdl/work
GHDLRUNFLAGS= --stop-time=20000ns --vcd=$(SIMFILE)
GTKWAVE=gtkwave
GTKWAVE_VIEW=vhdl/sim/top/view.sav

# Default target
all: top

# Preparation target
vhdl/work:
	mkdir -p vhdl/work

# Elaboration target
top: vhdl/work/epu_pack.o vhdl/work/top.o vhdl/work/freq_divider.o vhdl/work/core.o vhdl/work/memory_control.o vhdl/work/alu.o vhdl/work/control_unit.o vhdl/work/decoder.o vhdl/work/regfile.o vhdl/work/pc_unit.o vhdl/work/stack.o vhdl/work/ram_sim.o
	$(GHDL) -m $(GHDLFLAGS) $@
	rm -f e~*
	mv top vhdl/sim/top 2> /dev/null || true

# Run target
run: top
	./vhdl/sim/top/top $(GHDLRUNFLAGS)

# Simulate target
sim: run
	$(GTKWAVE) $(SIMFILE) $(GTKWAVE_VIEW) &

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
vhdl/work/ram_sim.o: vhdl/mem/ram_sim.vhdl vhdl/work
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
vhdl/work/ram_sim.o: vhdl/work/epu_pack.o
