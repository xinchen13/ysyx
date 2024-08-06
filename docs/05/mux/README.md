# 选择器
选择器是常用的组合逻辑电路，由多路数据输入，选择控制输入以及一路数据输出组成，选择控制信号决定了输出的是第几路输入信号

## verilog 常见的建模方法
对一个 1-bit 2选1选择器，a 和 b 为输入，s 为选择信号，y 为输出，则其逻辑表达式为 `y=(~s&a)|(s&b)`

### 数据流建模
数据流建模主要采用连续赋值语句 `assign` 描述电路功能，常用于组合逻辑电路，用 Verilog HDL 实现的2选1数据选择器：

```verilog
module m_2mux1(a,b,s,y);
    input a,b,s; // 3 * 1-bit wire input 
    output y; // 1 * 1-bit wire output
    assign y = (~s&a)|(s&b);
endmodule
```

### 结构化建模
结构化建模主要通过逐层例化子模块的方式实现电路，2选1数据选择器：

```verilog
module my_and(a,b,c);
  input  a,b;
  output c;
  assign c = a & b;
endmodule

module my_or(a,b,c);
  input  a,b;
  output c;
  assign c = a | b;
endmodule

module my_not(a,b);
  input  a;
  output b;
  assign b = ~a;
endmodule

module mux21b(a,b,s,y);
  input  a,b,s;
  output y;
  wire l, r, s_n; // 内部网线声明
  my_not i1(.a(s), .b(s_n));        // 实例化非门，实现~s
  my_and i2(.a(s_n), .b(a), .c(l)); // 实例化与门，实现(~s&a)
  my_and i3(.a(s),   .b(b), .c(r)); // 实例化与门，实现(s&b)
  my_or  i4(.a(l),   .b(r), .c(y)); // 实例化或门，实现(~s&a)|(s&b)
endmodule
```

### 行为建模
行为建模是类似面向过程的程序设计的电路描述方法，如使用 if, case 等高级语句等对电路进行逻辑描述，这里的 2mux1 如下所示

```verilog
module mux21c(a,b,s,y);
  input   a,b,s;
  output reg  y;   // y在always块中被赋值，一定要声明为reg型的变量

  always @ (*)
    if(s==0) y = a;
    else y = b;
endmodule
```

## 选择器模板
这里提供一个通用的选择器模板 [mux_template.v](./vsrc/mux_template.v)

- `MuxKey` 模块实现了“键值选择”功能，即在一个(键值，数据)的列表 `lut` 中，根据给定的键值 `key`，将 `out` 设置为与其匹配的数据, 若列表中不存在键值为 `key` 的数据，则 `out` 为 0; `MuxKeyWithDefault` 模块可以提供一个默认值 `default_out` ，当列表中不存在键值为 `key` 的数据，则 `out` 为 `default_out` 
- 使用者需要提供键值对的数量 `NR_KEY`，键值的位宽 `KEY_LEN` 以及数据的位宽 `DATA_LEN` 这三个参数，并保证端口的信号宽度与提供的参数一致，否则将会输出错误的结果
- 若列表中存在多个键值为 `key` 的数据，则 `out` 的值是未定义的，需要使用者来保证列表中的键值互不相同

## 实验: 二位四选一选择器
用选择器模板实现一个2位4选1的选择器，选择器有5个2位输入端，分别为 X0, X1, X2, X3和Y，输出端为 F; X0, X1, X2, X3 是四个2位的输入变量. 输出 F 端受控制端 Y 的控制，选择其中的一个 X 输出，当 Y = 00 时，输出端输出 X0，即 F = X0; 当 Y = 01 时，输出端输出 X1，即 F = X1, 以此类推

选择开发板上的 `SW0` 和 `SW1` 作为控制端Y，`SW2—SW9` 作为四个两位数据输入端 X0–X3，将两位的输出端 F 接到发光二极管 `LEDR0` 和 `LEDR1` 上显示输出，完成设计，对自己的设计进行功能仿真，并下载到开发板上验证电路性能

**实现:** 根据模板例化即可
- Verilog 源文件 [top.v](./vsrc/top.v)
- cpp 仿真文件 [sim_main.cpp](./csrc/sim_main.cpp)
- [Makefile](./Makefile)
- 管脚约束 [top.nxdc](./constr/top.nxdc)

通过 `make run` 运行, 多组检验结果无误