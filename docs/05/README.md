# 数字电路基础实验
数字电路是处理器设计的期前导课程，在这一节利用 HDL 来描述电路模块，重点关注

- 信息的二进制编码
- 组合逻辑设计: 多路选择器, 译码器, 优先编码器, 加法器, 比较器
- 时序逻辑设计: 时钟, D 触发器, 计数器, SRAM 和 DRAM, 有限状态机, 时序分析

**要注意培养硬件思维，要先有电路再利用硬件描述语言来描述**

## 数字电路与计算机组成实验
在这里完成南京大学的『数字电路与计算机组成实验』部分实验，并借助 NVBoard 进行仿真（有了 NVBoard 之后, 就可以把它当作 FPGA 来使用, 用它来实现需要 FPGA 支持的实验内容）

- [选择器](./mux/)
- [译码器和编码器](./encoder_decoder/)
- [加法器与ALU](./alu/)
- [移位寄存器及桶形移位器](./shift/)
- [状态机及键盘输入](./fsm/)

## 评估电路综合后的时序
`OSCPU/yosys-sta` 项目通过开源 RTL 综合器 yosys 对 RTL 设计进行综合, 并映射到一个 45nm 的开源工艺库 nangate45, 然后将综合得到的网表文件和工艺库中的标准单元信息文件输入到开源静态时序分析工具 iSTA 中, iSTA 将快速评估 RTL 设计中的时序路径, 并给出时序余量最少的若干条路径. 通过上述方式, RTL 设计者可快速得知 RTL 设计的时序情况, 并对 RTL 设计进行快速迭代

克隆该项目: `git clone git@github.com:OSCPU/yosys-sta.git`; 进入项目文件夹根据 README 完成库的安装和项目初始化

### 移位寄存器随机数发生器的 STA
把 RTL 文件与约束文件整理到 [shift_yosys_sta](./shift_yosys_sta/), 运行 `make sta DESIGN=top SDC_FILE=shift_yosys_sta/gcd.sdc RTL_FILES="./shift_yosys_sta/lfsr.v ./shift_yosys_sta/segment_hex.v ./shift_yosys_sta/top.v" CLK_FREQ_MHZ=100` 进行优化与综合, 得到评估结果: [shift_top-100MHz](./shift_top-100MHz/), 重点关注时序报告 `top.rpt` 和面积报告 `synth_stat.txt`

### 键盘输入 STA
把 RTL 文件与约束文件整理到 [fsm_yosys_sta](./fsm_yosys_sta/), 运行 `make sta DESIGN=top SDC_FILE=./fsm_yosys_sta/gcd.sdc RTL_FILES="./fsm_yosys_sta/top.v ./fsm_yosys_sta/rom.v ./fsm_yosys_sta/ps2_keyboard.v ./fsm_yosys_sta/segment_hex.v" CLK_FREQ_MHZ=100` 进行优化与综合, 得到评估结果: [fsm_top-100MHz](./fsm_top-100MHz/), 同样重点关注时序报告 `top.rpt` 和面积报告 `synth_stat.txt`
