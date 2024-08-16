# 支持RV32E的单周期NPC
- 采用RV32E指令集来设计npc (启动Linux使用RV64IMAC)
- RV32E的程序可以直接运行在RV32IM的处理器上, 因此可以把RV32IM的NEMU作为DiffTest的REF

## 搭建面向riscv32e-npc的运行时环境
AM项目已经提供了riscv32e-npc的基本框架, 只需要在 `am-kernels/tests/cpu-tests/` 目录下执行 `make ARCH=riscv32e-npc ALL=xxx` 即可将名为xxx的测试编译到riscv32e-npc的运行时环境中

### 从命令行中读入NPC需要执行的程序
接下来将会在NPC中不断地运行各种程序, 如果每次运行新程序都要重新编译NPC, 效率是很低的. 为了提高效率, 可以让仿真环境从命令行中读入程序的路径, 然后把程序内容放置到存储器中

- 参考nemu的参数读入，使用`getopt()`来读取命令行提供的`IMG`参数
- IMG参数由Makefile通过`make sim IMG=--img=xxx`的方式指定, 与am在调用nemu时的传递程序路径的方法相同(具体rtfsc: `$AM_HOME/scripts/platform/nemu.mk`)
- 根据nemu的存储器重构了仿真环境的存储器
- 使用`make sim IMG=--img=./default/dummy-riscv32e-npc.bin`测试，成功读入

### 一键编译并在NPC上运行AM程序
在AM项目中, 为riscv32e-npc提供run目标, 使得键入`make ARCH=riscv32e-npc ALL=xxx run`即可把AM程序编译并在NPC上运行

- 参考`$AM_HOME/scripts/platform/nemu.mk`, 为`$AM_HOME/scripts/platform/npc.mk`添加run目标, 即可直接将am程序编译到npc上

