# Pointers Dreaded Pointers
本节程序: [ex15.c](./ex15.c), 编译运行:

```sh
(base) xinchen@sakura:~/ysyx/docs/03/15$ ./ex15 
Alan has 23 years alive.
Frank has 43 years alive.
Mary has 12 years alive.
John has 89 years alive.
Lisa has 2 years alive.
---
Alan is 23 years old.
Frank is 43 years old.
Mary is 12 years old.
John is 89 years old.
Lisa is 2 years old.
---
Alan is 23 years old again.
Frank is 43 years old again.
Mary is 12 years old again.
John is 89 years old again.
Lisa is 2 years old again.
---
Alan lived 23 years so far.
Frank lived 43 years so far.
Mary lived 12 years so far.
John lived 89 years so far.
Lisa lived 2 years so far.
```

指针的用途就是手动对内存块进行索引，一些情况下数组并不能做到; 绝大多数情况中，你可能打算使用数组，但是一些处理原始内存块的情况，是指针的用武之地; 指针向你提供了原始的、直接的内存块访问途径，让你能够处理它们

可以用指针做下面四个最基本的操作:
- 向OS申请一块内存，并且用指针处理它，这包括字符串，结构体等
- 通过指针向函数传递大块的内存（比如很大的结构体），这样不必把全部数据都传递进去
- 获取函数的地址用于动态调用
- 对一块内存做复杂的搜索，比如，转换网络套接字中的字节，或者解析文件

`type *ptr`: type 类型的指针，名为 ptr

`*ptr`: ptr 所指向位置的值

`*(ptr + i)`: ptr 所指向位置加上i的值 (以字节为单位的话，应该是 ptr 所指向的位置再加上 sizeof(type) * i)

`&thing`: thing 的地址

`type *ptr = &thing`: 名为 ptr，type 类型的指针，值设置为 thing 的地址

`ptr++`:  自增 ptr 指向的位置

## 使程序崩溃
将 cur_age 指向 names, 见 [ex15v1.c](./ex15v1.c). 使用指针输出时会存在乱码

## 附加题
### 使用访问指针的方式重写所有使用数组的地方
见 [ex15v2.c](./ex15v2.c)

### 使用访问数组的方式重写所有使用指针的地方
见 [ex15v3.c](./ex15v3.c)

### 在其它程序中使用指针来代替数组访问
略

### 使用指针来处理命令行参数，就像处理 names 那样
见 [ex15v4_.c](./ex15v4.c)

### 将获取值和获取地址组合到一起
见 [ex15v5.c](./ex15v5.c), 输出:

```sh
(base) xinchen@sakura:~/ysyx/docs/03/15$ ./ex15v5
Alan is 23 years old.
cur_name+i is at 0x7ffdfac72750, cur_age+i is at 0x7ffdfac72730
Frank is 43 years old.
cur_name+i is at 0x7ffdfac72758, cur_age+i is at 0x7ffdfac72734
Mary is 12 years old.
cur_name+i is at 0x7ffdfac72760, cur_age+i is at 0x7ffdfac72738
John is 89 years old.
cur_name+i is at 0x7ffdfac72768, cur_age+i is at 0x7ffdfac7273c
Lisa is 2 years old.
cur_name+i is at 0x7ffdfac72770, cur_age+i is at 0x7ffdfac72740
```

### 在程序末尾添加一个 for 循环，打印出这些指针所指向的地址. 你需要在 `printf` 中使用 `%p`
利用如下语句打印地址, 见 [ex15v5.c](./ex15v5.c)

```c
printf("%p is the address of cur_name now\n",cur_name);
printf("%p is the address of cur_age now\n",cur_age);
```

### 对于每一种打印数组的方法，使用函数来重写程序，试着向函数传递指针来处理数据，记住你可以声明接受指针的函数，但是可以像数组那样用它
事实上，主函数接受的命令行参数就是指针. 具体见 [ex15v6.c](./ex15v6.c)

### 将 for 循环改为 while 循环，并且观察对于每种指针用法哪种循环更方便
都差不多，while 循环需要注意变量自增