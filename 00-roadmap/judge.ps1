<#
  judge.ps1 - C 语言通关练习判题器（v4）

  用法:
    .\judge.ps1 -List                  看有哪些题
    .\judge.ps1 -Problem table         判题（对错都给结果）
    .\judge.ps1 -Problem table -Run    编译后自己运行，手动输入

  可靠性说明:
    - 每次编译使用唯一临时文件名（含时间戳），可在同一终端里反复判题，
      不需要关闭终端
    - 编译失败遇到文件占用会自动换名重试
    - 会显示 main.c 的最后修改时间，便于确认判的是不是你刚保存的版本
    - 每个用例最多等 5 秒，死循环会被判定超时并终止
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
$runId = Get-Date -Format 'HHmmssfff'

# 清理历史临时文件
Get-ChildItem $root -Recurse -Filter '_j*.exe' -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

if (-not (Test-Path $gcc)) { Write-Host "找不到 gcc: $gcc" -ForegroundColor Red; exit 1 }

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

# 编译到临时文件，占用时自动换名重试
function Build-Problem {
  param([string]$Dir, [string]$Tag)
  $src = Join-Path $Dir 'main.c'
  $lastErr = @()
  for ($i = 1; $i -le 3; $i++) {
    $name = "_j${PID}_${Tag}_${i}_$($script:runId).exe"
    $out  = Join-Path $Dir $name
    Remove-Item $out -Force -ErrorAction SilentlyContinue
    $log = & $gcc 'main.c' -o $name -Wall 2>&1
    if ($LASTEXITCODE -eq 0 -and (Test-Path $out)) {
      return [pscustomobject]@{ Ok = $true; Exe = $out; Name = $name; Log = $log }
    }
    $lastErr = $log
    Start-Sleep -Milliseconds 400
  }
  return [pscustomobject]@{ Ok = $false; Exe = $null; Name = $null; Log = $lastErr }
}

# ---------- 收集题目 ----------
$all = @()
foreach ($s in (Get-ChildItem $root -Directory | Where-Object { $_.Name -match '^stage\d+$' } | Sort-Object Name)) {
  foreach ($p in (Get-ChildItem $s.FullName -Directory | Where-Object { -not $_.Name.StartsWith(".") -and (Test-Path (Join-Path $_.FullName "main.c")) } | Sort-Object Name)) {
    $all += [pscustomobject]@{ Stage = $s.Name; Dir = $p }
  }
}

if ($List) {
  Write-Host ""
  Write-Host "  ===== 全部题目 =====" -ForegroundColor Cyan
  foreach ($x in $all) {
    $src = Join-Path $x.Dir.FullName 'main.c'
    $mt = if (Test-Path $src) { (Get-Item $src).LastWriteTime.ToString('MM-dd HH:mm') } else { '--' }
    Write-Host ("   {0,-8} {1,-24} 最后修改 {2}" -f $x.Stage, $x.Dir.Name, $mt)
  }
  Write-Host ""
  Write-Host "  判题: .\judge.ps1 -Problem <名字里的一段>" -ForegroundColor DarkGray
  Write-Host ""
  exit 0
}

$sel = $all
if ($Stage)   { $sel = @($sel | Where-Object { $_.Stage -eq "stage$Stage" }) }
if ($Problem) {
  $sel = @($sel | Where-Object { $_.Dir.Name -like "*$Problem*" })
  # 如果关键字正好等于某个题目全名，就只判那一题
  $exact = @($sel | Where-Object { $_.Dir.Name -eq $Problem })
  if ($exact.Count -eq 1) { $sel = $exact }
}
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
if ($Problem -and $sel.Count -gt 1) {
  Write-Host ("  提示: '{0}' 同时命中了这些题 —— {1}" -f $Problem, (($sel | ForEach-Object { $_.Dir.Name }) -join '、')) -ForegroundColor Yellow
  Write-Host "        只判其中一题，用更精确的关键字，例如 -Problem 03 或 -Problem stats" -ForegroundColor DarkGray
}
Write-Host ""

