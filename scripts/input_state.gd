extends Node
## 输入状态机 — Idle → Dragging → Animating → Idle

enum State { IDLE, DRAGGING, ANIMATING }

var state: State = State.IDLE

func can_interact() -> bool:
	return state == State.IDLE

func start_drag() -> void:
	state = State.DRAGGING

func end_drag() -> void:
	if state == State.DRAGGING:
		state = State.IDLE

func start_anim() -> void:
	state = State.ANIMATING

func end_anim() -> void:
	if state == State.ANIMATING:
		state = State.IDLE