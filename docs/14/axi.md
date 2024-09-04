# AMBA AXI protocol
## Introduction
The AXI protocol supports high-performance, high-frequency system designs for communication between master and slave components

The AXI protocol is transactions-based and defines five independent channels:
- Write request, which has signal names beginning with AW
- Write data, which has signal names beginning with W
- Write response, which has signal names beginning with B
- Read request, which has signal names beginning with AR
- Read data, which has signal names beginning with R

## CLK & RESET
ACLK: 每个AXI接口都有自己的clk, 输入数据在上升沿采样

ARESETn: 低电平有效的复位信号, 异步复位同步释放, 复位时的信号要求:
- 主设备设置AWVALID, WVALID, ARVALID为低电平
- 从设备设置BVALID和RVALID为低电平
- 复位信号为高电平至少一周期后开始工作

## Channel handshake
Each of the five independent channels consists of a set of information signals and VALID and READY signals that provide a two-way handshake mechanism. The information source uses the VALID signal to show when valid address, data, or control information is available on the channel. The destination uses the READY signal to show when it can accept the information

**一些需要维护的关系**:
- A write response must always follow the last write transfer in a write transaction
- Read data and responses must always follow the read request
- When a Master issues a write request, it must be able to provide all write data for that transaction, without dependency on other transactions from that Master
- When a Master has issued a write request and all write data, it must be able to accept all responses for that transaction, without dependency on other transactions from that Master
- When a Master has issued a read request, it must be able to accept all read data for that transaction, without dependency on other transactions from that Master
- A Master is permitted to wait for one transaction to complete before issuing another transaction request
- A Slave is permitted to wait for one transaction to complete before accepting or issuing transfers for another transaction
- Channel handshakes must conform to the dependencies: 具体见 AMBA AXI Protocol Specification 中 Dependencies between channel handshake signals 章节, 总结来说就是 VALID 信号不能依赖于 READY 信号