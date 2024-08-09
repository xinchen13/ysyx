# ysyx
『一生一芯』的项目工程与学习记录等
- [lecture notes](https://ysyx.oscc.cc/docs/)
- [learning record](https://docs.qq.com/sheet/DZXVEQ0thWGZOaU9t?tab=j1z835)
- [notes](./docs/notes.md)

## Tips
#### set environment variables
```sh
source tenv
```

#### clone this repository & update all the branches
```sh
git clone -o xinchen git@github.com:xinchen13/ysyx.git
cd ysyx
./github-up.sh
```

#### synchronize all the modifications to GitHub
```sh
./github-commit.sh "commit_message"
```

## 『一生一芯』预学习
预学习阶段主要工作是搭建环境，熟悉工具使用以及复习编程、数电等基础

- [如何科学地提问](./docs/01/) :check_mark:
- [Linux系统安装和基本使用](./docs/02/) 
- [复习C语言](./docs/03/) 
- [搭建Verilator仿真环境](./docs/04/) 
- [数字电路基础实验](./docs/05/) 
- [完成PA1](./docs/06/) 

## 基础阶段(Baseline)
搭建基础设施，设计处理器，运行红白机

- [支持RV32IM的NEMU](./docs/07/)
- [用RTL实现最简单的处理器](./docs/08/)
- [运行时环境和基础设施](./docs/09/)
- [支持RV32E的单周期NPC](./docs/10/)
- [设备和输入输出](./docs/11/)
- [异常处理和RT-Thread](./docs/12/)
- [总线](./docs/13)