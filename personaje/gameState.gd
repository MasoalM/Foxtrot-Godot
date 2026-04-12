extends Node

var vidas_juego = 3
var maxVida = 99

func perder_vida():
	vidas_juego -= 1
	
	print("vidas restantes:", vidas_juego)
	
func ganar_vida():
	if vidas_juego == maxVida:
		return
	vidas_juego += 1
	print("vidas restantes:", vidas_juego)	

func reiniciar():
	vidas_juego = 3
