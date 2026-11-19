<#
  save.ps1 - 一键保存并推送到 GitHub

  用法:
    .\save.ps1                        用默认提交信息
    .\save.ps1 "feat: 通过 05-swap"    自定义提交信息（推荐写清楚做了什么）

  做三件事:
    1. git add .     把改动装进暂存区
    2. git commit    打个存档（写一条说明）
    3. git push      推到 GitHub

  注意: PowerShell 5.1 不支持 && 连接命令，所以这种脚本才有用。
#>
param(
  [string]$Message = "chore: 更新练习"
)

Set-Location $PSScriptRoot

$changed = @(git status --porcelain)
if ($changed.Count -eq 0) {
  Write-Host ""
  Write-Host "  没有改动，不需要提交。" -ForegroundColor Yellow
  Write-Host ""
  exit 0
}

Write-Host ""
Write-Host "  检测到这些改动：" -ForegroundColor Cyan
$changed | ForEach-Object { Write-Host ("    " + $_) -ForegroundColor Gray }
Write-Host ""

Write-Host "  1/3  git add ." -ForegroundColor DarkGray
git add .
if ($LASTEXITCODE -ne 0) { Write-Host "  暂存失败" -ForegroundColor Red; exit 1 }

Write-Host "  2/3  git commit -m `"$Message`"" -ForegroundColor DarkGray
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
  Write-Host "  ✗ 推送失败，检查网络或重新登录（git push 会弹登录窗）" -ForegroundColor Red
}
Write-Host ""
