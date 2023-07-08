class_name FuelManager
extends Node

## Emitted when the current fuel value changes.
signal changed(new_value: float)

## Emitted when the number of extra balls available changes.
signal extra_balls_changed(new_value: int)

## Emitted when the score changes.
signal score_changed(new_value: int)

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

## The number of balls played per game.
@export_range(1, 100, 1)
var total_balls := 3

## The number of points added for touching a pylon or bumper.
@export_range(1, 1000000, 1)
var pylon_score := 1000

## The current score.
var score := 0

## The current balance of fuel.
@onready
var current := maximum

## The number of extra balls remaining.
@onready
var extra_balls := total_balls - 1

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

## Consumes an extra ball, returning true if there were any or false if not.
func use_ball() -> bool:
	if extra_balls != 0:
		extra_balls -= 1
		extra_balls_changed.emit(extra_balls)
		if current !=  maximum:
			current = maximum
			changed.emit(current)
		return true
	else:
		return false

## Grants points for touching a pylon or bumper.
func score_pylon() -> void:
	score += pylon_score
	score_changed.emit(score)
