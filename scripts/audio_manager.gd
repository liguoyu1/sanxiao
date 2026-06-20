extends Node
## 音频系统 — 程序化生成音效 + BGM
## autoload 注册为 "AudioManager"

const VOL_CFG := "user://audio.cfg"

var master_bus: int
var sfx_bus: int
var music_bus: int
var _volume: float = 0.8
var _muted: bool = false

var _bgm_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []

func _ready() -> void:
	_load_config()
	master_bus = AudioServer.get_bus_index("Master")
	sfx_bus = _ensure_bus("SFX", master_bus)
	music_bus = _ensure_bus("Music", master_bus)

	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.bus = "Music"
	_bgm_player.volume_db = -12
	add_child(_bgm_player)

	for i in 3:
		var p = AudioStreamPlayer.new()
		p.bus = "SFX"
		p.volume_db = -6
		add_child(p)
		_sfx_players.append(p)

	_apply_volume()

func _load_config() -> void:
	var cfg = ConfigFile.new()
	if cfg.load(VOL_CFG) == OK:
		_volume = cfg.get_value("audio", "volume", 0.8)
		_muted = cfg.get_value("audio", "muted", false)

func _save_config() -> void:
	var cfg = ConfigFile.new()
	cfg.set_value("audio", "volume", _volume)
	cfg.set_value("audio", "muted", _muted)
	cfg.save(VOL_CFG)

func _ensure_bus(name: String, parent: int) -> int:
	for i in AudioServer.bus_count:
		if AudioServer.get_bus_name(i) == name:
			return i
	var idx = AudioServer.bus_count
	AudioServer.add_bus(idx)
	AudioServer.set_bus_name(idx, name)
	AudioServer.set_bus_send(idx, AudioServer.get_bus_name(parent))
	return idx

func _apply_volume() -> void:
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(clampf(_volume, 0.001, 1)))
	AudioServer.set_bus_mute(master_bus, _muted)

func play_sfx(freq: float = 440, dur: float = 0.15) -> void:
	var wav = _gen_tone(freq, dur, 0.3)
	var p = _next_sfx()
	if p and wav:
		p.stream = wav
		p.play()

func play_match() -> void:
	play_sfx(523, 0.12)

func play_swap() -> void:
	play_sfx(392, 0.08)

func play_ripple() -> void:
	play_sfx(659, 0.2)

func play_win() -> void:
	for f in [523, 659, 784, 1047]:
		play_sfx(f, 0.15)
		await get_tree().create_timer(0.1).timeout

func play_lose() -> void:
	play_sfx(262, 0.3)
	await get_tree().create_timer(0.15).timeout
	play_sfx(220, 0.4)

func play_click() -> void:
	play_sfx(880, 0.05)

func play_power() -> void:
	play_sfx(440, 0.1)
	await get_tree().create_timer(0.08).timeout
	play_sfx(880, 0.15)

func start_bgm() -> void:
	if _bgm_player.playing:
		return
	var wav = _gen_bgm(30.0)
	_bgm_player.stream = wav
	_bgm_player.play()

func stop_bgm() -> void:
	_bgm_player.stop()

func _next_sfx() -> AudioStreamPlayer:
	for p in _sfx_players:
		if not p.playing:
			return p
	return _sfx_players[0]

func get_volume() -> float:
	return _volume

func is_muted() -> bool:
	return _muted

func set_volume(v: float) -> void:
	_volume = clampf(v, 0, 1)
	_apply_volume()
	_save_config()

func toggle_mute() -> void:
	_muted = not _muted
	_apply_volume()
	_save_config()

## 生成正弦波音调
func _gen_tone(freq: float, dur: float, vol: float = 0.5) -> AudioStreamWAV:
	var sr = 22050
	var frames = int(sr * dur)
	if frames < 1: frames = 1
	var data = PackedByteArray()
	data.resize(frames * 2)
	for i in frames:
		var t = float(i) / sr
		var envelope = 1.0 - float(i) / frames
		envelope = envelope * envelope
		var s = sin(2.0 * PI * freq * t) * vol * envelope
		var v = int(clampf(s, -1, 1) * 32767.0)
		data.encode_s16(i * 2, v)
	var wav = AudioStreamWAV.new()
	wav.data = data
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sr
	wav.stereo = false
	return wav

## 生成简单 BGM 循环
func _gen_bgm(dur: float) -> AudioStreamWAV:
	var sr = 22050
	var frames = int(sr * dur)
	if frames < 1: frames = 1
	var data = PackedByteArray()
	data.resize(frames * 2)
	var chords = [
		[261, 329, 392],
		[293, 349, 440],
		[349, 440, 523],
		[261, 349, 440],
	]
	var beat_len = float(sr) * 2.0
	for i in frames:
		var chord_idx = int(i / beat_len) % chords.size()
		var t = float(i) / sr
		var s = 0.0
		for f in chords[chord_idx]:
			s += sin(2.0 * PI * f * t) * 0.08
		var envelope = 1.0 - float(i) / frames
		s *= envelope * 0.3
		var v = int(clampf(s, -1, 1) * 32767.0)
		data.encode_s16(i * 2, v)
	var wav = AudioStreamWAV.new()
	wav.data = data
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sr
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	return wav
