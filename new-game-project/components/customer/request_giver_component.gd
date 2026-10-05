class_name RequestGiverComponent extends Node
## What this customer wants. `active` is set once the shop has taken the request.

var request: RequestDef
var active: ActiveRequest


func set_request(r: RequestDef) -> void:
	request = r
	for a in GameState.active_requests:
		if a.def == r and not a.fulfilled:
			active = a  # a returning customer
