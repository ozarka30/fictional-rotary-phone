@tool
class_name InkPanel extends Control
## Comic panel: a fill shape that masks optional art, with the inked border on top.
## Size comes from the border texture. Put content under the Content node.

@export var border: Texture2D:
	set(v): border = v; _layout()
@export var fill: Texture2D:  ## the mask shape; its color shows where the art is transparent
	set(v): fill = v; _layout()
@export var art: Texture2D:  ## optional image clipped to the fill shape
	set(v): art = v; _layout()
@export var panel_scale := 1.0:
	set(v): panel_scale = v; _layout()
@export var fill_offset := Vector2.ZERO:  ## nudge the fill if it peeks past the border
	set(v): fill_offset = v; _layout()
@export var flip := false:  ## mirror the shape (callouts pointing the other way)
	set(v): flip = v; _layout()


func _ready() -> void:
	_layout()


func _layout() -> void:
	if not is_node_ready() or border == null:
		return
	var s := border.get_size() * panel_scale
	custom_minimum_size = s
	size = s
	$Border.texture = border
	$Border.flip_h = flip
	$Fill.texture = fill
	$Fill.flip_h = flip
	$Fill/Art.texture = art
	if fill:
		var off := Vector2(-fill_offset.x if flip else fill_offset.x, fill_offset.y)
		$Fill.size = fill.get_size() * panel_scale
		$Fill.position = (s - $Fill.size) / 2 + off
	_laid_out()


## Subclasses hook in here.
func _laid_out() -> void:
	pass
