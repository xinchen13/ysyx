# Linux系统安装和基本使用
## 安装一个Linux操作系统
复用PA讲义的内容, 根据PA0安装Linux操作系统

首先安装Ubuntu22.04虚拟机，系统语言选择English(具体STFW), screenfetch查看系统信息:

```sh
(base) xinchen@sakura:~/ysyx$ screenfetch
                          ./+o+-       xinchen@sakura
                  yyyyy- -yyyyyy+      OS: Ubuntu 22.04 jammy
               ://+//////-yyyyyyo      Kernel: x86_64 Linux 6.5.0-41-generic
           .++ .:/++++++/-.+sss/`      Uptime: 1h 44m
         .:++o:  /++++++++/:--:/-      Packages: 1672
        o:+o+:++.`..```.-/oo+++++/     Shell: bash 5.1.16
       .:+o:+o/.          `+sssoo+/    Resolution: 2558x1278
  .++/+:+oo+o:`             /sssooo.   DE: GNOME 41.7
 /+++//+:`oo+o               /::--:.   WM: Mutter
 \+/+o+++`o++o               ++////.   WM Theme: Adwaita
  .++.o+++oo+:`             /dddhhh.   GTK Theme: Yaru-purple [GTK2/3]
       .+.o+oo:.          `oddhhhh+    Icon Theme: Yaru-purple
        \+.++o+o``-````.:ohdhhhhh+     Font: Cantarell 11
         `:o+++ `ohhhhhhhhyo++os:      Disk: 15G / 98G (16%)
           .o:`.syhhhhhhh/.oo++o`      CPU: Intel Core Ultra 9 185H @ 16x 3.072GHz
               /osyyyyyyo++ooo+++/     GPU: VMware SVGA II Adapter
                   ````` +oo+++o\:     RAM: 2238MiB / 15948MiB
                          `oo++.      
```

备份apt官方源, 更换到tsinghua源(STFW), 之后查看源信息, 结果如下所示

```sh
(base) xinchen@sakura:~/ysyx$ cat /etc/apt/sources.list
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse

# 以下安全更新软件源包含了官方源与镜像站配置，如有需要可自行修改注释切换
deb http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse
# deb-src http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse

# 预发布软件源，不建议启用
# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse
# # deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse
```

下载安装PA实验需要的工具

```sh
sudo apt-get install build-essential    # build-essential packages, include binary utilities, gcc, make, and so on
sudo apt-get install man                # on-line reference manual
sudo apt-get install gcc-doc            # on-line reference manual for gcc
sudo apt-get install gdb                # GNU debugger
sudo apt-get install git                # revision control system
sudo apt-get install libreadline-dev    # a library used later
sudo apt-get install libsdl2-dev        # a library used later
sudo apt-get install llvm llvm-dev      # llvm project, which contains libraries used later
sudo apt-get install vim
sudo apt-get install tmux
```

通过deb包安装VSCode和Chrome; 官网安装Miniconda3; 安装中文语言包与输入法(ibus-pinyin); 安装clash

## Write a "Hello World" program under GNU/Linux
Write a "Hello World" program, compile it, then run it under GNU/Linux. If you do not know what to do, refer to the GNU/Linux tutorial above

首先编辑 [helloworld.c](./helloworld/helloworld.c) 源文件, 保存后编译得到可执行文件`helloworld`, 运行可执行文件`helloworld`查看输出:

```sh
(base) xinchen@sakura:~/ysyx/docs/02/helloworld$ make helloworld
cc     helloworld.c   -o helloworld
(base) xinchen@sakura:~/ysyx/docs/02/helloworld$ ./helloworld 
hello world
```

## Write a Makefile to compile the "Hello World" program
Write a Makefile to compile the "Hello World" program above. If you do not know what to do, refer to the GNU/Linux tutorial

Makefile是一个用来处理较大的c/cpp项目中文件的编译依赖关系的工具. 利用之前编辑的 [helloworld.c](./makefile/helloworld.c) 文件，接着编写简单的 [Makefile](./makefile/Makefile). 定义的`CC`宏表明使用gcc编译器; 当make没有参数时默认执行第一条规则; 对于小型项目这样的Makefile够用, 但是对于有更多依赖的大型项目需要更复杂的规则. 编译项目, 查看结果:

```sh
(base) xinchen@sakura:~/ysyx/docs/02/makefile$ make
gcc    -c -o helloworld.o helloworld.c
gcc -o helloworld helloworld.o
(base) xinchen@sakura:~/ysyx/docs/02/makefile$ ./helloworld 
hello world
```

## Learn to use GDB
Read the GDB tutorial above and use GDB following the tutorial. In PA1, you will be required to implement a simplified version of GDB. If you have not used GDB, you may have no idea to finish PA1:

以 [test.c](./gdb/test.c) 为例. 通过 `gcc -ggdb test.c -o test.out` 编译, `-ggdb` 选项为编译得到的二进制文件添加了 gdb 调试参数

运行报错: `Floating point exception (core dumped)`

gdb 调试记录见 [gdb.log](./gdb/gdb.log)

## Why Linux
Linux每个工具解决一个问题，做到极致，易于使用; 工具组合解决复杂问题

## 在github上添加ssh key
在github上添加一个ssh key, 具体操作STFW (略)

## 获取『一生一芯』框架代码，完成PA0
通过`git clone -b master git@github.com:OSCPU/ysyx-workbench.git ysyx`获取代码到本地 ysyx 文件夹

进行git的配置, 查看全局设置:

```sh
(base) xinchen@sakura:~/ysyx$ git config --global user.name "xinchen" # your student ID and name
(base) xinchen@sakura:~/ysyx$ git config --global user.email "xinchen.sakura@gmail.com"   # your email
(base) xinchen@sakura:~/ysyx$ git config --global core.editor vim                 # your favorite editor
(base) xinchen@sakura:~/ysyx$ git config --global color.ui true
(base) xinchen@sakura:~/ysyx$ cat ~/.gitconfig
[user]
        name = xinchen
        email = xinchen.sakura@gmail.com
[core]
        editor = vim
[color]
        ui = true
[http]
        proxy = socks5://127.0.0.1:7890
        proxy = http://127.0.0.1:7890
[https]
        proxy = socks5://127.0.0.1:7890
        proxy = https://127.0.0.1:7890
```

添加私人仓库到remote作备份, 远端名为xinchen

进入 `ysyx` 目录，初始化子项目:

```sh
```