extends Node
class_name GlapiGodotAudioManager

# Este es el verdadero MOTOR de sonido de Godot. No sabe qué es "Glapi", solo 
# sabe gestionar nodos AudioStreamPlayer, Polyphonics y Playlists.

const POOL_SIZE: int = 8
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_poly_player: AudioStreamPlayer
var _sfx_poly_playback: AudioStreamPlaybackPolyphonic

# Reproductores dedicados para BGM
var _bgm_player: AudioStreamPlayer
var _bgm_interactive_playback: AudioStreamPlaybackInteractive

# Un "Catálogo" simulado en memoria que asocia Strings con AudioStreams
var _audio_catalog: Dictionary = {}

func _ready() -> void:
	name = "GlapiGodotAudioManager"
	
	# 1. Setup SFX Pool (Para sonidos individuales concurrentes)
	for i in range(POOL_SIZE):
		var p = AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_sfx_pool.append(p)
		
	# 2. Setup Polyphonic SFX (Para spampear cientos de partículas, monedas)
	_sfx_poly_player = AudioStreamPlayer.new()
	_sfx_poly_player.bus = "SFX"
	var poly_stream = AudioStreamPolyphonic.new()
	poly_stream.polyphony = 32
	_sfx_poly_player.stream = poly_stream
	add_child(_sfx_poly_player)
	_sfx_poly_player.play() # Debe estar en play constante
	_sfx_poly_playback = _sfx_poly_player.get_stream_playback()

	# 3. Setup BGM Player
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.bus = "Music"
	add_child(_bgm_player)

# ----------------- REGISTRO DE RECURSOS -----------------
func register_stream(event_name: String, stream: AudioStream) -> void:
	_audio_catalog[event_name] = stream

# ----------------- REPRODUCCIÓN (SFX) -----------------
func play_sfx(event_name: String) -> void:
	if not _audio_catalog.has(event_name):
		push_warning("GodotAudioEngine: SFX No encontrado en catálogo: ", event_name)
		return
		
	var stream: AudioStream = _audio_catalog[event_name]
	
	# Buscar un reproductor libre en la pool
	for player in _sfx_pool:
		if not player.playing:
			player.stream = stream
			player.play()
			return
			
	push_warning("GodotAudioEngine: SFX Pool llena, priorizando no saturar (sonido omitido).")

func play_sfx_polyphonic(event_name: String, pitch_scale: float = 1.0) -> void:
	if not _audio_catalog.has(event_name): return
	var stream: AudioStream = _audio_catalog[event_name]
	
	# Añade el sonido al torrente polifónico sin instanciar ningún nodo nuevo. Súper rápido.
	if _sfx_poly_playback:
		_sfx_poly_playback.play_stream(stream, 0, 0, pitch_scale)

# ----------------- REPRODUCCIÓN (BGM) -----------------
func play_music(event_name: String) -> void:
	if not _audio_catalog.has(event_name): return
	var stream = _audio_catalog[event_name]
	
	_bgm_player.stream = stream
	_bgm_player.play()
	
	# Si resulta ser un Interactive stream, preparamos su controlador
	if stream is AudioStreamInteractive:
		_bgm_interactive_playback = _bgm_player.get_stream_playback()

func stop_music() -> void:
	_bgm_player.stop()
	_bgm_interactive_playback = null

# Cambiar clip de música en un AudioStreamInteractive (Godot 4.3+)
func set_interactive_music_state(state_name: StringName) -> void:
	if _bgm_interactive_playback:
		_bgm_interactive_playback.switch_to_clip_by_name(state_name)
	else:
		push_warning("GodotAudioEngine: Intentaste cambiar estado interactivo pero BGM actual no es Interactive.")

# ----------------- GENERADOR SINTÉTICO (MOCK) -----------------
# Solo para rellenar recursos si no hay archivos físicos
func _create_generator_noise(hz: float) -> AudioStreamGenerator:
	var gen = AudioStreamGenerator.new()
	gen.mix_rate = 44100
	gen.buffer_length = 0.5
	return gen
