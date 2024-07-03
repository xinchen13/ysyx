# git
用于追踪源代码或其他文件、文件夹改动的工具. 顾名思义，这些工具可以帮助我们管理代码的修改历史; 不仅如此，它还可以让协作编码变得更方便. VCS 通过一系列的快照将某个文件夹及其内容保存了起来，每个快照都包含了文件或文件夹的完整状态

- 一个人进行编程工作，它可以帮助创建项目的快照，记录每个改动的目的、基于多分支并行开发
- 和别人协作开发时，可以看到别人对代码进行的修改，同时解决由于并行开发引起的冲突

#### 快照: Git 将顶级目录中的文件和文件夹作为集合，并通过一系列快照来管理其历史记录
在 Git 的术语里，文件被称作 Blob 对象(数据对象)，也就是一组数据. 目录则被称之为“树”，它将名字与 Blob 对象或树对象进行映射，使得目录中可以包含其他目录. 快照则是被追踪的最顶层的树，例如，一个树看起来可能是这样的：

```
<root> (tree)
|
+- foo (tree)
|  |
|  + bar.txt (blob, contents = "hello world")
|
+- baz.txt (blob, contents = "git is wonderful")
```

#### 历史记录建模: 关联快照
在 Git 中，历史记录是一个由快照组成的有向无环图. 这代表 Git 中的每个快照都有一系列的“父辈”，也就是其之前的一系列快照. 注意，快照具有多个“父辈”而非一个，因为某个快照可能由多个父辈而来。例如经过合并后的两条分支

在 Git 中，这些快照被称为“提交”. 通过可视化的方式来表示这些历史提交记录时，看起来差不多是这样的(箭头指向了当前提交的父辈):

```
o <-- o <-- o <-- o <---- o
            ^            /
             \          v
              --- o <-- o
```

在第三次提交之后，历史记录分岔成了两条独立的分支. 这可能因为此时需要同时开发两个不同的特性，它们之间是相互独立的. 开发完成后，这些分支可能会被合并并创建一个新的提交，这个新的提交会同时包含这些特性

#### 数据模型及其伪代码表示

```
// 文件就是一组数据
type blob = array<byte>

// 一个包含文件和目录的目录
type tree = map<string, tree | blob>

// 每个提交都包含一个父辈，元数据和顶层树
type commit = struct {
    parent: array<commit>
    author: string
    message: string
    snapshot: tree
}
```

#### 对象和内存寻址
Git 中的对象可以是 blob, 树或提交; Git 在储存数据时，所有的对象都会基于它们的 SHA-1 哈希进行寻址

#### 引用
Git 的快照标记是给哈希值赋予可读的名字，也就是引用(references). 引用是指向提交的指针. 与对象不同的是，它是可变的(引用可以被更新，指向新的提交), 例如 `master` 引用通常会指向主分支的最新一次提交

这样，Git 就可以使用诸如 `master` 这样人类可读的名称来表示历史记录中某个特定的提交，而不需要在使用一长串十六进制字符了

通常情况下，我们会想要知道“我们当前所在位置”，并将其标记下来. 这样当我们创建新的快照的时候，我们就可以知道它的相对位置. 在 Git 中，我们当前的位置有一个特殊的索引，它就是 `HEAD`

#### 仓库: 对象和引用
在硬盘上，Git 仅存储对象和引用: 因为其数据模型仅包含这些东西. 所有的 git 命令都对应着对提交树的操作，例如增加对象，增加或删除引用

## exercises
### 1. 如果您之前从来没有用过 Git，推荐您阅读 Pro Git 的前几章，或者完成像 Learn Git Branching 这样的教程.重点关注Git命令和数据模型相关内容

### 2. Fork本课程网站的仓库
- 将版本历史可视化并进行探索: `git log --all --graph --decorate > git-log-graph.log`
- 谁最后修改了 `README.md` 文件: `git log README.md`
- 最后一次修改 `_config.yml` 文件中 `collections:` 行时的提交信息是什么: `git blame _config.yml | grep collections:`, `git show`

### 3. 使用 Git 时的一个常见错误是提交本不应该由 Git 管理的大文件，或是将含有敏感信息的文件提交给 Git. 尝试向仓库中添加一个文件并添加提交信息，然后将其从历史中删除

误提交了 `my_password` 文件, 利用 `git filter-branch` 清除提交记录，文件和提交记录均删除

```sh
$ git filter-branch --force --index-filter 'git rm --cached --ignore-unmatch ./my_password'  --prune-empty --tag-name-filter cat -- --all
```

### 4. 从 GitHub 上克隆某个仓库，修改一些文件。当您使用 `git stash` 会发生什么？当您执行 `git log --all --oneline` 时会显示什么？通过 `git stash pop` 命令来撤销 `git stash` 操作，什么时候会用到这一技巧

`git stash` 撤销了修改，`git stash pop` 撤销了撤销操作
`git log --all --oneline` 以简洁的形式显示了提交操作

### 5. 与其他的命令行工具一样，Git 也提供了一个名为 `~/.gitconfig` 配置文件. 请在 `~/.gitconfig` 中创建一个别名，使您在运行 `git graph` 时，您可以得到 `git log --all --graph --decorate --oneline` 的输出结果
向配置文件中添加:

```sh
[alias]
    graph = log --all --graph --decorate --oneline
```

之后运行 `git graph` 即可看到结果

### 6. 可以通过执行 `git config --global core.excludesfile ~/.gitignore_global` 在 `~/.gitignore_global` 中创建全局忽略规则. 配置您的全局 gitignore 文件来自动忽略系统或编辑器的临时文件，例如 `.DS_Store`

```sh
$ git config --global core.excludesfile ~/.gitignore .DS_Store
```