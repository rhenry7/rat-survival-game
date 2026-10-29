extends Node2D
## A stomping foot. The root sits on the ground line and draws the shadow;
## only the Body (Area2D) moves vertically: warn -> descend -> grounded -> lift.

signal landed

enum Phase { WARN, DESCEND, GROUNDED, LIFT }

var phase := Phase.WARN
var _fall_speed := 1700.0
var _warn_time := 0.75
var _mirrored := false
var _tween: Tween
var _t := 0.0

@onready var body: Area2D = $Body


func setup(fall_speed: float, warn_time: float, mirrored: bool) -> void:
	_fall_speed = fall_speed
	_warn_time = warn_time
	_mirrored = mirrored


func _ready() -> void:
	body.position.y = -Tuning.FOOT_START_H
	if _mirrored:
		body.scale.x = -1.0
	_tween = create_tween()
	_tween.tween_interval(_warn_time)
	_tween.tween_callback(func(): phase = Phase.DESCEND)
	_tween.tween_property(body, "position:y", 0.0, Tuning.FOOT_START_H / _fall_speed) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween.tween_callback(func():
		phase = Phase.GROUNDED
		landed.emit())
	_tween.tween_interval(Tuning.FOOT_GROUND_PAUSE)
	_tween.tween_callback(func(): phase = Phase.LIFT)
	_tween.tween_property(body, "position:y", -Tuning.FOOT_START_H - 300.0, Tuning.FOOT_LIFT_TIME) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_tween.tween_callback(queue_free)


func is_lethal() -> bool:
	match phase:
		Phase.DESCEND, Phase.GROUNDED:
			return true
		Phase.LIFT:
			return body.position.y > -Tuning.FOOT_LETHAL_LIFT_CLEARANCE
	return false


## True if this foot is (or will soon be) occupying ground near x.
func blocks(x: float, margin: float) -> bool:
	return phase != Phase.LIFT and absf(x - position.x) < margin


func freeze() -> void:
	if _tween:
		_tween.kill()
	set_process(false)


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	var closeness := clampf(1.0 - (-body.position.y / Tuning.FOOT_START_H), 0.0, 1.0)
	var r := Tuning.SHADOW_RADIUS * lerpf(0.45, 1.0, closeness)
	var col := Color(0, 0, 0, 0.35)
	if phase == Phase.WARN:
		var pulse := 0.5 + 0.5 * sin(_t * 18.0)
		col = Color(0.85, 0.15, 0.1, lerpf(0.25, 0.5, pulse))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, Tuning.SHADOW_Y_SQUASH))
	draw_circle(Vector2.ZERO, r, col)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
