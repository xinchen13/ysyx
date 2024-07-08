# Dust Off That Compiler

本节程序: [ex1.c](./ex1.c)

编译运行查看结果，可以看到有警告，说 `puts` 函数是 implicit declaration 的

```sh
(base) xinchen@sakura:~/ysyx/docs/03/01$ make ex1
cc     ex1.c   -o ex1
ex1.c: In function ‘main’:
ex1.c:3:5: warning: implicit declaration of function ‘puts’ [-Wimplicit-function-declaration]
    3 |     puts("Hello world.");
      |     ^~~~
ex1.c:1:1: note: include ‘<stdio.h>’ or provide a declaration of ‘puts’
  +++ |+#include <stdio.h>
    1 | int main(int argc, char *argv[])
(base) xinchen@sakura:~/ysyx/docs/03/01$ ./ex1 
Hello world.
```

## 使它崩溃
使用 `CFLAGS="-Wall" make ex1` 重新编译 (事实上没什么区别)

添加头文件 `stdio.h` 后保存到 [ex1v1.c](./ex1v1.c) 编译:

```sh
(base) xinchen@sakura:~/ysyx/docs/03/01$ make ex1v1
cc     ex1v1.c   -o ex1v1
(base) xinchen@sakura:~/ysyx/docs/03/01$ ./ex1v1 
Hello world.
```

像刚才一样重新执行 make 命令, warning 消失了

## 附加题
### 在你的文本编辑器中打开 ex1 文件，随机修改或删除一部分，之后运行它看看发生了什么
- 删除 `return 0;`，编译运行无报错
- 改为 `return 1;`，编译运行无报错
- 删除一个分号，编译报错需要分号

### 再多打印5行文本或者其它比 "Hello world." 更复杂的东西
见 [ex1v2.c](./ex1v2.c)

### 执行 `man 3 puts` 来阅读这个函数和其它函数的文档
`man 3` 用于查看库函数手册