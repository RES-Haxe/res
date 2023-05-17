package res.input;

import res.events.Emitter;
import res.input.KeyboardEvent;

typedef KeyboardListener = KeyboardEvent->Void;

class Keyboard extends Emitter<KeyboardEvent> {
	private final keysDown:Map<Int, Bool> = [];

	private final ctrlMap:Map<Int, {index:Int, btn:ControllerButton}> = [];

	final res:RES;

	@:allow(res)
	private function new(res:RES) {
		this.res = res;

		defaultControllerMapping();
	}

	public function keyDown(keyCode:Int) {
		keysDown[keyCode] = true;

		if (ctrlMap[keyCode] != null) {
			final bnd = ctrlMap[keyCode];
			res.ctrl(bnd.index).press(bnd.btn);
		}

		emit(KEY_DOWN(keyCode));
	}

	public function input(text:String) {
		emit(INPUT(text));
	}

	public function keyUp(keyCode:Int) {
		keysDown[keyCode] = false;

		if (ctrlMap[keyCode] != null) {
			final bnd = ctrlMap[keyCode];
			res.ctrl(bnd.index).release(bnd.btn);
		}

		emit(KEY_UP(keyCode));
	}

	public function isDown(keyCode:Int):Bool {
		return keysDown.exists(keyCode) && keysDown[keyCode];
	}

	public function map(key:Int, btn:ControllerButton, ctrlIndex:Int = 0) {
		ctrlMap[key] = {index: ctrlIndex, btn: btn};
	}

	public function defaultControllerMapping() {
		map(Key.A, LEFT);
		map(Key.D, RIGTH);
		map(Key.W, UP);
		map(Key.S, DOWN);
		map(Key.J, A);
		map(Key.K, B);
		map(Key.U, X);
		map(Key.I, Y);
	}
}
