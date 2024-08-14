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

- 安装device-tree-compiler: `sudo apt-get install device-tree-compiler`