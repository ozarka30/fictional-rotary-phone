extends PanelContainer
## A small comic pop-up list. `var i := await chooser.ask("Title", ["a", "b"])` -> index, or -1 for cancel.

signal picked(index: int)


func _ready() -> void:
	hide()


func ask(title: String, options: PackedStringArray) -> int:
	for c in %List.get_children():
		c.queue_free()
	%Title.text = title
	for i in options.size():
		_add(options[i], i)
	_add("Cancel", -1)
	show()
	var i: int = await picked
	hide()
	return i


func _add(text: String, i: int) -> void:
	var b := Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(picked.emit.bind(i))
	%List.add_child(b)
