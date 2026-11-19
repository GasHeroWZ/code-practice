<#
  judge.ps1 - C 语言通关练习判题器

  三种用法:
    .\judge.ps1 -List                  看有哪些题
    .\judge.ps1 -Problem table         判题（对错都给结果）
    .\judge.ps1 -Problem table -Run    自己跑一遍，手动输入，看实际效果

  说明: 判哪道题由 -Problem 后面的词决定，不是"记住上次"。
#>
param(
  [int]$Stage,
  [string]$Problem,
  [switch]$List,
  [switch]$Run
)
$ErrorActionPreference = 'Continue'
$root = $PSScriptRoot
$gcc  = 'D:\mingw64\bin\gcc.exe'

if (-not (Test-Path $gcc)) { Write-Host "找不到 gcc: $gcc" -ForegroundColor Red; exit 1 }

# ---------- 收集题目 ----------
$all = @()
foreach ($s in (Get-ChildItem $root -Directory | Where-Object { $_.Name -match '^stage\d+$' } | Sort-Object Name)) {
  foreach ($p in (Get-ChildItem $s.FullName -Directory | Sort-Object Name)) {
    $all += [pscustomobject]@{ Stage = $s.Name; Dir = $p }
  }
}

# ---------- -List ----------
if ($List) {
  Write-Host ""
  Write-Host "  ===== 全部题目 =====" -ForegroundColor Cyan
  foreach ($x in $all) { Write-Host ("   {0,-8} {1}" -f $x.Stage, $x.Dir.Name) }
  Write-Host ""
  Write-Host "  判题写法: .\judge.ps1 -Problem <名字里的一段>" -ForegroundColor DarkGray
  Write-Host "  比如:     .\judge.ps1 -Problem table" -ForegroundColor DarkGray
  Write-Host ""
  exit 0
}

# ---------- 选题目 ----------
$sel = $all
if ($Stage)   { $sel = @($sel | Where-Object { $_.Stage -eq "stage$Stage" }) }
if ($Problem) { $sel = @($sel | Where-Object { $_.Dir.Name -like "*$Problem*" }) }

if ($sel.Count -eq 0) {
  Write-Host ""
  Write-Host "  ✗ 没找到题目，你写的关键字是: $Problem" -ForegroundColor Red
  Write-Host "    用 .\judge.ps1 -List 看全部题目名" -ForegroundColor DarkGray
  Write-Host ""
  exit 1
}

$what = if ($Problem) { "关键字 '$Problem'" } elseif ($Stage) { "阶段 $Stage" } else { "全部题目" }
Write-Host ""
Write-Host ("  ===== 本次判题: {0}，共 {1} 题 =====" -f $what, $sel.Count) -ForegroundColor Cyan
Write-Host ""

# ---------- -Run：编译后交互运行 ----------
if ($Run) {
  foreach ($x in $sel) {
    Push-Location $x.Dir.FullName
    Remove-Item 'a.exe' -Force -ErrorAction SilentlyContinue
    Write-Host ("  编译 " + $x.Dir.Name + " ...") -ForegroundColor DarkGray
    $build = & $gcc 'main.c' -o 'a.exe' -Wall 2>&1
    if ($LASTEXITCODE -ne 0) {
      Write-Host "  [编译失败] 先改掉这些错误：" -ForegroundColor Red
      $build | Select-Object -First 8 | ForEach-Object { Write-Host "      $_" -ForegroundColor DarkGray }
      Pop-Location; continue
    }
    Write-Host ("  --- 开始运行 " + $x.Dir.Name + "，请输入测试数据，Ctrl+C 退出 ---") -ForegroundColor Green
    Write-Host ""
    & '.\a.exe'
    Write-Host ""
    Write-Host "  --- 程序已结束 ---" -ForegroundColor DarkGray
    Remove-Item 'a.exe' -Force -ErrorAction SilentlyContinue
    Pop-Location
  }
  exit 0
}

# ---------- 正常判题 ----------
$pass = 0; $fail = 0; $failed = @(); $curStage = ''

