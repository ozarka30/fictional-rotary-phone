@tool
class_name InfoPopup extends InkPanel
## Comic info card for a Hearthling or an egg: picture, name, colored grades.


func show_hearthling(h: HearthlingData, frames: SpriteFrames) -> void:
	_fill(h.name, frames, describe(h))


## Grades, caps, affinities, traits and toxicity, as BBCode. Also used by the bake preview.
static func describe(h: HearthlingData) -> String:
	var rows := PackedStringArray()
	for s in Types.Stat.values():
		rows.append("%s %s %d [color=#bdbdbd]/ %d[/color]" % [Ink.chip(Types.Stat.keys()[s].capitalize(), Types.STAT_COLORS[s]),
			Ink.grade(h.stat_grade(s), "", 20), h.stat(s), h.stat_caps.get(s, 0.0)])
	var affs := PackedStringArray()
	for a in h.affinity_caps:
		if h.affinity_caps[a] > 0.0:
			affs.append("%s %s %d[color=#bdbdbd]/%d[/color]" % [Ink.chip(Types.Affinity.keys()[a].capitalize(), Types.AFFINITY_COLORS[a]),
				Ink.grade(h.affinity_grade(a), "", 20), h.affinity(a), h.affinity_caps[a]])
	var extra := PackedStringArray()
	if h.traits():
		extra.append(", ".join(h.traits().map(func(t): return String(t).capitalize())))
	extra.append("Toxicity %d / %d" % [h.toxicity, Training.TOXICITY_MAX])
	return "\n".join(rows) + ("\n" + "  ".join(affs) if affs else "") + "\n[color=#dee2e6]%s[/color]" % "  -  ".join(extra)


func _fill(title: String, frames: SpriteFrames, body: String) -> void:
	%Name.text = title
	%Body.text = body
	%Sprite.sprite_frames = frames
	%Sprite.play(&"breathing" if frames.has_animation(&"breathing") else &"idle")
	show()


func _laid_out() -> void:
	if not %Picture.resized.is_connected(_center_sprite):
		%Picture.resized.connect(_center_sprite)


func _center_sprite() -> void:
	%Sprite.position = %Picture.size / 2
