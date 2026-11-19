<#
  save.ps1 - 一键保存并推送到 GitHub

  用法:
    .\save.ps1                        自动根据改动的题目生成提交信息（推荐）
    .\save.ps1 "任意说明"              自定义提交信息
    .\save.ps1 -DryRun                只预览会提交什么，不真的提交

  自动信息规则:
    只改了一道题           → feat: 完成 05-swap
    同时改了多道题         → feat: 完成 05-swap、06-max-by-pointer
    改的是文档/脚本等      → chore: 更新文件

  注意: PowerShell 5.1 不支持 && 连接命令，所以用这个脚本代替三行手敲。
#>
param(
  [string]$Message,
  [switch]$DryRun
)

Set-Location $PSScriptRoot

$changed = @(git status --porcelain)
if ($changed.Count -eq 0) {
  Write-Host ""
  Write-Host "  没有改动，不需要提交。" -ForegroundColor Yellow
  Write-Host ""
  exit 0
}

# ---------- 自动生成提交信息 ----------
if (-not $Message) {
  $probs = @()
  foreach ($line in $changed) {
    $path = $line.Substring(3).Trim().Trim('"')
    if ($path -match '00-roadmap/stage\d+/([^/]+)/') { $probs += $Matches[1] }
  }
  $probs = @($probs | Select-Object -Unique)
  if ($probs.Count -eq 1) {
    $Message = "feat: 完成 $($probs[0])"
  } elseif ($probs.Count -gt 1) {
    $Message = "feat: 完成 " + ($probs -join '、')
  } else {
    $Message = "chore: 更新文件"
  }
}

Write-Host ""
Write-Host "  检测到这些改动：" -ForegroundColor Cyan
$changed | ForEach-Object { Write-Host ("    " + $_) -ForegroundColor Gray }
Write-Host ("  提交信息: " + $Message) -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
  Write-Host "  （预览模式，没有真的提交）" -ForegroundColor Yellow
  Write-Host ""
  exit 0
}

Write-Host "  1/3  git add ." -ForegroundColor DarkGray
git add .
if ($LASTEXITCODE -ne 0) { Write-Host "  暂存失败" -ForegroundColor Red; exit 1 }

Write-Host "  2/3  git commit" -ForegroundColor DarkGray
git commit -m $Message | Select-Object -First 2 | ForEach-Object { Write-Host ("       " + $_) -ForegroundColor Gray }
if ($LASTEXITCODE -ne 0) { Write-Host "  提交失败" -ForegroundColor Red; exit 1 }

Write-Host "  3/3  git push" -ForegroundColor DarkGray
$env:GIT_TERMINAL_PROMPT = '0'
git push 2>&1 | Select-Object -Last 2 | ForEach-Object { Write-Host ("       " + $_) -ForegroundColor Gray }

if ($LASTEXITCODE -eq 0) {
  Write-Host ""
  Write-Host "  ✔ 已推送到 GitHub" -ForegroundColor Green
  Write-Host "    https://github.com/GasHeroWZ/code-practice" -ForegroundColor DarkGray
} else {
  Write-Host ""
  Write-Host "  ✗ 推送失败，检查网络或重新登录" -ForegroundColor Red
}
Write-Host ""
