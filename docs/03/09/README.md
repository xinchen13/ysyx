# Arrays And Strings
本节程序: [ex9.c](./ex9.c), 编译运行:

```sh
(base) xinchen@sakura:~/ysyx/docs/03/09$ make ex9
cc     ex9.c   -o ex9
(base) xinchen@sakura:~/ysyx/docs/03/09$ ./ex9 
numbers: 0 0 0 0
name each: a   
name: a
numbers: 1 2 3 4
name each: Z e d 
name: Zed
another: Zed
another each: Z e d 
```

- 如果在初始化只提供了一个元素，剩下的都会为 0
- numbers 的每个元素被打印时都输出 0
- names 的每个元素被打印时，只显示了第一个元素 'a'，因为 '\0' 是特殊字符不会显示
- 首次打印 names，打印出了 "a"，因为在初始化表达式中，'a' 字符之后的空间都用 '\0' 填充，是以 '\0' 结尾的有效字符串
- 创建一个字符串有两种语法: `char name[4] = {'a'}` 或者 `char *another = "name"` 前者不怎么常用，一般将后者用于字符串字面值

## 使程序崩溃
### 删掉 name 的初始化表达式
见 [ex9v1.c](./ex9v1.c), 运行结果如下, name 被初始化为全 `\0` 数组

```sh
(base) xinchen@sakura:~/ysyx/docs/03/09$ make ex9v1
cc     ex9v1.c   -o ex9v1
(base) xinchen@sakura:~/ysyx/docs/03/09$ ./ex9v1 
numbers: 0 0 0 0
name each:    
name: 
numbers: 1 2 3 4
name each: Z e d 
name: Zed
another: Zed
another each: Z e d 
```

### 无意中设置 name[3] = 'A'，于是它就没有终止字符了
见 [ex9v2.c](./ex9v2.c) 并没有报错，正常输出

### 将初始化表达式设置为{'a','a','a','a'}，于是就有过多的'a'字符，没有办法给'\0'留出位置
见 [ex9v2.c](./ex9v2.c) 并没有报错，正常输出

## 附加题
### 将一些字符赋给 numbers 的元素，之后用 printf 一次打印一个字符，你会得到什么编译器警告
将字符赋给 numbers 后，无论输出采用 `%d` 还是 `%c`，都没有警告，且输出对应的整形值或字符，见 [ex9v3.c](./ex9v3.c)

### 对 names 执行上述的相反操作，把 names 当成 int 数组，并一次打印一个 int，Valgrind 会提示什么
当 name 赋的 int 值过大时，编译器会给溢出警告; 但 valgrind 不报错. 见 [ex9v3.c](./ex9v3.c) 

### 有多少种其它的方式可以用来打印它
可以按字符串的形式打印，结果会产生乱码. 见 [ex9v3.c](./ex9v3.c) 

### 如果一个字符数组占四个字节，一个整数也占4个字节，你可以像整数一样使用整个 name 吗？你如何用黑魔法实现它？
把整数的位表示按字节拆分分别赋值给 name; 使用时再还原

### 拿出一张纸，将每个数组画成一排方框，之后在纸上画出代码中的操作，看看是否正确
略

### 将 name 转换成 another 的形式，看看代码是否能正常工作
可以正确输出. 见 [ex9v3.c](./ex9v3.c) 
