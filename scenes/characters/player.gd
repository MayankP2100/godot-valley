extends CharacterBody2D

var direction: Vector2
var speed := 50
@onready var move_state_machine = $Animation/AnimationTree.get("parameters/MoveStateMachine/playback")
@onready var tool_state_machine = $Animation/AnimationTree.get("parameters/ToolStateMachine/playback")
var current_tool: Enum.Tool = Enum.Tool.AXE


func _physics_process(_delta: float) -> void:
	get_basic_input()
	move()
	animate()

func get_basic_input():
	if Input.is_action_just_pressed("tool_forward") or Input.is_action_just_pressed("tool_backward"):
		var dir = Input.get_axis("tool_backward", "tool_forward")
		current_tool = posmod((current_tool + int(dir)), Enum.Tool.size()) as Enum.Tool
		print(current_tool)

	if Input.is_action_just_pressed("action"):
		tool_state_machine.travel(Data.TOOL_STATE_ANIMATIONS[current_tool])
		$Animation/AnimationTree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func move():
	direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed
	move_and_slide()

func animate():
	if direction:
		move_state_machine.travel("Walk")
		var animate_direction = Vector2(round(direction.x), round(direction.y))
		$Animation/AnimationTree.set("parameters/MoveStateMachine/Idle/blend_position", animate_direction)
		$Animation/AnimationTree.set("parameters/MoveStateMachine/Walk/blend_position", animate_direction)
		
		for animation in Data.TOOL_STATE_ANIMATIONS.values():
			var animation_name: String = "parameters/ToolStateMachine/" + animation + "/blend_position"
			$Animation/AnimationTree.set(animation_name, animate_direction)
	else:
		move_state_machine.travel("Idle")

func tool_use_emit():
	print('tool')
