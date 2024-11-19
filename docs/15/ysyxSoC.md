# ysyxSoC
ysyxSoC是可以在verilator上运行的SoC框架

## ysyxSoC包含的外围设备和相应的地址空间

| 设备     | 地址空间     | 其他     |
| -------- | -------- | -------- |
| CLINT	        |    0x0200_0000~0x0200_ffff |   |
| SRAM	        |    0x0f00_0000~0x0fff_ffff |   |
| UART16550	    |    0x1000_0000~0x1000_0fff |   |
| SPI master	|    0x1000_1000~0x1000_1fff |   |
| GPIO	        |    0x1000_2000~0x1000_200f |   |
| PS2	        |    0x1001_1000~0x1001_1007 |   |
| MROM	        |    0x2000_0000~0x2000_0fff |   |
| VGA	        |    0x2100_0000~0x211f_ffff |   |
| Flash	        |    0x3000_0000~0x3fff_ffff |   |
| ChipLink MMIO	|    0x4000_0000~0x7fff_ffff |   |
| PSRAM	        |    0x8000_0000~0x9fff_ffff |   |
| SDRAM	        |    0xa000_0000~0xbfff_ffff |   |
| ChipLink MEM	|    0xc000_0000~0xffff_ffff |   |
| Reverse	    |   其他 |   |

- 除了AXI以外, 还有APB, wishbone和SPI这些总线
- ysyxSoC的设备部分, 收集了一些设备控制器的开源项目, 相关代码在 `ysyxSoC/perip/` 目录下. 部分设备通过直接实例化 `rocket-chip` 项目中的IP来实现, 这部分设备并不在 `ysyxSoC/perip/` 目录下, 具体可以参考 `ysyxSoC/src/` 中的相关代码
- ysyxSoC的总线部分, 主要借助开源社区rocket-chip项目的diplomacy框架来实现它, 相关代码在`ysyxSoC/src/`目录下. 借助diplomacy, 可以很容易地将一个具备总线接口的设备接入ysyxSoC
- 为了设备可以得知软件需要访问的实际数据位宽, 从而在若干设备寄存器的地址紧密排布时, 亦可仅访问其中的某个寄存器, 避免意外改变设备的状态, 完整的AXI总线协议通过 `arsize`/`awsize` 信号来指示实际访问的数据位宽, 同时引入"窄传输"的概念, 用于指示"实际数据位宽小于总线数据位宽"的情况. 这两个"数据位宽"的概念并非完全一致, 具体地, 总线数据位宽是在硬件设计时静态决定的, 它表示一次总线传输的最大数据位宽, 也用于计算总线的理论带宽; 而实际数据位宽(即 `arsize`/`awsize` 信号的值)则由软件访存指令中的位宽信息动态决定, 它表示一次总线传输的实际数据位宽, 例如, `lb` 指令只访问1字节, 而 `lw` 指令则访问4字节

