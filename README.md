# Colony — v0.1 (Forager Loop)

## How to run
1. Open Godot 4.6 or 4.7.
2. "Import" this folder (select `project.godot`).
3. Press F5 (or click the Play button). It will run `scenes/main.tscn`.

## Controls
- WASD or Arrow Keys to move the ant.

## Loop
- Walk the ant (orange square) into a food node (green square) to pick it up.
  The ant turns green while carrying food.
- Walk it into the colony (brown square, center) to deliver. The counter in
  the top-left increases by 1 and the ant turns orange again, ready to
  collect the next food node.

## Folder structure
```
scenes/       main.tscn, ant.tscn, food_node.tscn, colony.tscn
scripts/      ant.gd, food_node.gd, colony.gd, game_manager.gd
assets/       empty placeholder — all visuals are ColorRects for now
```

## Architecture notes for v0.2
The brief asked me to flag anything that would make v0.2 (Queen spawning
new Foragers over time, multiple ants active at once) significantly
harder. Two small choices were made now specifically to keep that easy:

- **Ant scene is self-contained and reusable.** `ant.tscn` doesn't assume
  it's the only ant — it has no references to Main or to other ants.
  Spawning more copies at runtime (`load("res://scenes/ant.tscn").instantiate()`)
  will just work.
- **GameManager doesn't hardcode a single ant.** Instead of `@onready var
  ant = $Ant`, it looks up every node in the `"foragers"` group and
  connects to each one's `food_delivered` signal via a public
  `register_forager()` method. When the Queen spawns a new Forager in
  v0.2, its spawn code just needs to call
  `game_manager.register_forager(new_ant)` right after instancing —
  no changes needed elsewhere.

One thing *not* addressed yet, intentionally, since it's out of scope for
this brief: the ant's movement is currently always player input-driven.
When autonomous pathing arrives, `_get_input_direction()` in `ant.gd` is
the one function to replace or branch on (e.g. a `is_player_controlled`
flag) — everything else (pickup/delivery detection, signals, visuals) is
already movement-source-agnostic.
