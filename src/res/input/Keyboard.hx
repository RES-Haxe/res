package res.input;

import res.events.Emitter;
import res.input.KeyboardEvent;

typedef KeyboardListener = KeyboardEvent->Void;

class Keyboard extends Emitter<KeyboardEvent> {
	final res:RES;

	/** Keys states here **/
	private final keysDown:Map<Key, Bool> = [];

	/** Store Button -> Key mapping by controller index e.g. `keyMap[controllerIndex][button] = key` **/
	private final keyMap:Map<Int, Map<ControllerButton, Key>> = [];

	/** Store Key -> [controllerIndex, button] associatino here **/
	private final ctrlMap:Map<Key, {index:Int, btn:ControllerButton}> = [];

	@:allow(res)
	private function new(res:RES) {
		this.res = res;

		for (n in 0...res.ctrlNum)
			keyMap[n] = new Map();

		defaultControllerMapping();
	}

	public function keyDown(keyCode:Key) {
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

	public function keyUp(keyCode:Key) {
		keysDown[keyCode] = false;

		if (ctrlMap[keyCode] != null) {
			final bnd = ctrlMap[keyCode];
			res.ctrl(bnd.index).release(bnd.btn);
		}

		emit(KEY_UP(keyCode));
	}

	/**
		Returns the currenct state of a key

		@param keyCode Key code
	**/
	public function isDown(keyCode:Key):Bool
		return keysDown.exists(keyCode) && keysDown[keyCode];

	/**
		Assign a Keyboard Key to a Controller button

		@param key Key to assign
		@param btn Button to map
		@param ctrlIndex Controller index
	**/
	public function map(key:Key, btn:ControllerButton, ctrlIndex:Int = 0) {
		final existingKeymap = keyMap[ctrlIndex][btn];

		if (existingKeymap != null) {
			ctrlMap.remove(existingKeymap);
		}

		final existingMapping = ctrlMap[key];

		if (existingMapping != null) {
			keyMap[existingMapping.index].remove(existingMapping.btn);
		}

		ctrlMap[key] = {index: ctrlIndex, btn: btn};

		keyMap[ctrlIndex] = keyMap[ctrlIndex] ?? [];
		keyMap[ctrlIndex][btn] = key;
	}

	/**
		Returns the key used mapped to a controller button

		@param ctrlIndex Index of the controller
		@param button Mapped button
	**/
	public function whichKey(ctrlIndex:Int, button:ControllerButton)
		return keyMap[ctrlIndex][button];

	public function defaultControllerMapping() {
		// Player 1
		map(A, LEFT);
		map(D, RIGTH);
		map(W, UP);
		map(S, DOWN);
		map(J, A);
		map(K, B);
		map(U, X);
		map(I, Y);
		map(LSHIFT, SELECT);
		map(SPACE, START);

		// Player 2
		map(LEFT, LEFT, 1);
		map(RIGHT, RIGTH, 1);
		map(UP, UP, 1);
		map(DOWN, DOWN, 1);
		map(NUMPAD_1, A, 1);
		map(NUMPAD_2, B, 1);
		map(NUMPAD_4, X, 1);
		map(NUMPAD_5, Y, 1);
		map(RSHIFT, SELECT, 1);
		map(ENTER, START, 1);
	}
}
