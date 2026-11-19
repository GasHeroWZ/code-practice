<#
  judge.ps1 - C 语言通关练习判题器（v3）

  用法:
    .\judge.ps1 -List                  看有哪些题
    .\judge.ps1 -Problem table         判题（对错都给结果）
    .\judge.ps1 -Problem table -Run    编译后自己运行，手动输入

  说明:
    - 判哪道题由 -Problem 决定，不会"记住上次"
    - 每题编译到独立临时文件，不会被残留进程占用
    - 每个用例最多等 5 秒，程序死循环会被判定超时并终止
#>
param(
  [int]$Stage,
  [string]$Problem,
  [switch]$List,
  [switch]$Run,
  [int]$TimeoutSec = 5
)
$ErrorActionPreference = 'Continue'
$root  = $PSScriptRoot
$gcc   = 'D:\mingw64\bin\gcc.exe'
$exe   = "_j$PID.exe"

Get-ChildItem $root -Recurse -Filter '_j*.exe' -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

if (-not (Test-Path $gcc)) { Write-Host "找不到 gcc: $gcc" -ForegroundColor Red; exit 1 }

# 带超时地运行程序，把输入文件喂给它
function Invoke-Program {
  param([string]$ExePath, [string]$InFile, [int]$TimeoutMs)
  $psi = New-Object System.Diagnostics.ProcessStartInfo
  $psi.FileName = $ExePath
  $psi.RedirectStandardInput  = $true
  $psi.RedirectStandardOutput = $true
  $psi.RedirectStandardError  = $true
  $psi.UseShellExecute = $false
  $psi.StandardOutputEncoding = [System.Text.Encoding]::UTF8
  $psi.StandardErrorEncoding  = [System.Text.Encoding]::UTF8
  $proc = New-Object System.Diagnostics.Process
  $proc.StartInfo = $psi
  try { [void]$proc.Start() } catch { return [pscustomobject]@{ Text = "<启动失败: $($_.Exception.Message)>"; TimedOut = $false } }
  $inText = Get-Content -LiteralPath $InFile -Raw -Encoding UTF8
  try { $proc.StandardInput.Write($inText); $proc.StandardInput.Close() } catch {}
  $outTask = $proc.StandardOutput.ReadToEndAsync()
  $errTask = $proc.StandardError.ReadToEndAsync()
  if ($proc.WaitForExit($TimeoutMs)) {
    return [pscustomobject]@{ Text = ($outTask.Result + $errTask.Result); TimedOut = $false }
  } else {
    try { $proc.Kill() } catch {}
    return [pscustomobject]@{ Text = "<程序超过 $([math]::Round($TimeoutMs/1000,1)) 秒未结束，可能死循环（检查 while/for 的花括号）>"; TimedOut = $true }
  }
}

# ---------- 收集题目 ----------
$all = @()
foreach ($s in (Get-ChildItem $root -Directory | Where-Object { $_.Name -match '^stage\d+$' } | Sort-Object Name)) {
  foreach ($p in (Get-ChildItem $s.FullName -Directory | Sort-Object Name)) {
    $all += [pscustomobject]@{ Stage = $s.Name; Dir = $p }
  }
}

if ($List) {
  Write-Host ""
  Write-Host "  ===== 全部题目 =====" -ForegroundColor Cyan
  foreach ($x in $all) { Write-Host ("   {0,-8} {1}" -f $x.Stage, $x.Dir.Name) }
  Write-Host ""
  Write-Host "  判题: .\judge.ps1 -Problem <名字里的一段>" -ForegroundColor DarkGray
  Write-Host ""
  exit 0
}

$sel = $all
if ($Stage)   { $sel = @($sel | Where-Object { $_.Stage -eq "stage$Stage" }) }
if ($Problem) { $sel = @($sel | Where-Object { $_.Dir.Name -like "*$Problem*" }) }
if ($sel.Count -eq 0) {
  Write-Host ""
  Write-Host "  ✗ 没找到题目，关键字是 '$Problem'" -ForegroundColor Red
  Write-Host "    用 .\judge.ps1 -List 查看全部题目名" -ForegroundColor DarkGray
  Write-Host ""
  exit 1
}

$what = if ($Problem) { "关键字 '$Problem'" } elseif ($Stage) { "阶段 $Stage" } else { "全部题目" }
Write-Host ""
Write-Host ("  ===== 本次判题: {0}，共 {1} 题 =====" -f $what, $sel.Count) -ForegroundColor Cyan
Write-Host ""

