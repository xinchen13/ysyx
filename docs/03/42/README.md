# Stacks and Queues
Stack和Queue是非常简单的数据结构，它们是List的变体. 它们是List的弱化或者转换形式，因为只需要在List的一端放置元素. 对于Stack，你只能能够在一段压入和弹出元素. 而对于Queue，你只能够在开头压入元素，并在末尾弹出（或者反过来）

根据单元测试，需要实现头文件来让它们正常工作: 不能创建`stack.c`或`queue.c`实现文件来通过测试，只能使用`stack.h`和`queue.h`来使测试运行

- 实际上，只需要把queue与stack的对应操作转化为List的对应操作即可

## 附加题
### 使用DArray代替List实现Stack
之前没有实现DArray，略