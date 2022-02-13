package res.input;

import res.events.Emitter;
import res.input.KeyboardEvent;

typedef KeyboardListener = KeyboardEvent->Void;

class Keyboard extends Emitter<KeyboardEvent> {
	private final _down:Map<Int, Bool> = [];
	private final _bindings:Map<Int, Array<{controller:Controller, button:ControllerButton}>> = [];

	final res:RES;

	@:allow(res)
	private function new(res:RES) {
		this.res = res;

		defaultControllerMapping();
	}

	public function keyDown(keyCode:Int) {
		_down[keyCode] = true;

		if (_bindings[keyCode] != null)
			for (binding in _bindings[keyCode]) {
				binding.controller.push(binding.button);
			}

		emit(KEY_DOWN(keyCode));
	}

	public function input(text:String) {
		emit(INPUT(text));
	}

	public function keyUp(keyCode:Int) {
		_down[keyCode] = false;

		if (_bindings[keyCode] != null)
			for (binding in _bindings[keyCode]) {
				binding.controller.release(binding.button);
			}

		emit(KEY_UP(keyCode));
	}

	public function isDown(keyCode:Int):Bool {
		return _down.exists(keyCode) && _down[keyCode];
	}

	/**
		Bind keyboard keys to controller's button

		@param keys Keys to bind
		@param button Button to bind
		@param controller Controller to bind keys to 
	 */
	public function bind(keys:Array<Int>, button:ControllerButton, ?controller:Controller) {
		for (key in keys) {
			if (_bindings[key] == null)
				_bindings[key] = [];

			_bindings[key].push({
				controller: controller == null ? res.controller : controller,
				button: button
			});
		}
	}

	public function defaultControllerMapping() {
		_bindings.clear();

		bind([Key.LEFT], LEFT);
		bind([Key.RIGHT], RIGTH);
		bind([Key.UP], UP);
		bind([Key.DOWN], DOWN);
		bind([Key.Z], A);
		bind([Key.X], B);
		bind([Key.A], X);
		bind([Key.S], Y);
		bind([Key.ENTER], START);
		bind([Key.SHIFT], SELECT);
	}
}
