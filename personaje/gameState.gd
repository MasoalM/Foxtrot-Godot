extends Node

# =========================
#  DATOS DEL JUGADOR
# =========================
var jugador_id = 1
var nombre = "Hugo"
var nivel 

# =========================
#  VIDAS
# =========================
signal vidas_juego_cambiadas(vidas)

var vidas_juego = 5
var maxVida = 99
var tiempo_activo = false

func _ready():
	
	set_process(true)

func perder_vida():
	vidas_juego -= 1
	emit_signal("vidas_juego_cambiadas", vidas_juego)

func ganar_vida():
	if vidas_juego < maxVida:
		vidas_juego += 1
		emit_signal("vidas_juego_cambiadas", vidas_juego)
		
func _process(delta):
	if tiempo_activo:
		actualizar_tiempo(delta)

# =========================
#  COLECCIONABLES
# =========================
signal monedas_cambiadas(monedas_estado)

var monedas_estado = [false, false, false]

func recoger_moneda(index: int):
	if index >= 0 and index < monedas_estado.size():
		monedas_estado[index] = true
		emit_signal("monedas_cambiadas", monedas_estado)

func resetear_monedas():
	monedas_estado = [false, false, false]
	emit_signal("monedas_cambiadas", monedas_estado)

# =========================
#  TIEMPO
# =========================
signal tiempo_cambiado(tiempo)
signal tiempo_agotado

var tiempo_restante = 241.0
var musica_acelerada = false

func actualizar_tiempo(delta):
	if tiempo_restante > 0:
		tiempo_restante -= delta
		emit_signal("tiempo_cambiado", int(tiempo_restante))

		if tiempo_restante <= 0:
			tiempo_restante = 0
			emit_signal("tiempo_agotado")

func reiniciar_tiempo():
	tiempo_restante = 241
	emit_signal("tiempo_cambiado", tiempo_restante)

# =========================
#  CHECKPOINT
# =========================
var checkpoint_position: Vector2 = Vector2.ZERO
var checkpoint_activo = false
var checkpoint_tiempo: float = 0.0

# =========================
#  RESET DE NIVEL
# =========================
func resetear_nivel():
	resetear_monedas()
	reiniciar_tiempo()
	vidas_juego = 5
	checkpoint_activo = false
	checkpoint_position = Vector2.ZERO
	
func entrandoNivel(niv: int):
	if niv == null:
		print("ERROR: nivel no definido")
		return {}
	nivel = niv
	print("en gameState el nivel ya es : ", nivel )
	
	
		

# =========================
#  RESULTADO DEL NIVEL
# =========================
func obtener_resultado() -> Dictionary:
	return {
		"jugador_id": jugador_id,
		"nivel_id": nivel,
		"tiempo": tiempo_restante,
		"puntuacion": 0,
		"c1": monedas_estado[0] if 1 else 0,
		"c2": monedas_estado[1] if 1 else 0,
		"c3": monedas_estado[2] if 1 else 0
	}
	
