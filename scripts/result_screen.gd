extends ColorRect

signal action_next()
signal action_retry()
signal action_quit()

func _gf(): return GameFlow
func _sm(): return SaveManager

@onready var title_label = $VBox/TitleLabel
@onready var score_label = $VBox/ScoreLabel
@onready var stars_label = $VBox/StarsLabel
@onready var next_btn = $VBox/NextBtn
@onready var retry_btn = $VBox/RetryBtn
@onready var quit_btn = $VBox/QuitBtn

func _ready() -> void:
	next_btn.pressed.connect(func(): action_next.emit())
	retry_btn.pressed.connect(func(): action_retry.emit())
	quit_btn.pressed.connect(func(): action_quit.emit())
	hide()

func show_result(won: bool, score: int, stars: int) -> void:
	show()
	title_label.text = "通关!" if won else "失败"
	score_label.text = "积分: %d" % score
	var s = ""
	for i in 3:
		s += "★" if i < stars else "☆"
	stars_label.text = s
	var next_id = _gf().current_level + 1
	next_btn.visible = won and _sm().is_unlocked(next_id)
