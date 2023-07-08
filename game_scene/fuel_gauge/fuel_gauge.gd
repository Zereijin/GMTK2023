extends ProgressBar

func _ready() -> void:
	PlayerData.fuel_changed.connect(_on_fuel_changed)
	max_value = PlayerData.fuel_maximum
	value = PlayerData.fuel_maximum

func _on_fuel_changed(new_value: float) -> void:
	value = new_value
