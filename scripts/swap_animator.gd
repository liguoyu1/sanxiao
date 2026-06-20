extends Node
## 交换动画管理 — 合法交换 lerp / 非法交换抖动

const BoardRenderer = preload("res://scripts/board_renderer.gd")

var renderer: BoardRenderer

func setup(rend: BoardRenderer) -> void:
	renderer = rend

## 交换动画 (合法)
func animate_swap(hc1, hc2):
	var t1 = renderer._tiles.get(hc1.to_vector2i())
	var t2 = renderer._tiles.get(hc2.to_vector2i())
	if t1 == null or t2 == null:
		return
	var pos1 = t1.position
	var pos2 = t2.position
	var tw = create_tween().set_parallel(true)
	tw.tween_property(t1, "position", pos2, 0.25).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(t2, "position", pos1, 0.25).set_ease(Tween.EASE_IN_OUT)

## 非法交换抖动
func animate_invalid(hc):
	var t = renderer._tiles.get(hc.to_vector2i())
	if t == null:
		return
	var orig = t.position
	var tw = create_tween()
	tw.tween_property(t, "position:x", orig.x + 6, 0.05)
	tw.tween_property(t, "position:x", orig.x - 6, 0.05)
	tw.tween_property(t, "position:x", orig.x, 0.05)

## 是否正在播放动画 (简化: 用信号)
var animating: bool = false