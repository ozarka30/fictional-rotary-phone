# Placeholder art

Duelyst sprites (CC0), in `res://addons/duelyst_animated_sprites/`.
Units: `spriteframes/units/<name>.tres`, FX: `spriteframes/fx/<name>.tres`, icons: `spriteframes/icons/<name>.tres`.

Display settings for any Duelyst sprite: AnimatedSprite3D, `billboard = 1`, `shaded = false`,
`texture_filter = 0` (nearest), `pixel_size = 0.03` (3x), `offset.y` = half the frame height.

| Role | Placeholder | Status |
| --- | --- | --- |
| Gem (shop core) | `units/neutral_monstercrystalwisp` | in shop_room |
| Avatar | `units/neutral_prismaticillusionistminion` | use when avatar entity exists |
| Hunter (first customer) | `units/f6_ynuyttracker` | use when customer entity exists |
| Egg + hatch | `units/f5_egg` (`open` anim), fx `fx_f5_bbs_egg` | use when incubator exists |
| Pup base form | `units/neutral_xho` | |
| Pup forms per affinity | `units/neutral_pandoraminionrush` (Ember), `...celerity` (Bloom), `...fly` (Tide), `...provoke` (Frost), `neutral_rok` (Clay) | |
| Feed puff | fx `fx_fairiefire` (pick the color anim per affinity) | |
| Form locks in | fx `fx_f6_mesmerize` | |
| Avatar forming | fx `fx_teleportrecall2` | |
| Gem waking | fx `fx_f5_earthsphere` | |

Front desk, incubator, pen and training gadget have no fitting Duelyst art: they keep the Godot-icon placeholders in `art/placeholders/`.
Duelyst animations are all set to loop at 9 fps; turn loop off for one-shot FX and hit/death.
