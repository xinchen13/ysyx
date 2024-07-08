# Structs And Pointers To Them
C 中的结构体是其它数据类型(变量)的一个集合，它们储存在一块内存中，然而你可以通过独立的名字来访问每个变量. 它们就类似于数据库表中的一行记录，或者面向对象语言中的一个非常简单的类

本节程序: [ex16.c](./ex16.c), 编译运行:

```sh
(base) xinchen@sakura:~/ysyx/docs/03/16$ ./ex16 
Joe is at memory location 0x5a23d4a7c2a0:
Name: Joe Alex
        Age: 32
        Height: 64
        Weight: 140
Frank is at memory location 0x5a23d4a7c2e0:
Name: Frank Blank
        Age: 20
        Height: 72
        Weight: 180
Name: Joe Alex
        Age: 52
        Height: 62
        Weight: 180
Name: Frank Blank
        Age: 40
        Height: 72
        Weight: 200
```

- `struct Person`: 创建结构体，结构体含有四个成员来描述一个人，最后我们得到了一个复合类型，让我们通过一个名字来整体引用这些成员
- `Pearson_create 函数`: 需要一个方法来创建这些结构体，于是定义一个函数来实现. 下面是这个函数做的几件重要的事情:
  - 使用用于内存分配的 `malloc` 来向 OS 申请一块原始的内存
  - 向 `malloc` 传递 `sizeof(struct Person)` 参数，它计算结构体的大小，包含其中的所有成员
  - 使用了 `assert` 来确保从 `malloc` 得到一块有效的内存. 有一个特殊的常量叫做 `NULL`，表示 “未设置或无效的指针”. 这个 `assert` 大致检查了 `malloc` 是否会返回 `NULL`
  - 使用 `x->y` 语法来初始化 `struct Person` 的每个成员，它指明了所初始化的成员 (`x->y` 是 `(*x).y` 的简写)
  - 使用 `strdup` 来复制字符串 `name`，是为了确保结构体真正拥有它, `strdup` 的行为实际上类似 `malloc` 但是它同时会将原来的字符串复制到新创建的内存
- `Person_destroy函数`: 如果定义了创建函数，那么一定需要一个销毁函数，它会销毁 `Person` 结构体. 再一次使用了 `assert` 来确保不会得到错误的输入. 接着使用了 `free` 函数来交还通过 `malloc` 和 `strdup` 得到的内存. 如果不这么做则会出现“内存泄露”

## 使程序崩溃
### 传递 NULL 给 Person_destroy 来看看会发生什么 (如果它没有崩溃，你必须移除 Makefile 的 CFLAGS 中的 -g 选项)
见 [ex16v1.c](./ex16v1.c), 会触发断言错误: 

