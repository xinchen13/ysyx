# Sizes And Arrays
本节程序: [ex8.c](./ex8.c), 并编译运行:

```sh
(base) xinchen@sakura:~/ysyx/docs/03/08$ make ex8
cc     ex8.c   -o ex8
(base) xinchen@sakura:~/ysyx/docs/03/08$ ./ex8 
The size of an int: 4
The size of areas (int[]): 20
The number of ints in areas: 5
The first area is 10, the 2nd 12.
The size of a char: 1
The size of name (char[]): 4
The number of chars: 4
The size of full_name (char[]): 12
The number of chars: 12
name="Zed" and full_name="Zed A. Shaw"
```

在上面的代码中打印了各个变量及数组的大小. (`sizeof()` 的单位是 `byte`)

## 使程序崩溃
在 [ex8v1.c](./ex8v1.c) 中:

- 将 `full_name` 最后的 `'\0'` 去掉，; 
- 将 areas[0] 改为 areas[10]，

用 valgrind 运行，并无报错, full_name 正常输出; areas 没有报错和警告，但是输出的值不确定

## 附加题
### 尝试使用 `areas[0] = 100`; 以及相似的操作对 areas 的元素赋值
改变了 areas[0] 的值

```c
areas[0] = 100;
printf("The first area is %d now.\n",areas[0]);
```

### 尝试对 name 和 full_name 的元素赋值
把字符串看作字符数组，按以下的方式修改值

```c
name[1] = 'a';
full_name[0] = 'B';
printf("name=\"%s\" and full_name=\"%s\" now. \n",name, full_name);
```

### 尝试将 areas 的一个元素赋值为 name 中的字符
输出结果为100，因为字符 'd' 的 ASCII 码刚好为 100

```c
areas[1] = 'd';
printf("areas[1] is %d now.\n",areas[1]);
```

### 上网搜索在不同的 CPU 上整数所占的不同大小
一般来说，32 位与 64 位 CPU 中 `int` 都为 4 字节，`long int` 在 32 位中占 4 字节，64 位中 8 字节