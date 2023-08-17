extends Node2D

export (bool) var autostart = false
export (bool) var loop = false
export (bool) var snapshot = false
export (float) var animation_duration = 3.0
export (float) var text_animation_duration = 1.5
export (float) var inner_boing_animation_duration = 0.3
export (float) var inner_fade_animation_duration = 3.0
export (float) var particle_speed = 25.0
export (int) var moon_max_degree_rotation = 30

onready var moon = $LogoMoon
onready var text_layer = $Text
onready var particle_layer = $Particles
onready var inner_particle_layer = $InnerParticles

var particles_origin_y: Dictionary
var finished: bool = false

#TODO DO ALL THE ANIMATION VIA FOR LOOPS AND SCENE TWEENS
func _ready() -> void:
	if autostart:
		start()


func reset_objects() -> void:
	moon.rotation_degrees = -moon_max_degree_rotation
	for letter in text_layer.get_children():
		letter.modulate.a = 0
	for particle in particle_layer.get_children():
		particle.modulate.a = 0
		particle.rotation_degrees = -270
		particles_origin_y[particle.name] = particle.position.y
		particle.position.y = get_start_y(particle.position.x)
		particle.scale = Vector2(0.25,0.25)
	for inner_particle in inner_particle_layer.get_children():
		inner_particle.modulate.a = 0


func start() -> void:
	if !snapshot:
		finished = false
		reset_objects()
		moon_animate()
		text_animate()
		particle_animate()
		inner_particle_animate()


func moon_animate() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(moon, "rotation_degrees", 0, animation_duration)


func text_animate() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	var per_letter_duration = text_animation_duration/text_layer.get_child_count()
	for letter in text_layer.get_children():
		tween.tween_property(letter, "modulate:a", 1, per_letter_duration)


func particle_animate() -> void:
	#TODO calculate delay and duration depending on distance that the star travels
	for particle in particle_layer.get_children():
		var tween = create_tween()
		var destination = particles_origin_y[particle.name]
		var speed_time = min(get_particle_time(particle.position.y-destination), animation_duration)
		if speed_time == animation_duration:
			push_error("speed is too low for particle "+particle.name)
		var delay = animation_duration - speed_time
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(particle, "modulate:a", 1, speed_time/2).set_delay(delay)
		tween.parallel().tween_property(particle, "scale", Vector2(1,1), speed_time/2).set_delay(delay)
		tween.parallel().tween_property(particle, "rotation_degrees", 0, speed_time).set_delay(delay)
		tween.parallel().tween_property(particle, "position:y", destination, speed_time).set_delay(delay)
		if loop:
			set_particle_loop()
		else:
			tween.tween_callback(self, "finish")


func inner_particle_animate() -> void:
	pass


func finish() -> void:
	if !finished:
		#TODO freeze inner particles tweens
		finished = true


func set_particle_loop() -> void:
	pass #TODO


func get_particle_time(distance:float) -> float:
	return distance/particle_speed


func get_start_y (posX:float) -> float:
  return (9 * posX - 1000) / 17
