extends Node

@export var coin_scene:PackedScene
@export var catus_scene:PackedScene
@export var powerup_scene:PackedScene
@export var playtime = 30

@onready var coin_sound = $CoinSound
@onready var powerup_sound = $PowerupSound
@onready var game_ends_sound = $GameEndSound

var level:int
var score:int
var time_left:int
var screensize = Vector2.ZERO
var playing:bool


# Called when the node enters the scene tree for the first time.
func _ready():
	screensize = get_viewport().get_visible_rect().size
	playing = false
	$Player.screensize = screensize
	$Player.hide()
	coin_sound.volume_db -= 5
	powerup_sound.volume_db += 8
	game_ends_sound.volume_db += 20


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if playing and get_tree().get_nodes_in_group("coins").size() == 0:
		$PowerupTimer.stop()
		level += 1
		time_left += 5
		spawn_coins()
		var powerup_spawn_time = randi_range(1,10)
		$PowerupTimer.wait_time = powerup_spawn_time
		$PowerupTimer.start()

func new_game():
	playing = true
	level = 1
	score = 0
	time_left = playtime
	$Player.start()
	$Player.show()
	$GameTimer.start()
	$HUD.update_score(score)
	$HUD.update_timer(time_left)
	spawn_coins()
	
func spawn_coins():
	$LevelSound.play()
	get_tree().call_group("obstacles", "queue_free")
	spawn_cactus()
	for i in level + 4:
		var c = coin_scene.instantiate()
		add_child(c)
		c.screensize = screensize
		c.position = Vector2( randi_range(0,screensize.x), randi_range(0, screensize.y) )

func spawn_cactus():
	for i in level + 2:
		var cact = catus_scene.instantiate()
		add_child(cact)
		cact.position = Vector2( randi_range(0,screensize.x), randi_range(0, screensize.y) )

func _on_game_timer_timeout():
	time_left -= 1
	$HUD.update_timer(time_left)
	if time_left <= 0:
		game_over()

func _on_powerup_timer_timeout():
	var p = powerup_scene.instantiate()
	add_child(p)
	p.screensize = screensize
	p.position = Vector2( randi_range(0,screensize.x), randi_range(0, screensize.y) )
	
func _on_player_hurt():
	game_over()


func _on_player_pickup(type):
	match type:
		"coin":
			score += 1
			$HUD.update_score(score)
			$CoinSound.play()
		"powerup":
			time_left += 10
			$HUD.update_timer(time_left)
			$PowerupSound.play()
	
func game_over():
	playing = false
	$GameTimer.stop()
	get_tree().call_group("coins", "queue_free")
	$HUD.show_game_over()
	$Player.die()
	$GameEndSound.play()


func _on_hud_start_game():
	new_game()