foreach ($x in $sel) {
  if ($x.Stage -ne $curStage) { $curStage = $x.Stage; Write-Host "  --- $curStage ---" -ForegroundColor DarkCyan }
  $p = $x.Dir
  Push-Location $p.FullName
  Remove-Item 'a.exe' -Force -ErrorAction SilentlyContinue

  $build = & $gcc 'main.c' -o 'a.exe' -Wall 2>&1
  if ($LASTEXITCODE -ne 0) {
    Write-Host ("  [编译失败] " + $p.Name) -ForegroundColor Red
    $build | Select-Object -First 4 | ForEach-Object { Write-Host "      $_" -ForegroundColor DarkGray }
    $fail++; $failed += ("{0}(编译失败)" -f $p.Name)
    Pop-Location; continue
  }

  $cases = @(Get-ChildItem $p.FullName -Filter '*.in' | Sort-Object Name)
  $ok = 0; $rows = @()
  foreach ($c in $cases) {
    $expFile = [System.IO.Path]::ChangeExtension($c.FullName, '.out')
    if (-not (Test-Path $expFile)) { continue }
    $rawIn  = (Get-Content -LiteralPath $c.FullName -Raw)
    $actual = (Get-Content -LiteralPath $c.FullName -Encoding UTF8 | & '.\a.exe' 2>&1 | Out-String)
    $expect = (Get-Content -LiteralPath $expFile -Encoding UTF8 | Out-String)
    $clean = { param($t) (($t -replace "`r", '') -split "`n" | ForEach-Object { $_.TrimEnd() }) -join "`n" }
    $a = ((& $clean $actual).Trim()); $e = ((& $clean $expect).Trim())
    $same = ($a -eq $e)
    if ($same) { $ok++ }
    $rows += [pscustomobject]@{
      In = ($rawIn -replace "`r", '' -replace "`n", ' ').Trim()
      Actual = $a; Expect = $e; Same = $same
    }
  }

  if ($ok -eq $cases.Count -and $cases.Count -gt 0) {
    Write-Host ("  [PASS] " + $p.Name + "  ($ok/$($cases.Count))") -ForegroundColor Green
    foreach ($r in $rows) {
      Write-Host ("      输入 {0}  →  你的程序输出:" -f $r.In) -ForegroundColor DarkGray
      ($r.Actual -split "`n") | Select-Object -First 4 | ForEach-Object { Write-Host ("          " + $_) -ForegroundColor Gray }
      if (($r.Actual -split "`n").Count -gt 4) { Write-Host "          ..." -ForegroundColor DarkGray }
    }
    $pass++
  } else {
    Write-Host ("  [FAIL] " + $p.Name + "  ($ok/$($cases.Count))") -ForegroundColor Red
    foreach ($r in ($rows | Where-Object { -not $_.Same })) {
      Write-Host ("      输入 {0}" -f $r.In) -ForegroundColor DarkGray
      Write-Host ("      期望: " + ($r.Expect -replace "`n", ' | ')) -ForegroundColor DarkGray
      Write-Host ("      实际: " + ($r.Actual -replace "`n", ' | ')) -ForegroundColor Yellow
    }
    $fail++; $failed += $p.Name
  }
  Remove-Item 'a.exe' -Force -ErrorAction SilentlyContinue
  Pop-Location
}

Write-Host ""
Write-Host "  ============================================" -ForegroundColor Cyan
Write-Host ("    通过 {0} 题 / 失败 {1} 题" -f $pass, $fail) -ForegroundColor $(if ($fail -eq 0) { 'Green' } else { 'Yellow' })
if ($failed.Count -gt 0) { Write-Host ("    未通过: " + ($failed -join ', ')) -ForegroundColor Red }
if ($fail -eq 0 -and $pass -gt 0) { Write-Host "    全过！这一组可以往下走了。" -ForegroundColor Green }
Write-Host "  ============================================" -ForegroundColor Cyan
Write-Host ""
