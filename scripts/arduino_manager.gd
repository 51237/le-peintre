#arduino_manager.gd
extends Node2D

# ── Signaux ────────────────────────────────────────────
signal arduino_disconnected()
signal arduino_connected()
signal pairing_success(port: String)
signal pairing_failed()
signal button_changed(pressed: bool)
signal button_event(button_name: String, pressed: bool)
signal ldr_changed(dark: bool)

# ── Constantes de pairing ──────────────────────────────
const DISCOVER_MSG := "DISCOVER"
const ACK_PREFIX := "GDSERIAL_ACK"
const BAUD_RATE := 115200

# ── État interne ───────────────────────────────────────
var serial: GdSerial
var _paired: bool = false
var _is_pairing: bool = false
var _buffer: String = ""
var paired_port: String = ""
var timer_heartbeat: float = 0.0
var timer_heartbeat_max: float = 2.0
var last_port_name_used: String = ""

func _ready() -> void:
	serial = GdSerial.new()
	serial.set_baud_rate(BAUD_RATE)
	serial.set_timeout(10)
	start_pairing()

# ══ PAIRING ═══════════════════════════════════════════

func start_pairing() -> void:
	if _is_pairing:
		return

	_is_pairing = true
	_paired = false
	paired_port = ""

	var ports: Dictionary = serial.list_ports()
	if ports.is_empty():
		_is_pairing = false
		emit_signal("pairing_failed")
		return

	await _scan_ports(ports.values())
	_is_pairing = false

func _scan_ports(port_list: Array) -> void:
	for port_info in port_list:
		var port_name: String = port_info["port_name"]
		serial.set_port(port_name)

		if not serial.open():
			continue

		serial.clear_buffer()
		await get_tree().create_timer(0.5).timeout

		for i in range(3):
			serial.writeline(DISCOVER_MSG)
			await get_tree().create_timer(0.1).timeout

			var response := _read_all_available()
			if ACK_PREFIX in response:
				paired_port = port_name
				last_port_name_used = port_name
				_paired = true
				print("[Pairing] → CONNECTÉ sur ", port_name)
				emit_signal("pairing_success", port_name)
				emit_signal("arduino_connected")
				return

		serial.close()

	emit_signal("pairing_failed")

func _read_all_available() -> String:
	var result := ""
	if serial.bytes_available() > 0:
		result = serial.read_string(serial.bytes_available())
	return result

# ══ COMMUNICATION EN TEMPS RÉEL ════════════════════════

func _process(delta: float) -> void:
	timer_heartbeat -= delta

	if _paired:
		if timer_heartbeat < 0.0:
			timer_heartbeat = timer_heartbeat_max

			if not serial.is_open():
				_paired = false
				emit_signal("arduino_disconnected")

	if not _paired:
		if not _is_pairing:
			start_pairing()
		return

	while serial.bytes_available() > 0:
		_buffer += serial.read_string(serial.bytes_available())

	while "\n" in _buffer:
		var idx := _buffer.find("\n")
		var line := _buffer.substr(0, idx).strip_edges()
		_buffer = _buffer.substr(idx + 1)

		if line.length() > 0:
			_parse_message(line)

func _parse_message(msg: String) -> void:
	var parts := msg.split(":", false, 1)
	if parts.size() < 2:
		return

	match parts[0]:
		"button1", "button2", "button3", "button4":
			var is_pressed := parts[1] == "1"
			emit_signal("button_changed", is_pressed)
			emit_signal("button_event", parts[0], is_pressed)

		"ldr":
			emit_signal("ldr_changed", parts[1] == "1")

		"pong":
			print("[Arduino] Latence mesurée : ", Time.get_ticks_msec() - parts[1].to_int(), " ms")

		"ack":
			print("[Arduino] Ack : ", parts[1])

		_:
			pass

# ══ API PUBLIQUE ══════════════════════════════════════

func send_rgb_random() -> void:
	_send("rgb_random")

func send_ping() -> void:
	_send("ping:" + str(Time.get_ticks_msec()))

func send_vibration(duration_ms: int) -> void:
	_send("vib:" + str(duration_ms))

func stop_vibration() -> void:
	_send("vib:0")

func _send(cmd: String) -> void:
	if not _paired:
		push_warning("[Arduino] Non pairé, commande ignorée : " + cmd)
		return

	serial.writeline(cmd)

func _exit_tree() -> void:
	if serial and serial.is_open():
		serial.close()
