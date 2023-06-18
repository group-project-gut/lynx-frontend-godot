extends Node

@onready var get_state_http_request = get_node("GetStateHTTPRequest")
@onready var scene_recreator = get_node("SceneRecreator")
@onready var deltas_applier = get_node("DeltasApplier")
@onready var scene_wiper = get_node("SceneWiper")

var json = JSON.new()
var current_tick_number: int = -1

func _speed_up_actions_after_lag(old_tick_number, new_tick_number):
	Globals.ACTION_SPEED_MULTIPLIER = 1 if new_tick_number <= old_tick_number else new_tick_number - old_tick_number

	for object in Globals.WORLD_UPDATER.objects_container.get_children():
		object.get_node("ExecuteActionTimer").wait_time = 0.5 / Globals.ACTION_SPEED_MULTIPLIER
		object.get_node("AnimatedSprite2D").speed_scale = Globals.ACTION_SPEED_MULTIPLIER
		
func _update_state(response):
	if "scene" in response.keys():
		json.parse(response["scene"])
		scene_wiper.wipe()
		scene_recreator.recreate_scene(json.get_data())
	elif "deltas" in response.keys():
		deltas_applier.apply_deltas(response["deltas"])
	
	_speed_up_actions_after_lag(current_tick_number, response["tick_number"])
	current_tick_number = response["tick_number"]

func _on_get_state_http_request_request_completed(_result, response_code, _headers, body):
	if response_code == 200:
		json.parse(body.get_string_from_utf8())
		var response = json.get_data()
		_update_state(response)

# send get state requests every timer timeout (1s)
func _on_get_state_timer_timeout():
	if get_state_http_request.get_http_client_status() not in [HTTPClient.STATUS_CONNECTING, HTTPClient.STATUS_REQUESTING]:
		var error = get_state_http_request.request(Globals.SERVER_ADDRESS + "?tick_number=" + str(current_tick_number))
		if error != OK:
			push_error("An error occurred in the get state HTTP request.")
