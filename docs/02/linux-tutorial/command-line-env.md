# Command-line Environment
- 如何同时执行多个不同的进程并追踪它们的状态、如何停止或暂停某个进程以及如何使进程在后台运行
- 学习一些能够改善 shell 及其他工具的工作流的方法，这主要是通过定义别名或基于配置文件对其进行配置来实现的,这些方法都可以节省大量的时间. 例如，仅需要执行一些简单的命令，我们就可以在所有的主机上使用相同的配置

## 结束进程
shell 会使用 UNIX 提供的信号机制执行进程间通信. 当一个进程接收到信号时，它会停止执行、处理该信号并基于信号传递的信息来改变其执行. 就这一点而言，信号是一种软件中断

- `Ctrl-C`: shell 会发送一个 SIGINT 信号到进程
- `Ctrl-\`: shell 会发送一个 SIGQUIT 信号到进程
- `kill` 命令: 发送 SIGTERM

## 暂停和后台执行进程
- `Ctrl-Z`: 发送 SIGTSTP，让进程暂停，可以使用 `fg` 或 `bg` 命令恢复暂停的工作
- `jobs`: 列出当前终端会话中尚未完成的全部任务，可以使用百分号 + 任务编号 (jobs 会打印任务编号) 来选取该任务
- 让已经在运行的进程转到后台运行，可以键入 `Ctrl-Z` ，然后紧接着再输入`bg`. 注意，后台的进程仍然是终端进程的子进程，一旦关闭终端(会发送另外一个信号 SIGHUP)，这些后台的进程也会终止. 为了防止这种情况发生，可以使用 `nohup` (一个用来忽略 SIGHUP 的封装) 来运行程序
-  `man signal` 或使用 `kill -l` 来获取更多关于信号的信息

## 终端多路复用: tmux
## 别名
使用 `alias` 命令替换原命令，常用语句如下: `alias alias_name="command_to_alias arg1 arg2"`

## 配置文件 (dotfiles)
很多程序的配置都是通过纯文本格式的被称作 dotfiles 的配置文件来完成的，如

- bash: `~/.bashrc`
- git: `~/.gitconfig`
- vim: `~/.vimrc` 和 `~/.vim` 目录
- ssh: `~/.ssh/config`

## 远端设备
可以使用 `ssh` 连接到其他服务器

## exercises
### 1. 我们可以使用类似 `ps aux | grep` 这样的命令来获取任务的 pid，然后可以基于 pid 来结束这些进程. 但我们其实有更好的方法来做这件事. 在终端中执行 `sleep 10000` 这个任务。然后用 `Ctrl-Z` 将其切换到后台并使用 `bg` 来继续允许它. 现在，使用 `pgrep` 来查找 pid 并使用 `pkill` 结束进程而不需要手动输入 pid

```sh
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial$ sleep 10000
^Z
[1]+  Stopped                 sleep 10000
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial$ bg
[1]+ sleep 10000 &
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial$ pgrep -af sleep
33453 sleep 10000
33534 sleep 1
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial$ pkill sleep
[1]+  Terminated              sleep 10000
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial$ pgrep -af sleep
```

### 2. 如果希望某个进程结束后再开始另外一个进程，应该如何实现呢? 在这个练习中，我们使用 `sleep 60 &` 作为先执行的程序. 一种方法是使用 `wait` 命令. 尝试启动这个休眠命令，然后待其结束后再执行 `ls` 命令

```sh
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial$ sleep 60 &
[1] 33663
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial$ pgrep sleep | wait; ls
```

但是如果在不同的bash会话中进行操作，则上述方法就不起作用了. 因为 `wait` 只能对子进程起作用. 之前我们没有提过的一个特性是，`kill` 命令成功退出时其状态码为0，其他状态则是非0. `kill -0` 则不会发送信号，但是会在进程不存在时返回一个不为0的状态码. 请编写一个 bash 函数 `pidwait` ，它接受一个 pid 作为输入参数，然后一直等待直到该进程结束. 您需要使用 sleep 来避免浪费 CPU 性能

```sh
pidwait()
{
   while kill -0 $1 # 循环直到进程结束
   do
   sleep 1 
   done
   ls
}
```

### 3. 终端多路复用: 学习tmux
### 4. 别名: 创建一个 `dc` 别名，它的功能是当我们错误的将 `cd` 输入为 `dc` 时也能正确执行

```sh
alias dc="cd"
```

### 5. 执行 `history | awk '{$1="";print substr($0,2)}' | sort | uniq -c | sort -n | tail -n 10` 来获取最常用的十条命令，尝试为它们创建别名. (这个命令只在 Bash 中生效，如果使用 ZSH，使用 `history 1` 替换 `history`)

```sh
(base) xinchen@sakura:~/ysyx/docs/02/linux-tutorial$ history | awk '{$1="";print substr($0,2)}' | sort | uniq -c | sort -n | tail -n 10
[1]+  Done                    sleep 60
      2 pgrep -af sleep
      2 ./semester
      2 sudo apt-get upgrade
      3 conda --version
      3 git add .
      3 git push xinchen --all
      3 sudo apt-get update
      4 curl https://glados.rocks/tools/clash-linux.zip -o clash.zip
      7 cd ..
     40 ls
```

### 6. 配置文件
为您的配置文件新建一个文件夹，并设置好版本控制; 在其中添加至少一个配置文件，比如说您的 shell，在其中包含一些自定义设置; 建立一种在新设备进行快速安装配置的方法（无需手动操作）, 最简单的方法是写一个 shell 脚本对每个文件使用 `ln -s`; 将您现有的所有配置文件移动到项目仓库里

```sh
mkdir ~/dotfiles
git init ~/dotfiles
```

快速配置:

```sh
#!/bin/bash
files="bashrc vimrc "

for file in $files; do
   ln -s ~/dotfiles/$file ~/.$file
done
```

### 7. 远端设备
- 通过如下命令，您可以使用ssh连接到其他服务器: `ssh user_name@server_ip`
- `scp` 可以进行文件拷贝
- `sudo vim /etc/ssh/sshd_config` 可以修改ssh配置
- Mosh (即 mobile shell) 对 ssh 进行了改进，它允许连接漫游、间歇连接及智能本地回显