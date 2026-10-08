extends Control
## On every page: Back (except home), day and coin, Sleep, and the morning note.

@export var show_back := true


func _ready() -> void:
	%Back.visible = show_back
	%Back.pressed.connect(Nav.home)
	%Sleep.pressed.connect(func():
		EventBus.sleep_requested.emit()
		Nav.reload())
	EventBus.coin_changed.connect(func(_c): _refresh())
	_refresh()


func _refresh() -> void:
	%Status.text = "Day %d   %d coin" % [GameState.day, GameState.coin]
	%Note.text = Nav.note
	%Note.visible = not Nav.note.is_empty()
