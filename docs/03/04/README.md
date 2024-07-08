# Introducing Valgrind
## 安装Valgrind
使用 apt 安装，查看是否成功

```sh
(base) xinchen@sakura:~/ysyx/docs/03/04$ sudo apt install valgrind
...
(base) xinchen@sakura:~/ysyx/docs/03/04$ which valgrind
/usr/bin/valgrind
(base) xinchen@sakura:~/ysyx/docs/03/04$ valgrind --version
valgrind-3.18.1
```

## 使用Valgrind: 
`valgrind <exec_file_name>` 就会运行程序，打印错误

先写入错误的程序 [ex4.c](./ex4.c), 编译，并用 Valgrind 运行，结果保存在 [valgrind-run.log](./valgrind-run.log), 显示程序报错信息

## 附加题
### 按照上面的指导，使用 Valgrind 和编译器修复这个程序
标准输出添加 `age` 并给 `height` 赋初值，见 [ex4v1.c](./ex4v1.c)

再编译后使用 Valgrind 运行就没有报错了

### 在互联网上查询 Valgrind 相关的资料
- Valgrind 是一款用于内存调试、内存泄漏检测以及性能分析、检测线程错误的软件开发工具
- Valgrind 直接解释二进制代码使得应用程序基于它运行，从而能够检查内存操作时可能出现的错误. 所以在 Valgrind 下运行的程序运行速度要慢得多，而且使用的内存要多得多

### 下载另一个程序并手动构建它. 尝试一些你已经使用，但从来没有手动构建的程序
Verilator

### 看看 Valgrind 的源码是如何在目录下组织的，并且阅读它的 Makefile 文件