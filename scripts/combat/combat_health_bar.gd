extends Control

@onready var health_bar = $HealthBar

func update_health_value(newValue):
	health_bar.value = newValue
