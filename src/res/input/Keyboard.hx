package res.input;

import res.input.KeyboardEvent;

typedef KeyboardListener = KeyboardEvent->Void;

class Keyboard {
	private final _listeners:Array<KeyboardListener> = [];

	private final _down:Map<Int, Bool> = [];

	@:allow(res)
	private function new() {}

	public function listen(cb:KeyboardListener) {
		_listeners.push(cb);
	}

	public function unlisten(cb:KeyboardListener) {
		_listeners.remove(cb);
	}

	public function keyDown(keyCode:Int) {
		_down[keyCode] = true;
		for (listener in _listeners)
			listener(KEY_DOWN(keyCode));
	}

	public function keyPress(charCode:Int) {
		for (listener in _listeners)
			listener(KEY_PRESS(charCode));
	}

	public function keyUp(keyCode:Int) {
		_down[keyCode] = false;
		for (listener in _listeners)
			listener(KEY_UP(keyCode));
	}

	public function isDown(keyCode:Int):Bool {
		return _down.exists(keyCode) && _down[keyCode];
	}
}
