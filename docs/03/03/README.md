# Formatted Printing
本节程序: [ex3.c](./ex3.c), 编译运行结果如下

```sh
(base) xinchen@sakura:~/ysyx/docs/03/03$ make
cc -Wall -g    ex3.c   -o ex3
(base) xinchen@sakura:~/ysyx/docs/03/03$ ./ex3 
I am 10 years old.
I am 72 inches tall.
```

## 使它崩溃
### 从第一个 printf 中去掉 age 并重新编译

```sh
(base) xinchen@sakura:~/ysyx/docs/03/03$ make
cc -Wall -g    ex3.c   -o ex3
ex3.c: In function ‘main’:
ex3.c:11:36: error: expected expression before ‘)’ token
   11 |     printf("I am %d years old.\n", );
      |                                    ^
ex3.c:5:9: warning: unused variable ‘age’ [-Wunused-variable]
    5 |     int age = 10;
      |         ^~~
make: *** [<builtin>: ex3] Error 1
```
### 运行新的程序
由于报错, 没有编译出可执行程序

### 将 printf 恢复原样，并且去掉 age 的初值，将那一行改为 `int age;`，之后重新构建并运行

```sh
(base) xinchen@sakura:~/ysyx/docs/03/03$ make
cc -Wall -g    ex3.c   -o ex3
ex3.c: In function ‘main’:
ex3.c:9:5: warning: ‘age’ is used uninitialized [-Wuninitialized]
    9 |     printf("I am %d years old.\n", age);
      |     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
(base) xinchen@sakura:~/ysyx/docs/03/03$ ./ex3 
I am 25122 years old.
I am 72 inches tall.
```

由于 age 没有初始化, 打印出了随机的值

## 附加题
### 找到尽可能多的方法使 ex3 崩溃
包括上述的不定义初始值，在标准输出中移除变量外，还可以把格式化占位符改为 `%f`，初始化 age 改为 2e72 等

### 执行 `man 3 printf` 来阅读其它可用的 '%' 格式化占位符, 如果你在其它语言中使用过它们，应该看着非常熟悉（它们来源于 printf）
可用的有:

- `d` 整形
- `o`, `u`, `x` 无符号八进制，十进制，十六进制
- `f`, `g`, `s`, `%` 等

### 将 ex3 添加到你的 Makefile 的 all 列表中, 到目前为止，可以使用 make all 来构建你所有的练习
由于采用宏定义，每新建一个项目只需要指定对应的可执行文件名

### 将 ex3 添加到你的 Makefile 的 clean 列表中，当你需要的时候使用 make clean 可以删除它
见 [Makefile](./Makefile)