# ---------- -Run ----------
if ($Run) {
  foreach ($x in $sel) {
    Push-Location $x.Dir.FullName
    $b = Build-Problem -Dir $x.Dir.FullName -Tag 'run'
    if (-not $b.Ok) {
      Write-Host "  [编译失败] 先改掉这些错误：" -ForegroundColor Red
      $b.Log | Select-Object -First 8 | ForEach-Object { Write-Host "      $_" -ForegroundColor DarkGray }
      Pop-Location; continue
    }
    Write-Host ("  --- 运行 " + $x.Dir.Name + "（输入数据后回车，Ctrl+C 退出）---") -ForegroundColor Green
    Write-Host ""
    & $b.Exe
    Write-Host ""
    Remove-Item $b.Exe -Force -ErrorAction SilentlyContinue
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

  $src = Join-Path $p.FullName 'main.c'
  $mt  = (Get-Item $src).LastWriteTime.ToString('MM-dd HH:mm:ss')

  $b = Build-Problem -Dir $p.FullName -Tag 'c'
  if (-not $b.Ok) {
    Write-Host ("  [编译失败] " + $p.Name + "   （源码最后修改 $mt）") -ForegroundColor Red
    $b.Log | Select-Object -First 4 | ForEach-Object { Write-Host "      $_" -ForegroundColor DarkGray }
    $fail++; $failed += ("{0}(编译失败)" -f $p.Name)
    Pop-Location; continue
  }

  $cases = @(Get-ChildItem $p.FullName -Filter '*.in' | Sort-Object Name)
  $ok = 0; $rows = @()
  foreach ($c in $cases) {
    $expFile = [System.IO.Path]::ChangeExtension($c.FullName, '.out')
    if (-not (Test-Path $expFile)) { continue }
    $r = Invoke-Program -ExePath $b.Exe -InFile $c.FullName -TimeoutMs ($TimeoutSec * 1000)
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
    Write-Host ("  [PASS] " + $p.Name + "  ($ok/$($cases.Count))   源码 $mt") -ForegroundColor Green
    foreach ($r in $rows) {
      Write-Host ("      输入 {0}  →  你的程序输出:" -f $r.In) -ForegroundColor DarkGray
      ($r.Actual -split "`n") | Select-Object -First 4 | ForEach-Object { Write-Host ("          " + $_) -ForegroundColor Gray }
    }
    $pass++
  } else {
    Write-Host ("  [FAIL] " + $p.Name + "  ($ok/$($cases.Count))   源码 $mt") -ForegroundColor Red
    foreach ($r in ($rows | Where-Object { -not $_.Same })) {
      Write-Host ("      输入 {0}" -f $r.In) -ForegroundColor DarkGray
      if ($r.TimedOut) {
        Write-Host ("      问题: 程序没有正常结束（死循环）") -ForegroundColor Yellow
        Write-Host ("      提示: 检查 while/for 后面有没有加 { }") -ForegroundColor DarkGray
      } else {
        Write-Host ("      期望: " + ($r.Expect -replace "`n", ' | ')) -ForegroundColor DarkGray
        Write-Host ("      实际: " + ($r.Actual -replace "`n", ' | ')) -ForegroundColor Yellow
      }
    }
    $fail++; $failed += $p.Name
  }
  Remove-Item $b.Exe -Force -ErrorAction SilentlyContinue
  Pop-Location
}

Write-Host ""
Write-Host "  ============================================" -ForegroundColor Cyan
Write-Host ("    通过 {0} 题 / 失败 {1} 题" -f $pass, $fail) -ForegroundColor $(if ($fail -eq 0) { 'Green' } else { 'Yellow' })
if ($failed.Count -gt 0) { Write-Host ("    未通过: " + ($failed -join ', ')) -ForegroundColor Red }
if ($fail -eq 0 -and $pass -gt 0) { Write-Host "    全过！这一组可以往下走了。" -ForegroundColor Green }
Write-Host "  ============================================" -ForegroundColor Cyan
Write-Host ""
