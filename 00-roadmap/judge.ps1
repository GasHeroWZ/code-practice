<#
  judge.ps1 - C 语言通关练习自动判题器
  用法:
    .\judge.ps1                 # 判所有题
    .\judge.ps1 -Stage 1        # 只判阶段 1
    .\judge.ps1 -Problem prime  # 只判名字含 prime 的题
  原理: 编译 main.c -> 逐条喂 .in 文件 -> 比对输出与 .out 文件
#>
param(
  [int]$Stage,
  [string]$Problem
)
$ErrorActionPreference = 'Continue'
$root = $PSScriptRoot
$gcc = 'D:\mingw64\bin\gcc.exe'
if (-not (Test-Path $gcc)) { Write-Host "找不到 gcc: $gcc" -ForegroundColor Red; exit 1 }

$dirs = @(Get-ChildItem $root -Directory | Where-Object { $_.Name -match '^stage\d+$' } | Sort-Object Name)
if ($Stage) { $dirs = @($dirs | Where-Object { $_.Name -eq "stage$Stage" }) }

$pass = 0; $fail = 0; $failed = @()

foreach ($s in $dirs) {
  Write-Host ""
  Write-Host "===== $($s.Name) =====" -ForegroundColor Cyan
  $probs = @(Get-ChildItem $s.FullName -Directory | Sort-Object Name)
  if ($Problem) { $probs = @($probs | Where-Object { $_.Name -like "*$Problem*" }) }

  foreach ($p in $probs) {
    Push-Location $p.FullName
    Remove-Item 'a.exe' -Force -ErrorAction SilentlyContinue
    $build = & $gcc 'main.c' -o 'a.exe' -Wall 2>&1
    if ($LASTEXITCODE -ne 0) {
      Write-Host ("  [编译失败] " + $p.Name) -ForegroundColor Red
      $build | Select-Object -First 5 | ForEach-Object { Write-Host "      $_" -ForegroundColor DarkGray }
      $fail++; $failed += ("{0} (编译失败)" -f $p.Name)
      Pop-Location; continue
    }

    $cases = @(Get-ChildItem $p.FullName -Filter '*.in' | Sort-Object Name)
    if ($cases.Count -eq 0) { Write-Host ("  [无测试用例] " + $p.Name) -ForegroundColor Yellow; Pop-Location; continue }

    $ok = 0; $bad = @()
    foreach ($c in $cases) {
      $expFile = [System.IO.Path]::ChangeExtension($c.FullName, '.out')
      if (-not (Test-Path $expFile)) { continue }
      $actual = (Get-Content -LiteralPath $c.FullName -Encoding UTF8 | & '.\a.exe' 2>&1 | Out-String)
      $expect = (Get-Content -LiteralPath $expFile -Encoding UTF8 | Out-String)
      # 归一化: 去行尾空白、统一换行、去首尾空行
      $norm = {
        param($t)
        $lines = ($t -replace "`r", '') -split "`n"
        $lines = $lines | ForEach-Object { $_.TrimEnd() }
        ($lines -join "`n").Trim()
      }
      if ((& $norm $actual) -eq (& $norm $expect)) { $ok++ }
      else {
        $bad += [pscustomobject]@{ Case = $c.Name; Actual = (& $norm $actual); Expect = (& $norm $expect) }
      }
    }

    if ($bad.Count -eq 0) {
      Write-Host ("  [PASS] " + $p.Name + "  ($ok/$($cases.Count))") -ForegroundColor Green
      $pass++
    } else {
      Write-Host ("  [FAIL] " + $p.Name + "  ($ok/$($cases.Count))") -ForegroundColor Red
      foreach ($b in $bad) {
        Write-Host "      用例 $($b.Case)" -ForegroundColor DarkGray
        Write-Host "        期望: $($b.Expect -replace "`n", ' | ')" -ForegroundColor DarkGray
        Write-Host "        实际: $($b.Actual -replace "`n", ' | ')" -ForegroundColor DarkGray
      }
      $fail++; $failed += $p.Name
    }
    Remove-Item 'a.exe' -Force -ErrorAction SilentlyContinue
    Pop-Location
  }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ("  通过 {0} 题 / 失败 {1} 题" -f $pass, $fail) -ForegroundColor $(if ($fail -eq 0) { 'Green' } else { 'Yellow' })
if ($failed.Count -gt 0) {
  Write-Host ("  未通过: " + ($failed -join ', ')) -ForegroundColor Red
}
Write-Host "========================================" -ForegroundColor Cyan