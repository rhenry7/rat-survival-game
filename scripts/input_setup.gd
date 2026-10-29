class_name InputSetup
extends RefCounted
## Registers input actions in code (avoids hand-serialized InputEvents in project.godot).

const BINDINGS := {
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"start": [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER],
}


static func ensure() -> void:
	for action in BINDINGS:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in BINDINGS[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = key
			InputMap.action_add_event(action, ev)
