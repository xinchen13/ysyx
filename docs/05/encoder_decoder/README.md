# 译码器和编码器
译码器和编码器是常用的组合逻辑电路

**译码器**: 译码器通常是多路输入/输出组合逻辑电路，常用的译码器有 `n` 路输入和 `m=2^n` 路输出的逻辑电路，使能信号 `En` 等于0时，不输出有效值; 当 `En` 等于1时，译码器将输入端的二进制输入转化为独热码在输出端输出. 用 Verilog HDL 描述的2-4译码器如下所示

```verilog
module decode24(x, en, y);
  input [1:0] x;
  input en;
  output reg [3:0] y;
  always @ (x or en)
    if (en) begin
      case(x)
        2'd0: y = 4'b0001;
        2'd1: y = 4'b0010;
        2'd2: y = 4'b0100;
        2'd3: y = 4'b1000;
      endcase
    end
    else y = 4'b0000;
endmodule
```

**编码器**: 编码器的功能与译码器相反，将 `m=2^n` 路的输入信号转化成 `n` 路二进制信号输出. Verilog 实现的 4-2 编码器如下所示

```verilog
module encode42(x,en,y);
  input  [3:0] x;
  input  en;
  output reg [1:0]y;

  always @(x or en) begin
    if (en) begin
      case (x)
          4'b0001 : y = 2'b00;
          4'b0010 : y = 2'b01;
          4'b0100 : y = 2'b10;
          4'b1000 : y = 2'b11;
          default: y = 2'b00;
      endcase
    end
    else  y = 2'b00;
  end
endmodule
```

优先编码器允许几个输入端同时有输入信号，按预先排定的优先顺序进行编码

**七段数码管**: 七段 LED 数码管是一种常用的显示元件，分为共阴极和共阳极两种类型，共阴极就是将七个 LED 的阴极连在一起，让其接低电平。这样给任何一个 LED 的另一端高电平，它便能点亮；而共阳极就是将七个 LED 的阳极连在一起，让其接高电平. 这样，给任何一个 LED 的另一端低电平，它就能点亮

## 实验: 实现一个 8-3 优先编码器并在七段数码管上显示
查找 8-3 优先编码器相关原理和实现方法，实现一个 8-3 编码器，完成 8-3 编码器的设计、功能仿真和硬件实现. 输入一个8位二进制数，对此8位二进制数进行高位优先编码成一个3位二进制值，并根据是否有输入增加一位输入指示位，即8个输入全0时指示位为0，有任何一个输入为1时指示位为1. 编码器的使能端可选实现. 将此编码结果及指示位以二进制形式显示在四个发光二极管 LED 上. 再将此结果跟据七段数码管的显示进行译码，将二进制的优先编码结果以十进制的形式显示在数码管上

输入使用拨动开关 `SW7-SW0`，使能端用 `SW8`，输出为 `LED2-0`，输出指示是 `LED4`，数码管输出为 `HEX0`

**实现:**
- 8-3优先编码器 [encoder83.v](./vsrc/encoder83.v): 带有使能，利用`casez`完成高位优先
- 七段数码管 [segment.v](./vsrc/segment.v): 七段数码管事实上是一个译码器，把 8-3 编码器输出的 BCD 码译为电平控制信号
- 顶层模块 [top.v](./vsrc/top.v): 例化，并实现LED显示的功能
- C++ wrapper [sim_main.cpp](./csrc/sim_main.cpp)
- [Makefile](./Makefile)
- 管脚分配[top.nxdc](./constr/top.nxdc)
