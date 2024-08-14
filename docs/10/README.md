# nemu的设备和输入输出
输入输出是计算机与外界交互的基本手段, 已经在nemu上实现TRM了, 下一步是让它支持输入输出(完成pa2阶段3)

## 设备与CPU
在真实的计算机中, 输入输出都是通过访问I/O设备来完成的, 在程序看来, 访问设备 = 读出数据 + 写入数据 + 控制状态. 

CPU除了进行计算之外, 还需要访问设备, 一种最简单的方法就是把设备的寄存器作为接口, 让CPU来访问这些寄存器, 常用的I/O编址方式:

- 端口映射I/O(port-mapped I/O): CPU使用专门的I/O指令对设备进行访问, 并把设备的地址称作端口号. 有了端口号以后, 在I/O指令中给出端口号, 就知道要访问哪一个设备寄存器了. 但是 端口映射I/O所能访问的I/O地址空间的大小, 在设计I/O指令的那一刻就已经决定下来了
- 内存映射I/O(memory-mapped I/O, MMIO): 通过不同的物理内存地址给设备编址. 这种编址方式将一部分物理内存的访问"重定向"到I/O地址空间中, CPU尝试访问这部分物理内存的时候, 实际上最终是访问了相应的I/O设备. 这样CPU就可以通过普通的访存指令来访问设备

## 理解volatile关键字
编写 [test_volatile.c](./volatile/test_volatile.c) 和去掉volatile关键词的 [test.c](./volatile/test.c)，分别使用`-O2`编译并查看反汇编:

```sh
(base) xinchen@sakura:~/ysyx/docs/10/volatile$ riscv64-linux-gnu-gcc -c -march=rv32g -mabi=ilp32 -O2 test.c
(base) xinchen@sakura:~/ysyx/docs/10/volatile$ riscv64-linux-gnu-objdump -d test.o > test.asm
(base) xinchen@sakura:~/ysyx/docs/10/volatile$ riscv64-linux-gnu-gcc -c -march=rv32g -mabi=ilp32 -O2 test_volatile.c
(base) xinchen@sakura:~/ysyx/docs/10/volatile$ riscv64-linux-gnu-objdump -d test_volatile.o > test_volatile.asm
(base) xinchen@sakura:~/ysyx/docs/10/volatile$ rm test.o
(base) xinchen@sakura:~/ysyx/docs/10/volatile$ rm test_volatile.o
```

通过使用volatile关键字，告诉编译器不要对指针p所指向的地址进行优化，保证每次访问都从内存中读取或写入值，确保与设备寄存器的正确交互

## 状态机视角下的输入输出

```
状态机模型            |           状态机模型之外
S = <R, M>          |        D
计算机/程序  <----I/O指令----> 设备 <----模拟电路----> 物理世界
                    |
                    |
```

要对设备的状态和行为进行建模是一件很困难的事情, 除了设备本身的行为五花八门之外, 设备的状态还时时刻刻受到物理世界的影响. 于是, 我们在对状态机模型的行为进行扩展的时候, 并不考虑将D加入到S中, 而是仅仅对输入输出相关指令的行为进行建模

- 执行普通指令时, 状态机按照TRM的模型进行状态转移
- 执行设备输出相关的指令(如x86的out指令或者RISC架构的MMIO写指令)时, 状态机除了更新PC之外, 其它状态均保持不变, 但设备的状态和物理世界则会发生相应的变化
- 执行设备输入相关的指令(如x86的in指令或者RISC架构的MMIO读指令)时, 状态机的转移将会"分叉": 状态机不再像TRM那样有唯一的新状态了, 状态机具体会转移到哪一个新状态, 将取决于执行这条指令时设备的状态

这个扩展之后的状态机模型从微观的角度告诉我们, 设备的输入输出都是通过CPU的寄存器来进行数据交互的

当然也有通过内存进行数据交互的输入输出: DMA

## nemu中的输入输出
NEMU的框架代码已经在nemu/src/device/目录下提供了设备相关的代码

### I/O映射模拟方式

框架代码为映射定义了一个结构体类型IOMap(在`nemu/include/device/map.h`中), 包括名字, 映射的起始地址和结束地址, 映射的目标空间, 以及一个回调函数. 然后在`nemu/src/device/io/map.c`实现了映射的管理, 包括I/O空间的分配及其映射, 还有映射的访问接口.

其中`map_read()`和`map_write()`用于将地址addr映射到map所指示的目标空间, 并进行访问. 访问时, 可能会触发相应的回调函数, 对设备和目标空间的状态进行更新. 由于NEMU是单线程程序, 因此只能串行模拟整个计算机系统的工作, 每次进行I/O读写的时候, 才会调用设备提供的回调函数(callback). 基于这两个API, 可以很容易实现端口映射I/O和内存映射I/O的模拟

具体的, `paddr_read()`和`paddr_write()`会判断地址addr落在物理内存空间还是设备空间, 若落在物理内存空间, 就会通过`pmem_read()`和`pmem_write()`来访问真正的物理内存; 否则就通过`map_read()`和`map_write()`来访问相应的设备. 从这个角度来看, 内存和外设在CPU来看并没有什么不同, 只不过都是一个字节编址的对象而已.

### 设备
NEMU实现了串口, 时钟, 键盘, VGA, 声卡, 磁盘, SD卡七种设备，都不可编程，需要在menuconfig开启设备