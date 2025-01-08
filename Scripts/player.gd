extends CharacterBody2D

# --------- VARIABLES ---------- #

@export_category("Player Properties")
@export var move_speed : float = 400
@export var jump_force : float = 600
@export var gravity : float = 30
@export var max_jump_count : int = 2
var jump_count : int = 2

@export_category("Toggle Functions")
@export var double_jump : bool = false

var is_grounded : bool = false

@onready var player_sprite = $AnimatedSprite2D
@onready var spawn_point = %SpawnPoint
@onready var particle_trails = $ParticleTrails
@onready var death_particles = $DeathParticles

# --------- BUILT-IN FUNCTIONS ---------- #

func _process(_delta):
	# Calling functions
	movement()
	player_animations()
	flip_player()
	
# --------- CUSTOM FUNCTIONS ---------- #

# <-- Player Movement Code -->
func movement():
	# Gravity
	if !is_on_floor():
		velocity.y += gravity
	elif is_on_floor():
		jump_count = max_jump_count
	
	handle_jumping()
	
	# Move Player
	var inputAxis = Input.get_axis("Left", "Right")
	velocity = Vector2(inputAxis * move_speed, velocity.y)
	move_and_slide()

# Handles jumping functionality (double jump or single jump, can be toggled from inspector)
func handle_jumping():
	if Input.is_action_just_pressed("Jump"):
		if is_on_floor() and !double_jump:
			jump()
		elif double_jump and jump_count > 0:
			jump()
			jump_count -= 1

# Player jump
func jump():
	jump_tween()  # Call jump_tween when the player jumps
	AudioManager.jump_sfx.play()
	velocity.y = -jump_force

# Jump tween animation (function that was missing)
func jump_tween():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.7, 1.4), 0.1)  # Apply a small squash/stretch effect during jump
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)  # Return to normal size

# Handle Player Animations
func player_animations():
	particle_trails.emitting = false
	
	if is_on_floor():
		if abs(velocity.x) > 0:
			particle_trails.emitting = true
			player_sprite.play("Walk", 1.5)
		else:
			player_sprite.play("Idle")
	else:
		player_sprite.play("Jump")

# Flip player sprite based on X velocity
func flip_player():
	if velocity.x < 0: 
		player_sprite.flip_h = true
	elif velocity.x > 0:
		player_sprite.flip_h = false

# --------- SIGNALS ---------- #

# Reset the player's position to the current level spawn point if collided with any trap
func _on_collision_body_entered(_body):
	if _body.is_in_group("Traps"):
		AudioManager.death_sfx.play()  # Play death sound
		death_particles.emitting = true  # Start death particles
		death_tween()  # Play death animation/tween
		
		# Wait until the death tween is finished, then respawn the player
		await death_tween()  # Wait for the death tween to finish

		_respawn()  # Handle respawn

# Death tween animation that scales down the player and waits for completion
func death_tween():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.15)  # Scale down the player
	await tween.finished  # Wait until the tween finishes
	global_position = spawn_point.global_position  # Set position to spawn point
	await get_tree().create_timer(0.3).timeout  # Optional delay before respawn
	AudioManager.respawn_sfx.play()  # Play respawn sound
	respawn_tween()  # Play respawn tween

# Respawn tween to bring the player back to normal size
func respawn_tween():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.15)  # Scale back up
	velocity.y = 0  # Reset vertical velocity to stop falling into the ground
	jump_count = max_jump_count  # Reset jump count after respawn
	death_particles.emitting = false  # Stop emitting death particles

# Function to handle respawn logic after the player dies
func _respawn():
	# Reset the player's position to the spawn point
	position = spawn_point.global_position
	velocity.y = 0  # Reset vertical velocity to avoid falling immediately
	jump_count = max_jump_count  # Reset jump count after respawn
	particle_trails.emitting = false  # Stop emitting trail particles
