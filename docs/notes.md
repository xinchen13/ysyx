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

# rtl规范
在模块名前添加学号前缀; 如果使用Verilog, 需要在宏定义的标识符前添加学号前缀, 后续需要修改的地方:
- v与sv文件中 module 名
- 文件名(.v与.sv文件)
- $NPC_HOME/Makefile 中的 TOPNAME 等