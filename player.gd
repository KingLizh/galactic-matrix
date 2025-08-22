extends CharacterBody2D

#region Declaración de Variables
# Variables de movimiento --------------------------------------------------------------------------
const speed = 200
var direction : Vector2 # Vector 2 significa 2D, conjunto de coordenadas "(x,y)"

# Maquina de Estados -------------------------------------------------------------------------------
enum Estados {IDLE, WALK, RUN}
var estado_actual: Estados

# Variables de animación ---------------------------------------------------------------------------
@onready var player_animation: AnimatedSprite2D = $AnimatedSprite2D
var direccion_horizontal: Vector2

# Variable para poder tomar items ------------------------------------------------------------------
@onready var item: Node2D = $"../Item"
@onready var test_level: Node = $".."
var item_en_mano : Node = null # Null significa que no se tiene nada en la mano 
var distancia_umbral = 25.0

# Variables para la dirección a la que mira el jugador ---------------------------------------------
var direccion_mira: Vector2 = Vector2.RIGHT
#endregion 

func _process(delta: float) -> void:
	var input_dir = Vector2.ZERO
	
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if input_dir != Vector2.ZERO:
		direccion_mira = input_dir.normalized()
	
	var distancia = global_position.distance_to(item.global_position)
	if distancia < distancia_umbral and Input.is_action_just_pressed("take_item") and item_en_mano == null:
		tomar_item(item)
	elif distancia < distancia_umbral and Input.is_action_just_pressed("take_item") and item_en_mano == item:
		soltar_item(item)
		
func _physics_process(delta: float) -> void:
	
	## Movimientos del Jugador en 4 Direcciones ----------------------------------------------------
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	actualizar_estado()
	move_and_slide()

#---------------------------------------------------------------------------------------------------
# La función actualizar_estado permite crear las conexiones entre los estados, por ejemplo pasar
# del estado IDLE a WALK o a RUN, es cómo el sistema de redes de la maquina de estados.
#---------------------------------------------------------------------------------------------------

func actualizar_estado():
	if estado_actual == Estados.IDLE: ## Estado Actual IDLE ----------------------------------------
		if direction:
			if Input.is_action_pressed("RUN"):
				cambiar_estado(Estados.RUN) # Cambio a estado IDLE-RUN
			cambiar_estado(Estados.WALK) # Cambio a estado IDLE-WALK
	
	if estado_actual == Estados.WALK: ## Estado Actual WALK ----------------------------------------
		if !direction:
			cambiar_estado(Estados.IDLE) # Cambio a estado WALK-IDLE
		if Input.is_action_pressed("RUN"):
			cambiar_estado(Estados.RUN) # Cambio a estado WALK-RUN
			
	if estado_actual == Estados.RUN: ## Estado Actual RUN ------------------------------------------
		if !direction:
			cambiar_estado(Estados.IDLE) # Cambio a estado RUN-IDLE
		if !Input.is_action_pressed("RUN"):
			cambiar_estado(Estados.WALK) # Cambio a estado RUN-WALK
			
	#region Match para poder asignar características especiales a los estados ======================
	match estado_actual: 
	
		Estados.IDLE:
			velocity = Vector2.ZERO
			
		Estados.WALK: 
			velocity = direction * speed
			if direction.x:
				player_animation.play("walk_L_R")
				player_animation.flip_h = direction.x < 0
				
		Estados.RUN:
			velocity = direction * speed * 1.5
			if direction.x:
				player_animation.play("run_L_R")
				player_animation.flip_h = direction.x < 0
			
	#endregion
	
func cambiar_estado(nuevo_estado : Estados):
	estado_actual = nuevo_estado
	
func tomar_item(item: Node2D):
	item_en_mano = item
	item.get_parent().remove_child(item) # Hace que el item deje de estar en el "suelo" y se una a ti
	$HandPosition.add_child(item)
	item.position = Vector2.ZERO
	
func soltar_item(item: Node2D):
	if item_en_mano:
		var distancia_objeto = direccion_mira * 16 # Distancia de objeto delante del jugador
		item.get_parent().remove_child(item)
		test_level.add_child(item)
		item_en_mano.global_position = global_position + distancia_objeto
		# Aquí el item vuelve a estar tirado
		item_en_mano = null
