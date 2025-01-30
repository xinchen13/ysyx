# 性能评估结果

## 测试标准
- case 使用 train 规模的 microbench
- 开启 PMU, apb_delayer 的 device 延迟是 core 延迟的10倍

## 0 - 未经优化的 ysyxsoc
```
[/home/xinchen/ysyx/npc/csrc/tiktok.c:52 pmu_display] ************ Performance Monitor ************
[/home/xinchen/ysyx/npc/csrc/tiktok.c:53 pmu_display] Total cycle count = 18509971665
[/home/xinchen/ysyx/npc/csrc/tiktok.c:54 pmu_display]    - A(alu) type count         = 231768074(0.013)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:55 pmu_display]    - B(branch) type count      = 113140834(0.006)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:56 pmu_display]    - C(csr) type count         = 1(0.000)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:57 pmu_display]    - Memory load type count    = 4095556530(0.221)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:58 pmu_display]    - Memory store type count   = 1389412770(0.075)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:59 pmu_display]    - Front end: fetch count    = 12484886346(0.674)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:60 pmu_display] Total insts count = 195207110
[/home/xinchen/ysyx/npc/csrc/tiktok.c:61 pmu_display]    - A(alu) type count         = 115884037(0.594)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:62 pmu_display]    - B(branch) type count      = 56570417(0.290)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:63 pmu_display]    - C(csr) type count         = 1(0.000)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:64 pmu_display]    - Memory load type count    = 15597316(0.080)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:65 pmu_display]    - Memory store type count   = 7155339(0.037)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:66 pmu_display] CPI = 94.822 (IPC = 0.010546)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:67 pmu_display]    - A(alu) type         = 2.000
[/home/xinchen/ysyx/npc/csrc/tiktok.c:68 pmu_display]    - B(branch) type      = 2.000
[/home/xinchen/ysyx/npc/csrc/tiktok.c:69 pmu_display]    - C(csr) type         = 1.000
[/home/xinchen/ysyx/npc/csrc/tiktok.c:70 pmu_display]    - Memory load type    = 262.581
[/home/xinchen/ysyx/npc/csrc/tiktok.c:71 pmu_display]    - Memory store type   = 194.178
[/home/xinchen/ysyx/npc/csrc/tiktok.c:73 pmu_display] *********************************************
```

## 1 - 增加 icache
cache line 大小 4 bytes, 16个 cache line, 直接映射

```
[/home/xinchen/ysyx/npc/csrc/tiktok.c:52 pmu_display] ************ Performance Monitor ************
[/home/xinchen/ysyx/npc/csrc/tiktok.c:53 pmu_display] Total cycle count = 10030024312
[/home/xinchen/ysyx/npc/csrc/tiktok.c:54 pmu_display]    - A(alu) type count         = 231771098(0.023)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:55 pmu_display]    - B(branch) type count      = 113147282(0.011)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:56 pmu_display]    - C(csr) type count         = 1(0.000)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:57 pmu_display]    - Memory load type count    = 4082994102(0.407)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:58 pmu_display]    - Memory store type count   = 1388539746(0.138)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:59 pmu_display]    - Front end: fetch count    = 4018356676(0.401)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:60 pmu_display] Total insts count = 195215407
[/home/xinchen/ysyx/npc/csrc/tiktok.c:61 pmu_display]    - A(alu) type count         = 115885549(0.594)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:62 pmu_display]    - B(branch) type count      = 56573641(0.290)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:63 pmu_display]    - C(csr) type count         = 1(0.000)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:64 pmu_display]    - Memory load type count    = 15600937(0.080)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:65 pmu_display]    - Memory store type count   = 7155279(0.037)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:66 pmu_display] CPI = 51.379 (IPC = 0.019463)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:67 pmu_display]    - A(alu) type         = 2.000
[/home/xinchen/ysyx/npc/csrc/tiktok.c:68 pmu_display]    - B(branch) type      = 2.000
[/home/xinchen/ysyx/npc/csrc/tiktok.c:69 pmu_display]    - C(csr) type         = 1.000
[/home/xinchen/ysyx/npc/csrc/tiktok.c:70 pmu_display]    - Memory load type    = 261.715
[/home/xinchen/ysyx/npc/csrc/tiktok.c:71 pmu_display]    - Memory store type   = 194.058
[/home/xinchen/ysyx/npc/csrc/tiktok.c:73 pmu_display] *********************************************
```