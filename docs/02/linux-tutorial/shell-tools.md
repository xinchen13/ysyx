# Shell Tools and Scripting
## Shell scripting
在 Shell 命令的基础上，可以利用 Shell 脚本执行一系列操作并使用条件或循环的控制流，在这里主要关注 bash 脚本

bash 中赋值语句为 `foo=bar`; 访问变量中存储的数值语法为 `$foo`. 需要注意的是, `foo = bar` (使用空格隔开) 是不能正确工作的, 因为解释器会调用程序 foo 并将 = 和 bar 作为参数, **总的来说，在 Shell 脚本中使用空格会起到分割参数的作用**

bash 中的字符串通过 `'` 和 `"` 分隔符来定义，但是它们的含义并不相同. 以 `'` 定义的字符串为原义字符串，其中的变量不会被转义，而 `"` 定义的字符串会将变量值进行替换

bash 支持 `if`, `case`, `while` 和 `for` 等控制流关键字； 也支持函数，它可以接受参数并基于参数进行操作. 下面这个函数是一个例子，它会创建一个文件夹并使用 `cd` 进入该文件夹, 这里 `$1` 是脚本的第一个参数

```sh
mcd () {
    mkdir -p "$1"
    cd "$1"
}
```

与其他脚本语言不同的是，bash 使用了很多特殊的变量来表示参数，错误代码和相关变量，如:

- `$0`: 脚本名
- `$1` 到 `$9`: 脚本的参数 `$1` 是第一个参数，依此类推
- `$@`: 所有参数
- `$#`: 参数个数
- `$?`: 前一个命令的返回值
- `$$`: 当前脚本的进程识别码
- `!!`: 完整的上一条命令，包括参数,常见应用: 当你因为权限不足执行命令失败时，可以使用 `sudo !!` 再尝试一次

命令通常使用 `STDOUT` 来返回输出值，使用 `STDERR` 来返回错误及错误码，便于脚本以更加友好的方式报告错误命令返回值 0 表示正常执行，其他所有非 0 的返回值都表示有错误发生; 可以以变量的形式获取一个命令的输出，这可以通过命令替换(command substitution): 当通过 `$(CMD)` 这样的方式来执行 `CMD` 这个命令时，它的输出结果会替换掉 `$(CMD)`, 如 `echo $(ls)`

当执行脚本时，我们经常需要提供形式类似的参数，bash 使我们可以轻松的实现这一操作，它可以基于文件扩展名展开表达式。这一技术被称为 shell 的通配(globbing)

- 通配符: 当想要利用通配符进行匹配时，可以分别使用 `?` 和 `*` 来匹配一个或任意个字符, 例如对于文件 foo, foo1, foo2, foo10 和 bar, `rm foo?` 这条命令会删除 foo1 和 foo2，而 `rm foo*` 则会删除除了bar之外的所有文件
- 花括号{}: 当有一系列的指令, 其中包含一段公共子串时, 可以用花括号来自动展开这些命令, 这在批量移动或转换文件时非常方便

## Shell tools
- 查看命令使用方法: `man`, `tldr`
- 查找文件: `find`
- 查找代码: `grep` 
- 访问 Shell 中输入的历史命令: `history`
- 概览目录结构: `tree`

## exercises
### 1. 阅读 `man ls`，然后使用 `ls` 命令进行如下操作
- 所有文件（包括隐藏文件）
- 文件打印以人类可以理解的格式输出 (例如使用 454M 而不是 454279954)
- 文件以最近访问顺序排序
- 以彩色文本显示输出结果

```sh
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial$ ls -ahlt --color=auto
total 24K
-rw-rw-r-- 1 xinchen xinchen 3.5K Jul  2 21:36 shell-tools.md
drwxrwxr-x 3 xinchen xinchen 4.0K Jul  2 16:45 .
-rw-rw-r-- 1 xinchen xinchen 5.5K Jul  2 15:25 the-shell.md
drwxrwxr-x 2 xinchen xinchen 4.0K Jul  2 15:24 missing
drwxrwxr-x 6 xinchen xinchen 4.0K Jul  2 14:55 ..
```

### 2. 编写两个 bash 函数 `marco` 和 `polo` 执行下面的操作
每当执行 `marco` 时，当前的工作目录应当以某种形式保存，当执行 `polo`时，无论现在处在什么目录下，都应当 cd 回到当时执行 `marco` 的目录. 为了方便 debug, 可以把代码写在单独的文件 `marco.sh` 中，并通过 `source marco.sh` 命令重新加载函数

见 [macro.sh](./macro.sh), `macro` 保存的路径暂存于 `~/tmp.txt`

### 3. 假设有一个命令很少出错, 因此为了在出错时能够对其进行调试, 需要花费大量的时间重现错误并捕获输出. 编写一段 bash 脚本, 运行如下的脚本直到它出错，将它的标准输出和标准错误流记录到文件,并在最后输出所有内容(报告脚本在失败前共运行了多少次)
待运行脚本保存在 [bugbash.sh](./bugbash.sh) 中, 测试脚本保存在 [test.sh](./test.sh) 中, 测试结果在 [test.log](./test.log) 中

### 4. 编写一个命令, 它可以递归地查找文件夹中所有的 `HTML` 文件，并将它们压缩成 `zip` 文件. 注意即使文件名中包含空格, 命令也应该能够正确执行(提示: 查看 `xargs` 的参数 `-d`)
这里使用 `xargs` 命令，它可以使用标准输入中的内容作为参数. 例如 `ls | xargs rm` 会删除当前目录中的所有文件

首先新建包含 html 文件的目录

```sh
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial$ mkdir html-root
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial$ cd html-root/
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial/html-root$ touch {0..10}.html
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial/html-root$ mkdir sub-dir
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial/html-root$ touch sub-dir/"test zip.html"
```

查找并打包压缩

```sh
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial/html-root$ find . -type f -name "*.html" | xargs -d "\n" tar -cvzf html.zip
./6.html
./7.html
./3.html
./0.html
./1.html
./9.html
./8.html
./2.html
./5.html
./4.html
./sub-dir/test zip.html
./10.html
```

### 5. 编写一个命令或脚本递归的查找文件夹中最近使用的文件. 更通用的做法是按照最近的使用时间列出文件

采用 `-mmin` 进行初筛, 具体参数可调整; `-print0` 与 `-0` 对应: `find . -type f -mmin -60 -print0 | xargs -0 ls -lt | head -10`

```sh
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial$ find . -type f -mmin -60 -print0 | xargs -0 ls -lt | head -10
-rw-rw-r-- 1 xinchen xinchen 6696 Jul  3 09:54 ./shell-tools.md
-rw-rw-r-- 1 xinchen xinchen  232 Jul  3 09:53 ./html-root/html.zip
-rw-rw-r-- 1 xinchen xinchen    0 Jul  3 09:52 ./html-root/sub-dir/test zip.html
-rw-rw-r-- 1 xinchen xinchen    0 Jul  3 09:51 ./html-root/0.html
-rw-rw-r-- 1 xinchen xinchen    0 Jul  3 09:51 ./html-root/10.html
-rw-rw-r-- 1 xinchen xinchen    0 Jul  3 09:51 ./html-root/1.html
-rw-rw-r-- 1 xinchen xinchen    0 Jul  3 09:51 ./html-root/2.html
-rw-rw-r-- 1 xinchen xinchen    0 Jul  3 09:51 ./html-root/3.html
-rw-rw-r-- 1 xinchen xinchen    0 Jul  3 09:51 ./html-root/4.html
-rw-rw-r-- 1 xinchen xinchen    0 Jul  3 09:51 ./html-root/5.html
```