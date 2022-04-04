package res.input;

import res.events.Emitter;
import res.tools.MathTools.wrap;

class Mouse extends Emitter<MouseEvent> {
	public var enabled:Bool = true;

	public var x:Int;
	public var y:Int;

	var res:RES;

	@:allow(res)
	private inline function new(res:RES) {
		this.res = res;
	}

	public function push(button:MouseButton, posX:Int, posY:Int) {
		emit(DOWN(button, posX, posY));
	}

	public function release(button:MouseButton, posX:Int, posY:Int) {
		emit(UP(button, posX, posY));
	}

	public inline function moveTo(x:Int, y:Int) {
		this.x = wrap(x, res.frameBuffer.width);
		this.y = wrap(y, res.frameBuffer.height);
	}
}
