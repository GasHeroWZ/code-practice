# 02-seqlist · 动态顺序表练习

素材来自课程 `10月12日--顺序表讲解-代码+板书`（已转成 UTF-8 并修复一处笔误）。

## 已经能跑的

`TestSeqList1()` 和 `TestSeqList2()`：验证尾插/尾删/头插/头删，输出正确。

```powershell
cd D:\个人\code-practice\02-seqlist
gcc SeqList.c Test.c -o seqlist.exe -Wall
.\seqlist.exe
```

## 你的任务：实现三个接口

`SeqList.h` 里声明了、但课程讲到 10/12 时还没实现，`SeqList.c` 末尾留了骨架：

| 函数 | 要求 | 关键点 |
|---|---|---|
| `SeqListFind(ps, x)` | 找到返回下标，找不到返回 `-1` | 遍历 `0..size-1` |
| `SeqListInsert(ps, pos, x)` | 在 `pos` 处插入 `x` | ① 断言 `0 <= pos <= size` ② 先 `SeqListCheckCapacity` ③ 从后往前搬数据 ④ `size++` |
| `SeqListErase(ps, pos)` | 删除 `pos` 处数据 | ① 断言 `0 <= pos < size` ② 从前往后搬数据 ③ `size--` |

## 自测方法

`Test.c` 末尾已经写好 `TestSeqList3()`，**覆盖了边界情况**（头插、尾删、查找不存在的值）。

实现完三个接口后：

1. 打开 `Test.c`，把 `main` 里的 `//TestSeqList3();` 取消注释
2. 重新编译运行
3. 对照每行后面的「期望」值

期望输出：

```
初始:      1 2 3
Find(2)  = 1  (期望 1)
Find(99) = -1  (期望 -1)
插入100:   1 100 2 3
头插7:     7 1 100 2 3
删第一个:  1 100 2 3
删最后一个:1 100 2
```

## 三道思考题（做完再看）

1. 为什么 `Insert` 和 `Erase` 搬数据的方向是相反的？
2. `SeqListInsert(ps, ps->size, x)` 和 `SeqListPushBack(ps, x)` 是等价的吗？
3. 实现 `Insert` 后，`PushFront` 可以简化成一行 `SeqListInsert(ps, 0, x)`，但这样性能一样吗？

## 踩过的坑（记录）

| 问题 | 原因 |
|---|---|
| `print` 报 implicit declaration | 课程原始代码里 `print(` 少了 `f`，应为 `printf(` |
| 中文注释乱码 | 三个文件编码不一致：`SeqList.c` 是 UTF-8，`SeqList.h` / `Test.c` 是 GBK，需分别处理 |
| 第 27 行 `if` 被吞进注释 | 错误的整文件转码导致，已按文件真实编码重做 |