```sh
ex16v1: ex16v1.c:28: Person_destroy: Assertion `who != NULL' failed.
Aborted (core dumped)
```

### 在结尾处忘记调用 Person_destroy，在 Valgrind 下运行程序，你会看到它报告出你忘记释放内存. 弄清楚你应该向 Valgrind 传递什么参数来让它向你报告内存如何泄露
见 [ex16v2.c](./ex16v2.c) 在使用 valgrind 时加入选项`--leak-check=full`, 报告错误如下:

```sh
==22801== HEAP SUMMARY:
==22801==     in use at exit: 69 bytes in 4 blocks
==22801==   total heap usage: 5 allocs, 1 frees, 1,093 bytes allocated
==22801== 
==22801== 33 (24 direct, 9 indirect) bytes in 1 blocks are definitely lost in loss record 3 of 4
==22801==    at 0x4848899: malloc (in /usr/libexec/valgrind/vgpreload_memcheck-amd64-linux.so)
==22801==    by 0x1091EB: Person_create (in /home/xinchen/ysyx/docs/03/16/ex16v2)
==22801==    by 0x10936E: main (in /home/xinchen/ysyx/docs/03/16/ex16v2)
==22801== 
==22801== 36 (24 direct, 12 indirect) bytes in 1 blocks are definitely lost in loss record 4 of 4
==22801==    at 0x4848899: malloc (in /usr/libexec/valgrind/vgpreload_memcheck-amd64-linux.so)
==22801==    by 0x1091EB: Person_create (in /home/xinchen/ysyx/docs/03/16/ex16v2)
==22801==    by 0x109390: main (in /home/xinchen/ysyx/docs/03/16/ex16v2)
==22801== 
==22801== LEAK SUMMARY:
==22801==    definitely lost: 48 bytes in 2 blocks
==22801==    indirectly lost: 21 bytes in 2 blocks
==22801==      possibly lost: 0 bytes in 0 blocks
==22801==    still reachable: 0 bytes in 0 blocks
==22801==         suppressed: 0 bytes in 0 blocks
==22801== 
==22801== For lists of detected and suppressed errors, rerun with: -s
==22801== ERROR SUMMARY: 2 errors from 2 contexts (suppressed: 0 from 0)
```

### 忘记在 Person_destroy 中释放 who->name，并且对比两次的输出. 同时，使用正确的选项来让 Valgrind 告诉你哪里错了
见 [ex16v3.c](./ex16v3.c), Valgrind 报告如下:

```sh
==22874== HEAP SUMMARY:
==22874==     in use at exit: 21 bytes in 2 blocks
==22874==   total heap usage: 5 allocs, 3 frees, 1,093 bytes allocated
==22874== 
==22874== 9 bytes in 1 blocks are definitely lost in loss record 1 of 2
==22874==    at 0x4848899: malloc (in /usr/libexec/valgrind/vgpreload_memcheck-amd64-linux.so)
==22874==    by 0x491258E: strdup (strdup.c:42)
==22874==    by 0x10922A: Person_create (in /home/xinchen/ysyx/docs/03/16/ex16v3)
==22874==    by 0x10935F: main (in /home/xinchen/ysyx/docs/03/16/ex16v3)
==22874== 
==22874== 12 bytes in 1 blocks are definitely lost in loss record 2 of 2
==22874==    at 0x4848899: malloc (in /usr/libexec/valgrind/vgpreload_memcheck-amd64-linux.so)
==22874==    by 0x491258E: strdup (strdup.c:42)
==22874==    by 0x10922A: Person_create (in /home/xinchen/ysyx/docs/03/16/ex16v3)
==22874==    by 0x109381: main (in /home/xinchen/ysyx/docs/03/16/ex16v3)
==22874== 
==22874== LEAK SUMMARY:
==22874==    definitely lost: 21 bytes in 2 blocks
==22874==    indirectly lost: 0 bytes in 0 blocks
==22874==      possibly lost: 0 bytes in 0 blocks
==22874==    still reachable: 0 bytes in 0 blocks
==22874==         suppressed: 0 bytes in 0 blocks
==22874== 
==22874== For lists of detected and suppressed errors, rerun with: -s
==22874== ERROR SUMMARY: 2 errors from 2 contexts (suppressed: 0 from 0)
```

对比可得内存泄漏变少了, 且这种情况下泄露的内存就是未调用 `Person_destroy()` 带来的间接泄漏

### 向 Person_print 传递 NULL，并且观察 Valgrind 会输出什么
见 [ex16v4.c](./ex16v4.c), 报错 `Segmentation fault (core dumped)`. 原因是非法的内存访问

## 附加题
### 如何在栈上创建结构体，就像你创建任何其它变量那样
见 [ex16v5.c](./ex16v5.c)，不使用 `malloc` 与 `strdup` 就可以将变量创建在栈上

### 如何使用 x.y 而不是 x->y 来初始化结构体
- 一种方法是在栈上创建结构体, 见 [ex16v5.c](./ex16v5.c)
- 也可以使用 `(*x).y` 的方式代替 `x->y`, 见 [ex16v6.c](./ex16v6.c)
- 
### 如何不使用指针来将结构体传给其它函数
见 [ex16v5.c](./ex16v5.c)，把结构体作为带有成员的普通变量看待作为函数返回值