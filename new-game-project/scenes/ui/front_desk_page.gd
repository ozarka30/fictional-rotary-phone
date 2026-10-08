extends Control
## Front Desk: whoever is waiting talks to you. Returning customers come first.


func _ready() -> void:
	%Customer.finished.connect(Nav.home)
	var back := GameState.active_requests.filter(func(a): return not a.fulfilled and GameState.day >= a.due_day)
	if back:
		%Customer.open_request(back[0].def, back[0])
	elif GameState.waiting:
		%Customer.open_request(GameState.waiting[0])
	else:
		%Customer.hide()
		%Empty.show()
