class_name FuelManager
extends Node

## Emitted when the current fuel value changes.
signal changed(new_value: float)

## The maximum fuel the player can have.
@export
var maximum := 100.0

## The amount of fuel that regenerates per second.
@export
var regeneration_rate := 10.0

## The amount of fuel used per bump action.
@export
var bump_usage := 25.0

## The amount of fuel used per second while drag is active.
@export
var drag_usage := 25.0

## The current balance of fuel.
@onready
var current := maximum

func _physics_process(delta: float) -> void:
	var old := current
	current = min(current + regeneration_rate * delta, maximum)
	if current != old:
		changed.emit(current)

## Tries to consume a quantity of fuel, returning true on success or false if not enough was
## available.
func _use(amount: float) -> bool:
	if current >= amount:
		current -= amount
		changed.emit(current)
		return true
	else:
		return false

## Tries to use fuel for a bump, returning true on success or false if not enough was available.
func use_bump() -> bool:
	return _use(bump_usage)

## Tries to use fuel for a drag for a period of time, returning true on success or false if not
## enough was available.
func use_drag(delta: float) -> bool:
	return _use(drag_usage * delta)
