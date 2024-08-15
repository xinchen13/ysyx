# 支持RV32E的单周期NPC
- 采用RV32E指令集来设计npc (启动Linux使用RV64IMAC)
- RV32E的程序可以直接运行在RV32IM的处理器上, 因此可以把RV32IM的NEMU作为DiffTest的REF