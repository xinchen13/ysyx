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
