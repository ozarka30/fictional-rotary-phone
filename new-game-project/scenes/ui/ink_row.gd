@tool
class_name InkRow extends Control
## Lays its InkPanel children out in a row whose slanted edges interlock.
## `gaps` are in texture pixels between neighbouring panels' boxes (negative = overlap).

@export var panel_scale := 0.616:
	set(v): panel_scale = v; _layout()
@export var gaps: PackedFloat32Array:
	set(v): gaps = v; _layout()


func _ready() -> void:
	child_entered_tree.connect(func(_c): _layout.call_deferred())
	_layout()


func _layout() -> void:
	if not is_node_ready():
		return
	var x := 0.0
	var h := 0.0
	var panels := get_children().filter(func(c): return c is InkPanel)
	for i in panels.size():
		var p: InkPanel = panels[i]
		p.panel_scale = panel_scale
		p.position = Vector2(x, 0)
		x += p.size.x + (gaps[i] * panel_scale if i < gaps.size() else 0.0)
		h = maxf(h, p.size.y)
	custom_minimum_size = Vector2(x, h)
