@tool
class_name MenuCard extends InkPanel
## One home-menu button: an InkPanel with a title that opens a page when clicked.

signal pressed(page: StringName)

@export var page: StringName
@export var title := "Page":
	set(v): title = v; _layout()
@export_multiline var blurb := ""  ## shown in a callout on hover


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_STOP
	mouse_entered.connect(_hover.bind(true))
	mouse_exited.connect(_hover.bind(false))
	super()


func _gui_input(event: InputEvent) -> void:
	var mb := event as InputEventMouseButton
	if mb and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
		pressed.emit(page)


func _hover(on: bool) -> void:
	if Engine.is_editor_hint():
		return
	pivot_offset = size / 2
	create_tween().tween_property(self, "scale", Vector2.ONE * (1.06 if on else 1.0), 0.12)


func _laid_out() -> void:
	$Title.text = title
