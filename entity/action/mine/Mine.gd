extends LynxAction

var _object_id = int()
var _direction = Vector2()

func _init():
	self.accepted_attributes = ["object_id", "direction"]

func _execute():
	var vect_anim = {
		Vector2(1,0) : "mine_right",
		Vector2(-1,0) : "mine_left",
		Vector2(0,-1) : "mine_down",
		Vector2(0,1) : "mine_up"
	}
	var animation = ""
	if vect_anim.has( self._direction):
		animation = vect_anim[ self._direction]
	else:
		animation = "mine_right"
	var object = get_parent().object
	object.get_node("AnimatedSprite2D").set_animation(animation)
	object.get_node("AnimatedSprite2D").play()
	object.get_node("AnimatedSprite2D").set_frame(0)
