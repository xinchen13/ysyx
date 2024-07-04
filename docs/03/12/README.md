# If, Else-If, Else
输入示例代码 [ex12.c](./ex12.c), 并编译运行:

```sh
(base) xinchen@sakura:~/ysyx/docs/03/12$ ./ex12  f g  h j k 
You have too many arguments. You suck.
(base) xinchen@sakura:~/ysyx/docs/03/12$ ./ex12 hh 123
Here's your arguments:
./ex12 hh 123 
(base) xinchen@sakura:~/ysyx/docs/03/12$ ./ex12 
You only have one argument. You suck.
```

`if` 语句用于条件分支，其语法如下:

```c
if(TEST) {
    CODE;
} else if(TEST) {
    CODE;
} else {
    CODE;
}
```

## 使程序崩溃
### 移除 else 部分，使它不能处理边界情况
程序不会报错，只是不能处理边界情况

### 将 `&&` 改为 `||`，于是你会把与操作变成或操作，并且看看会发生什么
else 语句失效了, 只要不满足 `argc == 1`，就会进入第二种条件

## 附加题
### `&&` 执行与操作，上网搜索与之不同的布尔运算符
与操作是逻辑运算符，根据表达式的值返回真值或假值; 布尔运算符执行位运算，结果是位向量

### 为这个程序编写更多的测试用例，看看你会写出什么
见上

### 回到练习 10 和 11，使用 if 语句使循环提前退出，需要 break 语句来实现它，搜索它的有关资料
可以用到的模板为:

```c
while (TEST1) {
    if (TEST2) {
        break;
    }
}
```

### 第一个判断所输出的话真的正确吗？由于你的 “第一个参数” 不是用户输入的第一个参数，把它改正
见 [ex12v1.c](./ex12v1.c)