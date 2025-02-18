extends Node

const NUM_COINS_WIN=23

var coins :=0
var lives = 5
var gameWon = null
var timeLeft = 225 # in seconds
var portal=-1
var difficulty = "hard"

signal playerDied

func lostALife():
	lives-=1
	emit_signal("playerDied")
