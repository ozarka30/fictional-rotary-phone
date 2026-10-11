extends Node
## Ending the day: every Hearthling in a Training Yard environment trains, then the next morning.


func _ready() -> void:
	EventBus.sleep_requested.connect(sleep)


func sleep() -> void:
	EventBus.day_ending.emit(GameState.day)
	var notes := PackedStringArray()
	var trained := 0
	for h: HearthlingData in GameState.hearthlings.values():
		if h.env_id:
			Training.night(h, Database.get_def(&"envs", h.env_id), Database.get_def(&"activities", h.activity_id) if h.activity_id else null)
			trained += 1
	if trained:
		notes.append("%d Hearthling(s) trained overnight" % trained)
	GameState.day += 1
	for a in GameState.active_requests:
		if not a.fulfilled and a.due_day == GameState.day:
			notes.append("%s is back today" % a.def.customer_name)
	Nav.note = "Day %d: %s" % [GameState.day, ", ".join(notes) if notes else "a quiet morning."]
	EventBus.day_started.emit(GameState.day)
