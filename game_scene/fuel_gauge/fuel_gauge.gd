extends ProgressBar

## The fuel manager.
@export
var fuel_manager: FuelManager

func _ready() -> void:
	fuel_manager.changed.connect(_on_fuel_changed)
	max_value = fuel_manager.maximum
	value = fuel_manager.maximum

func _on_fuel_changed(new_value: float) -> void:
	value = new_value
