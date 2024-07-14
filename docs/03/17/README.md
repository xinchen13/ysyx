# Heap And Stack Memory Allocation
本节程序: [ex17.c](./ex17/ex17.c), 编译运行:

```sh
(base) xinchen@sakura:~/ysyx/docs/03/17/ex17$ ./ex17 db.dat c
(base) xinchen@sakura:~/ysyx/docs/03/17/ex17$ ./ex17 db.dat s 1 zed zed@zedshaw.com
(base) xinchen@sakura:~/ysyx/docs/03/17/ex17$ ./ex17 db.dat s 2 frank frank@zedshaw.com
(base) xinchen@sakura:~/ysyx/docs/03/17/ex17$ ./ex17 db.dat s 3 joe joe@zedshaw.com
(base) xinchen@sakura:~/ysyx/docs/03/17/ex17$ ./ex17 db.dat l
1 zed zed@zedshaw.com
2 frank frank@zedshaw.com
3 joe joe@zedshaw.com
(base) xinchen@sakura:~/ysyx/docs/03/17/ex17$ ./ex17 db.dat g 2
2 frank frank@zedshaw.com
```

- `Address` 结构体使用常量来创建数据，这些数据是定长的，它们并不高效，但是便于存储和读取; `Database` 结构体也是定长的，因为它有一个定长的 `Address` 结构体数组
- `die` 函数: 程序出现错误时调用 `exit` 退出程序
- 当函数返回了一个错误时，它通常设置一个叫做 `errno` 的外部变量，来描述发生了什么错误; 可以使用 `perror` 来打印出错误信息
- 一些新的函数比如 `fopen`，`fread`，`fclose`，和 `rewind` 来处理文件. 这些函数中每个都作用于 `FILE` 结构体上，由 C 标准库定义
- 字符串转为整数: `atoi` 函数在命令行中接受作为 id 的字符串并把它转换为 int id 变量

## 堆和栈的内存分配
堆更容易解释，它就是电脑中的剩余内存，可以通过 `malloc` 访问它来获取更多内存，OS 会使用内部函数为你注册一块内存区域，并且返回指向它的指针. 当使用完这片区域时，应该使用 `free` 把它交还给OS，使之能被其它程序复用. 如果你不这样做就会导致程序泄露内存 (可以使用 Valgrind 来检测)

栈是一个特殊的内存区域，它储存了每个函数的创建的临时变量，它们对于该函数为局部变量. 它的工作机制是，函数的每个变量都会压入栈中，并且可在函数内部使用. 它是一个真正的栈数据结构，所以是后进先出的. 这对于 `main` 中所有类似 `char section` 和 `int id` 的局部变量也是相同的. 使用栈的优点是，当函数退出时 C 编译器会从栈中“弹出”所有变量来清理. 这非常简单，也防止了栈上变量的内存泄露

- 如果用 `malloc` 获取了一块内存，并且把指针放在了栈上，那么当函数退出时，指针会被弹出而丢失
- 如果在栈上存放了大量数据 (比如大结构体和数组)，那么会产生栈溢出并且程序会中止. 这种情况下应该通过 `malloc` 放在堆上
- 如果获取了指向栈上变量的指针，并且将它用于传参或从函数返回，接收它的函数会产生“段错误”. 因为实际的数据被弹出而消失，指针也会指向被释放的内存

## 使程序崩溃
### 这个程序中有个 bug，因为 `strncpy` 有设计缺陷. 查询 `strncpy` 的相关资料，然后试着弄清楚如果 name 或者 address 超过 512 个字节会发生什么. 可以通过简单把最后一个字符设置成 `\0` 来修复它，你应该无论如何都这样做（这也是函数原本应该做的）
见 [ex17v1](./ex17v1/ex17.c) 在 `Database_set` 函数中完成字符串复制后添加语句手动设置最后一个字符为 `\0`: 

## 附加题
### die 函数需要接收 conn 变量作为参数，以便执行清理并关闭它
见 [ex17v2](./ex17v2/ex17.c), 接受 conn 指针后直接调用 `Database_close()`

### 修改代码，使其接收参数作为 `MAX_DATA` 和 `MAX_ROWS`，将它们储存在 `Database` 结构体中，并且将它们写到文件. 这样就可以创建任意大小的数据库
见 [ex17v3](./ex17v3/ex17.c)，改为变量后，数组需要改为指针，整个数据库都放在堆上 (除了 `MAX_DATA` 和 `MAX_ROWS`)

### 向数据库添加更多操作，比如 find
添加 `find` 功能，通过 name 或 email 匹配数据库数据, 见[ex17v4](./ex17v4/ex17.c)

### 查询 C 如何打包结构体，并且试着弄清楚为什么你的文件是相应的大小. 看看你是否可以计算出结构体添加一些字段之后的新大小
可以查看 `db.dat` 的大小是 103,200 bytes，共 100 个元素，也就是每个结构体的所占的物理空间大小是 1032 bytes.

考虑结构体存储的对齐规则，这里单个结构体的大小为 `2 * 4 + 2 * 1 * 512 = 1032 bytes`, 与计算出来的值吻合

### 向 Address 添加一些字段，使它们可被搜索
见[ex17v5](./ex17v5/ex17.c), 添加了 age 字段

### 编写一个 shell 脚本来通过以正确顺序运行命令执行自动化测试(提示: 在bash顶端使用使用 `set -e`，使之在任何命令发生错误时退出)
见各子文件夹下的 test.sh 文件

### 尝试重构程序，使用单一的全局变量来储存数据库连接. 这个新版本和旧版本比起来如何
重构的程序见 [ex17v6](./ex17v6/ex17.c), 新版本需要传递的参数少了，对应的程序的通用性变差了

### 搜索栈数据结构，并且在你最喜欢的语言中实现它，然后尝试在 C 中实现
实现了简单的栈，包括数据结构，初始化，打印，push 和 pop，在 [stack.c](./stack/stack.c)