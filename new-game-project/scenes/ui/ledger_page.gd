extends Control
## Ledger: one line per open request, with who asked, what they need and when they're back.

const ENTRY := preload("res://scenes/ui/ledger_entry.tscn")

@export var demo_request: RequestDef  ## ponytail: shown while there are no real requests, so the page can be checked on its own


func _ready() -> void:
	var open := GameState.active_requests.filter(func(a): return not a.fulfilled)
	%Subtitle.text = "%d open request(s)" % open.size()
	for a in open:
		_add().show_request(a.def, a)
	if open.is_empty():
		if demo_request:
			_add().show_request(demo_request)
		else:
			_add().show_message("No open requests. Customers wait at the front desk.")


func _add() -> LedgerEntry:
	var e: LedgerEntry = ENTRY.instantiate()
	%List.add_child(e)
	return e
