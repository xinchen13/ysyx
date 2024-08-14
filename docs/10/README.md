# nemu的设备和输入输出
输入输出是计算机与外界交互的基本手段, 已经在nemu上实现TRM了, 下一步是让它支持输入输出(完成pa2阶段3)

## 设备与CPU
在真实的计算机中, 输入输出都是通过访问I/O设备来完成的, 在程序看来, 访问设备 = 读出数据 + 写入数据 + 控制状态. 

CPU除了进行计算之外, 还需要访问设备, 一种最简单的方法就是把设备的寄存器作为接口, 让CPU来访问这些寄存器, 常用的I/O编址方式:

- 端口映射I/O(port-mapped I/O): CPU使用专门的I/O指令对设备进行访问, 并把设备的地址称作端口号. 有了端口号以后, 在I/O指令中给出端口号, 就知道要访问哪一个设备寄存器了. 但是 端口映射I/O所能访问的I/O地址空间的大小, 在设计I/O指令的那一刻就已经决定下来了
- 内存映射I/O(memory-mapped I/O, MMIO): 通过不同的物理内存地址给设备编址. 这种编址方式将一部分物理内存的访问"重定向"到I/O地址空间中, CPU尝试访问这部分物理内存的时候, 实际上最终是访问了相应的I/O设备. 这样CPU就可以通过普通的访存指令来访问设备

### 理解volatile关键字
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

