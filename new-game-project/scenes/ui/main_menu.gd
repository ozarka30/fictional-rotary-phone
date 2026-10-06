extends Control
## The home page: a row of cards, each opening one area of the shop.

signal page_selected(page: StringName)


func _ready() -> void:
	for card in %Row.get_children():
		card.pressed.connect(func(p): page_selected.emit(p); print("open page: ", p))  # ponytail: pages hook in here
