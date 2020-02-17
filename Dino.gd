extends Area2D

signal recomecou

var chao = Vector2(220, 657)
var gravidade = 4000
var vel = Vector2()
var vel_pulo = -1200
var modificador_gravidade = 2.3

var tempo = 0.0
var tempo_passaro = tempo
var intervalo = 3
var intervalo_passaro = 5
var intervalo_min = 0.6
var intervalo_min_passaro = 2
var intervalo_max = 3.0
var intervalo_max_passaro = 10
var trocou_fundo1 = false
var trocou_fundo2 = false
var trocou_fundo3 = false
var trocou_chao = false
var abaixou = false
var pode_passaro = false
var pode_cacto = true

var passou_100 = false
var inter_pisca = 0

var cactos = [preload("res://CactoP1.tscn"),
			  preload("res://CactoP2.tscn"),
			  preload("res://CactoP3.tscn"),
			  preload("res://CactoG1.tscn"),
			  preload("res://CactoG2.tscn"),
			  preload("res://CactoG3.tscn")]

var passaro = preload("res://Passaro.tscn")

func _ready():
	set_position(chao)
	randomize()
	$AnimationPlayer.play("parado")
	pass

func _physics_process(delta):
	if not get_parent().comecou:
		return
	
	tempo += delta
	tempo_passaro += delta
	
	inter_pisca = fmod(get_parent().pontos, 100)
	
	if inter_pisca == 0 or inter_pisca == 5 or inter_pisca == 10 or inter_pisca == 15:
		passou_100 = true

	if get_parent().pontos >= 100 and passou_100:
		get_parent().get_node("Pontos/AnimationPlayer").play("pisca_pisca")
		passou_100 = false
	
	if get_parent().pontos >= 200 and not trocou_fundo1:
		get_parent().get_node("ParallaxBackground2/ParallaxLayer/AnimationPlayer").play("primeiro_tarde")
		trocou_fundo1 = true
	
	if get_parent().pontos >= 500 and not trocou_fundo2 and not trocou_chao:
		get_parent().get_node("ParallaxBackground2/ParallaxLayer/AnimationPlayer").play("trocando")
		get_parent().get_node("ParallaxBackground/ParallaxLayer/AnimationPlayer").play("trocando")
		trocou_fundo2 = true
		trocou_chao = true
	
	if get_parent().pontos >= 800 and not trocou_fundo3:
		get_parent().get_node("ParallaxBackground2/ParallaxLayer/AnimationPlayer").play("segundo_tarde")
		trocou_fundo3 = true
	
	if tempo_passaro >= intervalo_passaro and get_parent().pontos >= 30 and pode_passaro:
		tempo_passaro = 0
		
		get_parent().add_child(passaro.instance())
		
		get_node("Timer2").start(1)
		
		intervalo_passaro = rand_range(intervalo_min_passaro, intervalo_max_passaro)
		
		pode_passaro = false
		pode_cacto = false
	
	if tempo >= intervalo and pode_cacto:
		tempo = 0
		
		# Decide cacto
		var c = rand_range(0, cactos.size())
		
		get_parent().add_child(cactos[c].instance())
		
		get_node("Timer").start(2)
		
		# Decide novo intervalo
		intervalo = rand_range(intervalo_min, intervalo_max)
		
	if get_parent().comecou:
		if Input.is_action_pressed("pular"):
			vel.y += gravidade * delta
		else:
			vel.y += gravidade * delta * modificador_gravidade
			
		if Input.is_action_just_pressed("pular") and position == chao:
			vel.y = vel_pulo
	
	position += vel * delta
	
	# Limita a posição até o chão
	if get_position().y > chao.y:
		set_position(chao)
		vel = Vector2()

func colidiu(area):
	if abaixou:
		$AnimationPlayer.play("morto_baixo")
	else:
		$AnimationPlayer.play("morto")
	intervalo = 3
	get_parent().comecou = false
	get_parent().acabou = true
	if get_parent().pontos > get_parent().record:
		get_parent().record = get_parent().pontos
	get_parent().pontos = 0
	
	pass

func _input(event):
	if Input.is_action_just_pressed("pular") or Input.is_action_just_pressed("abaixar") or event is InputEventMouseButton:
		if get_parent().acabou: # is_echo = ta segurando o botao
			emit_signal("recomecou")
			# get_tree().reload_current_scene()
			get_parent().acabou = false
			get_parent().get_node("Record").text = "Record: " + str(get_parent().record)
			get_parent().get_node("Pontos").text = "Pontos: " + str(get_parent().pontos)
			get_parent().get_node("ParallaxBackground2/ParallaxLayer/AnimationPlayer").play("tudo_dnv")
			get_parent().get_node("ParallaxBackground/ParallaxLayer/AnimationPlayer").play("tudo_dnv")
			trocou_fundo1 = false
			trocou_fundo2 = false
			trocou_fundo3 = false
			trocou_chao = false
			pass
		
		get_parent().comecou = true
		
	
	if get_parent().comecou:
		if Input.is_action_pressed("abaixar"):
			$AnimationPlayer.play("abaixado")
			abaixou = true
		else:
			$AnimationPlayer.play("andando")
			abaixou = false

func _on_Timer_timeout():
	pode_passaro = true
	get_node("Timer").stop()

func _on_Timer2_timeout():
	pode_cacto = true
	get_node("Timer2").stop()
