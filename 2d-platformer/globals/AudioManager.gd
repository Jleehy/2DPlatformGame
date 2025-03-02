extends Node

# Function to play a sound
func play_sound(audio_player: AudioStreamPlayer2D) -> void:
	#add_child(audio_player) # Add the player as a child of this node
	if (audio_player != null):
		audio_player.play() # Play the sound
	
	print("Playing sound: ", audio_player)
	# Connect the 'finished' signal to free the player after playback
	audio_player.finished.connect(audio_player.queue_free) 
