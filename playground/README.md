# playground · 试验代码专用

> 想随便写点东西试试？放这里，不要放桌面。

## 为什么不能放桌面

VS Code 的功能**依赖你「打开的文件夹」里的 `.vscode` 配置**：

| 位置 | 有 `.vscode` 吗 | 结果 |
|---|---|---|
| `D:\个人\code-practice\` | ✅ 有（tasks / launch / settings） | `Ctrl+Shift+B` 能编译、`F5` 能调试 |
| `C:\Users\32877\Desktop\` | ❌ 没有 | 按钮按下去没反应，或者报 `launch: program ... does not exist` |

桌面只是一个文件夹，本身不带任何编译配置。你在桌面按 F5，VS Code 找不到：
- **编译任务**（`tasks.json`）→ 不知道用什么命令、把 exe 输出到哪
- **调试配置**（`launch.json`）→ 不知道要运行哪个 exe

所以「新建文件就运行不了」不是代码问题，**是位置问题**。

## 正确做法

1. 在 `D:\个人\code-practice\playground\` 里新建 `.c` 文件
2. 文件名用**英文字母、数字、下划线**（不要中文、空格、括号）
3. 从 `..\template.c` 复制一份开始写（已带好 `#include <stdio.h>`）
4. `Ctrl+Shift+B` 编译，`F5` 调试

```powershell
cd D:\个人\code-practice\playground
copy ..\template.c test1.c
code test1.c
```

## 三条铁律

| 规则 | 原因 |
|---|---|
| 文件放在 `code-practice` 里的任意子目录 | 只有这里能用上编译/调试配置 |
| 文件名只用英文数字下划线 | 中文名会让输出的 `.exe` 变成乱码（实测 `模板.exe` → `Ä£°å.exe`） |
| 每个文件第一行写 `#include <stdio.h>` | 否则 `printf`/`scanf` 会报 implicit declaration（GCC 16 直接当 error） |

## 这个坑你踩过三次

| 时间 | 现象 | 原因 |
|---|---|---|
| 11-19 | `launch: program 'C:\...\Desktop\void PrintTable(int n).exe' does not exist` | 文件在桌面，且文件名带空格括号 |
| 11-20 | `stage2` 下出现了 `.vscode`，被判题器当成题目 | VS Code 在子目录里生成了配置 |
| 11-22 | 桌面 `Untitled-2.c` 运行不了 | 桌面没有 `.vscode`，F5 没有可用配置 |

**记住一句话：写代码之前先 `cd` 到项目目录，再新建文件。**
