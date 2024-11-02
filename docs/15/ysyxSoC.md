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