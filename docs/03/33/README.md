# Linked List Algorithms
使用链表实现冒泡排序(bubble sort)和归并排序(merge sort), 测试文件[list_algos_tests.c](../liblcthw/tests/list_algos_tests.c)

在[list_algos.c](../liblcthw/src/lcthw/list_algos.c)和[list_algos.h](../liblcthw/src/lcthw/list_algos.h)中实现了两种排序算法

## 算法改进
- 归并排序做了大量的链表复制和创建操作，寻找减少它们的办法
- 归并排序的维基百科描述提到了一些优化，实现它们
- 你能使用List_split和List_join（如果你实现了的话）来改进归并排序嘛
- 浏览所有防御性编程原则，检查并提升这一实现的健壮性，避免NULL指针，并且创建一个可选的调试级别的不变量，在排序后实现is_sorted的功能

## 附加题
### 创建单元测试来比较这两个算法的性能。你需要`man 3 time`来查询基本的时间函数，并且需要运行足够的迭代次数，至少以几秒钟作为样本. 改变需要排序的链表中的数据总量，看看耗时如何变化. 寻找方法来创建不同长度的随机链表，并且测量需要多少时间，之后将它可视化并与算法的描述对比
实现了排序长度为5,100,500的时间比较:
- 长度为5和100时冒泡排序比较快，原因在于问题规模小，List复制和递归调用占用了较多时间
- 当问题规模到达500时，归并排序优势明显，与时间复杂度趋势相同
- 结果如下:

```sh
bubble sort time: 0.331225 seconds
merge sort time: 1.693490 seconds
100-len: bubble sort time: 5.084960 seconds
100-len: merge sort time: 8.176788 seconds
500-len: bubble sort time: 135.477240 seconds
500-len: merge sort time: 64.144663 seconds
```

### 解释为什么对链表排序十分麻烦
链表不能够进行随机访问(索引)，同时交换数据也麻烦

### 实现`List_insert_sorted`（有序链表），它使用`List_compare`，接收一个值，将其插入到正确的位置，使链表有序. 它与创建链表后再进行排序相比怎么样
能够大量减少数据的访问和新链表的创建

### 尝试实现维基百科上“自底向上”的归并排序。上面的代码已经是C写的了，所以很容易重新创建，但是要试着理解它的工作原理，并与这里的低效版本对比
略