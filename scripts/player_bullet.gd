extends Area2D
class_name Bullet

# 世界碰撞层常数
const WORLD_COLLISION_MASK: int = 1

@onready var visible_on_screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier

# 射弹速度/pix
@export var speed: float = 400.0
# 生命周期/s
# 未完成
@export var life_time: float = 999.0
# 当前移动方向
var direction: Vector2 = Vector2.ZERO


# 射线查询使用的射线
var query := PhysicsRayQueryParameters2D.create(
	Vector2.ZERO, Vector2.ZERO, WORLD_COLLISION_MASK)


func _ready() -> void:
	self.scale = Vector2(0.25, 0.25)
	visible_on_screen_notifier.screen_exited.connect(queue_free)
	# 射线查询配置
	query.collide_with_bodies = true
	query.collide_with_areas = false
	query.hit_from_inside = false
	# 连接信号
	


func _physics_process(delta: float) -> void:
	var current_position = global_position
	var next_position = current_position + direction * speed * delta
	
	# 射弹碰到世界层检测 & 改变方向 & 重设 next_position
	var hit_dic: Dictionary = _hit_world(current_position, next_position)
	if not hit_dic.is_empty():
		var normal: Vector2 = hit_dic.normal
		direction = direction.bounce(normal)
		next_position = current_position + direction * speed * delta
	
	global_position = next_position


# 射弹初始化函数, 由 player 传入方向
func setup(init_direction: Vector2) -> void:
	# 对初始方向归一化
	if init_direction != Vector2.ZERO:
		direction = init_direction.normalized()
	# 设置偏转角度
	rotation = direction.angle()


# 射线检测当前帧移动路径, 返回碰撞字典
func _hit_world(from_position: Vector2, to_position: Vector2) -> Dictionary:
	var space_state := get_world_2d().direct_space_state
	if space_state == null:
		return {}
	# 调用预创建射线
	query.from = from_position
	query.to = to_position
	# 碰到世界层返回 true
	var hit_result: Dictionary = space_state.intersect_ray(query)
	return hit_result
