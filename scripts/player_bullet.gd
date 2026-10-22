extends Area2D
class_name Bullet

@onready var visible_on_screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier

# 射弹速度/pix
@export var speed: float = 400.0
# 当前移动方向
var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	self.scale = Vector2(0.25, 0.25)


func _physics_process(delta: float) -> void:
	if not visible_on_screen_notifier.is_on_screen():
		queue_free()
	
	var current_position = global_position
	var next_position = current_position + direction * speed * delta
	
	global_position = next_position


# 射弹初始化函数, 由 player 传入方向
func setup(init_direction: Vector2) -> void:
	# 对初始方向归一化
	if init_direction != Vector2.ZERO:
		direction = init_direction.normalized()
	# 设置偏转角度
	rotation = direction.angle()


func _on_invisible_on_screen() -> void:
	queue_free()
	return
