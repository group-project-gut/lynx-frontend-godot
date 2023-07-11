extends Node

@onready var get_state_http_request = get_node("GetStateHTTPRequest")
@onready var scene_recreator = get_node("SceneRecreator")
@onready var deltas_applier = get_node("DeltasApplier")
@onready var scene_wiper = get_node("SceneWiper")

var json = JSON.new()
var current_tick_number: int = -1
var get_state_wait_time: float = 1.0
var acceptable_delay: float = 0.01

func _speed_up_actions():
	for object in Globals.WORLD_UPDATER.objects_container.get_children():
		object.get_node("ExecuteActionTimer").wait_time = Globals.DEFAULT_ACTION_SPEED / Globals.ACTION_SPEED_MULTIPLIER
		object.get_node("AnimatedSprite2D").speed_scale = Globals.ACTION_SPEED_MULTIPLIER

func _handle_lag(old_tick_number, new_tick_number):
	var old_action_speed_multiplier = Globals.ACTION_SPEED_MULTIPLIER
	Globals.ACTION_SPEED_MULTIPLIER = 1 if new_tick_number <= old_tick_number else new_tick_number - old_tick_number
	
	if old_action_speed_multiplier != Globals.ACTION_SPEED_MULTIPLIER:
		_speed_up_actions()
		
func _update_state(response):
	if "scene" in response.keys():
		json.parse(response["scene"])
		scene_wiper.wipe()
		scene_recreator.recreate_scene(json.get_data())
	elif "deltas" in response.keys():
		deltas_applier.apply_deltas(response["deltas"])
	
	_handle_lag(current_tick_number, response["tick_number"])
	current_tick_number = response["tick_number"]

func _on_get_state_http_request_request_completed(_result, response_code, _headers, body):
	if response_code == 200:
		json.parse(body.get_string_from_utf8())
		var response = json.get_data()
		_update_state(response)
		
		if current_tick_number % 3 == 0:
			var difference_in_time = Time.get_unix_time_from_system()*1000
			var delay_time = 0 if (float(int(difference_in_time) % 1000)) / 1000 < self.acceptable_delay else (float(int(difference_in_time) % 1000)) / 1000
			var wait_time_delay = delay_time if delay_time < 0.85 else -(1 - delay_time)
			get_node("GetStateTimer").wait_time = 1 - wait_time_delay
		else:
			get_node("GetStateTimer").wait_time = 1


# send get state requests every timer timeout (1s)
func _on_get_state_timer_timeout():
	if get_state_http_request.get_http_client_status() not in Globals.BUSY_HTTP_STATUSES:
		var result = get_state_http_request.request(Globals.SERVER_ADDRESS + "?tick_number=" + str(current_tick_number))
		if result != OK:
			push_error("[ERROR] Could not GET state: " + str(result))
	
