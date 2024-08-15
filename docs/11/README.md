# 支持RV32E的单周期NPC
- 采用RV32E指令集来设计npc (启动Linux使用RV64IMAC)
- RV32E的程序可以直接运行在RV32IM的处理器上, 因此可以把RV32IM的NEMU作为DiffTest的REF

## 搭建面向riscv32e-npc的运行时环境
AM项目已经提供了riscv32e-npc的基本框架, 只需要在 `am-kernels/tests/cpu-tests/` 目录下执行 `make ARCH=riscv32e-npc ALL=xxx` 即可将名为xxx的测试编译到riscv32e-npc的运行时环境中