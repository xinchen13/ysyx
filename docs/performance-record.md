# 性能评估结果

## 测试标准
- case 使用 train 规模的 microbench
- 开启 PMU, apb_delayer 的 device 延迟是 core 延迟的10倍

## 0 - 未经优化的 ysyxsoc

```
======= Running MicroBench [input *train*] =======
[qsort] Quick sort: * Passed.
  min time: 1074499.516 ms [0]
[queen] Queen placement: * Passed.
  min time: 437455.216 ms [0]
[bf] Brainf**k interpreter: * Passed.
  min time: 1151817.932 ms [0]
[fib] Fibonacci number: * Passed.
  min time: 8996893.156 ms [0]
[sieve] Eratosthenes sieve: * Passed.
  min time: 1194640.328 ms [0]
[15pz] A* 15-puzzle search: * Passed.
  min time: 775803.948 ms [0]
[dinic] Dinic's maxflow algorithm: * Passed.
  min time: 665170.617 ms [0]
[lzip] Lzip compression: * Passed.
  min time: 583637.031 ms [0]
[ssort] Suffix sort: * Passed.
  min time: 1008676.955 ms [0]
[md5] MD5 digest: * Passed.
  min time: 721904.076 ms [0]
==================================================
MicroBench PASS
Scored time: 16610498.775 ms
Total  time: 18482828.998 ms
[/home/xinchen/ysyx/npc/csrc/tiktok.c:56 pmu_display] ************ Performance Monitor ************
[/home/xinchen/ysyx/npc/csrc/tiktok.c:57 pmu_display] Total cycle count = 18509971665
[/home/xinchen/ysyx/npc/csrc/tiktok.c:58 pmu_display]    - A(alu) type count         = 231768074(0.013)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:59 pmu_display]    - B(branch) type count      = 113140834(0.006)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:60 pmu_display]    - C(csr) type count         = 1(0.000)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:61 pmu_display]    - Memory load type count    = 4095556530(0.221)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:62 pmu_display]    - Memory store type count   = 1389412770(0.075)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:63 pmu_display]    - Front end: fetch count    = 12484886346(0.674)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:64 pmu_display] Total insts count = 195207110
[/home/xinchen/ysyx/npc/csrc/tiktok.c:65 pmu_display]    - A(alu) type count         = 115884037(0.594)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:66 pmu_display]    - B(branch) type count      = 56570417(0.290)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:67 pmu_display]    - C(csr) type count         = 1(0.000)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:68 pmu_display]    - Memory load type count    = 15597316(0.080)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:69 pmu_display]    - Memory store type count   = 7155339(0.037)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:70 pmu_display] CPI = 94.822 (IPC = 0.010546)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:71 pmu_display]    - A(alu) type         = 2.000
[/home/xinchen/ysyx/npc/csrc/tiktok.c:72 pmu_display]    - B(branch) type      = 2.000
[/home/xinchen/ysyx/npc/csrc/tiktok.c:73 pmu_display]    - C(csr) type         = 1.000
[/home/xinchen/ysyx/npc/csrc/tiktok.c:74 pmu_display]    - Memory load type    = 262.581
[/home/xinchen/ysyx/npc/csrc/tiktok.c:75 pmu_display]    - Memory store type   = 194.178
[/home/xinchen/ysyx/npc/csrc/tiktok.c:95 pmu_display] *********************************************
[/home/xinchen/ysyx/npc/csrc/tiktok.c:298 core_exec] npc: HIT GOOD TRAP at pc = 0xa0005614
```

## 1 - 增加 icache
cache line 大小 4 bytes, 16个 cache line, 直接映射

```
======= Running MicroBench [input *train*] =======
[qsort] Quick sort: * Passed.
  min time: 832880.290 ms [0]
[queen] Queen placement: * Passed.
  min time: 391537.202 ms [0]
[bf] Brainf**k interpreter: * Passed.
  min time: 1064612.400 ms [0]
[fib] Fibonacci number: * Passed.
  min time: 2665952.304 ms [0]
[sieve] Eratosthenes sieve: * Passed.
  min time: 701648.612 ms [0]
[15pz] A* 15-puzzle search: * Passed.
  min time: 590121.520 ms [0]
[dinic] Dinic's maxflow algorithm: * Passed.
  min time: 563715.323 ms [0]
[lzip] Lzip compression: * Passed.
  min time: 568991.377 ms [0]
[ssort] Suffix sort: * Passed.
  min time: 605001.317 ms [0]
[md5] MD5 digest: * Passed.
  min time: 715372.360 ms [0]
==================================================
MicroBench PASS
Scored time: 8699832.705 ms
Total  time: 10005308.053 ms
[/home/xinchen/ysyx/npc/csrc/tiktok.c:56 pmu_display] ************ Performance Monitor ************
[/home/xinchen/ysyx/npc/csrc/tiktok.c:57 pmu_display] Total cycle count = 10030024312
[/home/xinchen/ysyx/npc/csrc/tiktok.c:58 pmu_display]    - A(alu) type count         = 231771098(0.023)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:59 pmu_display]    - B(branch) type count      = 113147282(0.011)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:60 pmu_display]    - C(csr) type count         = 1(0.000)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:61 pmu_display]    - Memory load type count    = 4082994102(0.407)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:62 pmu_display]    - Memory store type count   = 1388539746(0.138)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:63 pmu_display]    - Front end: fetch count    = 4018356676(0.401)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:64 pmu_display] Total insts count = 195215407
[/home/xinchen/ysyx/npc/csrc/tiktok.c:65 pmu_display]    - A(alu) type count         = 115885549(0.594)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:66 pmu_display]    - B(branch) type count      = 56573641(0.290)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:67 pmu_display]    - C(csr) type count         = 1(0.000)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:68 pmu_display]    - Memory load type count    = 15600937(0.080)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:69 pmu_display]    - Memory store type count   = 7155279(0.037)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:70 pmu_display] CPI = 51.379 (IPC = 0.019463)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:71 pmu_display]    - A(alu) type         = 2.000
[/home/xinchen/ysyx/npc/csrc/tiktok.c:72 pmu_display]    - B(branch) type      = 2.000
[/home/xinchen/ysyx/npc/csrc/tiktok.c:73 pmu_display]    - C(csr) type         = 1.000
[/home/xinchen/ysyx/npc/csrc/tiktok.c:74 pmu_display]    - Memory load type    = 261.715p
[/home/xinchen/ysyx/npc/csrc/tiktok.c:75 pmu_display]    - Memory store type   = 194.058
[/home/xinchen/ysyx/npc/csrc/tiktok.c:87 pmu_display] iCache report
[/home/xinchen/ysyx/npc/csrc/tiktok.c:88 pmu_display]    - iCache hit            = 143415901(0.735)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:89 pmu_display]    - icache miss           = 51799506(0.265)
[/home/xinchen/ysyx/npc/csrc/tiktok.c:90 pmu_display]    - Access time (avg)     = 1.000 cycles
[/home/xinchen/ysyx/npc/csrc/tiktok.c:91 pmu_display]    - Miss penalty (avg)    = 71.038 cycles
[/home/xinchen/ysyx/npc/csrc/tiktok.c:92 pmu_display]    - AMAT                  = 19.584 cycles
[/home/xinchen/ysyx/npc/csrc/tiktok.c:95 pmu_display] *********************************************
[/home/xinchen/ysyx/npc/csrc/tiktok.c:298 core_exec] npc: HIT GOOD TRAP at pc = 0xa0005614
```