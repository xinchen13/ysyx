# Ring Buffer
环形缓冲区在处理异步IO时非常实用。它们可以在一端接收随机长度和区间的数据，在另一端以相同长度和区间提供密致的数据块

它们是Queue数据结构的变体，但是它针对于字节块而不是一系列指针

观察这个数据结构，会看到它含有buffer, start和end. RingBuffer的所做的事情只是在buffer中移动start和end，所以当数据到达缓冲区末尾时还可以继续“循环”. 这样就会给人一种在固定空间内无限读取的“幻觉”

在实现中，可以从中读取和写入数据，获得ringbuffer的大小和容量. 也有一些缓冲区使用OS中的技巧来创建虚拟的无限存储，但它们不可移植

由于RingBuffer处理读取和写入内存块，我要保证任何`end == start`出现的时候都要将它们重置为0，使它们从退回缓冲区头部

## 附加题
### 创建RingBuffer的替代版本，使用POSIX的技巧并为其执行单元测试; 为二者添加一个性能对比测试，通过带有随机数据和随机读写操作的模糊测试来比较两个版本. 确保对每个版本进行了相同的操作，便于你在操作之间比较二者

### 使用callgrind和cachegrind比较二者的性能