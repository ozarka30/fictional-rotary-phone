extends Control
## The home page: a row of cards, each opening one area of the shop.

signal page_selected(page: StringName)


func _ready() -> void:
	for card in %Row.get_children():
		card.pressed.connect(func(p): page_selected.emit(p); print("open page: ", p))  # ponytail: pages hook in here
		card.mouse_entered.connect(func(): %Callout.say(card.blurb, card.global_position + Vector2(card.size.x * 0.5, 8)))
		card.mouse_exited.connect(%Callout.hide)
