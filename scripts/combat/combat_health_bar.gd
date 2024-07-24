extends Control

@onready var health_bar = $HealthBar

@onready var timer_on_screen_duration = $OnScreenDuration

func _ready():
	health_bar.hide()
	timer_on_screen_duration.timeout.connect(health_bar.hide)

func update_health_value(newValue):
	health_bar.value = newValue
	health_bar.show()
	timer_on_screen_duration.start()
