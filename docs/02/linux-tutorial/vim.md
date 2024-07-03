# vim
vim or vscode?
- vim: 基于命令行，多模态编辑器，可编程，避免使用鼠标
- vscode: 流行，丰富的插件

## vim的编辑模式
- Normal: 在文件中四处移动光标进行修改
- Insert: 插入文本
- Replace: 替换文本
- Visual: 选中文本块
- Command-line: 用于执行命令

## 基本操作
do not try to memorize, learn to use

## 自定义 vim
vim 有一个位于 `~/.vimrc` 的文本配置文件 (包含vim脚本命令). 在这提供了一个配置文件 [vimrc](./vimrc)

## exercises
### 1. 完成 vimtutor
### 2. 下载提供的 vimrc，然后把它保存到 `~/.vimrc`, 通读这个注释详细的文件, 然后观察 vim 在这个新的设置下看起来和使用起来有哪些细微的区别
- 语法高亮
- 显示行号 (绝对和相对)
- 下方状态栏
- 禁用了方向键
- 添加鼠标支持

### 3. 安装和配置 `ctrlp.vim` 插件
略

### 4. 练习vim，重做演示
原文件如下所示：

```python
def fizz_buzz(limit):
    for i in range(limit):
        if i % 3 == 0:
            print('fizz')
        if i % 5 == 0:
            print('fizz')
        if i % 3 and i % 5:
            print(i)

def main():
    fizz_buzz(10)
```
- 主函数没有被调用

`G` 到文末，`o` 向下开新的一行，插入以下内容:

```python
if __name__=='__main__':
    main()
```

- 从 0 而不是 1 开始

在循环语句中limit前 `i` 修改为 `1, limit+1` 

- 在 15 的整数倍的时候没有打印 “fizz” 和 “buzz”

使用 `i` 在 `print()` 函数中加入`end=''`

- 在5的整数倍的时候打印了 “fizz” 而不是 “buzz”

定位到整除 5 的 fizz，使用 `R` 替换为 buzz

- 采用硬编码的参数10而不是从命令控制行读取参数

`ggO` 向上打开一行,添加 "import sys"; `/10` 搜索10, 替换为 "int(sys.argv[1])"

修改后保存在 [fizzbuzz.py](./fizzbuzz.py)

### 5. 下个月用 vim 完成所有的文件编辑
### 6. 在其他工具中设置 vim 快捷键
### 7. 进一步自定义你的 `~/.vimrc` 和安装更多插件
### 8. 用 vim 宏将 XML 转换到 JSON
原文件为: [example-data.xml](./example-data.xml)

- `Gdd`, `ggdd` 删除第一行和最后一行
- 录制格式化一个元素的宏(使用寄存器e),前往有 \<name\> 的行 `qe^r"f>s": "<ESC>f<C"<ESC>q`
- 录制格式化一个人物对象的宏, 前往有 \<person\> 的行 `qpS{<ESC>j@eA,<ESC>j@ejS},<ESC>q`
- 录制格式化完成跳转到下一个对象的宏, 前往有 \<person\> 的行 `qq@pjq`
- 执行宏到文件尾 `999@q`
- 手动删除最后的 `,` 并加上 `[ ]` 分隔符

修改完后后的json文件为: [example-data.json](./example-data.json)