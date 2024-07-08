# 一些笔记

## RV32e架构设计参考
1. nju-projectn: https://nju-projectn.github.io/dlco-lecture-note/exp/11.html
2. tinyriscv: https://gitee.com/liangkangnan/tinyriscv
3. 计算机组成与设计——硬件/软件接口
4. RISC-V开放架构设计之道-v1.0.0
5. riscv-spec-20191213
6. riscv-privileged-20211203
7. riscv-card
8. riscv abi: https://github.com/riscv-non-isa/riscv-elf-psabi-doc.git

## RTL代码风格和规范
1. 尽量使用数据流建模和结构化建模，不要使用行为建模(描述错误导致非预期电路，延迟大、面积大、功耗高). 真正描述电路 = 实例化 + 连线
2. 不要用negedge (posedge和negedge混用, 会导致时序收敛更加困难, 增加后端物理实现的难度)
3. 不要用异步复位,即复位信号不出现在always的事件列表中.(采用异步复位容易造成亚稳态, 导致芯片复位后无法正确工作. 一般使用异步复位, 同步释放的技术来解决这个问题)
4. 不要使用锁存器(Latch): 锁存器的变化不受时钟驱动, 时序分析工具难以对其进行分析
5.在模块名前添加学号前缀; 如果使用Verilog, 需要在宏定义的标识符前添加学号前缀
其他