# 圈层共振三消

## What This Is

独创「圈层共振三消」小游戏，基于六边形蜂窝棋盘，摒弃传统横竖线性消除规则，首创圈层闭环消除+共振连锁核心机制。玩家任意交换两个碎片，形成三角/四边/六边闭环圈层即可消除，消除后产生波纹扩散触发连锁共振。目标平台：Web / Android / iOS，基于 Godot 4.x + AI 全栈开发，1-2人小团队，30天上线。

## Core Value

**圈层闭环消除 + 共振连锁**：摆脱传统三消10年不变的横竖连线规则，用圈层环形的视觉爽感和随机不可逆的共振连锁，创造新颖解压体验。

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] **CORE-01**: 六边形蜂窝棋盘渲染，跨格自由交换
- [ ] **CORE-02**: 三角圈层（3同色）基础消除
- [ ] **CORE-03**: 四边圈层（4同色）进阶消除 + 小幅共振
- [ ] **CORE-04**: 六边满环（6同色）全域共振消除
- [ ] **CORE-05**: 嵌套圈层识别，双重共振 + 稀有道具掉落
- [ ] **CORE-06**: 圈层共振连锁系统（波纹扩散→自动补全→二次消除）
- [ ] **CORE-07**: 紊乱碎片阻挡机制 + 随机刷新
- [ ] **CORE-08**: 四大专属道具（共振波纹/圈层固化/全域谐振/紊乱净化）
- [ ] **MODE-01**: 经典闯关模式（步数限制 + 积分/圈层目标）
- [ ] **MODE-02**: 限时共振模式（60秒极速对局，无步数限制冲分）
- [ ] **MODE-03**: 圈层解谜模式（固定棋盘 + 极限步数 + 高阶通关）
- [ ] **COM-01**: 激励视频广告（复活/道具获取/双倍积分）
- [ ] **COM-02**: 内购系统（道具礼包/关卡解锁/去广告）
- [ ] **COM-03**: 皮肤系统（圈层皮肤/波纹特效/棋盘主题）
- [ ] **PLAT-01**: Web/HTML5 多端自适应
- [ ] **PLAT-02**: Android/iOS 移动端打包
- [ ] **LOC-01**: 多语言本地化（英/日/韩/东南亚/拉美）

### Out of Scope

- PVP实时对战 — v1聚焦单机体验，社交对战延后
- 大世界/MMO社交 — 轻量化定位，不增加服务器成本
- 剧情系统 — 文字无依赖是出海优势，不引入剧情

## Context

- **技术栈**: Godot 4.x (GDScript)，Compatibility Renderer 适配低端机
- **棋盘**: 正六边形蜂窝网格，轴向坐标 (q, r)，半径≤5
- **AI工具栈**: 美术(Midjourney/SD) + 特效(Runway) + 代码(GPT-4o/Claude) + 关卡(AI批量生成) + 本地化(AI多语言)
- **差异化**: 全网无同款圈层消除玩法，视觉表现力强，适配短视频买量
- **目标用户**: 全球轻度休闲+中度策略用户，覆盖传统三消未触达的男性和年轻群体

## Constraints

- **引擎**: Godot 4.x 开源免费，无授权成本
- **性能**: 低端手机 30fps+，棋盘半径≤5，粒子特效上限控制
- **时间**: 30天完整上线（MVP 7天）
- **平台**: Web优先 → Android/iOS 移动端
- **团队**: 1-2人 + AI辅助

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Godot 4 vs Unity | 开源免费、2D渲染优秀、多端导出原生支持 | — Pending |
| 六边形蜂窝 vs 方形网格 | 核心创新必需，支撑圈层闭环判定 | — Pending |
| AI辅助全流程 | 降低美术/代码/本地化人力成本70%+ | — Pending |
| 出海优先 vs 国内优先 | 零语言壁垒、素材表现力强、无直接竞品 | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-06-18 after initialization*
