class_name ActiveRequest extends Resource

@export var def: RequestDef
@export var received_day: int
@export var due_day: int
@export var fulfilled := false
@export var grade := Types.Grade.E


static func start(request: RequestDef, today: int) -> ActiveRequest:
	var r := ActiveRequest.new()
	r.def = request
	r.received_day = today
	r.due_day = today + request.return_after_days
	return r
