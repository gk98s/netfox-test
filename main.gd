extends Node2D

const PLAYER_SCENE = preload("res://player.tscn")
const PORT = 9999

@onready var host_button: Button = $HostButton
@onready var join_button: Button = $JoinButton
@onready var spawn_button: Button = $SpawnButton
@onready var crash_button: Button = $CrashButton

var peer: ENetMultiplayerPeer
var active_player: Player

func _ready() -> void:
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)
	spawn_button.pressed.connect(_on_spawn_pressed)
	crash_button.pressed.connect(_on_crash_pressed)

func _on_host_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(PORT)
	if err == OK:
		multiplayer.multiplayer_peer = peer
		print("Server hosting on port ", PORT)

func _on_join_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_client("127.0.0.1", PORT)
	if err == OK:
		multiplayer.multiplayer_peer = peer
		print("Client connecting...")

func _on_spawn_pressed() -> void:
	if not multiplayer.has_multiplayer_peer():
		print("Start host or client first!")
		return
		
	active_player = PLAYER_SCENE.instantiate()
	active_player.name = "TestPlayer"
	add_child(active_player)
	print("Player spawned and registered!")

func _on_crash_pressed() -> void:
	if not is_instance_valid(active_player):
		print("No active player to delete!")
		return
		
	# --- THE REPRODUCTION TRIGGER ---
	print("Triggering unparent-then-delete sequence...")
	
	# 1. Unparent the node. This triggers _exit_tree(), 
	# but is_queued_for_deletion() is FALSE, bypassing Netfox's cleanup.
	remove_child(active_player) 
	
	# 2. Free the unparented node.
	active_player.queue_free()
	
	print("Player unparented and freed. Watch the console on the next network tick.")
