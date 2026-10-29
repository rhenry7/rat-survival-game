extends Node2D
## Hand-drawn-looking kitchen: striped wall, baseboard with a mouse hole, checker floor.

const WALL := Color("#F6E7C8")
const STRIPE := Color("#EFD9B0")
const BASEBOARD := Color("#C98F5B")
const BASE_LINE := Color("#8A5A36")
const HOLE := Color("#3B2A20")
const TILE_A := Color("#F2D3A2")
const TILE_B := Color("#E2AE74")
const GROUT := Color("#C48E5A")
const INK := Color("#5A3B26")

const WALL_BOTTOM := 400.0
const FLOOR_TOP := 430.0
const TILE := 90.0

var _rng := RandomNumberGenerator.new()


func _draw() -> void:
	_rng.seed = 1234
	var w := Tuning.VIEW_W
	var h := Tuning.VIEW_H

	draw_rect(Rect2(0, 0, w, WALL_BOTTOM), WALL)
	for x in range(30, int(w), 60):
		draw_rect(Rect2(x, 0, 22, WALL_BOTTOM), STRIPE)

	# Floor checker
	for row in range(int(ceil((h - FLOOR_TOP) / TILE))):
		for col in range(int(ceil(w / TILE))):
			var c := TILE_A if (row + col) % 2 == 0 else TILE_B
			draw_rect(Rect2(col * TILE, FLOOR_TOP + row * TILE, TILE, TILE), c)
	for row in range(int(ceil((h - FLOOR_TOP) / TILE)) + 1):
		var y := FLOOR_TOP + row * TILE
		_sketch_line(Vector2(0, y), Vector2(w, y), GROUT, 3.0)
	for col in range(int(ceil(w / TILE)) + 1):
		var x := col * TILE
		_sketch_line(Vector2(x, FLOOR_TOP), Vector2(x, h), GROUT, 3.0)

	# Baseboard
	draw_rect(Rect2(0, WALL_BOTTOM - 10, w, FLOOR_TOP - WALL_BOTTOM + 10), BASEBOARD)
	_sketch_line(Vector2(0, WALL_BOTTOM - 10), Vector2(w, WALL_BOTTOM - 10), BASE_LINE, 4.0)
	_sketch_line(Vector2(0, FLOOR_TOP), Vector2(w, FLOOR_TOP), BASE_LINE, 4.0)

	# Mouse hole
	var hole_c := Vector2(120, FLOOR_TOP - 34)
	draw_rect(Rect2(hole_c.x - 34, hole_c.y, 68, 34), HOLE)
	draw_circle(hole_c, 34, HOLE)
	draw_arc(hole_c, 36, PI, TAU, 24, INK, 4.0, true)


func _sketch_line(a: Vector2, b: Vector2, color: Color, width: float) -> void:
	# Split into wobbly segments so lines look hand-drawn.
	var pts := PackedVector2Array()
	var steps := maxi(2, int(a.distance_to(b) / 60.0))
	for i in steps + 1:
		var p := a.lerp(b, float(i) / steps)
		if i != 0 and i != steps:
			p += Vector2(_rng.randf_range(-2, 2), _rng.randf_range(-2, 2))
		pts.append(p)
	draw_polyline(pts, color, width, true)
