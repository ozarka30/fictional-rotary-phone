@tool
class_name InfoPopup extends InkPanel
## Comic info card for a Hearthling or an egg: picture, name, colored grades.


func show_hearthling(h: HearthlingData, frames: SpriteFrames) -> void:
	var family: FamilyDef = Database.get_def(&"families", h.family_id)
	var rows := PackedStringArray()
	for s in Types.Stat.values():
		rows.append("%s %s %d [color=#bdbdbd]/ %d[/color]" % [Ink.chip(Types.Stat.keys()[s].capitalize(), Types.STAT_COLORS[s]),
			Ink.grade(h.stat_grade(s), "", 20), h.stats[s], h.potentials[s]])
	var affs := PackedStringArray()
	for a in h.affinities:
		if h.affinities[a] > 0.0:
			affs.append("%s %s %d" % [Ink.chip(Types.Affinity.keys()[a].capitalize(), Types.AFFINITY_COLORS[a]), Ink.grade(h.affinity_grade(a), "", 20), h.affinities[a]])
	var status := "Settled" if h.stabilized else "%d shaping day(s) left" % h.malleable_days_left
	_fill("%s #%d" % [family.name, h.uid], frames, "\n".join(rows) + ("\n" + "  ".join(affs) if affs else "") + "\n[color=#dee2e6]%s[/color]" % status)


func show_egg(egg: EggDef, frames: SpriteFrames) -> void:
	var family: FamilyDef = Database.get_def(&"families", egg.family_id)
	_fill(egg.name, frames, "Grade %s\nHatches into a %s\n%s" % [Ink.grade(egg.grade), family.name,
		Ink.chip("%d shaping days" % egg.malleable_days, Types.DAYS_COLOR)])


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
