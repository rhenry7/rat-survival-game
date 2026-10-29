extends Node2D
## Game flow: start screen -> playing (spawning feet & pizzas, levels) -> game over.

enum State { START, PLAYING, GAME_OVER }

const FootScene := preload("res://scenes/foot.tscn")
const PizzaScene := preload("res://scenes/pizza.tscn")
const SAVE_PATH := "user://save.cfg"

var state := State.START
var level := 1
var level_count := 0
var total := 0
var high_score := 0
var _accept_input_at_ms := 0
var _shake_tween: Tween

@onready var world: Node2D = $World
@onready var rat: Area2D = $World/Rat
@onready var feet: Node2D = $World/Feet
@onready var pizzas: Node2D = $World/Pizzas
@onready var foot_timer: Timer = $FootTimer
@onready var pizza_timer: Timer = $PizzaTimer
@onready var hud: CanvasLayer = $HUD


func _ready() -> void:
	InputSetup.ensure()
	randomize()
	high_score = _load_high()
	rat.died.connect(_on_rat_died)
	foot_timer.timeout.connect(_on_foot_timer)
	pizza_timer.timeout.connect(_on_pizza_timer)
	rat.active = false
	rat.position = Vector2(Tuning.VIEW_W / 2.0, Tuning.GROUND_Y)
	hud.show_start(high_score)
	if "--autostart" in OS.get_cmdline_user_args():
		start_game.call_deferred()


func _unhandled_input(event: InputEvent) -> void:
	var go: bool = event.is_action_pressed("start") \
		or (event is InputEventScreenTouch and event.pressed)
	if not go:
		return
	match state:
		State.START:
			start_game()
		State.GAME_OVER:
			if Time.get_ticks_msec() >= _accept_input_at_ms:
				start_game()


func start_game() -> void:
	# Detach immediately so leftover (frozen, lethal) feet can't hit the new rat this frame.
	for n in feet.get_children() + pizzas.get_children():
		n.get_parent().remove_child(n)
		n.queue_free()
	level = 1
	level_count = 0
	total = 0
	rat.reset(Tuning.VIEW_W / 2.0)
	rat.active = true
	state = State.PLAYING
	hud.show_playing()
	_refresh_hud()
	foot_timer.start(Tuning.FIRST_FOOT_DELAY)
	pizza_timer.start(Tuning.FIRST_PIZZA_DELAY)
	_log("[game] start")


func _on_foot_timer() -> void:
	if state != State.PLAYING:
		return
	if _live_feet().size() < Tuning.max_feet(level):
		_spawn_foot()
	foot_timer.start(Tuning.foot_interval(level) * randf_range(0.8, 1.2))


func _spawn_foot() -> void:
	var f := FootScene.instantiate()
	var x := _pick_foot_x()
	f.position = Vector2(x, Tuning.GROUND_Y)
	f.setup(Tuning.fall_speed(level), Tuning.warn_time(level), randf() < 0.5)
	f.landed.connect(_shake)
	feet.add_child(f)
	_log("[spawn] foot x=%d" % x)


func _pick_foot_x() -> float:
	var x := 0.0
	for i in 6:
		if randf() < Tuning.target_chance(level):
			x = clampf(rat.position.x + randf_range(-60, 60), Tuning.FOOT_X_MIN, Tuning.FOOT_X_MAX)
		else:
			x = randf_range(Tuning.FOOT_X_MIN, Tuning.FOOT_X_MAX)
		if not _any_foot_blocks(x, Tuning.FOOT_MIN_SEPARATION):
			break
	return x


func _on_pizza_timer() -> void:
	if state != State.PLAYING:
		return
	_spawn_pizza()
	pizza_timer.start(Tuning.pizza_interval(level) * randf_range(0.85, 1.15))


func _spawn_pizza() -> void:
	var x := 0.0
	for i in 8:
		x = randf_range(Tuning.PIZZA_X_MIN, Tuning.PIZZA_X_MAX)
		if not _any_foot_blocks(x, Tuning.PIZZA_AVOID_FOOT):
			break
	var p := PizzaScene.instantiate()
	p.position = Vector2(x, -60)
	p.setup(Tuning.pizza_speed(level))
	p.collected.connect(_on_pizza_collected)
	pizzas.add_child(p)


func _on_pizza_collected() -> void:
	if state != State.PLAYING:
		return
	total += 1
	level_count += 1
	if level_count >= Tuning.target(level):
		level += 1
		level_count = 0
		hud.show_banner("Level %d!" % level)
		_log("[level] %d" % level)
	_refresh_hud()


func _on_rat_died() -> void:
	state = State.GAME_OVER
	foot_timer.stop()
	pizza_timer.stop()
	get_tree().call_group("feet", "freeze")
	get_tree().call_group("pizzas", "freeze")
	var is_new := total > high_score
	if is_new:
		high_score = total
		_save_high()
	hud.show_game_over(total, level, high_score, is_new)
	_accept_input_at_ms = Time.get_ticks_msec() + Tuning.RESTART_DELAY_MS
	_log("[game] over total=%d level=%d" % [total, level])


func _shake() -> void:
	if _shake_tween:
		_shake_tween.kill()
	_shake_tween = create_tween()
	var step := Tuning.SHAKE_TIME / 4.0
	for i in 3:
		var off := Vector2(randf_range(-1, 1), randf_range(-1, 1)) * Tuning.SHAKE_PX
		_shake_tween.tween_property(world, "position", off, step)
	_shake_tween.tween_property(world, "position", Vector2.ZERO, step)


func _live_feet() -> Array:
	return feet.get_children().filter(func(f): return not f.is_queued_for_deletion())


func _any_foot_blocks(x: float, margin: float) -> bool:
	for f in _live_feet():
		if f.blocks(x, margin):
			return true
	return false


func _refresh_hud() -> void:
	hud.set_score(level, level_count, Tuning.target(level), total)


func _load_high() -> int:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return 0
	return int(cfg.get_value("score", "best", 0))


func _save_high() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("score", "best", high_score)
	cfg.save(SAVE_PATH)


func _log(msg: String) -> void:
	if OS.is_debug_build():
		print(msg)
