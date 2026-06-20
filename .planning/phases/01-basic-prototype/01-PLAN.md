# Phase 1: 基础原型 — Plan

**Created:** 2026-06-18
**Requirements:** CORE-01, CORE-02, CORE-03, CORE-13, VFX-01, VFX-05
**Duration:** 7 天 → 估 1 次执行会话

## Task Breakdown

### Wave 1: 基础设施 (无依赖，可并行)

| # | Task | 需求 | 描述 | 验收标准 |
|---|------|------|------|----------|
| T1.1 | Godot 项目初始化 | — | 创建 Godot 4.x 项目、目录结构、stretch mode 配置 | `project.godot` 存在、2D stretch mode = canvas_items、窗口 720×1280 |
| T1.2 | 六边形坐标系统 | CORE-01 | 实现 HexCoord 轴向坐标类（q,r）、邻居计算、距离、转换为屏幕像素 | 单元测试覆盖：邻居正确6个、距离函数正确、像素转换无偏移 |
| T1.3 | 棋盘数据模型 | CORE-01 | 创建 HexBoard 管理棋盘状态（字典 dict[q,r]→cell_info）、初始化、查询 | 7×7 棋盘正确初始化、所有 37 个 cell 坐标不重叠 |

### Wave 2: 渲染层 (依赖 Wave 1)

| # | Task | 需求 | 描述 | 验收标准 |
|---|------|------|------|----------|
| T2.1 | 蜂窝棋盘渲染 | CORE-01 | 使用 HexCoord 像素坐标绘制六边形网格线、居中到 Control 容器 | 7×7 蜂巢在 720×1280 窗口内居中、缩放窗口不变形 |
| T2.2 | 碎片 Sprite 渲染 | CORE-01 | 每个 cell 渲染圆形色块 Sprite2D、5 种颜色随机分配 | 37 个碎片正确位置、颜色随机但不相邻3同色有闭环 |
| T2.3 | 棋盘主题配置 | VFX-05 | 创建 .tres 资源文件定义颜色方案、棋子外观 | 创建 `themes/default_board.tres`，颜色可切换 |

### Wave 3: 交互层 (依赖 Wave 2)

| # | Task | 需求 | 描述 | 验收标准 |
|---|------|------|------|----------|
| T3.1 | 拖拽交换系统 | CORE-13 | 输入处理：检测拖拽方向、识别目标 neighbor、调用交换 | 拖拽到邻居 → 正确触发交换、拖拽到非邻居 → 无反应 |
| T3.2 | 交换动画 | CORE-13 | Tween 0.25s lerp 两个碎片位置互换、非法交换抖动回弹 | 交换动画流畅、非法交换碎片抖动后归位 |
| T3.3 | 输入状态机 | CORE-13 | 管理 Idle → Dragging → Animating → Idle 状态转换 | 动画期间不接受新输入、交换完成后恢复 |

### Wave 4: 消除逻辑 (依赖 Wave 3)

| # | Task | 需求 | 描述 | 验收标准 |
|---|------|------|------|----------|
| T4.1 | 三角圈层判定 | CORE-02 | BFS 从交换后的两个位置出发，搜索 3 个同色且形成闭环的相邻碎片 | 三角圈层正确识别、不识别 2 个或 4 个的组合 |
| T4.2 | 消除执行 | CORE-02 | 移除匹配碎片、计分、更新棋盘状态 | 消除后 cell 变为空、分数递增 |
| T4.3 | 消除特效 | VFX-01 | 消除时 Particles2D 粒子爆发 + 圈层闪光，0.3s 持续时间 | 特效触发正确、性能不下降（FPS ≥ 30） |

### Wave 5: 补充循环 (依赖 Wave 4)

| # | Task | 需求 | 描述 | 验收标准 |
|---|------|------|------|----------|
| T5.1 | 碎片掉落补充 | CORE-03 | 空 cell 从上方 cell 下落填充、或顶部新生成、Tween 0.2s 弹跳 | 消除后所有空位被填满、动画正确 |
| T5.2 | 游戏循环编排 | — | 连接 Wave 3→4→5：交换→判定→消除→补充→判定循环直到无消除 | 完整循环可玩无崩溃、连环消除自动触发 |

---

## 文件清单

```
project.godot
scenes/
  main.tscn                    # 主场景（棋盘 + UI 容器）
  board.tscn                   # 棋盘子场景
scripts/
  hex_coord.gd                 # T1.2 — 轴向坐标
  hex_board.gd                 # T1.3 — 棋盘数据模型
  board_renderer.gd            # T2.1 — 棋盘渲染
  tile.gd                      # T2.2 — 碎片 Sprite
  drag_handler.gd              # T3.1 — 拖拽输入
  swap_animator.gd             # T3.2 — 交换动画
  input_state.gd               # T3.3 — 输入状态机
  loop_detector.gd             # T4.1 — 圈层判定
  match_resolver.gd            # T4.2 — 消除执行
  particle_fx.gd               # T4.3 — 粒子特效
  tile_fall.gd                 # T5.1 — 掉落补充
  game_loop.gd                 # T5.2 — 游戏循环
themes/
  default_board.tres           # T2.3 — 棋盘主题配置
```

## 依赖图
```
Wave 1 ─┬─→ Wave 2 ──→ Wave 3 ──→ Wave 4 ──→ Wave 5
         │              (渲染)    (交互)     (消除)    (补充)
         └─→ (数据)
```