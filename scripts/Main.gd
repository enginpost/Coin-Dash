extends Node

@export var coin_scene:PackedScene
@export var playtime = 30

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
#	new_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if playing and get_tree().get_nodes_in_group("coins").size() == 0:
		level += 1
		time_left += 5
		spawn_coins()
		

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
	for i in level + 4:
		var c = coin_scene.instantiate()
		add_child(c)
		c.screensize = screensize
		c.position = Vector2( randi_range(0,screensize.x), randi_range(0, screensize.y) )


func _on_game_timer_timeout():
	time_left -= 1
	$HUD.update_timer(time_left)
	if time_left <= 0:
		game_over()


func _on_player_hurt():
	game_over()


func _on_player_pickup():
	score += 1
	$HUD.update_score(score)
	
func game_over():
	playing = false
	$GameTimer.stop()
	get_tree().call_group("coins", "queue_free")
	$HUD.show_game_over()
	$Player.die()


func _on_hud_start_game():
	new_game()
