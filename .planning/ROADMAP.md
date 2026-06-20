# Roadmap: 圈层共振三消

**Created:** 2026-06-18
**Milestone:** v1.0 — 完整可上线版本
**Phases:** 5 | **Requirements:** 35 | **Est. Duration:** 30 天

---

| # | Phase | 目标 | Requirements | 状态 |
|---|-------|------|--------------|------|
| 1 | **基础原型** | 蜂窝棋盘 + 跨格交换 + 三角消除 MVP | CORE-01,02,03,13 / VFX-01,05 | ✅ 完成 |
| 2 | **核心机制** | 全圈层 + 共振连锁 + 道具 + 紊乱 | CORE-04~12 / VFX-02,03 | 🔄 进行中 |
| 3 | **关卡模式** | 三模式关卡 + 主题切换 + AI批量生成 | MODE-01~04 / VFX-04 | ⬜ |
| 4 | **商业化+平台** | 广告/内购/皮肤 + 三端打包 + 本地化 | COM-01~03 / PLAT-01~03 / LOC-01~04 | ⬜ |
| 5 | **测试+上线** | 全量测试 + 性能优化 + 平台提审 | QA-01~04 | ⬜ |

---

## Phase 1: 基础原型 ✅

**Requirement Status:**
- CORE-01, CORE-02, CORE-03 ✅ 实现
- CORE-13 ✅ 实现
- VFX-01 ✅ 粒子特效实现
- VFX-05 ✅ 交换动画实现

---

## Phase 2: 核心机制 🔄

**Goal:** 全层级圈层消除 + 共振连锁 + 四大道具 + 紊乱碎片

**Requirements:** CORE-04, CORE-05, CORE-06, CORE-07, CORE-08, CORE-09, CORE-10, CORE-11, CORE-12, VFX-02, VFX-03

**Grey Area Decisions:**
1. 四边圈层: 菱形 (4-cell 菱形闭环)
2. 共振范围: 全棋盘
3. 紊乱碎片: 每轮消除后 20% 概率刷新
4. 道具获取: 免费送 + 看广告 + 积分兑换 + 内购 (All)
5. 嵌套触发: 同中心判定

---

## Phase 3: 关卡模式 ⬜

**Goal:** 三种对局模式 + 关卡递进 + 主题切换

**Requirements:** MODE-01, MODE-02, MODE-03, MODE-04, VFX-04

---

## Phase 4: 商业化 + 平台适配 + 本地化 ⬜

**Goal:** 广告/内购接入 + 三端打包 + 多语言本地化

**Requirements:** COM-01, COM-02, COM-03, PLAT-01, PLAT-02, PLAT-03, LOC-01, LOC-02, LOC-03, LOC-04

---

## Phase 5: 测试 + 上线 ⬜

**Goal:** 全量测试 + 性能优化 + 平台提审

**Requirements:** QA-01, QA-02, QA-03, QA-04

---

## Dependency Graph

```
Phase 1 ──→ Phase 2 ──→ Phase 3 ──→ Phase 4 ──→ Phase 5
```

*Roadmap created: 2026-06-18  |  Last updated: 2026-06-18 Phase 1 complete*