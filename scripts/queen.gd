extends Node2D
## Queen: sits at the nest and spawns new Foragers as food is delivered.
## Spawn rule (v0.2, tunable): every FOOD_PER_SPAWN deliveries — by any
## ant, autonomous or player-controlled — spawn one new Forager at the
## Queen's position. GameManager calls on_food_delivered() once per
## delivery; nothing else needs to change if that rule is retuned.

const FORAGER_SCENE := preload("res://scenes/ant.tscn")
const FOOD_PER_SPAWN := 5
const SPAWN_SCATTER := 10.0

var food_since_last_spawn: int = 0


func on_food_delivered() -> void:
	food_since_last_spawn += 1
	if food_since_last_spawn >= FOOD_PER_SPAWN:
		food_since_last_spawn = 0
		_spawn_forager()


func _spawn_forager() -> void:
	var forager := FORAGER_SCENE.instantiate() as Node2D
	var scatter := Vector2(randf_range(-SPAWN_SCATTER, SPAWN_SCATTER), randf_range(-SPAWN_SCATTER, SPAWN_SCATTER))

	var game_manager := get_parent()
	game_manager.add_child(forager)
	forager.global_position = global_position + scatter
	if game_manager.has_method("register_forager"):
		game_manager.register_forager(forager)
