# Pointers To Functions
函数在C中实际上只是指向程序中某一个代码存在位置的指针. 就像创建过的结构体指针、字符串和数组那样，也可以创建指向函数的指针. 函数指针的主要用途是向其他函数传递“回调”，或者模拟类和对象. 函数指针的格式类似这样:

```c
int (*POINTER_NAME)(int a, int b)
```

用法如下:
- 编写一个普通的函数声明：`int callme(int a, int b)`
- 将函数用指针语法包装：`int (*callme)(int a, int b)`
- 将名称改成指针名称：`int (*compare_cb)(int a, int b)`

```c
int (*tester)(int a, int b) = sorted_order;
printf("TEST: %d is same as %d\n", tester(2, 3), sorted_order(2, 3));
```

将`typedef`添加到相同的指针语法之前，然后你就可以将那个名字用作类型了. 编译运行示例程序[ex18.c](./ex18.c):

```sh
(base) xinchen@sakura:~/ysyx/docs/03/18$ ./ex18 4 1 7 3 2 0 8
0 1 2 3 4 7 8 
8 7 4 3 2 1 0 
3 4 2 7 1 0 8 
```

## 使程序崩溃
这些函数指针都是类似于其它指针的指针，他们都指向内存的一块区域. C中可以将一种指针的指针转换为另一种，以便以不同方式处理数据. 这些通常是不必要的，但是为了想你展示如何侵入你的电脑，我希望你把这段代码添加在`test_sorting`下面, 见[ex18v1.c](./ex18v1.c)

这个循环将你的函数转换成字符串，并且打印出来它的内容。这并不会中断你的程序，除非CPU和OS在执行过程中遇到了问题. 在它打印排序过的数组之后，你所看到的是一个十六进制数字的字符串

```sh
(base) xinchen@sakura:~/ysyx/docs/03/18$ ./ex18v1 4 1 7 3 2 0 8
0 1 2 3 4 7 8 
f3:0f:1e:fa:55:48:89:e5:89:7d:fc:89:75:f8:8b:45:fc:2b:45:f8:5d:c3:f3:0f:1e:
8 7 4 3 2 1 0 
f3:0f:1e:fa:55:48:89:e5:89:7d:fc:89:75:f8:8b:45:f8:2b:45:fc:5d:c3:f3:0f:1e:
3 4 2 7 1 0 8 
f3:0f:1e:fa:55:48:89:e5:89:7d:fc:89:75:f8:83:7d:fc:00:74:06:83:7d:f8:00:75:
```

这就应该是函数的原始的汇编字节码了，能看到它们有相同的起始和不同的结尾. 也有可能这个循环并没有获得函数的全部，或者获得了过多的代码而跑到程序的另外一片空间

## 附加题
### 用十六进制编辑器打开ex18，接着找到函数起始处的十六进制代码序列，看看是否能在原始程序中找到函数
利用`xxd ./ex18 hex-ex18.txt`输出16进制文件到[hex-ex18.txt](./hex-ex18.txt), 可以找到对应的字节序列

### 在你的十六进制编辑器中找到更多随机出现的东西并修改它们. 重新运行你的程序看看发生了什么. 字符串是你最容易修改的东西
用vim随机删除几个字符后运行: `bash: ./ex18: cannot execute binary file: Exec format error`

### 将错误的函数传给`compare_cb`，并看看C编辑器会报告什么错误
写了两个函数`return_zero()` 和`do_nothing()`, 在[ex18v2.c](./ex18v2.c)中.

编译结果显示第一个不报错，且不进行排序; 第二个报warning:

```sh
(base) xinchen@sakura:~/ysyx/docs/03/18$ make ex18v2
cc     ex18v2.c   -o ex18v2
ex18v2.c: In function ‘main’:
ex18v2.c:113:34: warning: passing argument 3 of ‘test_sorting’ from incompatible pointer type [-Wincompatible-pointer-types]
  113 |     test_sorting(numbers, count, do_nothing);
      |                                  ^~~~~~~~~~
      |                                  |
      |                                  void (*)()
ex18v2.c:81:55: note: expected ‘compare_cb’ {aka ‘int (*)(int,  int)’} but argument is of type ‘void (*)()’
   81 | void test_sorting(int *numbers, int count, compare_cb cmp)
      |                                            ~~~~~~~~~~~^~~  
```

### 将NULL传给它，看看程序中会发生什么. 然后运行Valgrind来看看它会报告什么
见 [ex18v3.c](./ex18v3.c), 直接运行会报`Segmentation fault (core dumped)`, 是对非法地址的访问

valgrind运行，报错“跳转到了错误的地址”: `Jump to the invalid address stated on the next line`

### 编写另一个排序算法，修改test_sorting使它接收任意的排序函数和排序函数的比较回调. 并使用它来测试两种排序算法
- 首先定义一个函数指针类型，用于指向排序函数(返回值是指针)
- 修改`test_sorting()`的传入参数, 使得接受一个排序函数
- 再写一个插入排序函数`insert_sort()`
- 代码见[ex18v4.c](./ex18v4.c)

测试结果为:

```sh
(base) xinchen@sakura:~/ysyx/docs/03/18$ ./ex18v4 4 1 7 3 2 0 8 
0 1 2 3 4 7 8 
8 7 4 3 2 1 0 
3 4 2 7 1 0 8 
0 1 2 3 4 7 8 
8 7 4 3 2 1 0 
4 1 7 3 2 0 8 
```