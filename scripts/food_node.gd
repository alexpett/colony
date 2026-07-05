extends Area2D
## A single static food source. v0.1: disappears entirely on collection.
## (A future phase could turn this into a depleting stack instead of a
## one-shot pickup — collect() is the seam to change for that.)

# v0.2: multiple autonomous ants can overlap this node's detection area in
# the same physics frame, before queue_free() actually removes it — this
# guard stops two ants from both registering a pickup off one food node.
var _collected: bool = false


func _ready() -> void:
	add_to_group("food")


func collect() -> void:
	if _collected:
		return
	_collected = true
	queue_free()
