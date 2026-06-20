# Phase 1: 基础原型 - Context

**Gathered:** 2026-06-18
**Status:** Ready for planning
**Mode:** Smart Discuss (interactive)

<domain>
## Phase Boundary

实现可演示 MVP：六边形蜂窝棋盘渲染 + 拖拽跨格交换 + 三角圈层消除判定 + 消除特效 + 碎片掉落补充。不包含四边/六边圈层、共振连锁、道具、关卡模式、商业化。

**Requirements:** CORE-01, CORE-02, CORE-03, CORE-13, VFX-01, VFX-05

**成功标准:**
1. 蜂窝棋盘正确渲染，多分辨率居中自适应
2. 点击拖拽→交换动画→三角圈层判定→消除→掉落补充 完整循环可玩
3. 消除时基础粒子特效正确显示
</domain>

<decisions>
## Implementation Decisions

### 六边形棋盘渲染
- 棋盘大小：半径3（7×7 蜂巢），符合 PROJECT.md ≤5 约束，MVP验证足够
- 碎片渲染：Sprite2D + 简单圆形色块，零依赖、Phase 1 无需美术素材
- 坐标系统：轴向坐标 (q, r)，与 PROJECT.md 约定一致，Godot 六边形网格标准
- 多分辨率：Control 容器居中 + Godot stretch mode，原生适配

### 交换交互设计
- 操作方式：拖拽交换（drag & drop），三消品类用户直觉，触屏+鼠标兼容
- 交换动画：0.25s 缓入缓出 Tween，快速但有质感
- 非法交换：碎片抖动 + 回弹，简洁反馈
- 判定时机：动画完成后判定，避免视觉混乱

### 消除判定与特效
- 三角圈层判定：BFS/DFS 沿同色邻居搜索闭环，标准图算法
- 消除特效：Particles2D 粒子爆发 + 圈层闪光，原生高性能
- 碎片补充：顶部随机生成下落，与传统三消一致
- 掉落动画：线性插值 0.2s + 轻微弹跳，快速但注重质感

### 项目与文件结构
- 文件组织：平面 scene/script 同目录，小团队零抽象开销
- 场景管理：单场景 + 节点树切换，Phase 1 仅棋盘
- 关卡数据：.tres 资源文件驱动棋盘配置，便于后续 AI 批量生成
- Git 策略：main 直接开发 + 阶段末 tag
</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- 无 — 绿地项目，零代码基础

### Established Patterns
- 无 — 首次建立项目规范

### Integration Points
- 无 — Phase 1 为起点，所有后续阶段以此为基础
</code_context>

<specifics>
## Specific Ideas

- 棋盘风格暂用纯色+几何图形，Phase 3 加入皮肤/主题系统
- 六边形坐标参考 https://www.redblobgames.com/grids/hexagons/ 轴向坐标实现
- Godot 六边形可参考 HexGrid 社区插件（不强制使用）

无其他特定需求 — 遵循 Godot GDScript 标准实践。
</specifics>

<deferred>
## Deferred Ideas

- 六边/四边圈层判定 → Phase 2
- 共振连锁系统 → Phase 2
- 道具系统 → Phase 2
- 关卡模式 → Phase 3
- 棋盘主题/皮肤 → Phase 4
- 音效 → Phase 4
</deferred>
