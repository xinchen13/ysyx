TOPNAME = xcore
NPC_BUILD_DIR = ./build
$(shell mkdir -p $(NPC_BUILD_DIR))
OBJ_DIR = $(NPC_BUILD_DIR)/obj_dir
BIN = $(NPC_BUILD_DIR)/$(TOPNAME)

# project source
VSRCS = $(shell find $(abspath ./vsrc) -name "*.v" -or -name "*.sv")
CSRCS = $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cc" -or -name "*.cpp")
NPC_INC_PATH ?=

# rules for verilator
VERILATOR = verilator
# may increase the risk of reset bugs in trade for performance
VERILATOR_CFLAGS += -MMD --build -cc  \
	-O3 --x-assign fast --x-initial fast --noassert	
INCFLAGS = $(addprefix -I, $(NPC_INC_PATH))
CXXFLAGS += $(INCFLAGS) -DTOP_NAME="\"V$(TOPNAME)\""

$(BIN): $(VSRCS) $(CSRCS)
	@rm -rf $(OBJ_DIR)
	$(VERILATOR) $(VERILATOR_CFLAGS) \
		--top-module $(TOPNAME) $^ \
		$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN))

NPC_EXEC := $(BIN)

.PHONY: all sim wave clean


all:
	$(BIN)

sim: $(BIN)
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	$(NPC_EXEC)

wave: $(BIN)
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	$(NPC_EXEC)
	@gtkwave $(BUILD_DIR)/wave.vcd


clean:
	rm -rf $(NPC_BUILD_DIR)
	
include ../Makefile
