extends CharacterBody2D
## Forager ant. v0.1: player-controlled.
## Detects food nodes (pick up) and the colony (deliver) via DetectionArea.
## In v0.2, multiple foragers may exist at once and may be autonomous instead
## of player-controlled — keep movement and detection logic self-contained here
## so swapping the movement source later doesn't touch other scripts.

signal food_delivered

const SPEED := 220.0

# Half the ant's visual/collision size. Used to keep the whole sprite (not
# just its center) inside the map bounds. This is a fixed-map stopgap for
# v0.1 — a real solution for scrolling/larger terrain is a separate task.
const HALF_SIZE := 16.0

var has_food: bool = false

@onready var visual: ColorRect = $Visual


func _ready() -> void:
	# Membership in this group lets GameManager find and register every
	# forager currently in the scene, including ones spawned later (v0.2 Queen).
	add_to_group("foragers")
	_update_visual()


func _physics_process(_delta: float) -> void:
	velocity = _get_input_direction() * SPEED
	move_and_slide()
	_clamp_to_map_bounds()


func _get_input_direction() -> Vector2:
	var input_dir := Vector2.ZERO

	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		input_dir.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		input_dir.x += 1.0
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
		input_dir.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
		input_dir.y += 1.0

	if input_dir.length() > 0.0:
		input_dir = input_dir.normalized()

	return input_dir


func _clamp_to_map_bounds() -> void:
	var map_size := get_viewport_rect().size
	position.x = clamp(position.x, HALF_SIZE, map_size.x - HALF_SIZE)
	position.y = clamp(position.y, HALF_SIZE, map_size.y - HALF_SIZE)


func _on_detection_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("food") and not has_food:
		if area.has_method("collect"):
			area.collect()
		has_food = true
		_update_visual()
	elif area.is_in_group("colony") and has_food:
		has_food = false
		_update_visual()
		food_delivered.emit()


func _update_visual() -> void:
	if visual == null:
		return
	# Green while carrying food, orange while empty-handed.
	visual.color = Color(0.2, 0.8, 0.2, 1.0) if has_food else Color(0.9, 0.5, 0.1, 1.0)
