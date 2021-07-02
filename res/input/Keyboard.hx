package res.input;

import res.input.KeyboardEvent;

typedef KeyboardListener = KeyboardEvent->Void;

class Keyboard {
	private final _listeners:Array<KeyboardListener> = [];

	@:allow(res)
	private function new() {}

	public function listen(cb:KeyboardListener) {
		_listeners.push(cb);
	}

	public function unlisten(cb:KeyboardListener) {
		_listeners.remove(cb);
	}

	public function keyDown(keyCode:Int, charCode:Int) {
		for (listener in _listeners)
			listener(KEY_DOWN(keyCode, charCode));
	}

	public function keyUp(keyCode:Int, charCode:Int) {
		for (listener in _listeners)
			listener(KEY_UP(keyCode, charCode));
	}
}
