# More Variables, Some Math

本节代码: [ex7.c](./ex7.c), 并编译运行:

```sh
(base) xinchen@sakura:~/ysyx/docs/03/07$ make ex7
cc     ex7.c   -o ex7
(base) xinchen@sakura:~/ysyx/docs/03/07$ ./ex7 
You have 100 bugs at the imaginary rate of 1.200000.
The entire universe has 1073741824 bugs.
You are expected to have 120.000000 bugs.
That is only a 1.117587e-07 portion of the universe.
Which means you should care 0%.
```

## 使它崩溃
使用 `%s` 来打印 `nul_byte` 变量: 无错误，只有输出不同

```sh
(base) xinchen@sakura:~/ysyx/docs/03/07$ make ex7
cc     ex7.c   -o ex7
ex7.c: In function ‘main’:
ex7.c:29:28: warning: format ‘%s’ expects argument of type ‘char *’, but argument 2 has type ‘int’ [-Wformat=]
   29 |     printf("%%s nul_byte: %s\n", nul_byte);
      |                           ~^     ~~~~~~~~
      |                            |     |
      |                            |     int
      |                            char *
      |                           %d
(base) xinchen@sakura:~/ysyx/docs/03/07$ ./ex7 
You have 100 bugs at the imaginary rate of 1.200000.
The entire universe has 1073741824 bugs.
You are expected to have 120.000000 bugs.
That is only a 1.117587e-07 portion of the universe.
Which means you should care 0%.
%s nul_byte: (null)
```

## 附加题
### 把为 `universe_of_defects` 赋值的数改为不同的大小，观察编译器的警告
在 [ex7v1.c](./ex7v1.c) 中, 将其改为 `1000000000000000L * 1024L * 1024L * 1024L`，即一个很大的数，编译器给出溢出警告; valgrind 没有报错

```sh
(base) xinchen@sakura:~/ysyx/docs/03/07$ make ex7v1
cc     ex7v1.c   -o ex7v1
ex7v1.c: In function ‘main’:
ex7v1.c:11:58: warning: integer overflow in expression of type ‘long int’ results in ‘-2888412201444442112’ [-Woverflow]
   11 |     long universe_of_defects = 1000000000000000L * 1024L * 1024L * 1024L;
      |                                                          ^
(base) xinchen@sakura:~/ysyx/docs/03/07$ ./ex7v1
You have 100 bugs at the imaginary rate of 1.200000.
The entire universe has -6255042485580464128 bugs.
You are expected to have 120.000000 bugs.
That is only a -1.918452e-17 portion of the universe.
Which means you should care 0%.                                                
```

### 这些巨大的数字实际上打印成了什么
实际打印成了一个负数（溢出了）

### 将 `long` 改为 `unsigned long`，并试着找到对它来说太大的数字
改为 `unsigned long`，警告溢出时，打印的数仍为正数

### 上网搜索 `unsigned` 做了什么
事实上，存储的变量的位表示没有变化，只是告诉编译器是按无符号数还是有符号数来解释位模式

### 试着自己解释 (在下个练习之前) 为什么 `char` 可以和 `int` 相乘
事实上 `char` 类型本质上是一个单字节的数据，由于类型转换机制, 计算时会把 `char` 类型转换为 `int` 再计算; 相乘后按 `int` 类型来看待结果并打印