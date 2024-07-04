# While-Loop And Boolean Expressions

## 布尔表达式
在 C 语言中，实际上没有真正的“布尔”类型，而是用一个整数来代替: `0` 代表 `false`，其它值代表 `true`

并不像 Python 是显式的 `Ture` 或者 `False`. 这是 C 语言更接近计算机工作方式的另一个例子，因为计算机只把值当成数字

## while循环
本节程序: [ex11.c](./ex11.c), 并编译运行:

```sh
(base) xinchen@sakura:~/ysyx/docs/03/11$ ./ex11  24 fG_0 8 true
arg 0: ./ex11
arg 1: 24
arg 2: fG_0
arg 3: 8
arg 4: true
state 0: California
state 1: Oregon
state 2: Washington
state 3: Texas
```

while循环和for功能类似，模板为:

```c
while (TEST) {
    CODE;
}
```

也更需要注意: 
- 初始化 i
- 不同的 while 循环最好使用不同的变量
- i的自增

## 附加题
### 让这些循环倒序执行，通过使用 i-- 从 argc 开始递减直到 0, 你可能需要做一些算数操作让数组的下标正常工作
见 [ex11v1.c](./ex11v1.c)

### 使用 while 循环将 argv 中的值复制到 states
为了防止溢出，while 判断处有两个条件, 见 [ex11v1.c](./ex11v1.c)

### 让这个复制循环不会执行失败，即使 argv 之中有很多元素也不会全部放进 states
如上

### 研究你是否真正复制了这些字符串. 答案可能会让你感到意外和困惑
查看输出，确实一样; 打印两者地址，发现地址也一样，所以字符串没有复制，只是将 states 数组的元素指针指向了 argv 数组的元素