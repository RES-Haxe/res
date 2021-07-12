package res.input;

class Controller {
	public final playerNum:Int;

	var pressed:Map<ControllerButton, Bool> = [
		for (button in Type.allEnums(ControllerButton))
			button => false
	];

	public var direction(get, never):{dx:Int, dy:Int};

	inline function get_direction() {
		return {
			dx: (pressed[ControllerButton.LEFT] ? -1 : 0) + (pressed[ControllerButton.RIGTH] ? 1 : 0),
			dy: (pressed[ControllerButton.UP] ? -1 : 0) + (pressed[ControllerButton.DOWN] ? 1 : 0)
		};
	}

	@:allow(res)
	private function new(playerNum:Int) {
		this.playerNum = playerNum;
	}

	public function isPressed(button:ControllerButton) {
		return pressed[button];
	}

	public function push(button:ControllerButton) {
		pressed[button] = true;
	}

	public function release(button:ControllerButton) {
		pressed[button] = false;
	}
}
