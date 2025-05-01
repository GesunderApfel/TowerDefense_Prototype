extends Node2D
class_name DebugDrawNode

var points: Array[Dictionary] = []

# capsule bullshit
var capsules: Array[Dictionary] = []

func _draw():
	for p in points:
		draw_circle(to_local(p.position), p.radius, p.color)
	for c in capsules:
		draw_capsule(c.collider, c.position, c.color)
	pass

func add_debug_point(global_pos: Vector2, color := Color.GREEN, radius := 6.0, lifetime := 1.0):
	points.append({
		"position": global_pos,
		"color": color,
		"radius": radius
	})
	queue_redraw()
	await get_tree().create_timer(lifetime).timeout
	points.erase(points.find(points.back()))
	queue_redraw()
	pass
	

func add_capsule(collider: CollisionShape2D, center: Vector2, color: Color, lifetime := 1.0):
	capsules.append({
		"collider": collider,
		"position": center,
		"color": color,
	})
	queue_redraw()
	await get_tree().create_timer(lifetime).timeout
	capsules.erase(capsules.find(capsules.back()))
	queue_redraw()
	pass


func draw_capsule(collider: CollisionShape2D, center: Vector2, color: Color, line_width := 1.0):
	var shape := collider.shape as CapsuleShape2D
	var radius := shape.radius
	var half_height := (shape.height * 0.5) - radius
	
	var up := collider.global_transform.y.normalized()
	var top := center - up * half_height
	var bottom := center + up * half_height
	var axis := (top - bottom).normalized()
	var perp := Vector2(-axis.y, axis.x) * radius
	
	# Draw center line
	draw_line(bottom, top, color, line_width)
	
	# Draw circles
	draw_circle(top, radius, color)
	draw_circle(bottom, radius, color)

	# Optional: Draw edges
	draw_line(top + perp, bottom + perp, color, line_width)
	draw_line(top - perp, bottom - perp, color, line_width)
	pass
