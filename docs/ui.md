# Módulo: UI (Componentes y Detectores In-Game)

El módulo `UI` de Glapi no es un Service tradicional, sino una colección de componentes de interfaz y AutoLoads especializados diseñados para resolver fricciones nativas del frontend (Safe Areas de iOS/Android, Cambios de Gamepad en Vivo).

---

## 📱 1. Safe Area Margin Container (`SafeAreaMarginContainer`)

### El Problema
Al exportar juegos a móviles modernos, te das cuenta de que los *Notches* (Muescas de cámara) en la parte superior, o la barra gestual nativa de Android/iOS en la parte inferior, se están comiendo tu Botón de Pausa o tus medidores de HP.

### La Solución Clásica (y mala)
Obligar al diseñador a darle un padding gigantesco a la UI de 120 pixeles arriba y abajo para tratar de esquivar estas áreas en todas las marcas de teléfonos.

### La Solución con Glapi

El componente `@tool class_name SafeAreaMarginContainer` hereda de `MarginContainer`.
Cuando este nodo se dibuje en pantalla, detectará dinámicamente cuántos pixeles nativos se come el Notch, y le inyectará ese margen exacto a todos los hijos dentro de él. Además, es un de *Smart Node*: si abres el juego en PC, ignorará los SafeArea y usará márgenes cero de inmediato.

#### ¿Cómo Usar?
1. Añade un nodo `SafeAreaMarginContainer` como hijo directo de la raíz de tu UI (Debajo del `CanvasLayer`).
2. Configura sus banderas en el panel del Inspector: `Apply To Top`, `Apply To Bottom` (Normalmente activarás solo Top para esquivar la cámara, y Bottom para los botones gestuales de Android).
3. Mete todo tu VBoxContainer, Texto u otros Contenedores dentro de él. 

*(¡El margen físico se sumará siempre a los márgenes override que ya le hayas puesto en el editor de temas!)*

---

## 🎮 2. Input Device Detector (`Glapi.input_type`)

En los juegos de Consola o PC (e incluso móviles con gamepad Bluetooth), quieres cambiar los Íconos de ayuda que el juego pinta de inmediato.

- Si el jugador toca el Joystick: Que diga **(A) Saltar** (Con icono Xbox o DualSense).
- Si el jugador toca el teclado: Que diga **[Space] Saltar**.
- Si el jugador toca la Touchscreen: Desaparecer el panel de ayuda y pintar botones virtuales.

### Uso en el Juego (`Service Layer`)

El Singleton global inyectado por el framework observa globalmente todo `InputEvent` que Godot dispara antes de que se lo coma cualquier UI (`set_process_input(true)`).

#### Leer el Dispositivo Actual

Puedes obtenerlo directamente de memoria para dibujar interfaces antes de jugar.
```gdscript
func update_jump_hint():
	var device = Glapi.input_type.current_device
	
	match device:
		InputDeviceChangedEvent.InputType.KEYBOARD:
			$HintLbl.text = "Presiona [ESPACIO]"
		InputDeviceChangedEvent.InputType.GAMEPAD:
			$HintLbl.text = "Presiona [A]"
		InputDeviceChangedEvent.InputType.TOUCH:
			show_virtual_jump_button()
```

#### Reacción Dinámica (Event-Driven)

Cuando el jugador estaba en PC jugando, suelta el control analógico y toca el mouse, el `InputDeviceDetector` gritará al ecosistema al instante.

**(Por Señal)**
```gdscript
func _ready():
	Glapi.input_type.device_changed.connect(_on_device_changed)

func _on_device_changed(new_device: InputDeviceChangedEvent.InputType):
	if new_device == InputDeviceChangedEvent.InputType.TOUCH:
		hide_pc_cursor()
```

**(Por Domain Event Central)**
El módulo UI también despacha un evento formalmente construido hacia cualquier oyente global del motor vía:
`Glapi.dispatch(InputDeviceChangedEvent.new(current_device))`
