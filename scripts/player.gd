extends CharacterBody2D

const PLAYER_BULLET_SCENE = preload("res://scenes/player_bullet.tscn")

# 默认玩家移动速度
var DEFAULT_PLAYER_MOVE_SPEED: float = 500.0
# 最大射弹射出间隔/s
const MAX_SHOOT_INTERVAL: float = 0.2
# 射弹射出距离玩家的偏移量/pix
const SHOOTOUT_OFFSET: float = 20.0
# 默认射击模式
const DEFAULT_SHOOT_MODE: int = 0


# 当前玩家速度/pix (默认为 DEFAULT_PLAYER_MOVE_SPEED)
@export var current_player_move_speed: float = DEFAULT_PLAYER_MOVE_SPEED
# 当前射弹射出剩余间隔/s
var current_shoot_interval: float = 2.0
# 当前射击模式 (默认为 DEFAULT_SHOOT_MODE)
var current_shoot_mode: int = DEFAULT_SHOOT_MODE


func _ready() -> void:
	# 获取初始窗口宽高
	var _window_width: float = _get_window_size().x
	var _window_height: float = _get_window_size().y
	# 设置自身初始缩放和位置
	self.scale = Vector2(0.5, 0.5)
	self.position = Vector2(_window_width / 2.0, _window_height / 4.0 * 3.0)
	# 设置初始变量
	current_shoot_interval = MAX_SHOOT_INTERVAL


func _physics_process(delta: float) -> void:
	# 每个逻辑刻减少射击冷却时间
	_reduce_shoot_interval(delta)
	# 尝试射出射弹
	_try_shoot()

	
	# 获取输入方向并归一化
	var move_direct: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	# 调用 velocity 并移动
	velocity = move_direct * current_player_move_speed
	move_and_slide()


# 减少射击冷却时间的函数
func _reduce_shoot_interval(amount: float) -> void:
	current_shoot_interval -= amount


# 尝试射出射弹, 尝试成功生成一个普通射弹, 重置射击间隔
# 当前射击间隔不可改变
# 短路写法
func _try_shoot() -> void:
	if current_shoot_interval > 0.0:
		return
	
	spawn_bullet()
	current_shoot_interval = MAX_SHOOT_INTERVAL


# 生成一个射弹
func spawn_bullet() -> void:
	var bullet := PLAYER_BULLET_SCENE.instantiate() as Bullet
	if bullet == null:
		return
	
	# 传入射弹方向
	var direction: Vector2
	# 根据射击模式配置射击方向
	if current_shoot_mode == DEFAULT_SHOOT_MODE: # 鼠标指示方向射击模式
		var to_mouse_direction = (get_global_mouse_position() - global_position).normalized()
		# 鼠标在角色下方, 将 y 方向反转并轻微反弹
		# 鼠标在角色下方, 若与 y 轴夹角小于60°, 反转 x 分量方向
		if to_mouse_direction.y > 0:
			to_mouse_direction.y = -to_mouse_direction.y / 2.0
			if to_mouse_direction.x < 0.86 and to_mouse_direction.x > -0.86:
				to_mouse_direction.x = -to_mouse_direction.x
		direction = to_mouse_direction
	bullet.setup(direction)
	
	# 设置父节点为场景, 避免射弹跟随玩家
	var parent := get_tree().current_scene
	if parent == null:
		bullet.queue_free()
		return
	
	parent.add_child(bullet)
	bullet.global_position = global_position + direction * SHOOTOUT_OFFSET


# 获取当前屏幕大小 (Vec2)
func _get_window_size() -> Vector2:
	var size: Vector2 = get_viewport().get_visible_rect().size
	return size
