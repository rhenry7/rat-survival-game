extends Area2D
## Falling food item (random art each spawn). Collected on touching the rat; disappears if missed.

signal collected

const TEXTURES: Array[Texture2D] = [
	preload("res://assets/pizza.png"),
	preload("res://assets/apple.png"),
	preload("res://assets/bagel.png"),
	preload("res://assets/hotdog.png"),
	preload("res://assets/chicken_leg.png"),
]

var speed := 300.0
var _t := 0.0


func setup(fall_speed: float) -> void:
	speed = fall_speed


func _ready() -> void:
	$Sprite.texture = TEXTURES.pick_random()
	_t = randf() * TAU
	area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	_t += delta * 3.0
	position.y += speed * delta
	rotation = sin(_t) * 0.2
	if position.y > Tuning.PIZZA_DESPAWN_Y:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("rat") and area.alive:
		collected.emit()
		queue_free()


func freeze() -> void:
	set_process(false)
	set_deferred("monitoring", false)
