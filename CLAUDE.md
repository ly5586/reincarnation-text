# CLAUDE.md — 轮回文本：影之枢纽

无限流文字冒险游戏。单文件 HTML，纯前端 JS，GitHub Pages 部署。

## 项目结构
```
index.html          # 唯一源文件 (~1800行，全部HTML/CSS/JS内联)
sync_deploy.ps1     # 本地→GitHub→Pages 同步部署脚本
```

## 架构
- **引擎**: 自研 passage-based 文字冒险引擎
- **状态**: 全局 `S` 对象，跨副本 RPG 属性 (level/xp/gold) 持久化 localStorage
- **视图**: 枢纽大厅 (4标签页) ↔ 副本视图 (sidebar + 文字区)
- **副本**: `passages` 对象，每个 passage 有 `text(state)=>string` + `choices[]`
- **道具**: `ITEM_DB` ID 化，`S.inventory` 存 ID 数组
- **角色**: `CHARACTER_DB`，6角色，金币解锁，属性加成 %

## 常用操作
```bash
# 本地测试 — 直接双击 index.html

# 同步部署 (需要 PowerShell)
powershell -File sync_deploy.ps1 -message "描述你的改动"

# 或手动部署
cp ~/OneDrive/Desktop/诡异宿舍_Demo.html ~/Projects/reincarnation-text/index.html
cd ~/Projects/reincarnation-text
git add index.html && git commit -m "update"
# 推送到 GitHub (代理未开则用 API)
gh api repos/ly5586/reincarnation-text/contents/index.html \
  -X PUT -f message="update" -f content="$(base64 -w0 index.html)" -f sha="$(gh api repos/ly5586/reincarnation-text/contents/index.html --jq '.sha')"
```

## 关键约定
- 道具用 ID 引用 (flashlight/old_key/mirror_shard)，不要用中文名
- 角色加成在 `resetDungeonState()` 中应用，副本内属性 = 基础属性 × (1+加成%)
- 结局 passage 的 choices 必须返回 `__return_hub__` 来回到枢纽
- `render(id)` 先处理 `__return_hub__`/`__restart__` 特殊路由
