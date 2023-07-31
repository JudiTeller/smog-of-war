extends Node2D

@export var songs = [
    {
        "sad": "res://assets/music/song1/sad.mp3",
        "happy": "res://assets/music/song1/happy.mp3",
    }, {
        "sad": "res://assets/music/song2/sad.mp3",
        "happy": "res://assets/music/song2/happy.mp3",
    }
]
@export var current_song = randi() % songs.size()
@export var volume = -25

@onready var sadPlayer: AudioStreamPlayer= $SadPlayer
@onready var happyPlayer: AudioStreamPlayer = $HappyPlayer
@onready var resMan: ResourceManager = get_parent().get_node("ResourceManager")

var loaded_songs = []
var current_mood = "sad"

# Called when the node enters the scene tree for the first time.
func _ready():
    resMan.connect("MusicChange", switchMode)

    for song in songs:
        loaded_songs.append([load_mp3(song["sad"]), load_mp3(song["happy"])])
    
    sadPlayer.stream = loaded_songs[current_song][0]
    sadPlayer.volume_db = volume
    sadPlayer.playing = true
    happyPlayer.stream = loaded_songs[current_song][1]
    happyPlayer.volume_db = -80
    happyPlayer.playing = true

    sadPlayer.connect("finished", _on_Player_finished)
    happyPlayer.connect("finished", _on_Player_finished)

    playSong(current_song)

func playSong(force=-1):
    var selection = randi() % songs.size()
    if force != -1:
        selection = force

    happyPlayer.stream = loaded_songs[selection][1]
    sadPlayer.stream = loaded_songs[selection][0]

    switchToPlayer(current_mood)

func switchToPlayer(player):
    if player== "sad":
        happyPlayer.volume_db = -80
        sadPlayer.volume_db = volume
    elif player == "happy":
        happyPlayer.volume_db = 0
        sadPlayer.volume_db = -80

func switchMode(force_to=null):
    var new_mode = force_to
    if force_to == null:
        if current_mood == "sad":
            new_mode = "happy"
        elif current_mood == "happy":
            new_mode = "sad"
    
    current_mood = new_mode
    switchToPlayer(current_mood)

func _on_Player_finished():
    playSong()

func changeVolume(value):
    volume = value
    sadPlayer.volume_db = value
    happyPlayer.volume_db = value

func load_mp3(path) -> AudioStreamMP3:
    var file = FileAccess.open(path, FileAccess.READ)
    var sound = AudioStreamMP3.new()
    sound.data = file.get_buffer(file.get_length())
    sound.loop = true
    return sound
