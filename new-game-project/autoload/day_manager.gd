extends Node
## Ending the day: every Hearthling in a Training Yard slot trains, then the next morning.


func _ready() -> void:
	EventBus.sleep_requested.connect(sleep)


func sleep() -> void:
	EventBus.day_ending.emit(GameState.day)
	var notes := PackedStringArray()
	var trained := 0
	for env_id in GameState.yard:
		for s in GameState.yard[env_id]:
			if GameState.hearthlings.has(s.uid):
				Training.night(GameState.hearthlings[s.uid], Database.get_def(&"envs", env_id), Database.get_def(&"activities", s.activity) if s.activity else null)
				trained += 1
	if trained:
		notes.append("%d Hearthling(s) trained overnight" % trained)
	GameState.day += 1
	for a in GameState.active_requests:
		if not a.fulfilled and a.due_day == GameState.day:
			notes.append("%s is back today" % a.def.customer_name)
	Nav.note = "Day %d: %s" % [GameState.day, ", ".join(notes) if notes else "a quiet morning."]
	EventBus.day_started.emit(GameState.day)
