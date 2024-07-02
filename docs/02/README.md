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