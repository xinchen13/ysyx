# Writing And Using Functions
本节代码: [ex14.c](./ex14.c), 并编译运行 (`ctype.h` 头文件可以访问 `isalpha` 和 `isblank`):

```sh
(base) xinchen@sakura:~/ysyx/docs/03/14$ ./ex14 
'e' == 101 'x' == 120 
(base) xinchen@sakura:~/ysyx/docs/03/14$ ./ex14  fxc ssddhh 2323JJFSjfs
'e' == 101 'x' == 120 
'f' == 102 'x' == 120 'c' == 99 
's' == 115 's' == 115 'd' == 100 'd' == 100 'h' == 104 'h' == 104 
'J' == 74 'J' == 74 'F' == 70 'S' == 83 'j' == 106 'f' == 102 's' == 115 
```
## 使程序崩溃
### 通过移除前向声明来把编译器搞晕
报告 `can_print_it` 和 `print_letters` 的错误

### 当你在 main 中调用 print_arguments 时，试着使 argc 加 1，于是它会越过 argv 数组的最后一个元素
数组访问越界，报告 Segmentation fault (core dumped)


## 附加题
### 重新编写这些函数，使它们的数量减少，比如，你真的需要 `can_print_it` 吗
移除 `can_print_it` 函数，见 [ex14v1.c](./ex14v1.c)

### 使用 strlen 函数，让 print_arguments 知道每个字符串参数都有多长，之后将长度传入 `print_letters`，然后重写 `print_letters`，让它只处理固定的长度，不按照 `\0` 终止符. 你需要 `#include <string.h>` 来实现它
给 `print_letters` 一个新的参数 (即字符串长度)，把 `strlen(argv[i])` 传给他，见 [ex14v2.c](./ex14v2.c)

### 使用 `man` 来查询 `isalpha` 和 `isblank` 的信息, 使用其它相似的函数来只打印出数字或者其它字符
- `isalpha`: 检查是否为字母表字母
- `isblank`: 检查是否为空字符，即空格/tab

`isalpha(ch)` 等价于 `isupper(ch) || islower(ch)`

### 上网浏览不同的人喜欢什么样的函数格式，永远不要使用“K&R”语法，因为它过时了，而且容易使人混乱，但是当你碰到一些人使用这种格式时，要理解代码做了什么
C 语言中有两种函数参数风格: ANSI 和 K&R. ANSI 是我们所学习的风格, K&R 则是老式的，是编写 Linux 内核所使用的风格

`int foo(void)` 还有 `int foo(int a, int b)` 就是ANSI风格的. 它的特点是参数都有类型; 对应的，`int foo()` 和 `int foo(a,b)` 是 K&R 风格，它使用初始化列