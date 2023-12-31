extends Node

## Emitted when the current fuel value changes.
signal fuel_changed(new_value: float)

## Emitted when the number of extra balls available changes.
signal extra_balls_changed(new_value: int)

## Emitted when an extra ball is earned, immediately after extra_balls_changed for the same event.
signal extra_ball_earned()

## Emitted when the score changes.
signal score_changed(new_value: int)

## The maximum fuel the player can have.
@export
var fuel_maximum := 100.0

## The amount of fuel that regenerates per second.
@export
var fuel_regeneration_rate := 10.0

## The amount of fuel used per bump action.
@export
var bump_usage := 25.0

## The amount of fuel used per second while drag is active.
@export
var drag_usage := 25.0

## The number of balls played per game.
@export_range(1, 100, 1)
var total_balls := 3

## The number of points added for touching a bumper.
@export_range(1, 1000000, 1)
var bumper_score := 1000

## The number of points added for touching a pylon.
@export_range(1, 1000000, 1)
var pylon_score := 500

## The number of points added for being captured by a kick-out hole.
@export_range(1, 1000000, 1)
var kickout_hole_score := 20000

## The number of points added for launching the same ball a second time.
@export_range(1, 1000000000, 1)
var relaunch_score := 50000

## The number of points needed to earn an extra ball.
@export_range(1, 1000000000, 1)
var extra_ball_score := 10000000

## The number of lowest scores to keep.
@export_range(1, 100, 1)
var low_score_count := 3

## The value to report in a lowest score slot that has not been filled.
@export_range(0, 0x7FFFFFFFFFFFFFFF, 1)
var low_score_missing := 999999999999999

## The current score.
var score: int

## Whether the current plunger activation is the first of this ball.
var first_launch: bool

## The current balance of fuel.
var fuel_current: float

## The number of extra balls remaining.
var extra_balls: int

func _physics_process(delta: float) -> void:
	var old := fuel_current
	fuel_current = min(fuel_current + fuel_regeneration_rate * delta, fuel_maximum)
	if fuel_current != old:
		fuel_changed.emit(fuel_current)

## Tries to use fuel for a bump, returning true on success or false if not enough was available.
func use_bump() -> bool:
	return _use_fuel(bump_usage)

## Tries to use fuel for a drag for a period of time, returning true on success or false if not
## enough was available.
func use_drag(delta: float) -> bool:
	return _use_fuel(drag_usage * delta)

## Consumes an extra ball, returning true if there were any or false if not.
func use_ball() -> bool:
	if extra_balls != 0:
		extra_balls -= 1
		extra_balls_changed.emit(extra_balls)
		if fuel_current !=  fuel_maximum:
			fuel_current = fuel_maximum
			fuel_changed.emit(fuel_current)
		return true
	else:
		return false

## Grants points for touching a bumper.
func score_bumper() -> void:
	_add_points(bumper_score)

## Grants points for touching a pylon.
func score_pylon() -> void:
	_add_points(pylon_score)

## Grants points for being captured by a kick-out hole.
func score_kickout_hole() -> void:
	_add_points(kickout_hole_score)

## Grants points for launching the same ball a second time.
func score_relaunch() -> void:
	_add_points(relaunch_score)

## Reads the lowest scores.
func read_lowest_scores() -> PackedInt64Array:
	var conf := ConfigFile.new()
	conf.load("user://scores.ini")
	var ret := PackedInt64Array()
	for i in range(low_score_count):
		var elt = conf.get_value("player" + str(i), "score")
		if elt is int:
			ret.append(elt)
		else:
			ret.append(low_score_missing)
	ret.sort()
	return ret

## Writes the lowest scores.
func write_lowest_scores(scores: PackedInt64Array) -> void:
	assert(scores.size() == low_score_count)
	var conf := ConfigFile.new()
	for i in range(low_score_count):
		conf.set_value("player" + str(i), "score", scores[i])
	conf.save("user://scores.ini")

## Checks whether a new score should appear in a low scores table and, if so, inserts it.
##
## Returns the position in the table, on success, or -1 if the score doesn’t make the cut.
func insert_lowest_score(scores: PackedInt64Array, new_score: int) -> int:
	for i in range(scores.size()):
		if new_score < scores[i]:
			scores.insert(i, new_score)
			scores.resize(low_score_count)
			return i
	return -1

## Runs the end-of-game score updating.
##
## Returns the lowest scores, plus the position of the current play within them or -1 if the current
## play did not make the cut.
func end_game() -> Array:
	var scores := read_lowest_scores()
	var pos := insert_lowest_score(scores, score)
	write_lowest_scores(scores)
	return [scores, pos]

## Sets up the start-of-game condition.
func start_game() -> void:
	score = 0
	first_launch = true
	fuel_current = fuel_maximum
	extra_balls = total_balls - 1
	fuel_changed.emit(fuel_current)
	extra_balls_changed.emit(extra_balls)
	score_changed.emit(score)

## Tries to consume a quantity of fuel, returning true on success or false if not enough was
## available.
func _use_fuel(amount: float) -> bool:
	if fuel_current >= amount:
		fuel_current -= amount
		fuel_changed.emit(fuel_current)
		return true
	else:
		return false

## Adds some points to the score.
func _add_points(amount: int) -> void:
	var before := score / extra_ball_score
	score += amount
	var after := score / extra_ball_score
	score_changed.emit(score)
	if before != after:
		extra_balls += after - before
		extra_balls_changed.emit(extra_balls)
		extra_ball_earned.emit()
