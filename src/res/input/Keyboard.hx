package res.input;

import res.input.KeyboardEvent;

typedef KeyboardListener = KeyboardEvent->Void;

class Keyboard {
	private final _listeners:Array<KeyboardListener> = [];

	private final _down:Map<Int, Bool> = [];

	private var controllerMappings:Map<Int, KeyboardControllerMapping> = [];

	final res:Res;

	@:allow(res)
	private function new(res:Res) {
		this.res = res;

		defaultControllerMapping();
	}

	public function listen(cb:KeyboardListener) {
		_listeners.push(cb);
	}

	public function unlisten(cb:KeyboardListener) {
		_listeners.remove(cb);
	}

	public function keyDown(keyCode:Int) {
		_down[keyCode] = true;
		final controllerMapping = controllerMappings[keyCode];

		if (controllerMapping != null)
			res.controllers[controllerMapping.playerNumber].push(controllerMapping.controllerButton);

		for (listener in _listeners)
			listener(KEY_DOWN(keyCode));
	}

	public function keyPress(charCode:Int) {
		for (listener in _listeners)
			listener(KEY_PRESS(charCode));
	}

	public function keyUp(keyCode:Int) {
		_down[keyCode] = false;

		final controllerMapping = controllerMappings[keyCode];

		if (controllerMapping != null)
			res.controllers[controllerMapping.playerNumber].release(controllerMapping.controllerButton);

		for (listener in _listeners)
			listener(KEY_UP(keyCode));
	}

	public function isDown(keyCode:Int):Bool {
		return _down.exists(keyCode) && _down[keyCode];
	}

	public function defaultControllerMapping() {
		mapControllers([
			[
				LEFT => Key.LEFT,
				RIGTH => Key.RIGHT,
				UP => Key.UP,
				DOWN => Key.DOWN,
				A => Key.Z,
				B => Key.X,
				X => Key.A,
				Y => Key.S,
				START => Key.ENTER,
				SELECT => Key.SHIFT
			]
		]);
	}

	public function mapControllers(mappings:Array<Map<ControllerButton, Int>>) {
		for (num in 0...mappings.length) {
			for (button => key in mappings[num]) {
				controllerMappings.set(key, {
					playerNumber: num + 1,
					controllerButton: button
				});
			}
		}
	}
}
