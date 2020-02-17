extends Area2D

onready var dinossauro = get_parent().get_node("Dino")
var ar = Vector2(1400, 600)
var velocidade = Vector2(-500, 0)
var tempo_vida = 5
var passou = false
onready var main = get_parent() #get_node("/root/Main")

func _ready():
	set_position(ar)
	
	connect("area_entered", dinossauro, "colidiu")
	dinossauro.connect("recomecou", self, "recomecou")
	pass

func _physics_process(delta):
	if not main.comecou:
		return
	
	$AnimationPlayer.play("voando")
	
	set_position(position + get_node("/root/Main").velocidade * delta * 1)
	
	tempo_vida = tempo_vida - delta
	
	if tempo_vida <= 0:
		queue_free()
		
	# Verifica se jogador já passou por esse pássaro e adiciona pontos
	if not passou:
		if get_position().x < main.get_node("Dino").get_position().x and dinossauro.position == dinossauro.chao:
			passou = true
			main.pontos = main.pontos + main.pontuacao_passaro
			main.get_node("Pontos").text = "Pontos: " + str(main.pontos)

func recomecou():
	queue_free()
