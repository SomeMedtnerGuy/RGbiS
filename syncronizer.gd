class_name Synchronizer
extends Node

## Emitted everytime a beat occurs
signal beat_occured
## Emitted everytime an input_window (time chunck when input is allowed) starts or ends
signal input_allowed_changed(value)


### DUE TO WIRELESS HEADPHONES USED FOR TESTING, A DELAY TO THE AUDIO MUST BE ADDED TO COMPENSATE. ###
##### REMOVE ON EXPORT!! #####
@export var WIRELESS_DELAY := 0.3



## Track speed in beats per minute
@export var _track_bpm := 120
## Length of each beat in seconds
@onready var _beat_length := 60.0 / _track_bpm
## Margin of error in either side of the beat for the players to press a button
@onready var _input_window := _beat_length / 5

var time_begin: float
var time_delay: float
## Number of the beat playing
var _current_beat_index := 0
## Beat that is currently being the base for the input_window checks
var _beat_for_input_check := 0

## Flag that holds whether input should be valid or not.
var _input_allowed := false: 
	set(value):
		# If we are trying to switch the variable to the same value, abort
		if _input_allowed == value:
			return
		
		# If we are at the end of an input window, start checking for the window of the next beat. This check works because the only time that it runs is the very first frame where these two values are the same (aka the frame after the end of the input window)
		if _input_allowed and value == false:
			_beat_for_input_check += 1
		_input_allowed = value 
		input_allowed_changed.emit(_input_allowed)

@onready var audio_stream_player := $AudioStreamPlayer


func _ready():
	play_track()


func _process(_delta):
	var track_position: float = get_track_position()
	
	# Updates which beat we currently are hearing by checking if track already passed the beat after the current one
	
	##### BECAUSE OF HWIRELESS HEADPHONES AUDIO DELAY, AN EXTRA DELAY MUST BE ADDED. REMOVE BEFORE EXPORT
	if track_position >= (_current_beat_index + 1) * _beat_length + WIRELESS_DELAY:
		_current_beat_index += 1
		beat_occured.emit()
	
	# Updates whether input is allowed, triggering the setter that sends the signal which updates the rest of the codebase (in Main)
	_input_allowed = is_input_allowed(track_position)


func play_track() -> void:
	time_begin = Time.get_ticks_usec()
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	audio_stream_player.play()


## Accurately gets how far along the track we currently are
func get_track_position() -> float:
	var time: float = (Time.get_ticks_usec() - time_begin) / 1000000.0
	time -= time_delay
	return max(0, time)

# Checks if input is allowed by checking if track is within the specified error margin from the beat
func is_input_allowed(track_position: float) -> bool:
	return (
		track_position > (_beat_for_input_check * _beat_length) - _input_window + WIRELESS_DELAY
		and track_position < (_beat_for_input_check * _beat_length) + _input_window + WIRELESS_DELAY
	)
