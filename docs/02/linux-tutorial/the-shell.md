# THE SHELL

## What is the shell
允许执行程序，输入并获取某种半结构化的输出的文字交互接口. 这里使用 Bourne Again SHell, 简称 bash, 见 `man bash`

## Using the shell
打开终端，看到 `(base) xinchen@sakura:~/ysyx$`, 这是 shell 最主要的文本接口. 主机名是`sakura`并且当前的工作目录 (current working directory) 或者说当前所在的位置是 `~/ysyx` (home/ysyx). `$` 符号表示现在的身份不是root 

## Navigating in the shell
常用命令有: `pwd`, `cd`, `ls`, `mkdir`, `mv`, `cp`, `rm`

## File permissions
root user 可以创建、读取、更新和删除系统中的任何文件, 可以使用 `sudo` 命令来获取管理员权限. 执行命令 `ls -l ~`, 查看输出:

```sh
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial$ ls -l ~
total 48
drwxr-xr-x  3 xinchen xinchen 4096 Jun  6  2023 clash
drwxr-xr-x  2 xinchen xinchen 4096 Jul  1 15:48 Desktop
drwxr-xr-x  2 xinchen xinchen 4096 Jul  1 15:48 Documents
drwxr-xr-x  4 xinchen xinchen 4096 Jul  2 14:42 Downloads
drwxrwxr-x 19 xinchen xinchen 4096 Jul  1 16:53 miniconda3
drwxr-xr-x  2 xinchen xinchen 4096 Jul  1 15:48 Music
drwxr-xr-x  3 xinchen xinchen 4096 Jul  2 14:19 Pictures
drwxr-xr-x  2 xinchen xinchen 4096 Jul  1 15:48 Public
drwx------  4 xinchen xinchen 4096 Jul  1 16:11 snap
drwxr-xr-x  2 xinchen xinchen 4096 Jul  1 15:48 Templates
drwxr-xr-x  2 xinchen xinchen 4096 Jul  1 15:48 Videos
drwxrwxr-x  9 xinchen xinchen 4096 Jul  2 14:23 ysyx
```

每行第一个字符 `d` 表示是一个目录; 然后接下来的九个字符，每三个字符构成一组 rwx. 它们分别代表了文件所有者，用户组 (users) 以及其他所有人具有的权限, 其中 `-` 表示该用户不具备相应的权限

从上面的信息来看，只有文件所有者可以修改 `w`; 为了进入某个文件夹，用户需要具备该文件夹以及其父文件夹的“搜索”权限 (即可执行 `x`)权限表示; 为了列出它的包含的内容，用户必须对该文件夹具备读权限 `r`

对于文件来说，权限的意义也是类似的，`/bin` 目录下的程序在最后一组，即表示所有人的用户组中，均包含 `x` 权限，也就是说任何人都可以执行这些程序

## 程序间创建链接
shell最主要的流：输入输出流
- 通过 `> file` 与 `< file` 重定向到文件
- 通过 `>>` 向文件追加内容
- 使用管道 (pipes) 将一个程序的输出和另一个程序的输入连接起来: `|` 操作符

## exercises
### 1. 查看shell

```sh
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial$ echo $SHELL
/bin/bash
```

### 2. 新建 missing 文件夹（为了方便就不在 `/tmp` 下新建了）

```sh
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial$ mkdir missing
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial$ ls
missing  the-shell.md
```

### 3. 用 `man` 查看程序 `touch` 的手册

### 4. 用 `touch` 新建一个叫 semester 的文件

```sh
(base) xinchen@xinchen-vm-ubuntu2204:~/ysyx/docs/02/linux-tutorial$ touch missing/semester
(base) xinchen@xinchen-vm-ubuntu2204:~/ysyx/docs/02/linux-tutorial$ ls missing/
semester
```

### 5. 将以下内容一行一行地写入 semester 文件

```sh
#!/bin/sh
curl --head --silent https://missing.csail.mit.edu
```

利用输出流重定向和追加写入，保存到 semester:

```sh
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial$ echo '#!/bin/sh' > missing/semester 
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial$ echo 'curl --head --silent https://missing.csail.mit.edu' >> missing/semester 
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial$ cat -n missing/semester 
     1  #!/bin/sh
     2  curl --head --silent https://missing.csail.mit.edu
```

### 6. 尝试执行这个文件

```sh
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial/missing$ ./semester
bash: ./semester: Permission denied
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial/missing$ ls -l
total 4
-rw-rw-r-- 1 xinchen xinchen 61 Jul  2 15:22 semester
```

发现该文件没有执行权限 `x`

### 7. 查看 chmod 的手册

### 8. 使用 chmod 命令改变权限，使 `./semester` 能够成功执行

```sh
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial/missing$ chmod +x semester 
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial/missing$ ./semester 
HTTP/2 200 
server: GitHub.com
content-type: text/html; charset=utf-8
last-modified: Sat, 18 May 2024 14:18:01 GMT
access-control-allow-origin: *
etag: "6648b899-205d"
expires: Tue, 02 Jul 2024 03:07:41 GMT
cache-control: max-age=600
x-proxy-cache: MISS
x-github-request-id: AAB8:3A5449:AF74:BCE2:66836CA4
accept-ranges: bytes
age: 0
date: Tue, 02 Jul 2024 07:24:24 GMT
via: 1.1 varnish
x-served-by: cache-qpg1240-QPG
x-cache: HIT
x-cache-hits: 0
x-timer: S1719905064.383194,VS0,VE263
vary: Accept-Encoding
x-fastly-request-id: 78dbc1438180807e022612c0e74de3a68f39dfdc
content-length: 8285
```

### 9. 使用 `|` 和 `>`，将 semester 文件输出的最后更改日期信息，写入主目录下的 `last-modified.txt`的文件中
为了方便直接保存在当前文件夹了

```sh
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial/missing$ ./semester | grep "last-modified" > last-modified.txt
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial/missing$ cat last-modified.txt 
last-modified: Sat, 18 May 2024 14:18:01 GMT
```

### 10. 写一段命令来从 `/sys` 中获取笔记本的电量信息，或者台式机 CPU 的温度
在 `/sys/class/powercap/` 等文件夹中未找到电池信息, 猜测可能的原因是虚拟机没有对应的驱动