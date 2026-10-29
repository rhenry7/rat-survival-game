extends SceneTree
## Prints each asset's size and opaque bounds, plus per-row opaque spans for the foot.
## Run: Godot --headless --path . --script res://tools/print_bbox.gd

func _init() -> void:
	for p in ["res://assets/rat.png", "res://assets/foot.png", "res://assets/pizza.png"]:
		var img := Image.load_from_file(ProjectSettings.globalize_path(p))
		print(p, " size=", img.get_size(), " used=", img.get_used_rect())
		if p.ends_with("foot.png") or p.ends_with("rat.png"):
			for y in range(0, img.get_height(), 20):
				var x0 := -1
				var x1 := -1
				for x in img.get_width():
					if img.get_pixel(x, y).a > 0.5:
						if x0 < 0:
							x0 = x
						x1 = x
				print("  y=", y, " x=", x0, "..", x1)
	quit()
