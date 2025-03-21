# npc的设备和输入输出

## NPC中的输入输出
- RTL: RISC-V的输入输出是通过MMIO实现的，当前通过DPI-C机制直接访问设备，真正的硬件MMIO通过总线来访问设备
- 设备模型: 这里不直接采用NEMU的设备模型, 而是为NPC在仿真环境中实现一套与将来流片SoC相近的设备模型. 实现总线后, 我们再来基于总线实现RTL版本的设备
- 客户程序代码: AM中IOE抽象的作用就体现出来了: NEMU和NPC的设备地址和设备模型都有所不同, 但经过抽象之后, AM上的所有程序都不必为不同的运行环境编写不同的代码

## 在NPC中运行超级玛丽
在RV32E的NPC上运行超级玛丽需要实现串口和时钟

### 在NPC仿真环境中实现串口的输出功能, 并运行hello程序
- 在`$AM_HOME/am/src/riscv/npc/trm.c`中完成`putch()`函数，当调用时对`SERIAL_PORT`进行写1字节操作 (需要定义函数和地址宏)
- 在DPI-C中的`pmem_write()`中增加地址判断，写端口地址时直接`putchar()`对应地址内容


### 在NPC仿真环境中实现时钟
- 使用`<time.h>`提供的`clock_gettime()`函数获取时间
- 在`$AM_HOME/am/src/riscv/npc/timer.c`中实现`__am_timer_uptime()`读时间寄存器, 运行am-tests的real-time clock test测试 (使用 `clock_gettime(CLOCK_THREAD_CPUTIME_ID, &ts)` 防止溢出)

### 运行字符版本的红白机模拟器
注释掉HAS_GUI能打开但是性能惨不忍睹：（