# ---------- -Run ----------
if ($Run) {
  foreach ($x in $sel) {
    Push-Location $x.Dir.FullName
    Remove-Item $exe -Force -ErrorAction SilentlyContinue
    Write-Host ("  编译 " + $x.Dir.Name + " ...") -ForegroundColor DarkGray
    $build = & $gcc 'main.c' -o $exe -Wall 2>&1
    if ($LASTEXITCODE -ne 0) {
      Write-Host "  [编译失败] 先改掉这些错误：" -ForegroundColor Red
      $build | Select-Object -First 8 | ForEach-Object { Write-Host "      $_" -ForegroundColor DarkGray }
      Pop-Location; continue
    }
    Write-Host ("  --- 运行 " + $x.Dir.Name + "（输入数据后回车，Ctrl+C 退出）---") -ForegroundColor Green
    Write-Host ""
    & ".\$exe"
    Write-Host ""
    Remove-Item $exe -Force -ErrorAction SilentlyContinue
    Pop-Location
  }
  exit 0
}

# ---------- 判题 ----------
$pass = 0; $fail = 0; $failed = @(); $curStage = ''

foreach ($x in $sel) {
  if ($x.Stage -ne $curStage) { $curStage = $x.Stage; Write-Host "  --- $curStage ---" -ForegroundColor DarkCyan }
  $p = $x.Dir
  Push-Location $p.FullName
  Remove-Item $exe -Force -ErrorAction SilentlyContinue

  $build = & $gcc 'main.c' -o $exe -Wall 2>&1
  if ($LASTEXITCODE -ne 0) {
    Write-Host ("  [编译失败] " + $p.Name) -ForegroundColor Red
    $build | Select-Object -First 4 | ForEach-Object { Write-Host "      $_" -ForegroundColor DarkGray }
    $fail++; $failed += ("{0}(编译失败)" -f $p.Name)
    Pop-Location; continue
  }

  $cases = @(Get-ChildItem $p.FullName -Filter '*.in' | Sort-Object Name)
  $ok = 0; $rows = @()
  $exePath = Join-Path $p.FullName $exe
  foreach ($c in $cases) {
    $expFile = [System.IO.Path]::ChangeExtension($c.FullName, '.out')
    if (-not (Test-Path $expFile)) { continue }
    $r = Invoke-Program -ExePath $exePath -InFile $c.FullName -TimeoutMs ($TimeoutSec * 1000)
    $expect = (Get-Content -LiteralPath $expFile -Encoding UTF8 | Out-String)
    $clean = { param($t) (($t -replace "`r", '') -split "`n" | ForEach-Object { $_.TrimEnd() }) -join "`n" }
    $a = ((& $clean $r.Text).Trim()); $e = ((& $clean $expect).Trim())
    $same = ($a -eq $e) -and (-not $r.TimedOut)
    if ($same) { $ok++ }
    $rows += [pscustomobject]@{
      In = ((Get-Content -LiteralPath $c.FullName -Raw) -replace "`r", '' -replace "`n", ' ').Trim()
      Actual = $a; Expect = $e; Same = $same; TimedOut = $r.TimedOut
    }
  }

  if ($ok -eq $cases.Count -and $cases.Count -gt 0) {
    Write-Host ("  [PASS] " + $p.Name + "  ($ok/$($cases.Count))") -ForegroundColor Green
    foreach ($r in $rows) {
      Write-Host ("      输入 {0}  →  你的程序输出:" -f $r.In) -ForegroundColor DarkGray
      ($r.Actual -split "`n") | Select-Object -First 4 | ForEach-Object { Write-Host ("          " + $_) -ForegroundColor Gray }
    }
    $pass++
  } else {
    Write-Host ("  [FAIL] " + $p.Name + "  ($ok/$($cases.Count))") -ForegroundColor Red
    foreach ($r in ($rows | Where-Object { -not $_.Same })) {
      Write-Host ("      输入 {0}" -f $r.In) -ForegroundColor DarkGray
      if ($r.TimedOut) {
        Write-Host ("      问题: 程序没有正常结束（死循环）") -ForegroundColor Yellow
        Write-Host ("      提示: 检查 while/for 后面有没有加 { }，循环体是否只有一行") -ForegroundColor DarkGray
      } else {
        Write-Host ("      期望: " + ($r.Expect -replace "`n", ' | ')) -ForegroundColor DarkGray
        Write-Host ("      实际: " + ($r.Actual -replace "`n", ' | ')) -ForegroundColor Yellow
      }
    }
    $fail++; $failed += $p.Name
  }
  Remove-Item $exe -Force -ErrorAction SilentlyContinue
  Pop-Location
}

Write-Host ""
Write-Host "  ============================================" -ForegroundColor Cyan
Write-Host ("    通过 {0} 题 / 失败 {1} 题" -f $pass, $fail) -ForegroundColor $(if ($fail -eq 0) { 'Green' } else { 'Yellow' })
if ($failed.Count -gt 0) { Write-Host ("    未通过: " + ($failed -join ', ')) -ForegroundColor Red }
if ($fail -eq 0 -and $pass -gt 0) { Write-Host "    全过！这一组可以往下走了。" -ForegroundColor Green }
Write-Host "  ============================================" -ForegroundColor Cyan
Write-Host ""
