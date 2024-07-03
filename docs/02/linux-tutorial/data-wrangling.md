# Data Wrangling
将某种形式的数据(如全部系统日志)转换成了另外一种形式的数据(如仅包含 intel 的日志)

查看系统日志: `journalctl`; 筛选涉及sshd的信息: `journalctl | grep sshd`

`sed` 是一个基于文本编辑器 `ed` 构建的”流编辑器”. 在 `sed` 中，基本上是利用一些简短的命令来修改文件，而不是直接操作文件的内容

## 正则表达式
正则表达式能够从文本中提取信息; 多数的 ASCII 字符都表示它们本来的含义，但是有一些字符确实具有表示匹配行为的“特殊”含义. 常见的模式有

- `.` 除换行符之外的”任意单个字符”
- `*` 匹配前面字符零次或多次
- `+` 匹配前面字符一次或多次
- `[abc]` 匹配 a, b 和 c 中的任意一个
- `(RX1|RX2)` 任何能够匹配 RX1 或 RX2 的结果
- `^` 行首
- `$` 行尾
- `d` 任何数字
- `D` 任何非数字
- `{m}` 重复n次
- `[a-z]` 小写字母
- `[0-9]` 所有数字
- `[A-Za-z0-9]` 所有字母和数字

## exercises
### 1. 学习交互式正则表达式教程
### 2. 统计 words 文件 `/usr/share/dict/words` 中包含至少三个 a 且不以 `'s` 结尾的单词个数. 这些单词中，出现频率前三的末尾两个字母是什么？ sed 的 `y` 命令，或者 `tr` 程序也许可以帮你解决大小写的问题. 共存在多少种词尾两字母组合？哪个组合从未出现过？

```sh
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial$ cat /usr/share/dict/words | tr "[:upper:]" "[:lower:]" | grep -E "^([^a]*a){3}.*$" | grep -v "'s$" | wc -l
854
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial$ cat /usr/share/dict/words | tr "[:upper:]" "[:lower:]" | grep -E "^([^a]*a){3}.*$" | grep -v "'s$" | sed -E "s/.*([a-z]{2})$/\1/" | sort | uniq -c | sort | tail -n3
      8 am
      8 ce
      9 ca
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial$ cat /usr/share/dict/words | tr "[:upper:]" "[:lower:]" | grep -E "^([^a]*a){3}.*$" | grep -v "'s$" | sed -E "s/.*([a-z]{2})$/\1/" | sort | uniq | wc -l
112
```

- 先用 [all.sh](./all.sh) 把所有组合保存在 [all.txt](./all.txt): `./all.sh > all.txt`
- 再保存出现过的组合到 [occurance.txt](./occurance.txt): `cat /usr/share/dict/words | tr "[:upper:]" "[:lower:]" | grep -E "^([^a]*a){3}.*$" | grep -v "'s$" | sed -E "s/.*([a-z]{2})$/\1/" | sort | uniq > occurance.txt`
- 比较二者不同: `diff --unchanged-group-format='' <(cat occurance.txt) <(cat all.txt) | wc -l`

### 3. 进行原地替换听上去很有诱惑力，例如 `sed s/REGEX/SUBSTITUTION/ input.txt > input.txt` 但是这并不是一个明智的做法，为什么呢？还是说只有sed是这样的? 查看`man sed`来完成这个问题
表达式中后一个 `input.txt` 会首先被清空，而且是发生在前的. 所以前面一个 `input.txt` 在还没有被sed处理时已经为空了. 在使用正则处理文件前最好是首先备份文件

### 4. 找出最近十次开机的开机时间平均数、中位数和最长时间
- 编辑获取最近10次开机时间的脚本 [getlog.sh](./getlog.sh)
- `./getlog.sh > starttime.txt`，保存开机数据到 [starttime.txt](./starttime.txt)
- 获取各种数值(分别是最长时间,最短时间,平均值,中位数):

```sh
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial$ cat starttime.txt | grep "systemd\[1\]" | sed -E "s/.*=\ (.*)s\.$/\1/"| sort -n | tail -n1
42.289
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial$ cat starttime.txt | grep "systemd\[1\]" | sed -E "s/.*=\ (.*)s\.$/\1/"| sort -nr | tail -n1
9.462
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial$ cat starttime.txt | grep "systemd\[1\]" | sed -E "s/.*=\ (.*)s\.$/\1/"| paste -sd+ | bc -l | awk '{print $1/7}'
18.7497
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial$ cat starttime.txt | grep "systemd\[1\]" | sed -E "s/.*=\ (.*)s\.$/\1/"| sort -n |paste -sd\  | awk '{print ($4)}'
18.872
```

由于开关机次数只有7, 因此对命令进行了调整