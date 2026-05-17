# 轮回文本：影之枢纽

无限流文字冒险游戏。纯前端单文件 HTML，GitHub Pages 免费部署。

**在线游玩**: https://ly5586.github.io/reincarnation-text/

## 技术栈

- 纯 HTML/CSS/JS，零框架，零构建
- 自研 passage-based 文字冒险引擎
- localStorage 持久化存档
- GitHub Pages 部署

## 项目结构

```
index.html        # 唯一源文件 (HTML+CSS+JS 全内联)
sync_deploy.ps1   # 一键部署脚本
CLAUDE.md         # AI 协作文档
```

## 核心系统

| 系统 | 说明 |
|------|------|
| 副本引擎 | passage 对象驱动，`text(s)=>html` + `choices[]` 分支选择 |
| RPG 成长 | Lv.1~99，XP 曲线 `100×1.15^(lv-1)`，升级提升属性上限 |
| 道具 | ITEM_DB 数据库，ID 引用，10 槽网格背包，稀有度色标 |
| 角色 | 6 位角色，金币解锁，百分比属性加成 |
| 存档 | 3 手动槽 + 自动保存，localStorage 持久化 |
| 测评 | 🔧 按钮或控制台 `debugMaxAll()`，满级全角色无限金币 |

## 部署

```powershell
powershell -File sync_deploy.ps1 -message "更新说明"
```

脚本流程：复制桌面文件 → git commit → 推送 GitHub → Pages 自动部署（1-2 分钟生效）

## 副本

- **诡异宿舍 407**（Lv.1）：3 天生存，收集 5 条规则
- **镜界回音**（Lv.3）：待开发

## 许可证

MIT
