class_name Hatching
## Egg -> fresh HearthlingData. Pure, so tests can call it without autoloads.


static func hatch(egg: EggDef, family: FamilyDef, uid: int) -> HearthlingData:
	var h := HearthlingData.new()
	h.uid = uid
	h.egg = egg
	h.family_id = family.id
	h.quality = egg.grade
	h.malleable_days_left = egg.malleable_days
	for s in Types.Stat.values():
		h.stats[s] = family.base_stat
		h.potentials[s] = family.base_potential
	return h
