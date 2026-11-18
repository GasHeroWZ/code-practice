# C 语言练习

记录刷题与练习代码。每完成一个练习，在下面「练习记录」里加一行。

## 环境

| 项目 | 位置 |
|---|---|
| 编译器 gcc | `D:\mingw64\bin\gcc.exe`（已在 PATH 里） |
| 调试器 gdb | `D:\mingw64\bin\gdb.exe`（GDB 17.2） |
| 编辑器 | VS Code |
| 版本控制 | Git 2.55 + GitHub |

## 目录约定

```
01-hello/        第一个程序
02-xxx/          按序号递增，一个练习一个文件夹
```

每个文件夹里放 `.c` 源码即可，编译产物（`.exe`）已被 `.gitignore` 忽略。

## 编译（三种方式，任选）

> ⚠️ **不要用绝对路径调 gcc**。mingw 在中文路径下会报
> `ld.exe: cannot open output file D:\????\...`，详见 [编译说明.md](编译说明.md)。

```powershell
# 方式一：cc 命令（推荐，任意目录可用）
cc hello.c

# 方式二：VS Code 里按 Ctrl+Shift+B

# 方式三：兜底脚本
.\build.ps1 hello.c
```

## 调试

在 VS Code 里打开某个 `.c` 文件，按 `F5`，会用 gdb 启动调试
（配置见 `.vscode/launch.json`，会自动先执行编译任务）。

## 日常流程

```powershell
cd D:\个人\code-practice
mkdir 02-xxx; cd 02-xxx
# ...写代码、编译、运行...

cd ..
git add .
git commit -m "feat: 完成 02-xxx"
git push
```

提交信息用约定式前缀：`feat:` 新练习 / `fix:` 修 bug / `docs:` 文档 / `chore:` 杂事。

## 练习记录

| 日期 | 练习 | 说明 |
|---|---|---|
| 2026-11-18 | 01-hello | Hello World |

## 文件说明

| 文件 | 作用 |
|---|---|
| `.gitignore` | 排除 `*.exe`、`build/` 等编译产物 |
| `.gitattributes` | 统一换行符，避免跨平台问题 |
| `build.ps1` | 兜底编译脚本（自动处理中文路径） |
| `.vscode/tasks.json` | Ctrl+Shift+B 编译 / 编译并运行 |
| `.vscode/launch.json` | F5 用 gdb 调试 |
| `.vscode/settings.json` | UTF-8 编码、tab 宽度、gcc 路径 |
| `编译说明.md` | 中文路径问题的原理与三种解法 |