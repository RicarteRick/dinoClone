extends Node

var velocidade = Vector2(-500, 0)
var velocidade_inicial = velocidade
var offset_inicial = Vector2()
var comecou = false
var acabou = false
var pontuacao_cacto = 10
var pontuacao_passaro = 15
var pontos = 0
var save = preload("res://save.res")
var record = save.recorde

func _ready():
	get_node("Record").text = "Record: " + str(record)
	get_node("Dino").connect("recomecou", self, "quando_recomecou")
	pass

func _process(delta):
	if not comecou:
		return
	
	velocidade.x -= delta/5

func quando_recomecou():
	# save.recorde =  record
	velocidade = velocidade_inicial
	$ParallaxBackground.set_scroll_offset(offset_inicial)