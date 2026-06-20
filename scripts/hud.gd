extends Control
## HUD — 计分/步数/计时/目标/道具按钮

signal pause_pressed()
signal power_pressed(idx: int)
signal level_result(score: int)

@onready var score_label = $ScoreLabel
@onready var steps_label = $StepsLabel
@onready var timer_label = $TimerLabel
@onready var target_label = $TargetLabel
@onready var power_buttons = [$PowerRow/PowerBtn0, $PowerRow/PowerBtn1, $PowerRow/PowerBtn2, $PowerRow/PowerBtn3]

var score: int = 0
var steps_left: int = 30
var time_left: float = 0.0
var target_score: int = 0
var target_loops: int = 0
var loops_made: int = 0
var is_timed: bool = false
var active: bool = false

func _ready() -> void:
	for i in 4:
		power_buttons[i].pressed.connect(func(): power_pressed.emit(i))

func setup_for_level(lv) -> void:
	steps_left = lv.max_steps if lv.max_steps > 0 else 999
	target_score = lv.target_score
	target_loops = lv.target_loops
	time_left = lv.time_limit
	is_timed = lv.mode == 1  # TIMED
	loops_made = 0
	active = true
	_update_ui()

func update_score(s: int) -> void:
	score = s
	_update_ui()
	_check_victory()

func use_step() -> void:
	if not is_timed:
		steps_left -= 1
		_update_ui()
		if steps_left <= 0:
			_check_victory()

func add_loop() -> void:
	loops_made += 1
	_update_ui()

func _process(delta: float) -> void:
	if is_timed and active and time_left > 0:
		time_left -= delta
		_update_ui()
		if time_left <= 0:
			time_left = 0
			_check_victory()

func _check_victory() -> void:
	active = false
	if is_timed and time_left <= 0:
		level_result.emit(score)
		return
	
	if not is_timed and steps_left <= 0:
		var score_ok = target_score <= 0 or score >= target_score
		var loop_ok = target_loops <= 0 or loops_made >= target_loops
		level_result.emit(score if (score_ok and loop_ok) else -1)
		return
	
	active = true

func _update_ui() -> void:
	score_label.text = "🍭 %d" % score
	if is_timed:
		timer_label.text = "⏱ %.0f" % max(0, time_left)
		timer_label.visible = true
		steps_label.visible = false
	else:
		steps_label.text = "👣 %d" % max(0, steps_left)
		steps_label.visible = true
		timer_label.visible = false
	
	var parts = []
	if target_score > 0: parts.append("目标积分: %d" % target_score)
	if target_loops > 0: parts.append("目标圈层: %d/%d" % [loops_made, target_loops])
	target_label.text = " | ".join(parts) if parts else ""

func set_power_counts(counts: Array) -> void:
	for i in 4:
		var btn = power_buttons[i]
		btn.text = "x%d" % counts[i]