extends Area2D
## A single static food source. v0.1: disappears entirely on collection.
## (A future phase could turn this into a depleting stack instead of a
## one-shot pickup — collect() is the seam to change for that.)


func _ready() -> void:
	add_to_group("food")


func collect() -> void:
	queue_free()
