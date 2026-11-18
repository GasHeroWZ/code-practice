<#
  build.ps1 - 编译脚本（不依赖 PowerShell 配置文件）
  用法:
    .\build.ps1                 # 编译当前目录里唯一的 .c
    .\build.ps1 hello.c         # 编译指定文件
    .\build.ps1 hello.c app.exe # 指定输出名
  原理: gcc 无法处理中文绝对路径，所以先切到源文件所在目录，只用相对路径。
#>
param([string]$File, [string]$Out)
$ErrorActionPreference = 'Stop'
$gcc = 'D:\mingw64\bin\gcc.exe'
if (-not (Test-Path $gcc)) { Write-Host "找不到 gcc: $gcc" -ForegroundColor Red; exit 1 }

if (-not $File) {
    $c = @(Get-ChildItem -File -Filter *.c)
    if ($c.Count -eq 0) { Write-Host '当前目录没有 .c 文件' -ForegroundColor Yellow; exit 1 }
    if ($c.Count -gt 1) { Write-Host "有多个 .c 文件，请指定: $($c.Name -join ', ')" -ForegroundColor Yellow; exit 1 }
    $File = $c[0].Name
}
$full = (Resolve-Path $File).Path
$dir  = Split-Path $full -Parent
$name = Split-Path $full -Leaf
if ($Out) { $outName = $Out } else { $outName = [System.IO.Path]::GetFileNameWithoutExtension($name) + '.exe' }

Push-Location -LiteralPath $dir
try {
    & $gcc $name -o $outName -Wall -g
    if ($LASTEXITCODE -eq 0) { Write-Host "编译成功 -> $(Join-Path $dir $outName)" -ForegroundColor Green }
    else { Write-Host '编译失败' -ForegroundColor Red; exit 1 }
} finally { Pop-Location }