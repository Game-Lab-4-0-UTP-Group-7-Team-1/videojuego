extends Area2D

@export var enemigo_escena: PackedScene
@export var posicion_spawn: Vector2

var ha_spawneado := false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	print("ActivadorEnemigo listo en ", global_position)

func _on_body_entered(body):
	print("Algo entró: ", body)
	if body.is_in_group("player"):
		print("El player entró al activador.")
		if not ha_spawneado:
			if enemigo_escena:
				var enemigo = enemigo_escena.instantiate()
				enemigo.global_position = posicion_spawn
				get_tree().current_scene.add_child(enemigo)
				print("Enemigo instanciado en: ", posicion_spawn)
				ha_spawneado = true
				queue_free()
			else:
				print("ERROR: enemigo_escena NO está asignado en el Inspector.")
