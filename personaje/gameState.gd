extends Node

signal vidas_juego_cambiadas(vidas)

var vidas_juego = 5
var maxVida = 99
var monedas_estado = [false, false, false]

signal monedas_cambiadas(monedas_estado)
var tiempo_restante = 300
var musica_acelerada = false

signal tiempo_cambiado(tiempo)
signal tiempo_agotado

var checkpoint_position: Vector2 = Vector2.ZERO
var checkpoint_activo = false

func perder_vida():
	vidas_juego -= 1
	emit_signal("vidas_juego_cambiadas", vidas_juego)

func ganar_vida():
	if vidas_juego < maxVida:
		vidas_juego += 1
		emit_signal("vidas_juego_cambiadas", vidas_juego)

func reiniciar():
	vidas_juego = 3
	checkpoint_activo = false
	musica_acelerada = false
	checkpoint_position = Vector2.ZERO
	emit_signal("vidas_juego_cambiadas", vidas_juego)

func _process(delta):
	if tiempo_restante > 0:
		tiempo_restante -= delta
		emit_signal("tiempo_cambiado", int(tiempo_restante))
		
		if tiempo_restante <= 0:
			tiempo_restante = 0
			emit_signal("tiempo_agotado")	
			
func reiniciar_tiempo():
	tiempo_restante = 20
	emit_signal("tiempo_cambiado", tiempo_restante)			
			
