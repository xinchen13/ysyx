# Make Is Your Python Now
make: C 语言源码构建工具, 编译源文件到二进制文件

本节代码: [ex2.c](./ex2.c), 编写简单的 Makefile:

```makefile
CFLAGS=-Wall -g

clean:
	rm -f ex2
```
其中 `-g` 添加了调试选项，`clean` 是清理上次编译结果的规则

## 使它崩溃
去掉 `rm -f ex2` 行的缩进:

```sh
(base) xinchen@sakura:~/ysyx/docs/03/02$ make ex2
Makefile:4: *** missing separator.  Stop.
```

Makefile 需要遵守严格的 TAB 缩进规则

## 附加题
### 创建目标 `all:ex2`，可以以单个命令 make 构建 ex2
在 Makefile 中添加 `all:ex2` 规则，之后可以直接 `make` 编译

### 阅读 `man make` 来了解关于如何执行它的更多信息
make 是用于管理编译大型项目的工具，搭配描述文件间关系的 Makefile 文件实现自动编译

### 阅读 `man cc` 来了解关于 `-Wall` 和 `-g` 行为的更多信息
进入 `man cc` 后，键入 `/-Wall` 和 `/-g` 查找对应词条，`n` 查找下一个，`N` 查找上一个

- `-Wall`: 允许所有项目构建可疑问题的警告 (不包括全部，其他参考 `-Wextra` 以及单独参数)
- `-g`: 打开调试选项 (有时 `-Og` 会在不同编译器下包含更全的调试信息) 供 gdb 使用

### 在互联网上搜索 Makefile 文件，看看你是否能改进你的文件
Makefile Cookbook 提供了较为通用的 [Makefile](./MakefileCookbook) 

### 在另一个 C 语言项目中找到 Makefile 文件，并且尝试理解它做了什么
参考 `NVBoard` 项目的Makefile，主要干了几件事: 
- 设定编译选项
- 指定源文件路径
- 指定 Verilator 和 NVBoard 规则
- 完成编译、清除、运行规则的编写