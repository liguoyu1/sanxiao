extends ColorRect

@onready var title = $Title
@onready var play_btn = $PlayBtn
@onready var settings_panel = $SettingsPanel
@onready var volume_slider = $SettingsPanel/VolumeSlider

func _am(): return get_node("/root/AudioManager")
func _sm(): return get_node("/root/SaveManager")
func _gf(): return get_node("/root/GameFlow")

func _ready() -> void:
	play_btn.pressed.connect(_on_play)
	$SettingsBtn.pressed.connect(_toggle_settings)
	volume_slider.value = _am().get_volume()
	volume_slider.value_changed.connect(func(v): _am().set_volume(v))
	$SettingsPanel/MuteBtn.toggled.connect(func(t):
		if t != _am().is_muted():
			_am().toggle_mute())
	$SettingsPanel/MuteBtn.button_pressed = _am().is_muted()
	$SettingsPanel/CloseBtn.pressed.connect(func(): settings_panel.hide())

	var theme_name = _sm().selected_theme
	match theme_name:
		"forest":
			color = Color(0.05, 0.12, 0.08)
		"deepsea":
			color = Color(0.03, 0.05, 0.15)
		_:
			color = Color(0.08, 0.08, 0.12)

	_am().start_bgm()

func _on_play() -> void:
	_am().play_click()
	_gf().go_to_level_select()

func _toggle_settings() -> void:
	settings_panel.visible = not settings_panel.visible
