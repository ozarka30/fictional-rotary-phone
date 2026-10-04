class_name HearthlingStateComponent extends Node
## The entity's link to its HearthlingData. Other components read `data`.

var data: HearthlingData


func set_data(d: HearthlingData) -> void:
	data = d
