# Types Of Variables

本节代码: [ex6.c](./ex6.c), 并编译运行:

```sh
(base) xinchen@sakura:~/ysyx/docs/03/06$ make ex6
cc     ex6.c   -o ex6
(base) xinchen@sakura:~/ysyx/docs/03/06$ ./ex6 
You are 100 miles away.
You have 2.345000 levels of power.
You have 56789.453200 awesome super powers.
I have an initial A.
I have a first name Zed.
I have a last name Shaw.
My whole name is Zed A. Shaw.
```

不同的数据类型有:

- 整型: 用 `int` 声明，使用 `%d` 格式化输出
- 浮: 用 `float` 或 `double` 声明, `%f` 格式化输出
- 字符: 用 `char` 声明，加单引号，`%c` 格式化输出
- 字符串: 用 `char name[]` 声明，加双引号，`%s` 格式化输出

## 使它崩溃
向 printf 传递错误的参数: 把 initial 放到 first_name 前

```sh
(base) xinchen@sakura:~/ysyx/docs/03/06$ make ex6
cc     ex6.c   -o ex6
ex6.c: In function ‘main’:
ex6.c:17:34: warning: format ‘%s’ expects argument of type ‘char *’, but argument 2 has type ‘int’ [-Wformat=]
   17 |     printf("I have a first name %s.\n", initial, first_name);
      |                                 ~^      ~~~~~~~
      |                                  |      |
      |                                  char * int
      |                                 %d
ex6.c:17:12: warning: too many arguments for format [-Wformat-extra-args]
   17 |     printf("I have a first name %s.\n", initial, first_name);
      |            ^~~~~~~~~~~~~~~~~~~~~~~~~~~
(base) xinchen@sakura:~/ysyx/docs/03/06$ ./ex6 
You are 100 miles away.
You have 2.345000 levels of power.
You have 56789.453200 awesome super powers.
I have an initial A.
Segmentation fault (core dumped)
```

会发生段错误

## 附加题
### 寻找其他通过修改 `printf` 使这段 C 代码崩溃的方法
将整型的输出变量改为浮点型

### 搜索 “printf 格式化”，试着使用一些高级的占位符
如:

```c
printf("You are %5d miles away.\n", distance);
printf("You have %.2f levels of power.\n", power);
```

`%5d` 强制要求输出的 `int` 占5格; `%.2f` 要求浮点输出保留两位小数, 见 [ex6v1.c](./ex6v1.c)

### 研究可以用几种方法打印数字. 尝试以八进制或十六进制打印，或者其它你找到的方法
如：

```c
printf("You are %o(oct) miles away.\n", distance);
printf("You are %x(hex) miles away.\n", distance);
```

`%o` 输出八进制; `%x` 输出十六进制, 见 [ex6v1.c](./ex6v1.c)

### 试着打印空字符串，即 ""
如下代码打印了空字符，发现没有输出; 再打印空字符的大小，有一个字节，是 `\0` 字符, 见 [ex6v1.c](./ex6v1.c)

```c
char empty_str[] = "";
printf("This is an empty string:%s \n",empty_str);
printf("Empty string has %ld bytes\n",sizeof(empty_str));
```