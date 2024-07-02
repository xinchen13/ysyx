# 如何科学地提问

## 填写通识问卷
<img src="../../figs/Screenshot from 2023-09-16 13-55-22.png" width="580" />

## STFW, RTFM, RTFSC
寻找并理解这三个缩写的含义
- STFW(Search The F**king Web): 善于利用互联网资源(如Google, Stack Overflow)，查找前人在遇到相同问题时的经验与方法
- RTFM(Read The F**king Manual): 通过手册来查找遇到的问题，例如工具的官方文档，`man`命令等
- RTFSC(Read The F**king Source Code): 浏览源代码，主要关注关键代码或者与我们感兴趣的问题相关的代码

## 阅读"提问的智慧"和"别像弱智一样提问", 编写读后感
仔细阅读提问的智慧和别像弱智一样提问这两篇文章, 结合自己过去提问和被提问的经历, 写一篇不少于800字的读后感, 谈谈你对"好的提问"以及"通过STFW和RTFM独立解决问题"的看法。读后感如下:

读完这两篇文章，我认为主要讨论了两个话题：遇到问题要不要求助，以及如何正确地求助他人。

在要不要求助这个问题上，其实就是先尝试独立解决问题。在仔细地审视问题后，无论是通过正确的途径与方法进行上网搜索（STFW）还是阅读手册（RTFM）还是阅读源代码（RTFSC），都能够极大地帮助我们解决问题，即使这个问题仍然没有得到答案，也能够帮助我们更好地提问。事实上，大部分问题都能够通过独立探索来解决，这对于我们的心态、能力都有一定的帮助。

在这一问题上我还是深有体会：本科期间曾做过一段时间的C语言学业帮扶，帮扶对象对于`++i`和`a---a`等习题的求值一头雾水，直接拿着习题来向我验证答案。事实上当时我也对运算顺序不太了解（不是），都是STFW后再写个小程序验证一下。因为不想再被提问这样的题，于是我把方法告诉了他。在这儿就如上面提到的，这种自己尝试就能够独立解决的问题，就完全没有必要麻烦别人了。

至于如何正确地求助别人，其意义不仅在于节约双方时间，更快解决问题，更在于体现严谨的态度，使得对问题的讨论是有价值的。从最基本的遣词造句，到提问内容，到已有的尝试，再到提问的地点与对象，都是值得三思后再敲定的。比如之前在一个GTNH整合包的群聊中，一旦有萌新问问题附了一张“拍屏”的崩溃日志，那立马就是24h禁言。甚至不愿意发一张清晰的截图，又怎么指望别人看清你的问题，再耐心给你解答呢？

在阅读过程中，回想起我之前的提问："[Twilight Oak Door Losing Texture](https://github.com/AllTheMods/ATM-3/issues/997)"，当时是在一个Minecraft整合包中遇到了名为"Twilight Forest"的mod中某个物品材质丢失的问题，去整合包的项目中提了这个issue。一开始很自然的以为是在最做整合包的过程中出现的问题导致没有材质包，其实应该是mod本身就存在的问题，应当先检查其他整合包或者单个模组的情况下是否存在问题，在开发者的回答引导下我才意识到这一点，也让我意识到自己多尝试对于独立解决问题的重要性，以及现在在回想起来，这其实就是一次不合格的提问。在这一开源项目中，他的issue模板其实就是对提问者进行正确提问的引导，如下所示:

```
<!--- Provide a general summary of the issue in the Title above -->
<!--- For game help join the discord and ask there-->

## Expected Behavior
<!--- Tell us what should happen -->

## Current Behavior
<!--- Tell us what happens instead of the expected behavior -->

## Possible Solution
<!--- Not obligatory, but suggest a fix/reason for the bug, -->

## Steps to Reproduce
<!--- Provide a link to a live example, or an unambiguous set of steps to -->
<!--- reproduce this bug.-->
1.
2.
3.
4.

## Log
<!--- If this is a crash, or something similar you will have to provide a log.-->
<!--- DON'T POST IT DIRECTLY! Use gist.github.com and post it there and link it here.-->

## Detailed Description
<!--- Provide a detailed description of the change or addition you are proposing -->
``` 

总之，提问也是门艺术，斟酌如何提问，最终还是培养我们独立思考与解决问题的能力。


