@tool
class_name MenuCard extends Control
## One home-menu button: a fill shape that masks an art image, with the inked border on top.
## Sizes come from the border texture, so swapping art never needs layout work.

signal pressed(page: StringName)

@export var page: StringName
@export var title := "Page":
	set(v): title = v; _layout()
@export var border: Texture2D:
	set(v): border = v; _layout()
@export var fill: Texture2D:  ## the mask shape; its own color shows where the art is transparent
	set(v): fill = v; _layout()
@export var art: Texture2D:  ## any image, clipped to the fill shape
	set(v): art = v; _layout()
@export var card_scale := 0.5:
	set(v): card_scale = v; _layout()
@export var fill_offset := Vector2.ZERO:  ## nudge the fill if it peeks past the border
	set(v): fill_offset = v; _layout()


func _ready() -> void:
	pivot_offset = size / 2
	mouse_entered.connect(_hover.bind(true))
	mouse_exited.connect(_hover.bind(false))
	_layout()


func _gui_input(event: InputEvent) -> void:
	var mb := event as InputEventMouseButton
	if mb and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
		pressed.emit(page)


func _hover(on: bool) -> void:
	if Engine.is_editor_hint():
		return
	pivot_offset = size / 2
	create_tween().tween_property(self, "scale", Vector2.ONE * (1.06 if on else 1.0), 0.12)


func _layout() -> void:
	if not is_node_ready() or border == null:
		return
	var s := border.get_size() * card_scale
	custom_minimum_size = s
	size = s
	$Border.texture = border
	$Fill.texture = fill
	$Fill/Art.texture = art
	if fill:
		$Fill.size = fill.get_size() * card_scale
		$Fill.position = (s - $Fill.size) / 2 + fill_offset
	$Title.text = title
