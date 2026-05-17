# ═══════════════════════════════════════════
# 轮回文本 · 同步部署脚本
# 本地 ↔ GitHub ↔ GitHub Pages 三端同步
# ═══════════════════════════════════════════
param(
    [string]$message = "update: 更新游戏内容"
)

$ErrorActionPreference = "Stop"
$projectDir = "$env:USERPROFILE\Projects\reincarnation-text"
$desktopFile = "$env:USERPROFILE\OneDrive\Desktop\诡异宿舍_Demo.html"
$repo = "ly5586/reincarnation-text"

Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  轮回文本 · 同步部署" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Step 1: 从桌面同步到项目目录
Write-Host "[1/4] 同步桌面文件 → 项目目录..." -ForegroundColor Yellow
if (Test-Path $desktopFile) {
    Copy-Item $desktopFile "$projectDir\index.html" -Force
    Write-Host "  ✓ 已复制: $desktopFile → index.html" -ForegroundColor Green
} else {
    Write-Host "  ⚠ 桌面文件不存在，使用项目目录中的版本" -ForegroundColor DarkYellow
}

Set-Location $projectDir

# Step 2: 提交到本地 git
Write-Host "[2/4] 提交到本地 Git..." -ForegroundColor Yellow
git add index.html .gitignore 2>$null
$status = git status --porcelain
if ($status) {
    git commit -m $message
    Write-Host "  ✓ 已提交: $message" -ForegroundColor Green
} else {
    Write-Host "  ⚠ 没有变更需要提交" -ForegroundColor DarkYellow
}

# Step 3: 推送到 GitHub (先尝试直连，失败则用 API)
Write-Host "[3/4] 推送到 GitHub..." -ForegroundColor Yellow

# 尝试直连 (代理可能未启动)
$pushOk = $false
$env:http_proxy = "socks5://localhost:12334"
$env:https_proxy = "socks5://localhost:12334"
git -c http.proxy="socks5://localhost:12334" -c https.proxy="socks5://localhost:12334" push origin main 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ Git Push 成功" -ForegroundColor Green
    $pushOk = $true
}

# 直连失败则用 GitHub API
if (-not $pushOk) {
    Write-Host "  ⚡ 直连失败，使用 GitHub API 上传..." -ForegroundColor DarkYellow

    # 获取当前文件 SHA
    $sha = (gh api "repos/$repo/contents/index.html" --jq '.sha') 2>$null
    if (-not $sha) {
        Write-Host "  ✗ 无法获取远程 SHA" -ForegroundColor Red
        exit 1
    }

    # 用 Node.js 上传 (避免命令行长度限制)
    $content = [Convert]::ToBase64String([IO.File]::ReadAllBytes("$projectDir\index.html"))
    $token = (gh auth token).Trim()

    $payload = @{
        message = $message
        content = $content
        sha = $sha
    } | ConvertTo-Json -Compress

    $body = [System.Text.Encoding]::UTF8.GetBytes($payload)
    $req = [System.Net.HttpWebRequest]::Create("https://api.github.com/repos/$repo/contents/index.html")
    $req.Method = "PUT"
    $req.UserAgent = "SyncScript/1.0"
    $req.Headers["Authorization"] = "Bearer $token"
    $req.ContentType = "application/json"
    $req.ContentLength = $body.Length

    $stream = $req.GetRequestStream()
    $stream.Write($body, 0, $body.Length)
    $stream.Close()

    try {
        $resp = $req.GetResponse()
        $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
        $result = $reader.ReadToEnd() | ConvertFrom-Json
        Write-Host "  ✓ API 上传成功: $($result.commit.sha)" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ API 上传失败: $_" -ForegroundColor Red
        exit 1
    }
}

# Step 4: 检查 GitHub Pages 部署状态
Write-Host "[4/4] 检查 Pages 状态..." -ForegroundColor Yellow
$pages = gh api "repos/$repo/pages" 2>$null | ConvertFrom-Json
Write-Host "  状态: $($pages.status)" -ForegroundColor $(if ($pages.status -eq 'built') { 'Green' } else { 'Yellow' })
Write-Host "  地址: https://ly5586.github.io/reincarnation-text/" -ForegroundColor Cyan

Write-Host ""
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  部署完成！" -ForegroundColor Green
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
