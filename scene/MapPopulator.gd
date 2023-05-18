extends Node

@onready var post_populate_endpoint_url = Globals.SERVER_ADDRESS + "populate"
@onready var post_populate_http_request = get_node("PostPopulateHTTPRequest")
@onready var state_getter = get_node("../WorldUpdater").state_getter

func post_populate():
	if post_populate_http_request.get_http_client_status() != HTTPClient.STATUS_CONNECTING:
		var error = post_populate_http_request.request(post_populate_endpoint_url, [], HTTPClient.METHOD_POST)
		if error != OK:
			push_error("[ERROR] Could not POST populate")
			return
		self.state_getter.current_tick_hash = -1


func _on_ui_post_populate_map_requested():
	self.post_populate()