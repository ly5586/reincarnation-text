# CLAUDE.md — 轮回文本：影之枢纽

单文件 HTML 无限流文字冒险游戏 (~2200行)。纯前端，GitHub Pages 部署。

## 文件位置
- **源文件**: `C:\Users\15045\OneDrive\Desktop\轮回文本\index.html` (也即桌面 `诡异宿舍_Demo.html`)
- **部署脚本**: `sync_deploy.ps1`
- **在线**: https://ly5586.github.io/reincarnation-text/
- **GitHub**: `ly5586/reincarnation-text`

## 架构速览

```
index.html 结构:
  <style>  全局CSS (~360行): 变量、枢纽、副本、标签页、响应式
  <body>
    <section class="seo-landing">  搜索引擎着陆文字(JS加载后隐藏)
    <div id="game-container">
      <div id="hub-view">          枢纽大厅
        <header>                   等级/金币/XP条
        <nav id="hub-tabs">        4标签: 总览/背包/角色/存档
        <div class="hub-tab-page"> 每个标签一个page
      <div id="dungeon-view">      副本视图
        <div id="sidebar">         侧边栏(属性条/道具/规则)
        <div id="main">            文字区+选项按钮+返回枢纽按钮
  <script>  JS (~1700行)
    1. 数据库: ITEM_DB, DUNGEON_DB, CHARACTER_DB
    2. 状态: defaults → S 全局对象
    3. RPG函数: xpForLevel, addXP, getItem, saveGame, loadGame
    4. 视图管理: showView, switchTab, renderHub, renderHubInventory, renderHubDungeons, renderCharShop, renderSaveSlots
    5. 副本引擎: passages 对象, render(id), updateStats, restart
    6. 初始化: init() → loadGame → renderHub
```

## 关键数据流

```
S (全局状态) = {
  // 持久化 (跨会话)
  level, xp, xpToNext, gold, maxInventorySlots,
  completedDungeons[], maxConstitution/ Sanity/ Vigilance,
  currentCharacter, unlockedCharacters[], saveSlots{},

  // 副本内 (每次 enterDungeon 重置)
  constitution, sanity, vigilance, day, inventory[],
  rulesKnown, causeOfDeath, currentDungeon,
  flag_* (8个布尔标记),
}
```

## 核心机制

### 道具系统
- **引用**: 道具用 ID 引用 (`'flashlight'`, `'old_key'`, `'mirror_shard'`)，不用中文
- **数据库**: `ITEM_DB[id]` → `{name, type, desc, rarity, icon}`
- **显示**: `getInventoryItems()` → `[{...item}, ...]`，取 `.name` 显示中文
- **添加**: `{ inventory_add: 'flashlight' }` 在 choice effect 中
- **检查**: `S.inventory.includes('flashlight')` 或 `hasItem('flashlight')`
- **迁移**: `loadGame()` 自动将旧版中文名转 ID

### 角色系统
- `CHARACTER_DB[id]` → `{name, emoji, cost, bonuses, desc, tag}`
- 加成在 `resetDungeonState()` 中应用: `属性 *= (1 + bonus%/100)`
- 选择角色: `S.currentCharacter = id`，购买: 扣金币 + `unlockedCharacters.push(id)`

### 副本引擎
- `passages[id]` = `{ text(s), choices[] }`  其中 s 即 S
- `text` 可以是 `s => string` 函数 (支持动态内容)
- `choices` 可以是数组或 `s => array` 函数 (支持条件选项)
- 每个 choice: `{ text, next, condition?(s), effect?(s)|object }`
- 特殊路由: `__return_hub__` → 返回枢纽, `__restart__` → 重新开始

### 结局奖励
- 好结局: XP 100+规则加成+50, 金币50
- 隐藏结局: +200 XP, 金币100
- 坏结局: XP 5 (少量)
- 效果用 choice 的 `effect(s)` 函数: `addXP(total); S.gold += 50; saveGame()`

## 编辑注意事项

1. **道具引用**: 永远用 ID，不要用中文名
2. **choice effect**: 用函数形式 `effect(s){...}` 可以访问完整状态
3. **text 函数**: 不要有副作用 (除了显示用)，状态修改放 effect 里
4. **CSS 选择器**: 
   - 副本视图: `#dungeon-view` (不是旧 `#app`)
   - 移动端: `@media(max-width:700px)` 已更新
5. **inventory 边界**: `apply()` 不检查上限，但 `S.maxInventorySlots` 控制显示槽位数
6. **HTML 特殊字符**: 模板字符串中的 `"` `"` `—` `…` 等全角字符容易在编辑时损坏，尽量不改动

## 部署

```powershell
# 方式1: 脚本一键
powershell -File sync_deploy.ps1 -message "描述"

# 方式2: 手动 API (代理不可用时)
cd C:\Users\15045\Projects\reincarnation-text
SHA=$(gh api repos/ly5586/reincarnation-text/contents/index.html --jq '.sha')
# 用 Node.js 上传 (避免 base64 命令行长度限制)
```

GitHub Pages 1-2分钟生效。GFW 阻断直连 git push 时用 API 上传。

## 已修复的坑
- 模板字符串缺失反引号 → JS 全部不执行 → 页面空白
- `#app` 改为 `#dungeon-view` 后移动端 CSS 忘记更新 → 窄屏布局崩坏
- `window.debugMaxAll` 用函数声明在某种作用域下不挂 window → 改为直接赋值
- `choices` IIFE + getter/setter 模式破坏 → 改为箭头函数 `choices: (s) => [...]`

## 测评模式

- 控制台: `debugMaxAll()` (直接全局函数)
- 按钮: 枢纽页 🔧 测评按钮
- 效果: Lv.99, 99999金币, 全角色, 全道具, 全副本解锁
