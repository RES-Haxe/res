package res.input;

import res.events.Emitter;
import res.geom.Vec;

@:build(res.input.ControllerBuildMacro.build())
class Controller extends Emitter<ControllerEvent> {
	public final index:Int;

	final pressed:Map<ControllerButton,
		Bool> = [for (btn in Type.allEnums(ControllerButton)) btn => false];

	@:allow(res)
	function new(index:Int) {
		this.index = index;
	}

	public function axis():Vec {
		return Vec.of({
			x: (pressed.get(LEFT) ? -1 : 0) + (pressed.get(RIGTH) ? 1 : 0),
			y: (pressed.get(UP) ? -1 : 0) + (pressed.get(DOWN) ? 1 : 0)
		});
	}

	public inline function btn(which:ControllerButton)
		return pressed[which];

	public function press(btn:ControllerButton) {
		pressed[btn] = true;
		emit(BUTTON_DOWN(this, btn));
	}

	public function release(btn:ControllerButton) {
		pressed[btn] = false;
		emit(BUTTON_UP(this, btn));
	}
}
