TOPNAME = soc_top

# dump dir/files
NPC_BUILD_DIR = ./build
$(shell mkdir -p $(NPC_BUILD_DIR))
OBJ_DIR = $(NPC_BUILD_DIR)/obj_dir
BIN = $(NPC_BUILD_DIR)/$(TOPNAME)
WAVE_FILE = $(NPC_BUILD_DIR)/wave.vcd

# argv
IMG ?= --img\=./default/dummy-riscv32e-npc.bin
LOG = --log\=$(NPC_BUILD_DIR)/npc.log
ELF ?= --elf\=./default/dummy-riscv32e-npc.elf
DIF ?= --diff\=$(NEMU_HOME)/build/riscv32-nemu-interpreter-so
WAV ?= --wave\=$(WAVE_FILE)

# project source: csrc, vsrc, include
VSRCS = $(shell find $(abspath ./vsrc) -name "*.v" -or -name "*.sv")
CSRCS = $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cc" -or -name "*.cpp")
NPC_INC_PATH ?= ./vsrc/inc
INCFLAGS = $(addprefix +incdir+, $(NPC_INC_PATH))

# rules for verilator
VERILATOR = verilator
VERILATOR_CFLAGS += -MMD --build -cc --trace \
	-O3 --x-assign fast --x-initial fast --noassert	\
	$(INCFLAGS)

# rules for gcc
LLVM_CXXFLAGS  = -I/usr/lib/llvm-14/include -std=c++14
LLVM_CXXFLAGS += -fno-exceptions -D_GNU_SOURCE 
LLVM_CXXFLAGS += -D__STDC_CONSTANT_MACROS -D__STDC_LIMIT_MACROS 
CXXFLAGS += -DTOP_NAME="\"V$(TOPNAME)\"" $(LLVM_CXXFLAGS) -fPIE
LDFLAGS ?= -lreadline $(shell llvm-config --libs)

$(BIN): $(VSRCS) $(CSRCS)
	@rm -rf $(OBJ_DIR)
	$(VERILATOR) $(VERILATOR_CFLAGS) \
		--top-module $(TOPNAME) $^ \
		$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN))

NPC_EXEC := $(BIN) $(IMG) $(LOG) $(ELF) $(DIF)

NPC_EXEC_WAVE := $(BIN) $(IMG) $(LOG) $(ELF) $(DIF) $(WAV)

.PHONY: all sim wave clean

all:
	$(BIN)

sim: $(BIN)
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	$(NPC_EXEC)

wave: $(BIN)
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	$(NPC_EXEC_WAVE)
	@gtkwave $(WAVE_FILE)


clean:
	rm -rf $(NPC_BUILD_DIR)

include ../Makefile
