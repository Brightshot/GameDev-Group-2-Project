# This script is an autoload, that can be accessed from any other script!

extends Node

@onready var jump_sfx = $JumpSfx
@onready var coin_pickup_sfx = $CoinPickup
@onready var death_sfx = $DeathSfx
@onready var respawn_sfx = $RespawnSfx
@onready var level_complete_sfx = $LevelCompleteSfx
@onready var music_player = $MusicPlayer  # Reference to the AudioStreamPlayer node

func _ready():
	# Set the music stream if it's not already set
	if music_player.stream == null:
		music_player.stream = load("res://music/background_theme.ogg")  # Path to your music file
	
	# Play the background music
	music_player.play()

	# Optionally, adjust volume
	music_player.volume_db = -5.0  # Adjust volume level if needed
