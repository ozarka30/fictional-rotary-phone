extends Node
## Loads every definition under res://data/<category>/ at startup.
## Look up with Database.get_def(&"foods", &"brine_fish").
## Each def needs an `id` property; files without one fall back to the file name.

const DATA_ROOT := "res://data"

var _defs := {}  # category -> {id -> Resource}


func _ready() -> void:
	for category in DirAccess.get_directories_at(DATA_ROOT):
		_defs[StringName(category)] = _load_folder(DATA_ROOT.path_join(category))


func get_def(category: StringName, id: StringName) -> Resource:
	var def: Resource = _defs.get(category, {}).get(id)
	if def == null:
		push_error("Database: no %s with id '%s'" % [category, id])
	return def


func get_all(category: StringName) -> Array:
	return _defs.get(category, {}).values()


func _load_folder(path: String) -> Dictionary:
	var out := {}
	for file in DirAccess.get_files_at(path):
		# Exported builds rename .tres to .tres.remap; load() wants the original name.
		file = file.trim_suffix(".remap")
		if not (file.ends_with(".tres") or file.ends_with(".res")):
			continue
		var res := load(path.path_join(file))
		var id = res.get("id")
		if id == null or String(id).is_empty():
			id = file.get_basename()
		out[StringName(id)] = res
	return out
