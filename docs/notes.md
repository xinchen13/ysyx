# 一些笔记

## optional
- nemu 声卡
- 优化 LiteNES
- nemu 涉及 csrr 指令的 qemu difftest 会产生错误，原因未知
- 修复 RT-Thread 运行时不输出最后的命令提示符的问题
- 让核支持完整的 AXI4 协议（当前部分信号直接赋默认值了）
- 替 AXIM 为自研的 AXIM（不是）
- 为 ysyxSOC 重新添加 DiffTest
- 让 NPC 抛出 Access Fault 异常

## emacs verilog-mode
- 生成: `emacs --batch ${FILES} -f verilog-batch-auto`
- 删除: `emacs --batch ${FILES} -f verilog-batch-delete-auto`