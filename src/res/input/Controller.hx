package res.input;

import res.geom.Vec;

@:build(res.input.ControllerBuildMacro.build())
class Controller {
	final pressed:Map<ControllerButton,
		Bool> = [for (btn in Type.allEnums(ControllerButton)) btn => false];

	@:allow(res)
	function new() {}

	public function axis():Vec {
		return Vec.of({
			x: (pressed.get(LEFT) ? -1 : 0) + (pressed.get(RIGTH) ? 1 : 0),
			y: (pressed.get(UP) ? -1 : 0) + (pressed.get(DOWN) ? 1 : 0)
		});
	}

	public function press(btn:ControllerButton)
		pressed[btn] = true;

	public function release(btn:ControllerButton)
		pressed[btn] = false;
}
