AM_SRCS := riscv/ysyxsoc/start.S \
           riscv/ysyxsoc/trm.c \
           riscv/ysyxsoc/ioe.c \
           riscv/ysyxsoc/timer.c \
		   riscv/ysyxsoc/gpu.c \
           riscv/ysyxsoc/input.c \
           riscv/ysyxsoc/cte.c \
           riscv/ysyxsoc/trap.S \
           platform/dummy/vme.c \
           platform/dummy/mpe.c

CFLAGS    += -fdata-sections -ffunction-sections

ifeq ($(NAME), rtthread)
LDFLAGS   += -T $(AM_HOME)/scripts/ysyxsoc_linker_rtt.ld \
                        --defsym=_entry_offset=0x0
else
LDFLAGS   += -T $(AM_HOME)/scripts/ysyxsoc_linker.ld \
                        --defsym=_entry_offset=0x0
endif
						
                         
LDFLAGS   += --gc-sections -e _start
CFLAGS += -DMAINARGS=\"$(mainargs)\"
.PHONY: $(AM_HOME)/am/src/riscv/ysyxsoc/trm.c

image: $(IMAGE).elf
	@$(OBJDUMP) -d $(IMAGE).elf > $(IMAGE).txt
	@echo + OBJCOPY "->" $(IMAGE_REL).bin
	@$(OBJCOPY) -S --set-section-flags .bss=alloc,contents -O binary $(IMAGE).elf $(IMAGE).bin

run: image
	$(MAKE) -C $(NPC_HOME) sim IMG=--img\=$(IMAGE).bin ELF=--elf\=$(IMAGE).elf

gdb: image
	$(MAKE) -C $(NPC_HOME) wave IMG=--img\=$(IMAGE).bin ELF=--elf\=$(IMAGE).elf
