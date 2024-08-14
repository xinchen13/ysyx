# Differential Testing
为了在工程实现中debug, 需要找到一种方法能够表达指令的正确行为: 找一台正确实现的计算机

DiffTest需要提供一个和DUT(Design Under Test, 测试对象) 功能相同但实现方式不同的REF(Reference, 参考实现), 然后让它们接受相同的有定义的输入, 观测它们的行为是否相同(作为状态机, 检查寄存器和内存即可)

## difftest API
nemu在dut和ref之间定义了如下的API:

```c
// 在DUT host memory的`buf`和REF guest memory的`addr`之间拷贝`n`字节,
// `direction`指定拷贝的方向, `DIFFTEST_TO_DUT`表示往DUT拷贝, `DIFFTEST_TO_REF`表示往REF拷贝
void difftest_memcpy(paddr_t addr, void *buf, size_t n, bool direction);
// `direction`为`DIFFTEST_TO_DUT`时, 获取REF的寄存器状态到`dut`;
// `direction`为`DIFFTEST_TO_REF`时, 设置REF的寄存器状态为`dut`;
void difftest_regcpy(void *dut, bool direction);
// 让REF执行`n`条指令
void difftest_exec(uint64_t n);
// 初始化REF的DiffTest功能
void difftest_init();
```

其中寄存器状态dut要求寄存器的成员按照某种顺序排列, 若未按要求顺序排列, `difftest_regcpy()`的行为是未定义的. REF需要实现这些API, DUT会使用这些API来进行DiffTest. 在这里, DUT和REF分别是NEMU和其它模拟器

NEMU的框架代码已经准备好DiffTest的功能了, 在menuconfig中可以打开相应的选项

riscv32对应的ref为Spike. Spike是RISC-V社区的一款全系统模拟器, 它的工作原理与NEMU非常类似. 已经在Spike中增加了少量接口来实现DiffTest的API. 为了运行Spike, 还需要安装device-tree-compiler: `sudo apt-get install device-tree-compiler`

`nemu/tools/difftest.mk`中已经设置了相应的规则和参数, 会自动进入`nemu/tools/`下的相应子目录`spike-diff`编译动态库, 并把其作为NEMU的`--diff`选项的参数传入. 打开DiffTest后, `nemu/src/cpu/difftest/dut.c`中的`init_difftest()`会额外进行以下初始化工作:

- 打开传入的动态库文件`ref_so_file`
- 通过动态链接对动态库中的上述API符号进行符号解析和重定位, 返回它们的地址
- 对REF的DIffTest功能进行初始化, 具体行为因REF而异
- 将DUT的guest memory拷贝到REF中
- 将DUT的寄存器状态拷贝到REF中

进行了上述初始化工作之后, DUT和REF就处于相同的状态了. 接下来就可以进行逐条指令执行后的状态对比了, 实现这一功能的是`difftest_step()`函数(在`nemu/src/cpu/difftest/dut.c`中定义). 它会在`cpu_exec()`的主循环中被调用, 在NEMU中执行完一条指令后, 就在`difftest_step()`中让REF执行相同的指令, 然后读出REF中的寄存器, 并进行对比. 由于不同ISA的寄存器有所不同, 框架代码把寄存器对比抽象成一个ISA相关的API, 即`isa_difftest_checkregs()`函数(在`nemu/src/isa/$ISA/difftest/dut.c`中定义). 

## 实现 `isa_difftest_checkregs()`
需要实现`isa_difftest_checkregs()`函数, 把通用寄存器和PC与从DUT中读出的寄存器的值进行比较. 若对比结果一致, 函数返回true; 如果发现值不一样, 函数返回false, 框架代码会自动停止客户程序的运行. 特别地, `isa_difftest_checkregs()`对比结果不一致时, 第二个参数pc应指向导致对比结果不一致的指令, 可用于打印提示信息

- 上文在介绍API约定的时候, 提到了寄存器状态r需要把寄存器按照某种顺序排列. 首先RTFSC, 在`$NEMU_HOME/tools/spike-diff/difftest.cc`中发现了`difftest_regcpy`函数，即`$NEMU_HOME/src/cpu/difftest/dut.c`中调用的函数，结合传入参数可以发现这一顺序就是`CPU_state`的存储顺序
- 按顺序在`isa_difftest_checkregs()`中对比即可