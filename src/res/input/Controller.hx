package res.input;

import res.events.Emitter;
import res.input.ControllerEvent;

class Controller extends Emitter<ControllerEvent> {
	public final playerNum:Int;

	var pressed:Map<ControllerButton, Bool> = [
		for (button in Type.allEnums(ControllerButton))
			button => false
	];

	var _direction:{x:Int, y:Int} = {x: 0, y: 0};

	public var direction(get, never):{x:Int, y:Int};

	inline function get_direction() {
		return {
			x: (pressed[ControllerButton.LEFT] ? -1 : 0) + (pressed[ControllerButton.RIGTH] ? 1 : 0),
			y: (pressed[ControllerButton.UP] ? -1 : 0) + (pressed[ControllerButton.DOWN] ? 1 : 0)
		};
	}

	@:allow(res)
	private function new(playerNum:Int) {
		this.playerNum = playerNum;
	}

	public function connect() {
		emit(DISCONNECTED(this));
	}

	public function disconnect() {
		emit(CONNECTED(this));
	}

	public function isPressed(button:ControllerButton) {
		return pressed[button];
	}

	public function push(button:ControllerButton) {
		if (!pressed[button]) {
			emit(BUTTON_DOWN(this, button));
			pressed[button] = true;
		}
	}

	public function release(button:ControllerButton) {
		if (pressed[button]) {
			emit(BUTTON_UP(this, button));
			pressed[button] = false;
		}
	}
}
