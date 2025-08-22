extends Control

@onready var debug_label: Label = $DebugLabel
@onready var player: CharacterBody2D = $"../Player"

func _process(delta: float) -> void:
	debug_label.text = "Estado: " + str(player.estado_actual)
