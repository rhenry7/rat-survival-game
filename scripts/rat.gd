extends Area2D
## Player rat: horizontal-only movement, faces its direction, bobs while moving.

signal died

var active := false
var alive := true
var velocity_x := 0.0
var _bob_t := 0.0
var _touches := {}  # touch index -> x position
var _death_tween: Tween

@onready var visual: Node2D = $Visual


func reset(x: float) -> void:
	if _death_tween:
		_death_tween.kill()
	position.x = x
	velocity_x = 0.0
	alive = true
	_touches.clear()
	_bob_t = 0.0
	visual.scale = Vector2(Tuning.RAT_SCALE, Tuning.RAT_SCALE)
	visual.position = Vector2.ZERO
	visual.rotation = 0.0
	visual.modulate = Color.WHITE


func _physics_process(delta: float) -> void:
	if not active or not alive:
		return

	var dir := Input.get_axis("move_left", "move_right")
	if dir == 0.0:
		dir = _touch_dir()

	velocity_x = move_toward(velocity_x, dir * Tuning.RAT_SPEED, Tuning.RAT_ACCEL * delta)
	position.x = clampf(position.x + velocity_x * delta, Tuning.RAT_MIN_X, Tuning.RAT_MAX_X)

	if absf(velocity_x) > 20.0:
		_bob_t += delta * Tuning.BOB_FREQ
		visual.position.y = -absf(sin(_bob_t)) * Tuning.BOB_HEIGHT
		visual.rotation = sin(_bob_t) * Tuning.BOB_TILT
	else:
		visual.position.y = lerpf(visual.position.y, 0.0, 0.3)
		visual.rotation = lerpf(visual.rotation, 0.0, 0.3)

	for a in get_overlapping_areas():
		if not a.is_in_group("foot_hitbox") or not a.is_inside_tree():
			continue
		var foot := a.get_parent()
		if not foot.is_queued_for_deletion() and foot.is_lethal():
			die()
			return


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_touches[event.index] = event.position.x
		else:
			_touches.erase(event.index)
	elif event is InputEventScreenDrag:
		_touches[event.index] = event.position.x


func _touch_dir() -> float:
	if _touches.is_empty():
		return 0.0
	var x: float = _touches[_touches.keys().back()]
	return -1.0 if x < Tuning.VIEW_W / 2.0 else 1.0


func die() -> void:
	if not alive:
		return
	alive = false
	died.emit()
	var sx := signf(visual.scale.x) * Tuning.RAT_SCALE
	_death_tween = create_tween().set_parallel()
	_death_tween.tween_property(visual, "scale", Vector2(sx * 1.4, Tuning.RAT_SCALE * 0.25), 0.12)
	_death_tween.tween_property(visual, "rotation", 0.0, 0.12)
	_death_tween.tween_property(visual, "position:y", 0.0, 0.12)
	_death_tween.tween_property(visual, "modulate", Color(1, 0.75, 0.75), 0.12)
