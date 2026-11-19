<#
  judge.ps1 - C 语言通关练习自动判题器

  用法:
    .\judge.ps1 -List                列出全部题目和编号
    .\judge.ps1                      判全部（16 题）
    .\judge.ps1 -Stage 1             只判阶段 1
    .\judge.ps1 -Problem table       只判名字含 table 的题
    .\judge.ps1 -Problem 04          只判编号以 04 开头的题

  提示: 判哪个题，取决于你命令里的 -Problem 参数。
       按 ↑ 调出的历史命令，参数还是老的，需要自己改。
#>
param(
  [int]$Stage,
  [string]$Problem,
  [switch]$List
)
$ErrorActionPreference = 'Continue'
$root = $PSScriptRoot
$gcc = 'D:\mingw64\bin\gcc.exe'

if (-not (Test-Path $gcc)) {
  Write-Host "找不到 gcc: $gcc" -ForegroundColor Red
  exit 1
}

# ---------- 收集全部题目 ----------
$all = @()
foreach ($s in (Get-ChildItem $root -Directory | Where-Object { $_.Name -match '^stage\d+$' } | Sort-Object Name)) {
  foreach ($p in (Get-ChildItem $s.FullName -Directory | Sort-Object Name)) {
    $all += [pscustomobject]@{ Stage = $s.Name; Dir = $p }
  }
}

# ---------- -List ----------
if ($List) {
  Write-Host ""
  Write-Host "  全部题目：" -ForegroundColor Cyan
  foreach ($x in $all) {
    $mark = if (Test-Path (Join-Path $x.Dir.FullName '.passed')) { " ✔" } else { "  " }
    Write-Host ("  {0,-8} {1,-24}{2}" -f $x.Stage, $x.Dir.Name, $mark)
  }
  Write-Host ""
  Write-Host "  用法: .\judge.ps1 -Problem <名字片段>" -ForegroundColor DarkGray
  Write-Host ""
  exit 0
}

# ---------- 过滤 ----------
$sel = $all
if ($Stage) { $sel = @($sel | Where-Object { $_.Stage -eq "stage$Stage" }) }
if ($Problem) { $sel = @($sel | Where-Object { $_.Dir.Name -like "*$Problem*" }) }

if ($sel.Count -eq 0) {
  Write-Host ""
  Write-Host "  ✗ 没有匹配的题目。" -ForegroundColor Red
  Write-Host ("    你给的条件: " + $(if ($Problem) { "-Problem '$Problem'" } else { "" }) + $(if ($Stage) { " -Stage $Stage" } else { "" })) -ForegroundColor DarkGray
  Write-Host "    可用题目：" -ForegroundColor DarkGray
  foreach ($x in $all) { Write-Host ("      {0}" -f $x.Dir.Name) -ForegroundColor DarkGray }
  Write-Host ""
  exit 1
}

# ---------- 顶部说明"现在判什么" ----------
$filterText = if ($Problem) { "-Problem '$Problem'" } elseif ($Stage) { "-Stage $Stage" } else { "全部" }
Write-Host ""
Write-Host ("  判题范围: {0}   共 {1} 题" -f $filterText, $sel.Count) -ForegroundColor Cyan
Write-Host ""

$pass = 0; $fail = 0; $failed = @()
$currentStage = ''

foreach ($x in $sel) {
  if ($x.Stage -ne $currentStage) {
    $currentStage = $x.Stage
    Write-Host "  --- $currentStage ---" -ForegroundColor DarkCyan
  }
  $p = $x.Dir
  Push-Location $p.FullName
  Remove-Item 'a.exe' -Force -ErrorAction SilentlyContinue

  $build = & $gcc 'main.c' -o 'a.exe' -Wall 2>&1
  if ($LASTEXITCODE -ne 0) {
    Write-Host ("  [编译失败] " + $p.Name) -ForegroundColor Red
    $build | Select-Object -First 4 | ForEach-Object { Write-Host "      $_" -ForegroundColor DarkGray }
    $fail++; $failed += ("{0} (编译失败)" -f $p.Name)
    Pop-Location; continue
  }

  $cases = @(Get-ChildItem $p.FullName -Filter '*.in' | Sort-Object Name)
  if ($cases.Count -eq 0) { Pop-Location; continue }

  $ok = 0; $bad = @()
  foreach ($c in $cases) {
    $expFile = [System.IO.Path]::ChangeExtension($c.FullName, '.out')
    if (-not (Test-Path $expFile)) { continue }
    $actual = (Get-Content -LiteralPath $c.FullName -Encoding UTF8 | & '.\a.exe' 2>&1 | Out-String)
    $expect = (Get-Content -LiteralPath $expFile -Encoding UTF8 | Out-String)
    $norm = {
      param($t)
      $lines = ($t -replace "`r", '') -split "`n"
      ($lines | ForEach-Object { $_.TrimEnd() }) -join "`n"
    }
    if (((& $norm $actual).Trim()) -eq ((& $norm $expect).Trim())) { $ok++ }
    else { $bad += [pscustomobject]@{ In = (Get-Content -LiteralPath $c.FullName -Raw).Trim(); Actual = (& $norm $actual); Expect = (& $norm $expect) } }
  }

  if ($bad.Count -eq 0) {
    Write-Host ("  [PASS] " + $p.Name + "  ($ok/$($cases.Count))") -ForegroundColor Green
    $pass++
  } else {
    Write-Host ("  [FAIL] " + $p.Name + "  ($ok/$($cases.Count))") -ForegroundColor Red
    foreach ($b in $bad) {
      Write-Host ("      输入: " + ($b.In -replace "`n", ' ')) -ForegroundColor DarkGray
      Write-Host ("      期望: " + ($b.Expect -replace "`n", ' | ')) -ForegroundColor DarkGray
      Write-Host ("      实际: " + ($b.Actual -replace "`n", ' | ')) -ForegroundColor Yellow
    }
    $fail++; $failed += $p.Name
  }
  Remove-Item 'a.exe' -Force -ErrorAction SilentlyContinue
  Pop-Location
}

Write-Host ""
Write-Host "  ==========================================" -ForegroundColor Cyan
$color = if ($fail -eq 0) { 'Green' } else { 'Yellow' }
Write-Host ("    通过 {0} 题 / 失败 {1} 题" -f $pass, $fail) -ForegroundColor $color
if ($failed.Count -gt 0) { Write-Host ("    未通过: " + ($failed -join ', ')) -ForegroundColor Red }
if ($fail -eq 0 -and $pass -gt 0) { Write-Host "    全部通过，这一组可以往下走了。" -ForegroundColor Green }
Write-Host "  ==========================================" -ForegroundColor Cyan
Write-Host ""