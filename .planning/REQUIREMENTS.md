# Requirements: 圈层共振三消

**Defined:** 2026-06-18
**Core Value:** 圈层闭环消除 + 共振连锁 — 摆脱传统三消横竖连线规则，创造新颖解压体验

## v1 Requirements

### 核心玩法 (CORE)

- [ ] **CORE-01**: 六边形蜂窝棋盘正确渲染，各分辨率居中自适应
- [ ] **CORE-02**: 玩家可点击选中任意碎片，再点击另一碎片完成跨格自由交换
- [ ] **CORE-03**: 交换后若形成三角圈层（3个同色碎片两两相邻闭合），触发基础消除
- [ ] **CORE-04**: 交换后若形成四边圈层（4个同色碎片闭环），触发进阶消除+小幅共振
- [ ] **CORE-05**: 交换后若形成六边满环（6个同色碎片正六边形闭环），触发全域共振消除
- [ ] **CORE-06**: 系统自动识别嵌套圈层（小三角在大六边形内部），触发双重共振
- [ ] **CORE-07**: 任意圈层消除后，波纹扩散至周边同色碎片，自动补全残缺圈层触发连锁消除
- [ ] **CORE-08**: 棋盘随机刷新紊乱碎片，该碎片不参与圈层成型且阻挡波纹共振
- [ ] **CORE-09**: 玩家可使用「共振波纹」道具主动触发小范围波纹扩散
- [ ] **CORE-10**: 玩家可使用「圈层固化」道具自动吸附周边同色碎片快速成型
- [ ] **CORE-11**: 玩家可使用「全域谐振」道具激活棋盘所有半成品圈层
- [ ] **CORE-12**: 玩家可使用「紊乱净化」道具清除全场紊乱碎片
- [ ] **CORE-13**: 消除后棋盘自动掉落补充，掉落动画流畅

### 关卡模式 (MODE)

- [ ] **MODE-01**: 经典闯关 — 步数限制内达成指定圈层消除数量/积分目标即通关
- [ ] **MODE-02**: 限时共振 — 60秒倒计时，无步数限制，冲击最高分
- [ ] **MODE-03**: 圈层解谜 — 固定棋盘布局，极少步数，需精准规划才能通关
- [ ] **MODE-04**: 关卡递进解锁，难度平滑提升，新手零压力

### 视觉特效 (VFX)

- [ ] **VFX-01**: 消除时粒子爆发特效（基础/进阶/全屏/嵌套 四档区分）
- [ ] **VFX-02**: 波纹扩散动画（以消除圈层为中心向外扩散）
- [ ] **VFX-03**: 圈层发光/共振炸裂特效
- [ ] **VFX-04**: 棋盘主题切换（森林/星空/深海）一键切换背景与配色
- [ ] **VFX-05**: 碎片交换平滑动画（缓动位移）

### 商业化 (COM)

- [ ] **COM-01**: 激励视频广告 — 复活看广告、道具获取看广告、双倍积分看广告
- [ ] **COM-02**: 内购系统 — 道具礼包、关卡解锁、去广告
- [ ] **COM-03**: 皮肤商店 — 圈层皮肤、波纹特效皮肤、棋盘主题皮肤

### 平台适配 (PLAT)

- [ ] **PLAT-01**: Web/HTML5 导出，浏览器全屏适配
- [ ] **PLAT-02**: Android APK 打包，多分辨率适配
- [ ] **PLAT-03**: iOS 打包，App Store 配置

### 本地化 (LOC)

- [ ] **LOC-01**: 多语言文本提取与翻译键值系统
- [ ] **LOC-02**: 英文翻译
- [ ] **LOC-03**: 日韩翻译
- [ ] **LOC-04**: 东南亚/拉美翻译（泰/印尼/西/葡）

### 测试与优化 (QA)

- [ ] **QA-01**: AI自动化万次对局模拟，检测卡屏/判定失效/连锁异常
- [ ] **QA-02**: 低端设备性能压测，30fps+ 目标
- [ ] **QA-03**: 多分辨率UI适配验证
- [ ] **QA-04**: 难度数值微调（胜率曲线/道具使用率/广告触达率）

## v2 Requirements

### 社交与排行

- **SOC-01**: 好友排行榜（关卡分数/限时模式分数）
- **SOC-02**: 每日挑战关卡
- **SOC-03**: 关卡攻略分享

### 长线运营

- **LIVE-01**: 节日限定皮肤/特效
- **LIVE-02**: 周活动关卡
- **LIVE-03**: 赛季通行证

## Out of Scope

| Feature | Reason |
|---------|--------|
| PVP实时对战 | v1聚焦单机体验，社交对战延后 |
| 大世界/MMO社交系统 | 轻量化定位，不增加服务器成本 |
| 剧情/文字叙事系统 | 文字无依赖是出海核心优势，不引入 |
| 关卡编辑器/UGC | 开发成本高，v1由AI批量生成 |
| 微信/抖音小程序 | 国内市场不考虑，专注海外 Web + Android + iOS |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| CORE-01 | Phase 1 | Pending |
| CORE-02 | Phase 1 | Pending |
| CORE-03 | Phase 1 | Pending |
| CORE-04 | Phase 2 | Pending |
| CORE-05 | Phase 2 | Pending |
| CORE-06 | Phase 2 | Pending |
| CORE-07 | Phase 2 | Pending |
| CORE-08 | Phase 2 | Pending |
| CORE-09 | Phase 2 | Pending |
| CORE-10 | Phase 2 | Pending |
| CORE-11 | Phase 2 | Pending |
| CORE-12 | Phase 2 | Pending |
| CORE-13 | Phase 1 | Pending |
| MODE-01 | Phase 3 | Pending |
| MODE-02 | Phase 3 | Pending |
| MODE-03 | Phase 3 | Pending |
| MODE-04 | Phase 3 | Pending |
| VFX-01 | Phase 1 | Pending |
| VFX-02 | Phase 2 | Pending |
| VFX-03 | Phase 2 | Pending |
| VFX-04 | Phase 3 | Pending |
| VFX-05 | Phase 1 | Pending |
| COM-01 | Phase 4 | Pending |
| COM-02 | Phase 4 | Pending |
| COM-03 | Phase 4 | Pending |
| PLAT-01 | Phase 4 | Pending |
| PLAT-02 | Phase 4 | Pending |
| PLAT-03 | Phase 4 | Pending |
| LOC-01 | Phase 4 | Pending |
| LOC-02 | Phase 4 | Pending |
| LOC-03 | Phase 4 | Pending |
| LOC-04 | Phase 4 | Pending |
| QA-01 | Phase 5 | Pending |
| QA-02 | Phase 5 | Pending |
| QA-03 | Phase 5 | Pending |
| QA-04 | Phase 5 | Pending |

**Coverage:**
- v1 requirements: 35 total
- Mapped to phases: 35
- Unmapped: 0 ✓

---
*Requirements defined: 2026-06-18*
*Last updated: 2026-06-18 after initial definition*