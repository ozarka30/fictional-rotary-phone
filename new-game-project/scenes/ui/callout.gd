@tool
class_name Callout extends InkPanel
## A comic callout whose tail points at something. Flips itself to stay on screen.

@export var tip := Vector2(29, 115)  ## where the tail ends, in texture pixels (unflipped)
@export_multiline var text := "":
	set(v): text = v; _layout()


## Show `msg` with the tail touching `target` (a canvas position).
func say(msg: String, target: Vector2) -> void:
	text = msg
	show()
	point_at(target)


func point_at(target: Vector2) -> void:
	flip = false
	var pos := target - tip * panel_scale
	var view := get_viewport_rect().size
	if pos.x + size.x > view.x or pos.x < 0:
		flip = true
		pos.x = target.x - (border.get_size().x - tip.x) * panel_scale
	global_position = pos


func _laid_out() -> void:
	%Text.text = text
