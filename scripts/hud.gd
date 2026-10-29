extends CanvasLayer
## Score display, level banner, and start / game-over panels. Built in code.

const CREAM := Color("#FFF6E0")
const INK := Color("#3B2A20")

var level_label: Label
var total_label: Label
var banner: Label
var start_panel: Control
var start_best: Label
var over_panel: Control
var over_stats: Label
var over_new_best: Label
var _blinkers: Array[Label] = []
var _banner_tween: Tween
var _t := 0.0


func _ready() -> void:
	level_label = _label("", 34, Vector2(20, 20), Vector2(320, 60), HORIZONTAL_ALIGNMENT_LEFT)
	add_child(level_label)
	total_label = _label("", 34, Vector2(340, 20), Vector2(360, 60), HORIZONTAL_ALIGNMENT_RIGHT)
	add_child(total_label)

	banner = _label("", 72, Vector2(0, 260), Vector2(720, 100))
	banner.pivot_offset = Vector2(360, 50)
	banner.modulate.a = 0.0
	add_child(banner)

	start_panel = _panel()
	start_panel.add_child(_label("Rat Survival", 88, Vector2(0, 110), Vector2(720, 120)))
	start_panel.add_child(_label("Dodge the feet, grab the food!", 34, Vector2(0, 230), Vector2(720, 50)))
	var prompt := _label("Press Space / Enter or tap to start", 36, Vector2(0, 340), Vector2(720, 50))
	_blinkers.append(prompt)
	start_panel.add_child(prompt)
	start_panel.add_child(_label("A / D or Arrows to move\nPhone: hold left or right side", 28, Vector2(0, 420), Vector2(720, 90)))
	start_best = _label("", 32, Vector2(0, 530), Vector2(720, 50))
	start_panel.add_child(start_best)
	add_child(start_panel)

	over_panel = _panel()
	over_panel.add_child(_label("SQUASHED!", 96, Vector2(0, 170), Vector2(720, 130)))
	over_stats = _label("", 40, Vector2(0, 320), Vector2(720, 170))
	over_panel.add_child(over_stats)
	over_new_best = _label("New best!", 44, Vector2(0, 500), Vector2(720, 60))
	over_new_best.label_settings.font_color = Color("#FFD34D")
	over_panel.add_child(over_new_best)
	var again := _label("Press Space / Enter or tap to restart", 34, Vector2(0, 620), Vector2(720, 50))
	_blinkers.append(again)
	over_panel.add_child(again)
	add_child(over_panel)


func _process(delta: float) -> void:
	_t += delta
	var a := 0.55 + 0.45 * sin(_t * 4.0)
	for l in _blinkers:
		l.modulate.a = a


func show_start(best: int) -> void:
	start_best.text = "Best: %d food scavenged" % best if best > 0 else ""
	start_panel.visible = true
	over_panel.visible = false
	level_label.visible = false
	total_label.visible = false


func show_playing() -> void:
	start_panel.visible = false
	over_panel.visible = false
	level_label.visible = true
	total_label.visible = true
	banner.modulate.a = 0.0


func set_score(level: int, count: int, target: int, total: int) -> void:
	level_label.text = "Level %d: %d/%d" % [level, count, target]
	total_label.text = "Food scavenged: %d" % total


func show_banner(text: String) -> void:
	if _banner_tween:
		_banner_tween.kill()
	banner.text = text
	banner.scale = Vector2(0.5, 0.5)
	banner.modulate.a = 1.0
	_banner_tween = create_tween()
	_banner_tween.tween_property(banner, "scale", Vector2(1.1, 1.1), 0.15).set_trans(Tween.TRANS_BACK)
	_banner_tween.tween_property(banner, "scale", Vector2.ONE, 0.1)
	_banner_tween.tween_interval(0.8)
	_banner_tween.tween_property(banner, "modulate:a", 0.0, 0.35)


func show_game_over(total: int, level: int, best: int, is_new: bool) -> void:
	if _banner_tween:
		_banner_tween.kill()
	banner.modulate.a = 0.0
	over_stats.text = "Food scavenged: %d\nLevel reached: %d\nBest: %d" % [total, level, best]
	over_new_best.visible = is_new
	over_panel.visible = true


func _label(text: String, size: int, pos: Vector2, box: Vector2,
		align := HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var ls := LabelSettings.new()
	ls.font_size = size
	ls.font_color = CREAM
	ls.outline_size = maxi(6, size / 5)
	ls.outline_color = INK
	ls.shadow_color = Color(0, 0, 0, 0.35)
	ls.shadow_offset = Vector2(3, 4)
	var l := Label.new()
	l.text = text
	l.label_settings = ls
	l.position = pos
	l.size = box
	l.horizontal_alignment = align
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _panel() -> Control:
	var p := ColorRect.new()
	p.color = Color(0.12, 0.08, 0.05, 0.55)
	p.position = Vector2.ZERO
	p.size = Vector2(Tuning.VIEW_W, Tuning.VIEW_H)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.visible = false
	return p
