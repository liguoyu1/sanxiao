extends Node
## 粒子特效 — 消除时爆裂 + 圈层闪光

var renderer

func setup(rend) -> void:
	renderer = rend

func play_remove_fx(positions: Array) -> void:
	for pos in positions:
		var particles = CPUParticles2D.new()
		particles.emitting = true
		particles.one_shot = true
		particles.lifetime = 0.5
		particles.amount = 12
		particles.explosiveness = 1.0
		particles.direction = Vector2(0, -1)
		particles.spread = 180
		particles.gravity = Vector2(0, 80)
		particles.initial_velocity_min = 60
		particles.initial_velocity_max = 120
		particles.color = Color(1, 0.8, 0.2, 1)
		particles.scale_amount_min = 3.0
		particles.scale_amount_max = 5.0
		particles.finished.connect(particles.queue_free)
		particles.position = pos
		renderer.add_child(particles)
	
	# 圈层闪光 (中心脉冲)
	if positions.size() > 0:
		var center = positions[0]
		var flash = ColorRect.new()
		flash.color = Color(1, 1, 1, 0.3)
		flash.size = Vector2(80, 80)
		flash.position = center - Vector2(40, 40)
		renderer.add_child(flash)
		var tw = create_tween()
		tw.tween_property(flash, "modulate:a", 0.0, 0.3)
		tw.tween_callback(flash.queue_free)

func play_purge_fx() -> void:
	var flash = ColorRect.new()
	flash.color = Color(0.5, 0.8, 1, 0.4)
	flash.size = Vector2(600, 600)
	flash.position = Vector2(-300, -300)
	renderer.add_child(flash)
	var tw = create_tween()
	tw.tween_property(flash, "modulate:a", 0.0, 0.5)
	tw.tween_callback(flash.queue_free)